* * * * * * * * * * * * * * * *  PRELIMS * * * * * * * * * * * * * * * * 

* Unify consecutive unemploymetn spells:
* --------------------------------------
sort id year jobcount dtin
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

replace cdtin = mdy(1,1,year) if year(dtin)<year
replace cdtout = mdy(12,31,year) if year(dtout)>year
by id: replace days_c = cdtout-cdtin+1 if _n!=1
replace days = dtout-dtin+1

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


* * * * * * * * * * * *  EXPANDING UNEMPLOYMENT (1) * * * * * * * * * * * * 
gen mod_u = 0

* Adding missing days of unemployment :
* -------------------------------------
* Many of these are just a few days off - for adminsitrative reasons - but many 
* of them (specially unemployment) are due to expiration of UI.Note that I only
* consider unemployment spells that finish in employment, not retirement (R).
by id: replace mod_u  = 1          if state[_n]=="U"&state[_n+1]!="U"&state[_n+1]!="R"&state[_n+1]!=""&diff_days>0
by id: replace cdtout  = cdtin[_n+1] if state[_n]=="U"&state[_n+1]!="U"&state[_n+1]!="R"&state[_n+1]!=""&diff_days>0

* Adding missing days of unemployment (unfinished spells as of 2013):
* -------------------------------------------------------------------
* The trend in unemployment differs a lot from the lfs if we do not take into
* account unfinished spells as of the end of 2013.
* (Except if the reason for the end of the spell is retirement or death)
by id: replace mod_u  = 1           if state[_n]=="U"&dtout<td(31dec2013)&last_spell==1&regular_dismissal==1&first_spell!=1
by id: replace cdtout=td(31dec2013) if state[_n]=="U"&dtout<td(31dec2013)&last_spell==1&regular_dismissal==1&first_spell!=1

* * * * * * * * * * * *  EXPANDING UNEMPLOYMENT (2) * * * * * * * * * * * *  

sort id year jobcount dtin dtout
gen state2 = state

* Adding missing days, all gaps greater than 15 days
* ---------------------------------------------------
* Note: cause=94 marks discountinuous workes. The gap between jobs is voluntary.
by id: replace state2="U" if state[_n]!="U"&state[_n+1]!="U"&state!="R"&state[_n+1]!="R"&diff_days>15&regular_dismissal==1

* Adding employment spells that end before the end of 2013
* ------------------------------------------------------------
* approx. 60 % of the observations that would qualify are in 2013
by id: replace state2="U" if last_spell==1&first_spell==0&unfinish==1&regular_dismissal==1&state!="R"&state!="U"&year(dtout)>2010


* hidden_u: a duplicate of the employment spell that presents a gap with the 
* next employment spell if such gap is greater than 15 days.
expand 2 if state2!=state, gen(hidden_u)

* Corrects for the dates of entry and exit to the gap
sort id year jobcount dtin dtout hidden_u
by id: replace cdtin=cdtout[_n-1] if hidden_u==1
by id: replace cdtout=cdtin[_n+1] if hidden_u==1&last_spell==0
by id: replace cdtout=td(31dec2013) if hidden_u==1&last_spell==1

replace days_c = cdtout-cdtin if hidden_u==1

* Replace state variable to unemployment
replace state=state2 if hidden_u==1

* Recalls : Gaps between employment spells added by the correction
* ---------------------------------------------------------------
* firm identifiers - 31% recalls
sort id year jobcount dtin dtout
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

//    cleaning |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           0 |    980,565       71.41       71.41
//           1 |    240,444       17.51       88.92
//           2 |    152,098       11.08      100.00
// ------------+-----------------------------------
//       Total |  1,373,107      100.00

// . tab mod_u if state=="U"&dtout>td(01jan2005)
//
//       mod_u |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           0 |  1,728,455       60.87       60.87
//           1 |    417,308       14.70       75.56
//           2 |    693,966       24.44      100.00
// ------------+-----------------------------------
//       Total |  2,839,729      100.00



