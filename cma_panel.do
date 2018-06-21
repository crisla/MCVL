
** CONTRACT MODIFICATION ADJUSTMENT ******************************************

* No modifications for unemployed or retired
replace mod1dt = "" if state=="U"|state=="R"
replace mod1ty = "" if state=="U"|state=="R"
replace mod2dt = "" if state=="U"|state=="R"
replace mod2ty = "" if state=="U"|state=="R"

* Format the date of 1st change of contract
gen mod1dt_copy = date(mod1dt,"YMD")
drop mod1dt
rename mod1dt_copy mod1dt
order mod1dt, before(mod1ty)
destring mod1ty,replace
format mod1dt %td

* Format the date of 2nd change of contract
gen mod2dt_copy = date(mod2dt,"YMD")
drop mod2dt
rename mod2dt_copy mod2dt
order mod2dt, before(mod2ty)
destring mod2ty,replace
format mod2dt %td

* Unify jobs
sort id jobcount year dtin
by id jobcount: replace mod1dt = mod1dt[_n-1] if mod1dt==.&mod1dt[_n-1]!=.&state!="R"
by id jobcount: replace mod1ty = mod1ty[_n-1] if mod1ty==.&mod1ty[_n-1]!=.&state!="R"

by id jobcount: replace mod2dt = mod2dt[_n-1] if mod2dt==.&mod2dt[_n-1]!=.&state!="R"
by id jobcount: replace mod2ty = mod2ty[_n-1] if mod2ty==.&mod2ty[_n-1]!=.&state!="R"

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

* Generate split variable if there was an effective  change in labour contract 
* on the 1st modification
gen statch1 = ""
replace statch1 = "T" if mod1ty> 400 & mod1ty < 900
replace statch1 = "P" if mod1ty>0 & mod1ty < 400
gen splitt = 1 if statch1!=""&state!=statch1&(year==year(mod1dt)|(year(mod1dt)<2005&year==2005))
replace splitt = . if mod1dt>dtout

* Generate split2 variable if there was an effective change in labour contract 
* on the 2nd modification
gen statch2 = ""
replace statch2 = "T" if mod2ty> 400 & mod2ty < 900
replace statch2 = "P" if mod2ty>0 & mod2ty < 400
gen split2 = 1 if statch2!=""&state!=statch2&(year==year(mod2dt)|(year(mod2dt)<2005&year==2005))

* If the actual change came in the 2nd modification, do not count the first
replace splitt=. if statch1==statch2

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

* Separate the job spell into 2 periods with different contracts (1st mod)
expand 2 if splitt==1, gen(contract_change)

* Replace dates and state to separate the spells (same year)
sort id dtin dtout contract_change
by id dtin: replace state = statch1 if contract_change==1
by id dtin: replace dtout = mod1dt if contract_change==1
by id: replace dtin = mod1dt if contract_change==0&contract_change[_n+1]==1&jobcount==jobcount[_n+1]

sort id jobcount year dtin
by id jobcount: replace dtin = dtin[_n-1] if dtin[_n]!=dtin[_n-1]&mod1dt==mod1dt[_n-1]&contract_change==0&contract_change[_n-1]!=1&mod1dt!=.
by id jobcount: replace state = statch1 if year<year(mod1dt)&mod1dt!=.&state!=statch1&statch1!=""

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Make sure the second change is necessary
replace split2=. if mod2dt>dtout&split2==1
by id: replace split2 = . if contract_change==1

* Separate the job spell into 2 periods with different contracts (2nd mod)
expand 2 if split2==1, gen(contract_change2)

* Replace dates and state to separate the spells (same year)
sort id dtin dtout contract_change2
by id dtin: replace state = statch2 if contract_change2==1
by id dtin: replace dtout = mod2dt if contract_change2==1
by id: replace dtin = mod2dt if contract_change2==0&contract_change2[_n+1]==1&jobcount==jobcount[_n+1]

sort id jobcount year dtin dtout
by id jobcount: replace state = statch2 if year<year(mod2dt)&mod2dt!=.&state!=statch2&statch2!=""
by id jobcount: replace dtin = dtin[_n-1] if dtin[_n]<dtin[_n-1]&mod2dt!=.&dtin[_n-1]!=.

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

* Fixing days
* 62 observations with negative days because of likely clerical errors to be removed
replace days = dtout-dtin
drop if days<0


