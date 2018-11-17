* * * * * * * * * * * * * * * *  PRELIMS * * * * * * * * * * * * * * * * 

* Unify consecutive unemploymetn spells:
* --------------------------------------
sort id jobcount dtin
* Some unemployment spells overlap due to administrative reasons, mostly
* expiration of regular unemployment insurance.
* This modification is useful when tabulating in quarters and for duration calculation.
gen dupu =0
by id : replace dupu = 1 if state=="U"&state[_n+1]=="U"
by id : replace dupu = dupu[_n-1]+1 if state=="U"&state[_n-1]=="U"

by id : gen dupu_cut = 1 if dupu==1&dupu[_n+1]==2
by id : replace dupu_cut=sum(dupu_cut) if state=="U"&dupu>0

sort id dupu_cut jobcount dtin dupu
by id dupu_cut: replace dtout=dtout[_N] if state=="U"&dupu==1&dupu[_n+1]>1

drop if dupu>1
drop dupu dupu_cut

sort id jobcount dtin dtout

replace days = dtout-dtin
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
sort id jobcount dtin dtout
by id : gen state1 = state[_n-1]
by id : gen nextS = state[_n+1]

* Short employment (less than 12 months of continuous employmnet)
* -----------------------------------------------------
gen emp_count = 0 if state=="U"|state=="R"
replace emp_count = days if state!="U"&state!="R"
sort id NoU dtin dtout
by id NoU: gen emp_spell = sum(emp_count)
gen short_emp = 0
replace short_emp = 1 if emp_spell<360 & year(dtout)>=1992 & (state=="T"|state=="P")
replace short_emp = 1 if emp_spell<180 & year(dtout)<1992 & (state=="T"|state=="P")
sort id jobcount dtin dtout

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
sort id jobcount dtin dtout

by id : gen diff_days = dtin[_n+1]-dtout[_n] if _n!=1


* Multiple spells at the same time:

by id: replace dtout = dtin[_n+1] if diff_days<0&(state[_n+1]!="U"&state[_n+1]!="R")
by id : replace diff_days = dtin[_n+1]-dtout[_n] if _n!=1

by id: replace dtin = dtout[_n-1] if diff_days[_n-1]<0&(state=="U"|state=="R")
by id : replace diff_days = dtin[_n+1]-dtout[_n] if _n!=1

replace diff_days = 0 if diff_days==.


* * * * * * * * * * * *  EXPANDING UNEMPLOYMENT (1) * * * * * * * * * * * * 
gen mod_u = 0

* Adding missing days of unemployment :
* -------------------------------------
* Many of these are just a few days off - for adminsitrative reasons - but many 
* of them (specially unemployment) are due to expiration of UI.Note that I only
* consider unemployment spells that finish in employment, not retirement (R).
by id: replace mod_u  = 1          if state[_n]=="U"&state[_n+1]!="U"&state[_n+1]!="R"&state[_n+1]!=""&diff_days>0
by id: replace dtout  = dtin[_n+1] if state[_n]=="U"&state[_n+1]!="U"&state[_n+1]!="R"&state[_n+1]!=""&diff_days>0

* Adding missing days of unemployment (unfinished spells as of 2013):
* -------------------------------------------------------------------
* The trend in unemployment differs a lot from the lfs if we do not take into
* account unfinished spells as of the end of 2013.
* (Except if the reason for the end of the spell is retirement or death)
by id: replace mod_u  = 1           if state[_n]=="U"&dtout<td(31dec2013)&last_spell==1&regular_dismissal==1&first_spell!=1
by id: replace dtout=td(31dec2013)  if state[_n]=="U"&dtout<td(31dec2013)&last_spell==1&regular_dismissal==1&first_spell!=1

* * * * * * * * * * * *  EXPANDING UNEMPLOYMENT (2) * * * * * * * * * * * *  

sort id jobcount dtin dtout
gen state2 = state

* Adding missing days, all gaps greater than 15 days
* ---------------------------------------------------
* Note: cause=94 marks discountinuous workes. The gap between jobs is voluntary.
by id: replace state2="U" if state[_n]!="U"&state[_n+1]!="U"&state[_n+1]!="R"&diff_days>15&cause!=94

* Adding employment spells that end before the end of 2013
* ------------------------------------------------------------
* approx. 60 % of the observations that would qualify are in 2013
by id: replace state2="U" if last_spell==1&first_spell==0&unfinish==1&regular_dismissal==1&state!="R"&state!="U"&year(dtout)>2010


* hidden_u: a duplicate of the employment spell that presents a gap with the 
* next employment spell if such gap is greater than 15 days.
expand 2 if state2!=state, gen(hidden_u)

* Corrects for the dates of entry and exit to the gap
sort id jobcount dtin dtout hidden_u
by id: replace dtin=dtout[_n-1] if hidden_u==1
by id: replace dtout=dtin[_n+1] if hidden_u==1&last_spell==0
by id: replace dtout=td(31dec2013) if hidden_u==1&last_spell==1

replace days = dtout-dtin if hidden_u==1

* Replace state variable to unemployment
replace state=state2 if hidden_u==1

* Recalls : Gaps between employment spells added by the correction
* ---------------------------------------------------------------
* firm identifiers - 31% recalls
sort id jobcount dtin dtout
by id: gen recall=1 if hidden_u==1&firmID==firmID[_n+1]&state[_n+1]!="U"&firmID!="00"
by id: replace recall=0 if recall==.

* recall2 : Non gap recalls (unemployment spell between employment spells), to
* use for tables and alike - 22.76%
by id: gen last_firm = firmID if state!="U"&state!="R"&firmID!="00"
by id: replace last_firm = last_firm[_n-1] if last_firm ==""&hidden_u!=1
by id: gen recall2 = 1 if last_firm==last_firm[_n-1]&state[_n-1]=="U"&state[_n]!="U"&hidden_u[_n-1]!=1&state!="A"
by id: replace recall2 = 0 if last_firm!=last_firm[_n-1]&state[_n-1]=="U"&state[_n]!="U"&state!="A"

* Self-Employment:
* -----------------------------------------------------
by id: gen self_emp = 0
by id: replace self_emp = 1 if hidden_u==1&state[_n-1]=="A"

* Quits 
* -----------------------------------------
by id: gen quit=0
by id: replace quit=1 if hidden_u==1&cause==51
*drop if hidden_u==1&short_emp==0&self_emp==0&quit==0

* Cleanign Options:
* ---------------------------------------------------------------------
* Option 1: do count self-employment, short tenures and quits. Rest no.
* (15 days minimun gap) *

// drop if hidden_u==1&short_emp==0&self_emp==0&quit==0

* Option 2: do count self-employment, short tenures, quits but NOT recalls

drop if hidden_u==1&recall==1
drop if hidden_u==1&short_emp==0&self_emp==0&quit==0

replace mod_u = 2 if hidden_u==1

//tab mod_u if state=="U"
//
//       mod_u |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           0 |    283,326        7.50        7.50
//           1 |  2,302,399       60.91       68.41
//           2 |  1,193,984       31.59      100.00
// ------------+-----------------------------------
//       Total |  3,779,709      100.00


// gen type_u = "quit" if quit==1
// replace type_u = "short emp" if short_emp==1
// replace type_u = "self emp" if self_emp==1
// tab type_u if hidden_u==1
//
//      type_u |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//        quit |    135,541       13.82       13.82
//    self emp |     86,027        8.77       22.60
//   short emp |    758,997       77.40      100.00
// ------------+-----------------------------------
//       Total |    980,565      100.00

replace days = dtout-dtin
