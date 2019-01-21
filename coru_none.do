* * * * * * * * * * * * * * * *  PRELIMS * * * * * * * * * * * * * * * * 

* Unify consecutive unemployment spells:
* --------------------------------------
sort id year jobcount dtin
* Some unemployment spells overlap due to administrative reasons, mostly
* expiration of regular unemployment insurance.
* This modification is useful when tabulating in quarters and for duration calculation.
gen dupu =0
by id year: replace dupu = 1 if state=="U"&state[_n+1]=="U"
by id year: replace dupu = dupu[_n-1]+1 if state=="U"&state[_n-1]=="U"

by id year: gen dupu_cut = 1 if dupu==1&dupu[_n+1]==2
by id year: replace dupu_cut=sum(dupu_cut) if state=="U"&dupu>0

sort id year dupu_cut jobcount dtin dupu
by id year dupu_cut: replace dtout=dtout[_N] if state=="U"&dupu==1&dupu[_n+1]>1

drop if dupu>1
drop dupu dupu_cut

sort id year jobcount dtin dtout

* Reseat censored days
replace cdtin = dtin
replace cdtout = dtout
format cdtin %td
format cdtout %td

replace cdtin = mdy(1,1,year) if year(dtin)<year&old_obs==0
replace cdtout = mdy(12,31,year) if year(dtout)>year&old_obs==0
by id: replace days_c = cdtout-cdtin+1 if old_obs==0
replace days = dtout-dtin+1

* Recording the date before extension
replace ext_dt = dtout
format ext_dt %td

* regular_dismissal - not transiting to non-participant
* ------------------------------------------------------
gen regular_dismissal = 1 if cause<56
replace regular_dismissal = 1 if cause>=74
replace regular_dismissal = 0 if regular_dismissal ==.
replace regular_dismissal=0 if cause==94 // Note: cause=94 marks discountinuous workes.

* state1: job market state last period
* -------------------------------------
sort id jobcount year dtin
by id jobcount: gen state1 = state[_n-1] if _n==1
by id: replace state1 = state[_n-1] if state1==""

* last_spell and unfinish (ends before 31dec2013)
* ---------------------------------------------
by id: gen last_spell=1 if _n==_N
replace last_spell=0 if last_spell==.
gen unfinish=1 if  last_spell==1&dtout<td(31dec2013)
replace unfinish=0 if unfinish==.

by id: gen first_spell = 1 if _n==1
replace first_spell = 0 if first_spell==.

* Diff_days: difference between start of next spells and end of current spell
* ---------------------------------------------------------------------------
* Negative differences cut so no overlapping occurs. 
sort id year jobcount dtin dtout

by id : gen diff_days = cdtin[_n+1]-cdtout[_n]-1 if _n!=1
// by id : gen diff_days = cdtin[_n+1]-cdtout[_n]

* Multiple spells at the same time:

by id: replace cdtout = cdtin[_n+1] if diff_days<0&(state[_n+1]!="U"&state[_n+1]!="R")
by id : replace diff_days = cdtin[_n+1]-cdtout[_n]-1 if _n!=1

by id: replace cdtin = cdtout[_n-1] if diff_days[_n-1]<0&(state=="U"|state=="R")
by id : replace diff_days = cdtin[_n+1]-cdtout[_n]-1 if _n!=1

replace diff_days = 0 if diff_days==.
replace days_c = cdtout-cdtin
