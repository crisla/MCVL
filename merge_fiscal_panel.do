// use "./MCVL0313.dta", clear

* **************************************************************************** *
* This file adds the wages.dta file, which is the sum of all tax files 	       *
* with the formatted working histories. For this we need to duplicate          *
* temporarily all observations for each year they are in the sample, so we can *
* match them with their wages. Then I take the average wage in the next job    *
* as the wage variable and drop all repeated cases.                            *
* **************************************************************************** *

* PRELIMINARIES *********************************************

* Panel adjustment *********************************************

replace year = year(dtout) if year(dtout)<2005
* Censor observations that go over 2005
gen over05 = 0
replace over05 = 1 if dtin<td(01jan2005)&dtout>td(01jan2005)&state!="R"
expand 2 if over05, gen(cen05)
sort id year jobcount dtin dtout cen05
by id: replace year=2004 if cen05[_n+1]==1&over05==1
replace dtin =td(01jan2005) if cen05==1
replace dtout =td(31dec2004) if cen05[_n+1]==1&over05==1
replace days_c = dtout-dtin+1 if over05==1

* Clear out over the limit cases
drop if dtin==date("01jan"+ string(year), "DMY")&dtout==date("01jan"+ string(year), "DMY")
drop if dtin==date("31dec"+ string(year), "DMY")&dtout==date("31dec"+ string(year), "DMY")

* Adjust number of jobs to account for hidden unemployment spells
gen jc = 1
by id: replace jc = 0 if jobcount==jobcount[_n-1]
by id: replace jc = 1 if jobcount==jobcount[_n-1]&hidden_u==1
by id: replace jobcount = sum(jc)
drop jc

* Erase firm code in gaps in between unemployment 
replace firmID = "" if hidden_u==1

* Some employer codes without a letter at the begining are represented as
* starting from 0 in the fiscal file. In order to match them I correct for this:
replace firmID = "0"+firmID if firm1==""|firm1==" "

* MERGING  *********************************************

merge m:m id firmID year using "./rawfiles/wages_panel.dta"

sort id year dtin

* Unemployment adjustment: match recorded UB with unemployment spells
replace state="U" if state==""&_merge==2&key=="C"
replace state="U" if state==""&_merge==2&key=="D"
sort state id year dtin
by state id year: replace income=income[_N] if firmID=="00"&income==.&income[_N]!=.&state=="U"&state[_N]=="U"&hidden_u!=1&_merge[_N]==2&dtout>=td(01jan2005)
by state id year: replace income=income[_N] if state=="U"&income==.&income[_N]!=.&state[_N]=="U"&hidden_u!=1&_merge[_N]==2&dtout>=td(01jan2005)

*Self-employed adjustment: match declared profits with unemployment spells
gen profits = 1 if _merge==2&(key=="A"|key=="L"|key=="G"|key=="H"|key=="I"|key=="F")
replace profits=0 if profits==.
replace state = "A" if profits==1&state==""

sort id year profits //firmID
by id year profits : gen income2 = sum(income) if profits==1
by id year profits : replace income = income2[_N] if profits==1
// replace profits = 0 if _merge==2&(key=="A"|key=="L")

sort state id year profits dtin
by state id year: replace income=income[_N] if income==.&income2[_N]!=.&state=="A"&state[_N]=="A"&_merge[_N]==2&profits[_N]==1
drop income2 profits

* Daily Income calculation *********************************************
drop if _merge == 2

* Sum days in the firm in each year
sort id firmID year dtin
by id firmID year: gen days_firm = sum(days_c)
by id firmID year: replace days_firm=days_firm[_N]

* Sum days of registered unemployment in each year
sort id year dtin
gen days_u = 0
replace days_u = days_c if state=="U"&hidden_u==0
by id year: replace days_u = sum(days_u) if state=="U"&hidden_u==0
by id year: replace days_u = days_u[_N] if state=="U"&hidden_u==0

* Average daily income
gen av_income = income/(days_firm) if income!=.&state!="U"
replace av_income = income/(days_u) if income!=.&state=="U"&hidden_u==0
replace av_income = 0 if hidden_u==1

* Average monthly income
gen av_income_m = av_income*30 if income!=.

* Before the clean up: uncomment to get a csv with wages by years
// export delimited id firmID year state av_income_m days_firm days_c cop sevpay age if av_income!=.&av_income!=0&_merge!=2&dtout>td(01jan2005)&age>20&age<55 using "./sc/allwages.csv", replace
 
*** Cleaning up ************************************************************

* Here I drop the duplicate observations., so one spell=one observation.
* I also preserve the first and last wages for robutness.

* For panel: select starting from 2005
gen beyond05 = 0
replace beyond05 = 1 if year>=2005

* kepp the first and last wage
sort id beyond05 jobcount year dtin
by id beyond05 jobcount: gen start_inc = av_income[1]
by id beyond05 jobcount: gen end_inc = av_income[_N]

* Rename older variables
rename av_income av_income_by_year
rename av_income_m av_income_m_by_year

*Calculate mean income
egen av_income = mean(av_income_by_year) if beyond05==1, by(id beyond05 jobcount)
egen av_income_m = mean(av_income_m_by_year) if beyond05==1, by(id beyond05 jobcount)
replace av_income =. if  av_income ==0&state!="U"
replace av_income_m =. if  av_income_m ==0&state!="U"

*** For Panel: collapse into one spell-one observation *****************
* Clean up starting dates
sort id jobcount year dtin
* First count temporayr and permanetn contracts as different spells (so not collapse into one)
gen jc = 1
by id: replace jc = 0 if state==state[_n-1]&jobcount==jobcount[_n-1]
by id: replace jc = 0 if state==state[_n-1]&hidden_u==1
by id: replace jobcount = sum(jc)
drop jc 

* Finally, collapse the panel
sort id jobcount year dtin
by id jobcount: replace dtin = dtin[1]
by id jobcount: keep if _n==_N

* Cleaning up days
replace dtin = odtin if state=="R"&odtin<dtin
replace days = dtout-dtin+1
drop if days<0 // final clean of in-between spells. 1,246 in total


*** Other adjustments ***************************************************

* Adjustep income for part-time workers
gen adjincome = av_income/cop
gen adjincome_m = adjincome*30

* Uncomment to make this the main variable
replace av_income = adjincome
replace av_income_m = adjincome_m
drop adjincome adjincome_m

* Future and past income - annual
replace av_income = av_income*365
sort id jobcount dtin
by id: gen next_income = av_income[_n+1]
by id: gen next2_income = av_income[_n+2]
by id: gen past_income = av_income[_n-1]

* Average observed income (in general)
gen all_time_income = 0
gen all_time_employed = 0
replace all_time_income = av_income if (state=="T"|state=="P")&av_income!=.
by id: replace all_time_income =sum(all_time_income)
replace all_time_employed = days if (state=="T"|state=="P")&av_income!=.
by id: replace all_time_employed =sum(all_time_employed)
gen income_id = all_time_income/all_time_employed
by id: replace income_id = income_id[_N]
drop all_time_income  all_time_employed

* Make sure non-registered unemployment spells get zero
replace av_income = 0 if hidden_u==1

gen year_in = year(dtin)
gen year_out = year(dtout)
* Uncomment to export a csv file with the resulting wages (for figures and tables)
// export delimited id state jobcount av_income_m av_income days year_in year_out cop start_inc sevpay age if av_income!=.&av_income!=0&_merge!=2&age>20&age<55 using "./sc/wages.csv", replace

saveold "./MCVL_wages_panel.dta", v(12) replace
