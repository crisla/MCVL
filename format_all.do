

* FORMAT AFILIATION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 

* First, formal the personal file, containing all the demographic variables
* -------------------------------------------------------------------------
// quietly do "./format_all_personal.do"

* Second, read and format afiliation files, depending on the flavour
* -------------------------------------------------------------------------
* Old style: 2005-2008
forvalues yy=2006(2)2008 {
	local y =  substr("`yy'",3,4)
	forvalues i=1/3{
		clear 
		insheet using "./rawfiles/`yy'/AFILANON`i'.trs", delimiter(";")
		save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
	}
	use "./rawfiles/`yy'/afilianon`y'1.dta"
	forvalues i=2/3{		
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
	}
	do "./rawfiles/format_afilianon.do"
	
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge
	
	* Add pension file
	append using using "./rawfiles/`yy'/pension`y'.dta"
	drop if _merge==2
	drop _merge	
	
	* Tie up the pension file to the afiliation file
	quietly do "./rawfiles/pension_append.do"
	
	* Changing the end dates of retirement: death
	by id: replace death=death[_n-1] if death==.
	tostring death, replace
	replace dtout = date(death,"YM") if dtout==.
	* Changing the end dates of retirement: ongoing
	replace dtout = td(31dec`yy') if dtout==.
	by id: replace year=year[_n-1] if year==.

	saveold "./rawfiles/afilianon`yy'.dta", version (13) replace
}

* New Style, 3 files: 2009-2012
forvalues yy=2011/2012 {
	local y =  substr("`yy'",3,4)
	forvalues i=1/3{
		clear 
		insheet using "./rawfiles/`yy'/MCVL`yy'AFILIAD`i'_CDF.txt", delimiter(";")
		save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
	}
	use "./rawfiles/`yy'/afilianon`y'1.dta"
	forvalues i=2/3{		
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
	}
	quietly do "./rawfiles/format_afilianon.do"
	
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge
	
	* Add pension file
	append using using "./rawfiles/`yy'/pension`y'.dta"
	drop if _merge==2
	drop _merge	
	
	* Tie up the pension file to the afiliation file
	quietly do "./rawfiles/pension_append.do"
	
	* Changing the end dates of retirement: death
	by id: replace death=death[_n-1] if death==.
	tostring death, replace
	replace dtout = date(death,"YM") if dtout==.
	* Changing the end dates of retirement: ongoing
	replace dtout = td(31dec`yy') if dtout==.
	by id: replace year=year[_n-1] if year==.

	saveold "./rawfiles/afilianon`yy'.dta", version (13) replace
}

* New Style, 4 files: 2013-2020
forvalues yy=2013/2020 {
	local y =  substr("`yy'",3,4)
	forvalues i=1/4{
		clear 
		insheet using "./rawfiles/`yy'/MCVL`yy'AFILIAD`i'_CDF.txt", delimiter(";")
		save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
	}
	use "./rawfiles/`yy'/afilianon`y'1.dta"
	forvalues i=2/4{		
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
	}
	quietly do "./rawfiles/format_afilianon.do"
	
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge
	
	* Add pension file
	append using using "./rawfiles/`yy'/pension`y'.dta"
	drop if _merge==2
	drop _merge	
	
	* Tie up the pension file to the afiliation file
	quietly do "./rawfiles/pension_append.do"
	
	* Changing the end dates of retirement: death
	by id: replace death=death[_n-1] if death==.
	tostring death, replace
	replace dtout = date(death,"YM") if dtout==.
	* Changing the end dates of retirement: ongoing
	replace dtout = td(31dec`yy') if dtout==.
	by id: replace year=year[_n-1] if year==.

	saveold "./rawfiles/afilianon`yy'.dta", version (13) replace
}

* * * * * * * * * * * * * * * * * * * * * * * * * * * 

