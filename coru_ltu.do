* * * * * * * * * * * * * * * *  PRELIMS * * * * * * * * * * * * * * * * 

* Unify consecutive unemployment spells:
* --------------------------------------
sort id jobcount dtin year 
* Some unemployment spells overlap due to administrative reasons, mostly
* expiration of regular unemployment insurance.
* This modification is useful when tabulating in quarters and for duration calculation.
gen dupu =0
by id: replace dupu = 1 if state=="U"&state[_n+1]=="U"
by id: replace dupu = dupu[_n-1]+1 if state=="U"&state[_n-1]=="U"

by id: gen dupu_cut = 1 if dupu==1&dupu[_n+1]==2
by id: replace dupu_cut=sum(dupu_cut) if state=="U"&dupu>0

sort id dupu_cut year jobcount dtin dupu
by id dupu_cut: replace dtout=dtout[_N] if state=="U"&dupu==1&dupu[_n+1]>1

drop if dupu>1
drop dupu dupu_cut

sort id year jobcount dtin dtout

* Reseat censored days
replace cdtin = dtin
replace cdtout = dtout
format cdtin %td
format cdtout %td

replace cdtin = mdy(1,1,year) if year(dtin)!=year&old_obs==0
replace cdtout = mdy(12,31,year) if year(dtout)!=year&old_obs==0
by id: replace days_c = cdtout-cdtin+1 if old_obs==0
replace days = dtout-dtin+1

* regular_dismissal - not transiting to non-participant
* ------------------------------------------------------
gen regular_dismissal = 1 if cause<56
replace regular_dismissal = 1 if cause>=74
replace regular_dismissal = 0 if regular_dismissal ==.
replace regular_dismissal=0 if cause==94 // Note: cause=94 marks discountinuous workes.

* state1: job market state last period
* -------------------------------------
sort id jobcount year cdtin
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
sort id year cdtin cdtout

by id : gen diff_days = cdtin[_n+1]-cdtout[_n]-1 //if _n!=1
// by id : gen diff_days = cdtin[_n+1]-cdtout[_n]

* Multiple spells at the same time:

by id: replace cdtout = cdtin[_n+1] if diff_days<0&(state[_n+1]!="U"&state[_n+1]!="R")
by id : replace diff_days = cdtin[_n+1]-cdtout[_n]-1 if _n!=1

by id: replace cdtin = cdtout[_n-1] if diff_days[_n-1]<0&(state=="U"|state=="R")
by id : replace diff_days = cdtin[_n+1]-cdtout[_n]-1 if _n!=1

replace diff_days = 0 if diff_days==.

* Clear out overlapping spells left
gen inbetween_left = 0
replace inbetween_left = 1 if days_c<0 // 0.18% of observations
drop if inbetween_left
drop inbetween_left

* Recording the date before extension
replace ext_dt = dtout
format ext_dt %td


* * * * * * * * * * * *  EXPANDING UNEMPLOYMENT (1) * * * * * * * * * * * * 
gen mod_u = 0

* Adding missing days of unemployment :
* -------------------------------------
* Many of these are just a few days off - for adminsitrative reasons - but many 
* of them (specially unemployment) are due to expiration of UI.Note that I only
* consider unemployment spells that finish in employment, not retirement (R).
by id: replace mod_u  = 1          if state[_n]=="U"&state[_n+1]!="U"&state[_n+1]!="R"&state[_n+1]!=""&diff_days>1
by id: replace cdtout  = cdtin[_n+1] if state[_n]=="U"&state[_n+1]!="U"&state[_n+1]!="R"&state[_n+1]!=""&diff_days>1

* Adding missing days of unemployment (unfinished spells as of 2013):
* -------------------------------------------------------------------
* The trend in unemployment differs a lot from the lfs if we do not take into
* account unfinished spells as of the end of 2013.
* (Except if the reason for the end of the spell is retirement or death)
by id: replace mod_u  = 1           if state[_n]=="U"&dtout<td(31dec2013)&last_spell==1&regular_dismissal==1&first_spell!=1&year(cdtin)>2003
by id: replace cdtout=td(31dec2013) if state[_n]=="U"&dtout<td(31dec2013)&last_spell==1&regular_dismissal==1&first_spell!=1&year(cdtin)>2003

* * * * * * * * * * * *   FIXING SPELLS OVER THE YEAR * * * * * * * * * * * *  
sort id year jobcount cdtin cdtout 

* As a result of the extended dates of end of spells, some spells now end in a 
* different year that their corresponding one. 
by id: gen gap_years = 0
replace gap_years = year(cdtout)-year if old_obs==0

* Expanding spells over time:
expand gap_years+1 if state=="U"&gap_years>0, gen(u_ext)
sort id year jobcount cdtin cdtout u_ext
replace year=year[_n-1]+1 if u_ext==1

* Fixing days
replace cdtin = mdy(1,1,year) if year(cdtin)!=year&old_obs==0
replace cdtout = mdy(12,31,year) if year(cdtout)!=year&old_obs==0
by id: replace days_c = cdtout-cdtin+1 if old_obs==0

* Fixing dates: orignal date in and out
gen odtin =dtin
gen odtout = dtout
replace dtin=cdtin
replace dtout=cdtout
drop cdtin cdtout

format odtin %td
format odtout %td