gen type_u = "quit" if quit==1
replace type_u = "short emp" if short_emp==1
replace type_u = "self emp" if self_emp==1
// tab type_u if hidden_u==1
//
//      type_u |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//        quit |    151,461       19.06       19.06
//    self emp |     91,972       11.57       30.63
//   short emp |    551,272       69.37      100.00
// ------------+-----------------------------------
//       Total |    794,705      100.00

// . sum days_c if hidden_u==1,d
// . sum days_c if mod_u==1&days_c>0&dtout>=td(01jan2005),d
//
//                            days_c
// -------------------------------------------------------------
//       Percentiles      Smallest
//  1%            6              1
//  5%           26              1
// 10%           37              1       Obs             417,334
// 25%           91              1       Sum of Wgt.     417,334
//
// 50%          203                      Mean            370.557
//                         Largest       Std. Dev.      456.8372
// 75%          412           3286
// 90%          992           3286       Variance       208700.2
// 95%         1460           3286       Skewness       2.525348
// 99%         2191           3286       Kurtosis       10.78857

//
// . sum days_c if hidden_u==1&dtout>=td(01jan2005),d
//
//                            days_c
// -------------------------------------------------------------
//       Percentiles      Smallest
//  1%           14              1
//  5%           19              1
// 10%           23              1       Obs             694,059
// 25%           40              1       Sum of Wgt.     694,059
//
// 50%           96                      Mean           210.8426
//                         Largest       Std. Dev.      292.6692
// 75%          253           3168
// 90%          553           3169       Variance       85655.27
// 95%          823           3174       Skewness       3.059732
// 99%         1432           3226       Kurtosis       15.89696
replace state1 = ""
by id: replace state1 = state[_n-1] if jobcount!=jobcount[_n-1]|mod_u==2
by id: replace state1 = state1[_n-1] if state1==""

gen state_1 = ""
by id: replace state_1 = state[_n+1] if jobcount!=jobcount[_n+1]
by id: replace state_1 = state1[_n+1] if state_1==""

// by id year: replace state1 = state[_n-1] 
// by id: replace state1 = state[_n-1] if state1==""
// by id year : gen state_1 = state[_n+1]
// by id: replace state_1 = state[_n+1] if state_1==""
// . tab state1 if hidden_u==1
//
//      state1 |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           A |     91,972       11.57       11.57
//           P |    137,369       17.29       28.86
//           R |          5        0.00       28.86
//           T |    565,359       71.14      100.00
// ------------+-----------------------------------
//       Total |    794,705      100.00
//
// . 
// . tab state1 if mod_u==1
//
//      state1 |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           A |      1,888        0.41        0.41
//           P |     58,804       12.79       13.20
//           R |         68        0.01       13.21
//           T |    191,765       41.70       54.91
//           U |    207,369       45.09      100.00
// ------------+-----------------------------------
//       Total |    459,894      100.00

// export delimited id state year mod_u cdtin cdtout dtin dtout cop age sex cause type_u state1 ExpP ExpT ExpU NoU NoT NoP state_1 if state=="U"&days_c>0&dtout>=td(01jan2005)&jobcount!=jobcount[_n+1] using "/home/clafuente/New/gaps_stats.csv", replace

* * * * * * * * * * * *   FIXING SPELLS OVER THE YEAR * * * * * * * * * * * *  
sort id year jobcount cdtin cdtout 

* As a result of the extended dates of end of spells, some spells now end in a 
* different year that their corresponding one. 
by id: gen gap_years = year(cdtout)-year

* Expanding spells over time:
expand gap_years+1 if state=="U"&gap_years>0, gen(u_ext)
sort id year jobcount cdtin cdtout u_ext
replace year=year[_n-1]+1 if u_ext==1


* Fixing days
replace cdtin = mdy(1,1,year) if year(cdtin)<year
replace cdtout = mdy(12,31,year) if year(cdtout)>year
by id: replace days_c = cdtout-cdtin+1 if _n!=1

* Fixing dates: orignal date in and out
gen odtin =dtin
gen odtout = dtout
replace dtin=cdtin
replace dtout=cdtout
drop cdtin cdtout

format odtin %td
format odtout %td
