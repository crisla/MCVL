******************************************************************************
* PATCHWORK FILE
******************************************************************************
* 0. Define globals and options

* Please cahnge this code according to what you need.
* First, year selection
global start_year 2015                   // <- Change accordingly
global start_year_next =${start_year}+1
global end_year 2024                     // <- Change accordingly

* Second, unemployment consolidation flavour (see manual)
* Has to be: none, ltu, stu
* You can adjust settings inside de the coru file.
global xp  "stu"


* 1. Formatting
******************************************************************************
* Reads personal, pension and afiliation files. 
* Make sure they are in the correct rawfiles folder (so rawfiles/2023 for example) 
do format_all_new.do

* 2. Join in formatted afiliation files
******************************************************************************

* Initiate the File
use "./rawfiles/afilianon${start_year}.dta", clear
gen year=${start_year}
gen ext_dt=dtout
replace dtout=td(31dec${start_year}) if dtout>td(31dec${start_year})

* Main appending loop
forvalues yy= $start_year_next / $end_year {
	append using "./rawfiles/afilianon`yy'.dta"
	replace year=`yy' if year==.
	* Drop duplicate spells
	sort id dtin dtout year
	by id: drop if dtin==dtin[_n-1]&dtout==dtout[_n-1]&year>year[_n-1]&year==`yy'
	* Adjust end dates
	replace ext_dt=dtout if year==`yy'
	replace dtout=td(31dec`yy') if dtout>td(31dec`yy')
	di "`yy' added"
}

* New blood: new observations added retrospectively
capture drop new_blood
gen new_blood = 0
replace new_blood = 1 if year(dtout)<year&year>${start_year}

* Jobcount consistent with new observations
gen jc = 1
by id: replace jc = 0 if dtin==dtin[_n-1]&state==state[_n-1]
by id: replace jc = sum(jc)
replace jobcount = jc
drop jc

* Make sure start and end dates are consistent
sort id jobcount dtin dtout 
by id jobcount: replace dtout = mdy(12,31,year) if year<year(dtout)
by id jobcount: replace dtin = mdy(1,1,year) if year>year(dtin)&year>${start_year}

* Uncomment to safe a backup at this point
compress
save "./Patchwork_baseline.dta", replace 


* 2 Other adjustments
******************************************************************************

** Autonomous adjustment **
replace state = "A" if regi>700&regi<800
replace state = "A" if regi>824&regi<840

** The Specials Adjustment - just contributing but not actually working
replace state = "R" if regi==140

** Industry harmonization **
quietly do "./rawfiles/industry_clean_panel.do"

sort id jobcount dtin dtout 

by id: replace ind_short=ind_short[_n-1] if state=="U"

* Age at the begining of the spell
by id: replace dtbirth = dtbirth[_n-1] if state=="R"
gen age_in = year(dtin)-year(dtbirth)

* Redefining unemployment for pensioneers
by id: replace dtout = dtin[_n+1] if state=="U"&state[_n+1]=="R"&dtout<dtin[_n+1]
by id: replace dtin = dtout[_n-1] if state=="R"&state[_n-1]=="U"&dtin<dtout[_n-1]
by id: replace days = dtout-dtin if state=="U"&state[_n+1]=="R"

* Zombie workers
sort id dtin dtout
gen samesame =(id!=id[_n+1])
by id: gen samejob=(jobcount==jobcount[_n+1])
* First: id zombie workers (81 cases)
gen muerto_vivo=(cause==56&samesame==0&samejob==0)
replace unfin = 0 if muerto_vivo
* Next: people out of retirement (28,000 cases)
by id: gen next_retire=(state[_n+1]=="R")
gen out_of_retirement=(cause==58&samesame==0&next_retire==0)
replace unfin = 0 if out_of_retirement


* Clean-up
// drop samesame samejob muerto_vivo next_retire out_of_retirement

* Education from the last record
by id: replace education=education[_n-1] if education==""
by id: replace education=education[_N] if education[_N]!=""

* Some clerical errors make less than 1% of the sample (mostly in the 80s)
* appear as having negative duration. I swap the dates of entry for those cases
replace days = dtout-dtin
gen dtin_temp = dtin if days<0
replace dtin = dtout if days<0
replace dtout = dtin_temp if days<0
replace days = dtout-dtin
drop dtin_temp

* Reorder variables
order year state dtin dtout,after(jobcount)

** CONTRACT MODIFICATION ADJUSTMENT ******************************************

quietly do "./cma_panel.do"

* Counting Spells *************************************************************

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
* Censored dates for repeated observations
gen cdtin = dtin
replace cdtin = mdy(1,1,year) if year>${start_year}&year(dtin)!=year
gen cdtout = dtout
replace cdtout = mdy(12,31,year) if year>${start_year}&year(dtout)!=year

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

* Midpoint save: uncomment to save before spell corrections
// save "./Patchwork_midpoint.dta", replace
// use "./Patchwork_midpoint.dta", clear

* Sample Selection ***********************************************************

* Uncomment your option:

* OPTION 1: include obs from 2003 onwards. Lighter version.
global year_0 = 2004

* Drop observations ending before year_0
by id: drop if dtout<td(01jan${year_0})
* Create extra observations for years until start
expand ${start_year}-${year_0}+1 if dtout>td(01jan${start_year})&dtin<td(01jan${start_year})&year==${start_year}, gen(panel_obs)
sort id jobcount year dtin dtout
by id jobcount year: replace panel_obs=sum(panel_obs)
replace year = year - panel_obs

* Cleaning up
drop panel_obs
sort id year jobcount dtin dtout
gen old_obs = (year(dtout)<${year_0})

// replace year=2004 if y04==1
// drop y04
// drop if state ==""
//
// replace year = 2003 if dtout<td(01jan2004)
// expand 2 if dtout>td(01jan2004)&dtin<td(01jan2004)&year==2004, gen(y03)
// replace year=2003 if y03==1
// drop y03
// drop if state ==""
//
// gen old_obs = 0
//
// * If you are keeping the sample from 2004/2003 onwards:
// replace old_obs = 1 if year(dtout)<2003
// replace old_obs = 1 if year(dtout)<2003

* OPTION 2 : include all observations. May be more innacurate the further back it's used.

// gen old_obs = 0
// * Change year (necessary for expansion to work right)
// replace year = year(dtout) if year(dtout)<${start_year}
// replace old_obs = 1 if year(dtout)<${start_year}


* 3 Unemployment Expansions
******************************************************************************
* Posibilities for unemployment extensions:

//  "./coru_none.do" // Only registered unemployment, joins consecutive spells.
//  "./coru_ltu.do"	// Unfinished unemployment spells extended until end of sample (gaps less than 2 years)
//  "./coru_stu.do" // Same as ltu, plus all qualifying gaps between employment (gaps less than 15 days)

do "./coru_$xp.do"

******************************************************************************

* 4 Saving
******************************************************************************

* Congratulations! Your working history files are now nicely formatted into an annual panel.
* Save before continuing.
compress
save "./MCVL_${end_year}.dta", replace

