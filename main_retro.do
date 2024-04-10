******************************************************************************
* FORMAT ONE YEAR FILE
******************************************************************************

* Change to the location of your folder
global path = "C:\Users\clm96\Documents\Research\MCVL\"
cd $path

* Change to the year you are using
global year = 2020

* Step 1: formatting files * * * * * * * * * * * * * * * * * * * * * * * * * * 
* 1.1 Personal data files
clear
insheet using "./rawfiles/${year}/MCVL${year}PERSONAL.txt", delimiter(";")
do "./rawfiles/personal_format.do"
saveold "./rawfiles/${year}/personal${year}.dta", v(12) replace

* 1.2 Pension files
clear
insheet using "./rawfiles/${year}/MCVL${year}PRESTAC_CDF.txt", delimiter(";")
do "./rawfiles/pension_format.do"
save "./rawfiles/${year}/pension${year}.dta", replace

* 1.3 Afiliation files
clear
forvalues i = 1/4{
	insheet using "./rawfiles/${year}/MCVL${year}AFILIAD`i'_CDF.txt", delimiter(";")
save "./rawfiles/${year}/afilianon13`i'.dta", replace
clear
	
}

use "./rawfiles//${year}/afilianon131.dta"
forvalues i=2/4{
	append using "./rawfiles//${year}/afilianon13`i'.dta"
}

quietly do "./rawfiles/format_afilianon.do"

* 1.3 Add personal file
merge m:1 id using "./rawfiles/${year}/personal${year}.dta"
drop if _merge==2
drop _merge

* Save
save "./rawfiles/afilianon${year}.dta", replace

* 1.4 adding pensions ********************************************************

* Recovery saving file point
use "./rawfiles/afilianon${year}.dta", clear

* For simplicity, use the latest pension file.
append using "./rawfiles/${year}/pension${year}.dta"

* New state: Retired (R)
sort id jobcount dtin
replace state = "R" if state=="" & p_type!=.
replace dtin = p_dtin if state=="R"
drop if state=="R"&id!=id[_n-1]&id!=id[_n+1]
by id: replace dtbirth = dtbirth[_n-1] if state=="R"
gen age_in = year(dtin)-year(dtbirth)

* Cause 58 - retirement
by id: replace state="R" if cause[_n-1]==58&state=="U"&(state[_n+1]!="P"&state[_n+1]!="T"&state[_n+1]!="A")
drop if cause==81 &state=="R"

* Changing the end dates of retirement: death
by id: replace death=death[_n-1] if death==.
tostring death, replace
replace dtout = date(death,"YM") if dtout==.
* Changing the end dates of retirement: ongoing
replace dtout = td(31dec${year}) if dtout==.

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

* Redefining unemployment for pensioneers
replace dtout = dtin[_n+1] if state=="U"&state[_n+1]=="R"&dtout<dtin[_n+1]
replace dtin = dtout[_n-1] if state=="R"&state[_n-1]=="U"&dtin<dtout[_n+1]
replace days = dtout-dtin if state=="U"&state[_n+1]=="R"

*************************************************
* Part 2: Data cleaning *************************************************
* 2.1 Main adjustments 
** Autonomous adjustment **
replace state = "A" if regi>700&regi<800
replace state = "A" if regi>824&regi<840

** Industry harmonization **
quietly do "./rawfiles/industry_clean.do" 
by id: replace ind_short=ind_short[_n-1] if state=="U"

* Education from the last record
by id: replace education=education[_n-1] if education==""
by id: replace education=education[_N] if education[_N]!=""

* Prepare firm identifier
tostring firm2, replace
** Autonomous adjustment **
replace state = "A" if regi>700&regi<800
replace state = "A" if regi>824&regi<840
** The Spceials Adjustment
replace state = "R" if regi==140 // The Specials

* Some clerical errors make less than 1% of the sample (mostly in the 80s)
* appear as having negative duration. I swap the dates of entry fro those cases
replace days = dtout-dtin
gen dtin_temp = dtin if days<0
replace dtin = dtout if days<0
replace dtout = dtin_temp if days<0
replace days = dtout-dtin
drop dtin_temp

* Reorder variables
order state dtin dtout,after(jobcount)

* 2.2 Contract modification adjustment
******************************************
* This creates a new labour market state when the contract type changes - so from temporary to permanent or vice-versa
quietly do "./cma.do"

* 2.3 Counting Spells ********************

order state dtin dtout,after(jobcount)

