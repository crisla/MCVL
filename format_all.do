

* FORMAT AFILIATION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 

quietly do "./format_all_personal.do"


* Old style: 2005-2008
forvalues yy=2006/2008 {
	local y =  substr("`yy'",3,4)
	forvalues i=1/3{
		clear 
		insheet using "./rawfiles/`yy'/AFILANON`i'.txt", delimiter(";")
		save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
	}
	use "./rawfiles/`yy'/afilianon`y'1.dta"
	forvalues i=2/3{		
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
	}
	do "./rawfiles/format_afilianon.do"
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge

	saveold "./rawfiles/afilianon`yy'.dta", version (13) replace
}

* New Style, 3 files: 2009-2012
forvalues yy=2010/2012 {
	local y =  substr("`yy'",3,4)
	forvalues i=1/3{
		clear 
		insheet using "./rawfiles/`yy'/MCVL`yy'AFILIAD`i'_CDF.txt", delimiter(";")
		save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
	}
	use "./rawfiles/`yy'/afilianon`y'1.dta"
	forvalues i=2/3{		
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
	}
	quietly do "./rawfiles/format_afilianon.do"
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge

	saveold "./rawfiles/afilianon`yy'.dta", version (13) replace
}

* New Style, 4 files: 2013-2020
forvalues yy=2012/2020 {
	local y =  substr("`yy'",3,4)
	forvalues i=1/4{
		clear 
		insheet using "./rawfiles/`yy'/MCVL`yy'AFILIAD`i'_CDF.txt", delimiter(";")
		save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
	}
	use "./rawfiles/`yy'/afilianon`y'1.dta"
	forvalues i=2/3{		
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
		append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
	}
	quietly do "./rawfiles/format_afilianon.do"
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge

	saveold "./rawfiles/afilianon`yy'.dta", version (13) replace
}

* * * * * * * * * * * * * * * * * * * * * * * * * * * 

