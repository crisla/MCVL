******************************************************************************
* PATCHWORK FILE - FORMAT FILE FOR WORKING HISTORIES
******************************************************************************
* 0. Define globals and options

* Please cahnge this code according to what you need.
* First, year selection
global start_year 2006                   // <- Change accordingly
global start_year_next =${start_year}+1
global end_year 2024                     // <- Change accordingly

* If you want to start the panel before the start_year, using retrospective information, change this setting accordingly. This is useful when filling gaps in the ltu and stu consolidation.
* Defult is: panel starts when the sample starts - 1
global year_0 = ${start_year}-1

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

* Make sure start and end dates are consistent
sort id jobcount dtin dtout 
by id jobcount: replace dtout = mdy(12,31,year) if year<year(dtout)
by id jobcount: replace dtin = mdy(1,1,year) if year>year(dtin)&year>${start_year}

* Unfinished spell indicator
gen unfin = (id!=id[_n+1]&dtout==td(31dec${end_year}))

* Uncomment to safe a backup at this point
compress
save "./Patchwork_baseline.dta", replace 


* 3 Other adjustments
******************************************************************************

** Autonomous adjustment **
replace state = "A" if regi>700&regi<800
replace state = "A" if regi>824&regi<840

** The Specials Adjustment - just contributing but not actually working
replace state = "R" if regi==140

** Industry harmonization **
quietly do "./rawfiles/industry_clean.do"

sort id year jobcount dtin dtout 
by id: replace ind_short=ind_short[_n-1] if state=="U"|state=="R"

** Age at the begining of the spell
by id: replace dtbirth = dtbirth[_n-1] if state=="R"&dtbirth==.
gen age_in = year(dtin)-year(dtbirth)

** Zombie workers: people marked as deceased by mistake (surely because they come back to work after the fact)
sort id year jobcount dtin dtout
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

* Education refresh
by id: replace education=education[_n-1] if education==""
* I choose to set Education to the latest obtained (because of how the variable is recorded, using the census). Comment out if you prefer to keep education changes.
by id: replace education=education[_N] if education[_N]!=""

* Some clerical errors make less than 1% of the sample (mostly in the 80s) appear as having negative duration. I swap the dates of entry for those cases
replace days = dtout-dtin
gen dtin_temp = dtin if days<0
replace dtin = dtout if days<0
replace dtout = dtin_temp if days<0
replace days = dtout-dtin
drop dtin_temp

* Reorder variables
order year state dtin dtout,after(jobcount)

** CONTRACT MODIFICATION ADJUSTMENT ******************************************
* This takes care of contract modifications, creating a separate entry for a separate contract (but keeping jobcount the same, as it is the same job)

quietly do "./cma_panel.do"

* Counting Spells *************************************************************

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
* Censored dates for multi-year spells (so max days_c =  366)
gen cdtin = dtin
replace cdtin = mdy(1,1,year) if year>${start_year}&year(dtin)!=year
gen cdtout = dtout
replace cdtout = mdy(12,31,year) if year>${start_year}&year(dtout)!=year

gen days_c = cdtout-cdtin+1
drop if days_c<=0 // Sanity check: no observations deleted

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
save "./Patchwork_baseline2.dta", replace 
// use "./Patchwork_baseline2.dta", clear

* Sample Selection ***********************************************************

* Before adding gaps, we need to make sure we catch missing unemployment gaps that overalp the start of the sample year.
* This section of the code expans the data one year earlier, so the gaps can be calcualted appropiately.
* You can choose to go back even earlier, for this modify the global year_0 above.
	
* Drop observations ending before year_0
by id: drop if dtout<td(01jan${year_0})

* Drop duplicates
drop if state==state[_n+1]&jobcount==jobcount[_n+1]&id==id[_n+1]&year==year[_n+1]&dtin==dtin[_n+1]&dtout==dtout[_n+1]

* Create extra observations for years until start
expand ${start_year}-${year_0}+1 if dtout>td(01jan${start_year})&dtin<td(01jan${start_year})&year==${start_year}, gen(panel_obs)
sort id jobcount year dtin dtout
// by id jobcount year: replace panel_obs=sum(panel_obs)
replace year = year - panel_obs
* Replacing observations starting the year before
replace year = $year_0 if dtout>td(01jan${year_0})&dtout<td(01jan${start_year})&year==${start_year}

* Cleaning up
drop panel_obs
sort id year jobcount dtin dtout

* Indicator variable
gen old_obs = (year(dtout)<${year_0})

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

