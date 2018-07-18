******************************************************************************
* PATCHWORK FILE
******************************************************************************

* 1. Join in formatted afiliation files
******************************************************************************
use "./rawfiles/afilianon2005.dta", clear
gen year=2005
gen ext_dt=dtout
replace dtout=td(31dec2005) if dtout>td(31dec2005)

append using "./rawfiles/afilianon2006.dta",force
replace year=2006 if year==.
drop if year==2006&dtout<td(01jan2006)
replace ext_dt=dtout if year==2006
replace dtout=td(31dec2006) if dtout>td(31dec2006)

append using "./rawfiles/afilianon2007.dta",force
replace year=2007 if year==.
drop if year==2007&dtout<td(01jan2007)
replace ext_dt=dtout if year==2007
replace dtout=td(31dec2007) if dtout>td(31dec2007)

append using "./rawfiles/afilianon2008.dta",force
replace year=2008 if year==.
drop if year==2008&dtout<td(01jan2008)
replace ext_dt=dtout if year==2008
replace dtout=td(31dec2008) if dtout>td(31dec2008)

append using "./rawfiles/afilianon2009.dta",force
replace year=2009 if year==.
drop if year==2009&dtout<td(01jan2009)
replace ext_dt=dtout if year==2009
replace dtout=td(31dec2009) if dtout>td(31dec2009)

append using "./rawfiles/afilianon2010.dta",force
replace year=2010 if year==.
drop if year==2010&dtout<td(01jan2010)
replace ext_dt=dtout if year==2010
replace dtout=td(31dec2010) if dtout>td(31dec2010)

append using "./rawfiles/afilianon2011.dta",force
replace year=2011 if year==.
drop if year==2011&dtout<td(01jan2011)
replace ext_dt=dtout if year==2011
replace dtout=td(31dec2011) if dtout>td(31dec2011)

append using "./rawfiles/afilianon2012.dta",force
replace year=2012 if year==.
drop if year==2012&dtout<td(01jan2012)
replace ext_dt=dtout if year==2012
replace dtout=td(31dec2012) if dtout>td(31dec2012)

append using "./rawfiles/afilianon2013.dta",force
replace year=2013 if year==.
drop if year==2013&dtout<td(01jan2013)
replace ext_dt=dtout if year==2013
replace dtout=td(31dec2013) if dtout>td(31dec2013)

* Uncomment to safe a backup at this point
saveold "./Patchwork_baseline.dta", replace version(12)
// use "./Patchwork_baseline.dta", clear

* 2 Other adjustments
******************************************************************************

* Pensions ********************************************************
append using "./rawfiles/2013/pension2013.dta"
* New state: Retired (R)
sort id year jobcount dtin
replace state = "R" if state=="" & p_type!=.
replace dtin = p_dtin if state=="R"

* Cause 58 - retirement
by id year: replace state="R" if cause[_n-1]==58&state=="U"&(state[_n+1]!="P"&state[_n+1]!="T"&state[_n+1]!="A")
drop if cause==81 &state=="R"

* Changing the end dates of retirement: death
by id: replace death=death[_n-1] if death==.
tostring death, replace
replace dtout = date(death,"YM") if dtout==.
* Changing the end dates of retirement: ongoing
replace dtout = td(31dec2013) if dtout==.
by id: replace year=year[_n-1] if year==.

*Adjust dates of entry to retirement: those in partial retirament count as employed
by id: replace dtin=dtout[_n-1] if cause[_n-1]==58&dtin<dtout[_n-1]&state=="R"

* Adjustment for contributive unemployment (unemployed about to retire)
by id: replace state = "R" if regi==140&(state[_n+1]=="R")

* Likely retirement - afiliated because of retirement
by id: gen diff_days_in = dtin[_n+1]-dtin
gen likely_retired = 0
by id: replace likely_retired = 1 if state[_n+1]=="R"&dtin[_n+1]<=dtout[_n]&p_type[_n+1]==3
by id: replace likely_retired=0 if abs(diff_days_in)>30
drop if likely_retired==1

* Other adjustments *************************************************

** Autonomous adjustment **
replace state = "A" if regi>700&regi<800
replace state = "A" if regi>824&regi<840

** Industry harmonization **
quietly do "./rawfiles/industry_clean_panel.do" 
by id: replace ind_short=ind_short[_n-1] if state=="U"

** Interger age **
replace age = year-year(dtbirth)

* Some clerical errors make less than 1% of the sample (mostly in the 80s)
* appear as having negative duration. I swap the dates of entry fro those cases
replace days = dtout-dtin
gen dtin_temp = dtin if days<0
replace dtin = dtout if days<0
replace dtout = dtin_temp if days<0
replace days = dtout-dtin
drop dtin_temp

* Reorder variables
order year state dtin dtout,after(jobcount)

