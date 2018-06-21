
* Merging all fiscal files * * * * * * * * * * * * * * * * * * * * * * * * * * 

use "./rawfiles/2013/fiscal13.dta", clear
gen year = 2013

append using "./rawfiles/2012/fiscal12.dta"
replace year = 2012 if year==.

append using "./rawfiles/2011/fiscal11.dta"
replace year = 2011 if year==.

append using "./rawfiles/2010/fiscal10.dta"
replace year = 2010 if year==.

destring tyco, replace
destring disabl, replace

append using "./rawfiles/2009/fiscal09.dta"
replace year = 2009 if year==.

append using "./rawfiles/2008/fiscal08.dta"
replace year = 2008 if year==.

append using "./rawfiles/2007/fiscal07.dta"
replace year = 2007 if year==.

append using "./rawfiles/2006/fiscal06.dta"
replace year = 2006 if year==.

append using "./rawfiles/2005/fiscal05.dta"
replace year = 2005 if year==.

* Varaible adjustment * * * * * * * * * * * * * * * * * * * * * * * * * * 

tostring(firm2), gen(firm22)
gen firmID = firm1+firm22
order firmID, after(id)
sort firmID id year

drop kids*
drop grand*

sort id firmID year
by id firmID: gen years_firm = _N

gen severance =1 if key=="L"&subkey==5
replace severance =0 if severance==.

sort id firmID year
by id firmID: gen income = sum(moneyin+espec) if severance==0
by id firmID:replace income = income[_N]
gen av_income_tax = income/years_firm

gen sevpay = 0
by id firmID: replace sevpay = sum(moneyin) if severance==1
by id firmID: replace sevpay = sum(sevpay)

keep id firmID key subkey income av_income_tax sevpay year years_firm
by id firmID: keep if _n==_N

saveold "./rawfiles/wages_panel.dta", version(12) replace

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*  In case you want to keep only wages, no severance payments or anything else

// sort id firmID year
//
// drop if key!="A"
//
// by id firmID year: gen wages = sum(moneyin+espec)
// by id firmID year: replace wages = wages[_N]
//
// keep id firmID wages year
// by id firmID year: keep if _n==_N
//
// saveold "./rawfiles/wages_only_panel.dta", version(12) replace

