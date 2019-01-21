use "./MCVL0313.dta", clear

* **************************************************************************** *
* This file adds the wages.dta file, which is the sum of all tax files 	       *
* with the formatted working histories. For this we need to duplicate          *
* temporarily all observations for each year they are in the sample, so we can *
* match them with their wages. Then I take the average wage in the next job    *
* as the wage variable and drop all repeated cases.                            *
* **************************************************************************** *

* PRELIMINARIES *********************************************

* Because the wage data is only available after 2005, all older spells are dropped
* Dropping out cases before 2005
drop if dtout<td(01jan2005)

* Recoding colldiss (Colelctive Dissmissals dummy)
sort id jobcount dtin
gen colldiss2=1 if cause==77&state=="P"		// 1 From Perm Contract
replace colldiss2=2 if state=="T"&cause==77	// 2 From Temp Contract
replace colldiss2=0 if colldiss2==.		// 0 None of the above
by id: replace colldiss2 = colldiss2[_n-1] if state=="U"&(state[_n-1]=="T"|state[_n-1]=="P")

* Same firm indicator
sort firmID id
by firmID id: gen SfirmSwrk = _n
by firmID id: replace SfirmSwrk = SfirmSwrk[_N]-1
by firmID id: replace SfirmSwrk =. if _n!=_N
by firmID: gen SfirmSwrk2= sum(SfirmSwrk)
by firmID: replace SfirmSwrk2 = SfirmSwrk2[_N]
by firmID: gen nworks=_n
by firmID: replace nworks=nworks[_N]-SfirmSwrk2
drop SfirmSwrk2 SfirmSwrk

* Forwardlooking variables:
sort id dtin dtout
by id: gen next_state=state[_n+1]
by id: gen next_days= days[_n+1]
by id: gen next2_state=state[_n+2]
by id: gen next2_days= days[_n+2]
* For inspection:
*sort firmID dtout cause 

* Grouping by workforce
gen short_nworks = 5 if nworks<=5
replace short_nworks = 10 if nworks<=10&short_nworks==.
replace short_nworks = 20 if nworks<=20&short_nworks==.
replace short_nworks = 50 if nworks<=50&short_nworks==.
replace short_nworks = 100 if nworks<=100&short_nworks==.
replace short_nworks = 200 if nworks<=200&short_nworks==.
replace short_nworks = 500 if nworks<=500&short_nworks==.
replace short_nworks = 1000 if nworks<=1000&short_nworks==.
replace short_nworks = 5000 if nworks<=5000&short_nworks==.
replace short_nworks = 10000 if nworks<=10000&short_nworks==.
replace short_nworks = 100000 if nworks>10000&short_nworks==.
*tab short_nworks

* Adapting some short codes
gen let1 = substr(firmID,1,1)
replace firmID = "0"+substr(firmID,2,.) if let1==" "
drop let1

* Duplicating years *********************************************
* Because we need to match one-year-fiscal-file with one-year-spells,
* if you are using only one year (say, the last one in the sample)
* you need to duplicate the spell creating one observation per year
* that the spell is active. If you are using a panel, you don't need to
* do this.
******************************************************************
// sort id jobcount dtin
// gen year_expansion = year(dtout)-year(dtin) if year(dtin)<year(dtout)&year(dtout)>=2005
//
// expand year_expansion+1 if year_expansion!=., gen(year_split)
// sort id jobcount dtin year_split
// gen year = year(dtin) if year_split==0
// replace year = year[_n-1]+1 if year_split==1
// drop if year_split==1&year<2005

* For panel version: indicator for same job (corrected)
* Comment out if using a single year
gen jc = 1
by id: replace jc = 0 if jobcount==jobcount[_n-1]&state==state[_n-1]
by id: replace jobcount = sum(jc)
drop jc

*Adjusting dates
gen nyd = date("01jan"+ string(year), "DMY") if year!=.
gen nye = date("31dec"+ string(year), "DMY") if year!=.
gen days_cen = min(dtout,nye)-max(nyd,dtin) if year!=.
drop nyd nye


* MERGING  *********************************************

merge m:m id firmID year using "./rawfiles/wages_panel.dta"

sort id year dtin

* Unemployment adjustment: match recorded UB with unemployment spells
replace state="U" if state==""&_merge==2&key=="C"
replace state="U" if state==""&_merge==2&key=="D"
sort state id year dtin
by state id year: replace income=income[_N] if firmID=="00"&income==.&income[_N]!=.&state=="U"&state[_N]=="U"&hidden_u!=1&_merge[_N]==2&dtout>=td(01jan2005)


*Self-employed adjustment: match declared profits with unemployment spells
gen profits = 1 if _merge==2&(key=="A"|key=="L"|key=="G"|key=="H"|key=="I"|key=="F")
replace profits=0 if profits==.
replace state = "A" if profits==1&state==""

sort id profits year firmID
by id profits year: gen income2 = sum(income) if profits==1
by id profits year: replace income = income2[_N] if profits==1
replace profits = 0 if _merge==2&(key=="A"|key=="L")

sort state id year dtin
by state id year: replace income=income[_N] if income==.&income2[_N]!=.&state=="A"&state[_N]=="A"&_merge[_N]==2
drop income2

* Average Income calculation
drop if _merge == 2

sort id firmID year dtin
by id firmID year: gen days_firm = sum(days_cen)
by id firmID year: replace days_firm=days_firm[_N]

gen av_income = income/(days_firm) if income!=.
replace av_income = 0 if hidden_u==1
gen av_income_m = av_income*30 if income!=.

* Before the clean up: uncomment to get a csv with wages by years
// export delimited id firmID year state av_income_m days_firm days cop sevpay age if av_income!=.&av_income!=0&_merge!=2&dtout>td(01jan2005)&age>20&age<55 using "./sc/allwages.csv", replace

*** Cleaning up ************************************************************
* Here I drop the duplicate observations., so one spell=one observation.
* I also preserve the first and last wages for robutness.

sort id jobcount year dtin
by id jobcount: gen start_inc = av_income[1]
by id jobcount: replace start_inc = av_income[2] if year[2]==2005
by id jobcount: gen end_inc = av_income[_N]
rename av_income mean_income
rename av_income_m mean_income_m
egen av_income = mean(mean_income), by(id jobcount)
egen av_income_m = mean(mean_income_m), by(id jobcount)
replace av_income =. if  av_income ==0&state!="U"
replace av_income_m =. if  av_income_m ==0&state!="U"

* One-year version uncomment:
// drop if year_split>0
// drop year_split year_expansion year days_cen mean_income mean_income_m

* Panel version uncomment:
sort id jobcount year dtin
by id jobcount: replace dtin = dtin[1]
by id: drop if jobcount==jobcount[_n+1]

gen adjincome = av_income/cop
gen adjincome_m = (adjincome/365)*30

* Uncomment to export a csv file with the resulting wages (for figures and tables)
// export delimited id state jobcount av_income_m adjincome_m days cop start_inc sevpay age if av_income!=.&av_income!=0&_merge!=2&dtout>td(01jan2005)&av_income!=av_income[_n-1]&age>20&age<55 using "./sc/wages.csv", replace

replace av_income = adjincome
replace av_income_m = adjincome_m

drop adjincome adjincome_m

* Future and past income - annual
replace av_income = av_income*365
sort id dtin
by id: gen next_income = av_income[_n+1]
by id: gen next2_income = av_income[_n+2]
by id: gen past_income = av_income[_n-1]


saveold "./MCVL_wages.dta", v(12) replace
