******************************************************************************
* FORMAT ONE YEAR FILE
******************************************************************************
* 0. Define globals and options

* Please cahnge this code according to what you need.
* First, year selection
global start_year 2016                  // <- Change accordingly
global start_year_next =${start_year}+1
global end_year 2021                     // <- Change accordingly

* If you want to start the panel before the start_year, using retrospective information, change this setting accordingly. This is

* Second, unemployment consolidation flavour (see manual)
* Has to be: none, ltu, stu
* You can adjust settings inside de the coru file.
global xp  "stu"
* If picking ltu/stu consolidation, select max gap to fill (in years, default 2) 
global ylimit_ltu = 2
* If picking stu consolidation, select min gap to fill between spells
global stu_min = 15

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

* Generating firm identifiers (recalls don't count as different jobs)
tostring firm2, replace
gen firmID = firm1+firm2
order firmID, after(id)

* Consolidating pensions - Full retirement > partial retirement > full disability > other
gen pension_rank = (p_type==3) * 3
replace pension_rank = 2 if p_type==4
replace pension_rank = 1 if p_type==1
gen full_year = (days>365)
* Drop fully overlaping pension spells, keeping the most important one (see above)
sort id year state pension_rank dtin dtout
by id year state: drop if state=="R"&full_year==1&year!=${start_year}&_n!=_N
by id year state: drop if state=="R"&dtin>=dtin[_N]&dtout[_N]>=dtout&_n!=_N

* Partial retirement
replace state="P" if tyco==540
gen partial_retirement=(tyco==540)

* Overlapping partial disability
gen pension_ind = (state=="R")
sort id year pension_ind dtin dtout
by id year: gen comp_benefit = p_type[_N] if _n!=_N&state[_N]=="R"&dtin>=dtin[_N]&dtout[_N]>=dtout
by id year: replace comp_benefit = p_type[_N] if _n!=_N&state[_N]=="R"&dtout[_N]>=dtout
by id year: drop if comp_benefit[_n-1]!=.&_n==_N&state=="R"
* Clean up the rest - I throw all away that are partial disability complements
replace partial_retirement=1 if comp_benefit==5
drop if (p_type==2|p_type>4&p_type!=.&state=="R")
drop pension_ind pension_rank full_year

* Jobcount consistent with new observations
gen jc = 1
by id: replace jc = 0 if dtin==dtin[_n-1]&state==state[_n-1]&firmID==firmID[_n-1]
by id: replace jc = sum(jc)
replace jobcount = jc
drop jc

* Unfinished spell indicator
gen unfin = (id!=id[_n+1]&dtout==td(31dec${end_year}))

* * * * Keeping one entry only * * * * * * * * * * * 
* This is the main difference with the panel file. Keeps only the latest entry per spell.
* Keep one spell per person
sort id jobcount dtin dtout
by id jobcount: keep if _n==_N   

* 2 Other adjustments
******************************************************************************

* Pensions ********************************************************

* New state: Retirement adjustments
sort id jobcount dtin
replace state = "R" if state=="" & p_type!=.
replace dtin = p_dtin if state=="R"

* This drops observations that are ONLY retirement (keep them if interested)
drop if state=="R"&id!=id[_n-1]&id!=id[_n+1]

* Interger age (from file)
replace age = year-year(dtbirth)

* Age at the begining of the spell
by id: replace dtbirth = dtbirth[_n-1] if state=="R"
gen age_in = year(dtin)-year(dtbirth)

* Redefining unemployment for pensioneers
replace dtout = dtin[_n+1] if state=="U"&state[_n+1]=="R"&dtout<dtin[_n+1]
replace dtin = dtout[_n-1] if state=="R"&state[_n-1]=="U"&dtin<dtout[_n+1]
replace days = dtout-dtin if state=="U"&state[_n+1]=="R"

* Other adjustments *************************************************

** Autonomous adjustment **
replace state = "A" if regi>700&regi<800
replace state = "A" if regi>824&regi<840

** Industry harmonization **
quietly do "./rawfiles/industry_clean.do" 
by id: replace ind_short=ind_short[_n-1] if state=="U"|state=="R"

* Education refresh
by id: replace education=education[_n-1] if education==""
* I choose to set Education to the latest obtained (because of how the variable is recorded, using the census). Comment out if you prefer to keep education changes.
by id: replace education=education[_N] if education[_N]!=""

** The Specials Adjustment - just contributing but not actually working
replace state = "R" if regi==140

** Zombie workers: people marked as deceased by mistake (surely because they come back to work after the fact)
sort id jobcount dtin dtout
gen samesame =(id!=id[_n+1])
by id: gen samejob=(jobcount==jobcount[_n+1])
gen death_dt = date(death, "YM")
format death_dt %td
* First: id zombie workers (131 cases)
gen muerto_vivo=(cause==56&samesame==0&samejob==0&death_dt==.)
replace unfin = 0 if muerto_vivo
* Next: people out of retirement (28,000 cases)
by id: gen next_retire=(state[_n+1]=="R")
gen out_of_retirement=(cause==58&samesame==0&next_retire==0)
replace unfin = 0 if out_of_retirement
* Clean-up
drop samesame samejob muerto_vivo next_retire out_of_retirement

* Some clerical errors make less than 1% of the sample (mostly in the 80s)
* appear as having negative duration. I swap the dates of entry fro those cases
replace days = dtout-dtin
gen dtin_temp = dtin if days<0
replace dtin = dtout if days<0
replace dtout = dtin_temp if days<0
replace days = dtout-dtin
drop dtin_temp

** CONTRACT MODIFICATION ADJUSTMENT ******************************************

quietly do "./cma.do"

* Counting Spells *************************************************************
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
drop if dtin>td(31dec${end_year})
replace dtout=td(31dec${end_year}) if  dtout>td(31dec${end_year})

* 3 Unemployment Expansions
******************************************************************************
capture drop ext_dt // in case you are using one afiliation file
gen ext_dt = dtout

* Uncomment to select your option

// <not implemented yet>		// Only registered
// <not implemented yet>		// Extended until next employment spell
quietly do  "./coru_$xp_retro.do" // Same as ltu, plus all gaps between employment<15 days

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
sort id jobcount dtin dtout
saveold "./MCVL_${end_year}_spells.dta", v(12) replace


// 4 PANELIZATION (to turn back into a panel to match with wages/cotizaciones) 
**************************************************************************
* Year consistent with panel
replace year = year(dtout) if year>year(dtout)&year(dtout)>=${start_year}
replace year = ${start_year} if year>year(dtout)&year(dtout)<${start_year}

* Panelize
gen newobs = 0
replace newobs = year-max(year(dtin),${start_year}) if new_blood==1&year>${start_year}

expand newobs+1, gen(new_panel_obs)

sort id jobcount dtin dtout new_panel_obs
by id jobcount: replace year = max(year(dtin),${start_year}) if new_panel_obs==0&new_panel_obs[_n+1]==1
by id jobcount: replace year = year[_n-1]+1 if new_panel_obs==1

by id jobcount: replace dtout = mdy(12,31,year) if newobs>0&year<year(dtout)
by id jobcount: replace dtin = mdy(1,1,year) if newobs>0&year>year(dtin)&year>${start_year}

by id jobcount: replace year = max(year(dtin),${start_year}) if new_panel_obs==0&new_panel_obs[_n+1]==1
by id jobcount: replace year = year[_n-1]+1 if new_panel_obs==1

******************************************************************************
******************************************************************************
