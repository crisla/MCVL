* * * * * * * * * * * * * * * *  PRELIMS * * * * * * * * * * * * * * * * 

* Unify consecutive unemploymetn spells:
* --------------------------------------
sort id year jobcount dtin
* Some unemployment spells overlap due to administrative reasons, mostly
* expiration of regular unemployment insurance.
* This modification is useful when tabulating in quarters and for duration calculation.
gen dupu =0
by id : replace dupu = 1 if state=="U"&state[_n+1]=="U"
by id : replace dupu = dupu[_n-1]+1 if state=="U"&state[_n-1]=="U"

by id : gen dupu_cut = 1 if dupu==1&dupu[_n+1]==2
by id : replace dupu_cut=sum(dupu_cut) if state=="U"&dupu>0

sort id dupu_cut year jobcount dtin dupu
by id dupu_cut: replace dtout=dtout[_N] if state=="U"&dupu==1&dupu[_n+1]>1

drop if dupu>1
drop dupu dupu_cut

* Fixing spells over the year
by id: gen gap_years = year(dtout)-year
expand gap_years+1 if state=="U"&gap_years>0, gen(u_ext)
sort id year jobcount dtin dtout u_ext
replace year=year[_n-1]+1 if u_ext==1
drop gap_years u_ext


* regular_dismissal - not transiting to non-participant
* ------------------------------------------------------
gen regular_dismissal = 1 if cause<56
replace regular_dismissal = 1 if cause>=74
replace regular_dismissal = 0 if regular_dismissal ==.
replace regular_dismissal=0 if cause==94 // Note: cause=94 marks discountinuous workes.

* state1: job market state last period
* -------------------------------------
sort id year jobcount dtin
by id year: gen state1 = state[_n-1]
by id: replace state1 = state[_n-1] if state1==""

* last_spell and short (ends before 31dec2013)
* ---------------------------------------------
by id: gen last_spell=1 if _n==_N
replace last_spell=0 if last_spell==.
gen short=1 if  last_spell==1&dtout<td(31dec2013)
replace short=0 if short==.


* Diff_days: difference between start of next spells and end of current spell
* ---------------------------------------------------------------------------
* Negative differences cut so no overlapping occurs. 
sort id year jobcount dtin
by id year: gen diff_days = dtin[_n+1]-dtout[_n]
by id year: replace dtout = dtin[_n+1] if diff_days<0
by id year: replace diff_days = dtin[_n+1]-dtout[_n]
* For last year spells, fill in diff days for last or single year-observations:
* (the -1 takes into account the difference between 31dec and 01jan)
by id:replace diff_days = cdtin[_n+1]-dtout[_n]-1 if diff_days==.

replace ext_dt = dtout
