
*** Panellize **************************************************************

* Clear out overlapping spells left
sort id year dtin dtout
gen total_overlap = 0
by id year: replace total_overlap=1 if dtin==dtin[_n-1]&dtout==dtout[_n-1]&state==state[_n-1]
by id year: replace total_overlap=1 if dtin==dtin[_n+1]&dtout<dtout[_n+1]&state==state[_n+1]&firmID==firmID[_n+1]
drop if total_overlap
drop total_overlap

* Clear out negative duration spells
gen inbetween_left = 0
replace inbetween_left = 1 if days_c<0 // 0.07% of observations
drop if inbetween_left
drop inbetween_left

* spell_no: for each spell, one code
gen jc = 1
by id : replace jc = 0 if dtin==dtin[_n-1]&state==state[_n-1]&firmID==firmID[_n-1]
by id : replace jc = sum(jc)
gen spell_no = jc
drop jc

* Make sure observations are indeed censored
*drop year_s
tostring year,gen(year_s)
*replace dtout = date("31jan"+year_s,"DMY") if dtout < date("31jan"+year_s,"DMY")

gen dtoutQ1 = date("01feb"+year_s,"DMY")
gen dtoutQ2 = date("01may"+year_s,"DMY")
gen dtoutQ3 = date("01aug"+year_s,"DMY")
gen dtoutQ4 = date("01nov"+year_s,"DMY")

gen dtinQ1 = date("15feb"+year_s,"DMY")
gen dtinQ2 = date("15may"+year_s,"DMY")
gen dtinQ3 = date("15aug"+year_s,"DMY")
gen dtinQ4 = date("15nov"+year_s,"DMY")

gen Q1 = 0
gen Q2 = 0
gen Q3 = 0
gen Q4 = 0

sort id year jobcount dtin
foreach i in "1" "2" "3" "4" {
by id year: replace Q`i' = 1 if dtin<dtinQ`i'&dtout>dtoutQ`i'
}
* Cleaning
drop dtinQ* dtoutQ*

gen no_quarters = Q1+Q2+Q3+Q4
expand no_quarters, gen(qrt_ext)

sort id year spell_no dtin qrt_ext
gen quarter = . 
foreach i in "1" "2" "3" "4" {
     replace quarter = `i' if qrt_ext==0&Q`i'==1&quarter==.
}
*
by id year spell_no dtin: replace quarter = quarter[_n-1]+1 if qrt_ext>0

* Drop in-between quarter observations
drop if quarter==.
order quarter,after(year)

* Duplicates: more than one spell per quarter (2% or less each quarter)
sort id year quarter dtin spell_no
gen dups = 0
by id year quarter: replace dups = dups[_n-1]+1 if _n!=1

* Clean up repetitions - 1 out of 9 have only 2 states
by id year quarter: gen states_per_quarter = state if _n==1
by id year quarter: replace states_per_quarter = states_per_quarter[_n-1]+state if _n!=1
by id year quarter: drop if _n==2&_n==_N&state==state[_n-1]

// log using dups_stu.log,replace
// tab dups quarter
// log close

// log using which_dups_stu.log,replace
// tab states_per_quarter if length(states_per_quarter)>1
// log close

* Choosing among duplicates
* OPTION 1: Last spell stays in
by id year quarter: keep if _n == _N
drop dup

* OPTION 2a: Ranking (A>P)
// gen state_ranking = 0
// replace state_ranking = 1 if state=="T"
// replace state_ranking = 2 if state=="P"
// replace state_ranking = 3 if state=="A"
// replace state_ranking = 4 if state=="R"
//
// by id year quarter: drop if state_ranking<=state_ranking[_n-1]&dups>0
// replace dups = 0
// by id year quarter: replace dups = dups[_n-1]+1 if _n!=1
// by id year quarter: drop if state_ranking<=state_ranking[_n+1]&dups==0&dups[_n+1]>0&dups[_n+1]!=.
// replace dups = 0
// by id year quarter: replace dups = dups[_n-1]+1 if _n!=1
// by id year quarter: drop if state_ranking<=state_ranking[_n-1]&dups>0
// * Extremes cases, keep last:
// by id year quarter: keep if _n == _N

* Finally, format time
gen time = yq(year,quarter)
order time,after(id)
format time %tq

drop Q1 Q2 Q3 Q4  qrt_ext

*** U0s **************************************************************

gen ext_q = qofd(ext_dt)
replace state="0" if ext_q<time&state=="U"

by id: gen flow = state+state[_n+1] if time+1==time[_n+1]

gen pre08 = 0
replace pre08 = 1 if time<yq(2008,1)

gen post08 = 0
replace post08 = 1 if time>=yq(2008,1)
