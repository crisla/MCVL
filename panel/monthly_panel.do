
*** Panellize **************************************************************

* Make sure observations are indeed censored
*drop year_s
tostring year,gen(year_s)
replace dtout = date("31jan"+year_s,"DMY") if dtout < date("31jan"+year_s,"DMY")

forvalues i = 1(1)12 {
     gen dtoutM`i' =  date("01"+"/"+"`i'"+"/"+year_s,"DMY")
     gen dtinM`i' =  date("15"+"/"+"`i'"+"/"+year_s,"DMY")
     format dtoutM`i' %td
     format dtinM`i' %td
     gen M`i' = 0
}

// gen dtoutQ1 = date("01jan"+year_s,"DMY")
// gen dtoutQ2 = date("01apr"+year_s,"DMY")
// gen dtoutQ3 = date("01jul"+year_s,"DMY")
// gen dtoutQ4 = date("01oct"+year_s,"DMY")
//
// gen dtinQ1 = date("15jan"+year_s,"DMY")
// gen dtinQ2 = date("15apr"+year_s,"DMY")
// gen dtinQ3 = date("15jul"+year_s,"DMY")
// gen dtinQ4 = date("15oct"+year_s,"DMY")

// gen Q1 = 0
// gen Q2 = 0
// gen Q3 = 0
// gen Q4 = 0


sort id year jobcount dtin
forvalues i = 1(1)12 {
by id year: replace M`i' = 1 if dtin<=dtinM`i'&dtout>dtoutM`i'
}
*


* Cleaning
drop dtinM* dtoutM*

gen no_months= M1+M2+M3+M4+M5+M6+M7+M8+M9+M10+M11+M12
expand no_months, gen(mth_ext)

sort id year jobcount dtin mth_ext
gen month = . 
forvalues i = 1(1)12 {
     replace month = `i' if mth_ext==0&M`i'==1&month==.
}
*
by id year: replace month = month[_n-1]+1 if mth_ext>0

* Drop in-between quarter observations
drop if month==.

order month,after(year)

* Choosing among duplicates
sort id year month jobcount dtin
gen dups = 0
by id year month: replace dups = dups[_n-1]+1 if _n!=1

* My criterion is going to be: last observation stays in *
by id year month: keep if _n == _N

drop dup

gen time = ym(year,month)
order time,after(id)
format time %tm

drop M* mth_ext

*** U0s **************************************************************

gen ext_m = mofd(ext_dt)
replace state="0" if ext_m<time

by id: gen flow = state+state[_n+1] if time+1==time[_n+1]

gen pre08 = 0
replace pre08 = 1 if time<ym(2008,1)

gen post08 = 0
replace post08 = 1 if time>=ym(2008,1)