** CONTRACT MODIFICATION ADJUSTMENT ******************************************
* Uncomment for the right flavour
// quietly do "./rawfiles/cma.do"
do "./cma_panel.do"

* Counting Spells *************************************************************
order year state dtin dtout,after(jobcount)

* Generating firm identifiers (recalls don't count as different jobs)
tostring firm2, replace
gen firmID = firm1+firm2
order firmID, after(id)

gen scount = 0
sort id state jobcount year dtin
foreach s in "P" "T" {
	by id state: replace scount = 1 if jobcount!=jobcount[_n-1]&firmID!=firmID[_n-1]&state=="`s'"
	by id state: gen No`s' = sum(scount)
	replace scount = 0
}
* For unemployment, it doesn't matter if it is the same admin paying UB
by id state: replace scount = 1 if jobcount!=jobcount[_n-1]&state=="U"
by id state: gen NoU = sum(scount)
drop scount

sort id jobcount year dtin
foreach s in "P" "T" "U"{
	by id : replace No`s' = No`s'[_n-1] if No`s'==0&No`s'[_n-1]!=0
	replace No`s' = 0 if No`s'==.
}
*
gen cdtin = dtin
replace cdtin = mdy(1,1,year) if year>2005&year(dtin)!=year
gen cdtout = dtout
replace cdtout = mdy(12,31,year) if year>2005&year(dtout)!=year

gen days_c = cdtout-cdtin+1
drop if days_c<=0 // 5 obs.

* Counting Experience *************************************************************

sort id state jobcount year dtin
foreach s in "P" "T" "U"{
	by id state: gen Exp`s' = sum(days_c) if state=="`s'"
	replace Exp`s' = 0 if Exp`s' == .
}
*
sort id jobcount year dtin
foreach s in "P" "T" "U"{
	by id : replace Exp`s' = Exp`s'[_n-1] if Exp`s'==0&Exp`s'[_n-1]!=0
	replace Exp`s' = 0 if Exp`s'==.
}
*

* Short employment (less than 12 months of continuous employmnet)
gen emp_count = 0 if state=="U"|state=="R"
replace emp_count = days_c if state!="U"&state!="R"
sort id NoU year dtin
by id NoU: gen emp_spell = sum(emp_count)
gen short_emp = 0
replace short_emp = 1 if emp_spell<360 & year(dtout)>=1992 & (state=="T"|state=="P")
replace short_emp = 1 if emp_spell<180 & year(dtout)<1992 & (state=="T"|state=="P")
sort id year jobcount dtin

* Sample Selection ***********************************************************
* Include up to 2004
// by id: drop if dtout[_n+1]<td(01jan2004)
// * Include 2004
// by id: drop if dtout[_n+1]<td(01jan2003)
// replace year = 2004 if dtout<td(01jan2005)
// expand 2 if dtout>td(01jan2005)&dtin<td(01jan2005)&year==2005, gen(y04)
// replace year=2004 if y04==1
// drop y04
// drop if state ==""

* Include 2003
by id: drop if dtout[_n+1]<td(01jan2002)
replace year = 2004 if dtout<td(01jan2005)
expand 2 if dtout>td(01jan2005)&dtin<td(01jan2005)&year==2005, gen(y04)
replace year=2004 if y04==1
drop y04
drop if state ==""

replace year = 2003 if dtout<td(01jan2004)
expand 2 if dtout>td(01jan2004)&dtin<td(01jan2004)&year==2004, gen(y03)
replace year=2003 if y03==1
drop y03
drop if state ==""


* 3 Unemployment Expansions
******************************************************************************
* Uncomment to select your option

// quietly do "./coru_none.do"		// Only registered
// quietly do "./coru_ltu.do"		// Extended until next employment spell
quietly do  "./coru_stu.do" // Same as ltu, plus all gaps between employment<15 days

*replace year = 2004 if dtout<td(01jan2005)&dtout!=.

* No need for these guys anymore
drop if dtout<td(01jan2003)

* If you don't wnat to panelize the data (as in the LFS) you can stop here
saveold "./MCVL0313.dta", replace version(12)

* 4 Making into a Panel
******************************************************************************

* Transform into quarterly panel
do  "./panel/quarterly_panel_U0.do"

* Transform into monthly panel
* WARNING: this requires more than 32GB of RAM! 
* Split the sample into different periods to do it properly
// drop if year<2008
drop if year>2007
drop if year<2004
quietly do  "./panel/monthly_panel_U0.do"
// tab time state

do "./panel/export_flows_stu.do"
// do "./panel/export_flows_ltu.do"
// do "./panel/export_flows_none.do"

// saveold "./panel/MCVL_flows_none.dta", replace version(12)
saveold "./panel/flows_m00407.dta.dta", replace version(12)
// saveold "./panel/MCVL_flows_U01b.dta", replace version(12)

