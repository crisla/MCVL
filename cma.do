** CONTRACT MODIFICATION ADJUSTMENT ******************************************

* Unify jobs
sort id jobcount dtin
by id: replace jobcount = jobcount[_n-1] if dtin==dtin[_n-1]
by id: replace mod1dt = mod1dt[_n-1] if jobcount==jobcount[_n-1]&mod1dt[_n-1]!=""&state!="R"
by id: replace mod1ty = mod1ty[_n-1] if jobcount==jobcount[_n-1]&mod1ty[_n-1]!=""&state!="R"

by id: replace mod2dt = mod2dt[_n-1] if jobcount==jobcount[_n-1]&mod2dt[_n-1]!=""&state!="R"
by id: replace mod2ty = mod2ty[_n-1] if jobcount==jobcount[_n-1]&mod2ty[_n-1]!=""&state!="R"

* In rare cases where there is a contract adjustment while unemployed, shut this down.
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

* Generate split variable if there was an effective  change in labour contract 
* on the 1st modification
gen statch1 = ""
replace statch1 = "T" if mod1ty> 400 & mod1ty < 900
replace statch1 = "P" if mod1ty>0 & mod1ty < 400
* Other, older temporary contracts:
replace statch1 = "T" if tyco>=4&tyco<8
replace statch1 = "T" if tyco>=14&tyco<18
replace statch1 = "T" if tyco==22|(tyco>=24&tyco<28)
replace statch1 = "T" if tyco>=34&tyco<39
replace statch1 = "T" if tyco>=53&tyco<59
replace statch1 = "T" if tyco==64|(tyco>=66&tyco<69)
replace statch1 = "T" if tyco>=72&tyco<100
* Other, older permanet contracts:
replace statch1 = "P" if tyco==18
replace statch1 = "P" if tyco>0&tyco<4
replace statch1 = "P" if tyco>10&tyco<14
replace statch1 = "P" if tyco==20|tyco==23
replace statch1 = "P" if tyco>=28&tyco<34
replace statch1 = "P" if tyco>=39&tyco<53
replace statch1 = "P" if tyco>=59&tyco<64
replace statch1 = "P" if tyco==65
replace statch1 = "P" if tyco>=69&tyco<72

gen splitt = 1 if statch1!=""&state!=statch1
* Generate split2 variable if there was an effective change in labour contract 
* on the 2nd modification
gen statch2 = ""
replace statch2 = "T" if mod2ty> 400 & mod2ty < 900
replace statch2 = "P" if mod2ty>0 & mod2ty < 400
* Other, older temporary contracts:
replace statch2 = "T" if tyco>=4&tyco<8
replace statch2 = "T" if tyco>=14&tyco<18
replace statch2 = "T" if tyco==22|(tyco>=24&tyco<28)
replace statch2 = "T" if tyco>=34&tyco<39
replace statch2 = "T" if tyco>=53&tyco<59
replace statch2 = "T" if tyco==64|(tyco>=66&tyco<69)
replace statch2 = "T" if tyco>=72&tyco<100
* Other, older permanet contracts:
replace statch2 = "P" if tyco==18
replace statch2 = "P" if tyco>0&tyco<4
replace statch2 = "P" if tyco>10&tyco<14
replace statch2 = "P" if tyco==20|tyco==23
replace statch2 = "P" if tyco>=28&tyco<34
replace statch2 = "P" if tyco>=39&tyco<53
replace statch2 = "P" if tyco>=59&tyco<64
replace statch2 = "P" if tyco==65
replace statch2 = "P" if tyco>=69&tyco<72

gen split2 = 1 if statch2!=""&state!=statch2
* If the actual change came in the 2nd modification, do not count the first
replace splitt=. if statch1==statch2

* Separate the job spell into 2 periods with different contracts (1st mod)
expand 2 if splitt==1, gen(contract_change)

* Replace dates and state to separate the spells 
sort id dtin dtout contract_change
by id dtin: replace state = statch1 if contract_change==1
by id dtin: replace dtout = mod1dt if contract_change==1
by id dtin: replace dtin = mod1dt if contract_change==0&contract_change[_n+1]==1
by id: replace split2 = . if contract_change==1

// sort id jobcount dtin dtout
// by id jobcount: replace state = state[_n+1] if state[_n]!=state[_n+1]&contract_change[_n+1]==1&mod1dt==mod1dt[_n+1]
* Same for 2004 (no date of modification)
*sort id year dtin dtout
*by id : replace state = state[_n+1] if state[_n]!=state[_n+1]&contract_change[_n+1]==1&jobcount==jobcount[_n+1]

* Separate the job spell into 2 periods with different contracts (2nd mod)
expand 2 if split2==1, gen(contract_change2)

* Replace dates and state to separate the spells
sort id dtin split2 contract_change2
by id dtin: replace state = statch2 if contract_change2==1
by id dtin: replace dtout =mod2dt if contract_change2==1
by id dtin: replace dtin = mod2dt if contract_change2==0&contract_change2[_n+1]==1

// sort id jobcount dtin dtout
// by id jobcount: replace state = state[_n+1] if state[_n]!=state[_n+1]&contract_change2[_n+1]==1&mod2dt==mod2dt[_n+1]
* Same for 2004 (no date of modification)
*sort id year dtin dtout
*by id : replace state = state[_n+1] if state[_n]!=state[_n+1]&contract_change2[_n+1]==1&jobcount==jobcount[_n+1]
*Change date on entering into the spell
*sort id year dtin dtout
*by id: replace dtin = dtin[_n-1] if jobcount==jobcount[_n-1]&dtin<dtin[_n-1]&year>year[_n-1]

* Drop the cases of negative days (6 obs in total)
replace days = dtout-dtin