* Generating firm identifiers (recalls don't count as different jobs)
tostring firm2, replace
gen firmID = firm1+firm2
order firmID, after(id)

* Countiung different jobs/contracts
gen scount = 0
sort id state jobcount dtin
foreach s in "P" "T" {
	by id state: replace scount = 1 if jobcount!=jobcount[_n-1]&firmID!=firmID[_n-1]&state=="`s'"
	by id state: gen No`s' = sum(scount)
	replace scount = 0
}
* For unemployment, it doesn't matter if it is the same admin paying UB
by id state: replace scount = 1 if jobcount!=jobcount[_n-1]&state=="U"
by id state: gen NoU = sum(scount)
drop scount

* Filling gaps 
sort id jobcount dtin
foreach s in "P" "T" "U"{
	by id : replace No`s' = No`s'[_n-1] if No`s'==0&No`s'[_n-1]!=0
	replace No`s' = 0 if No`s'==.
}
*
* ExpT/P: days of experience in each contract type
sort id state jobcount dtin
foreach s in "P" "T" "U"{
	by id state: gen Exp`s' = sum(days) if state=="`s'"
	replace Exp`s' = 0 if Exp`s' == .
}
*
sort id jobcount dtin
foreach s in "P" "T" "U"{
	by id : replace Exp`s' = Exp`s'[_n-1] if Exp`s'==0&Exp`s'[_n-1]!=0
	replace Exp`s' = 0 if Exp`s'==.
}
*
* Censored observations for the last year
drop if dtin>td(31dec${year})
replace dtout=td(31dec${year}) if  dtout>td(31dec${year})

* Part 3 Unemployment Expansions
******************************************************************************
gen ext_dt = dtout

* Uncomment to select your option

// <not implemented yet>		// Only registered
// <not implemented yet>		// Extended until next employment spell
quietly do  "./coru_stu_retro.do" // Same as ltu, plus all gaps between employment<15 days

* Post correction adjustments
replace days = dtout-dtin
drop if days<=0
* Re-write number of unemployment spells
sort id state jobcount dtin
gen scount = 0
by id state: replace scount = 1 if jobcount!=jobcount[_n-1]&state=="U"
by id state: replace NoU = sum(scount)
drop scount

* Save the file
compress
save "./MCVL_${year}.dta", replace

******************************************************************************
******************************************************************************

* Appendix: Other auxiliary variables
******************************************************************************

* In case you need some of these for other applications

* Weeks since last unemployment spell
sort id NoU jobcount
by id NoU: gen weeksE = sum(days) if state!="U"
sort id jobcount
by id: replace weeksE=weeksE[_n-1] if weeksE==. 
replace weeksE = 0 if weeksE==.
replace weeksE = weeksE/7
gen yearsE = weeksE/52

* Previous tenure (NO UPGRADES)
sort id dtin
by id: gen days1 = days[_n-1]

* First_P: #TCs when found first permanent contract
by id: gen First_P = NoT if NoP[_n]==1&NoP[_n-1]==0

* Dummy for last contract being permanet (and its tenure interaction dummy)
by id: gen lastP = 1 if state1=="P"
by id: replace lastP =0 if lastP==.
by id: gen lastA = 1 if state1=="A"
by id: replace lastA =0 if lastA==.
gen lastPdays = days1*lastP 

* Long-term unemployment (greater than a year)
by id: gen LTU1 = 1 if state=="U"&days>=365
replace LTU1 = 0 if LTU1==.
* Long-term unemployment (greater than 2 years)
by id: gen LTU2 = 1 if state=="U"&days>=730
replace LTU2 = 0 if LTU2==.

* Unfinished spell (does NOT end in employment) as of the end of the sample:
sort id jobcount dtin
gen unfin = 1 if dtout>=td(31dec${year})|state[_n+1]=="R"|state=="R"|cause==58|cause==56
replace unfin=0 if unfin==.
* Avoid confusiong with unfinish variable (work history ends before the end of the sample)
drop unfinish

* OTHER WORK RELATED VARIABLES *********************************************

* Collective Dismissals
gen colldiss = 1 if cause==77&state!="U"&state!="R"
replace colldiss=0 if colldiss==.
sort id dtin
by id: replace colldiss = 1 if colldiss[_n-1]==1&state=="U"&(state[_n-1]=="P"|state[_n-1]=="T")

* Industry for the unemployed
sort id jobcount dtin
replace ind_short = 0 if state=="U"|state=="R"
by id: replace ind_short=ind_short[_n-1] if state=="U"&ind[_n-1]!=0&state[_n-1]!="U"
quietly tab ind_short, gen(ind_dummy_)
drop ind_dummy_1 ind_dummy_2 ind_dummy_8

* Construction special
// gen const_post = 1 if ind_short==7&post08==1
// gen const_pre = 1 if ind_short==7&post08==0
// replace const_post=0 if const_post==.
// replace const_pre=0 if const_pre==.

* Replace quit with proper quit dummy
replace quit = 0
replace quit = 1 if cause==51&(state=="P"|state=="T")
by id: replace quit = 1 if quit[_n-1]==1&state=="U"&(state[_n-1]=="P"|state[_n-1]=="T")

* Fired or quit or collective dismissal (normal fire)
gen normal_f = 1 if (cause>50&cause<60)|cause==77|cause==69|(cause>90&cause<94)
by id: replace normal_f = 1 if state=="U"&(state[_n-1]=="P"|state[_n-1]=="T")&normal_f[_n-1]==1
replace normal_f = 0 if normal_f == .

* For exporting: Year in/year out
// gen year_in = year(dtin)
// quietly tab year_in if year_in>=2005, gen(year_d) 
// gen year_out = year(dtout)
// drop year_d1 // 2005 base year

* Save the file
save "./MCVL_${year}.dta", replace