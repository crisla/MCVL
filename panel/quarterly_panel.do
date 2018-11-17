
*** Panellize **************************************************************

* Make sure observations are indeed censored
*drop year_s
tostring year,gen(year_s)
*replace dtout = date("31jan"+year_s,"DMY") if dtout < date("31jan"+year_s,"DMY")


gen dtoutQ1 = date("01jan"+year_s,"DMY")
gen dtoutQ2 = date("01apr"+year_s,"DMY")
gen dtoutQ3 = date("01jul"+year_s,"DMY")
gen dtoutQ4 = date("01oct"+year_s,"DMY")

gen dtinQ1 = date("15jan"+year_s,"DMY")
gen dtinQ2 = date("15apr"+year_s,"DMY")
gen dtinQ3 = date("15jul"+year_s,"DMY")
gen dtinQ4 = date("15oct"+year_s,"DMY")

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

sort id year jobcount dtin qrt_ext
gen quarter = . 
foreach i in "1" "2" "3" "4" {
     replace quarter = `i' if qrt_ext==0&Q`i'==1&quarter==.
}
*
by id year: replace quarter = quarter[_n-1]+1 if qrt_ext>0

* Drop in-between quarter observations
drop if quarter==.

order quarter,after(year)

* Choosing among duplicates
sort id year quarter jobcount dtin
gen dups = 0
by id year quarter: replace dups = dups[_n-1]+1 if _n!=1

* My criterion is going to be: last observation stays in *
by id year quarter: keep if _n == _N

drop dup

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
