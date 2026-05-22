

* FORMAT AFILIATION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 

* First, formal the personal file, containing all the demographic variables
* -------------------------------------------------------------------------

// capture confirm file "path/to/file.dta"
//   if _rc != 0 {
//       * File does NOT exist — run your formatting code here
//       ...
//       save "path/to/file.dta"
//   }
//   else {
//       display "File already exists, skipping."
//   }
//
//   capture confirm file tries to confirm the file exists. If it doesn't, Stata sets _rc to a non-zero return code
//   (typically 601). If the file exists, _rc is 0.
//
//   For your loop structure in format_all.do, it would look like:
//
//   forvalues yy=2006/2008 {
//       local y = substr("`yy'",3,4)
//
//       capture confirm file "./formatted/afilianon`y'.dta"
//       if _rc != 0 {
//           * File doesn't exist, format it
//           forvalues i=1/3 {
//               ...
//           }
//           save "./formatted/afilianon`y'.dta"
//       }
//   }

* Old style: 2006-2008
forvalues yy=2006/2008 {
	local y =  substr("`yy'",3,4)
	di `y'
	clear
	insheet using "./rawfiles/`yy'/PERSANON.trs", delimiter(";")
	do "./rawfiles/personal_format.do"
	save "./rawfiles/`yy'/personal`y'.dta", replace
}

* New style: 2009-
forvalues yy=2009/$end_year {
	local y =  substr("`yy'",3,4)
	di `y'
	clear
	insheet using "./rawfiles/`yy'/MCVL`yy'PERSONAL_CDF.txt", delimiter(";")
	do "./rawfiles/personal_format.do"
	save "./rawfiles/`yy'/personal`y'.dta", replace
}


* FORMAT PENSION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 

* Old style: 2006-2008
forvalues yy=2006/2008 {
	local y =  substr("`yy'",3,4)
	clear
	insheet using "./rawfiles/`yy'/PREANON.trs", delimiter(";")
	quietly do "./rawfiles/pension_format.do"
	save "./rawfiles/`yy'/pension`y'.dta", replace
}

* New style: 2009-
forvalues yy=2009/$end_year {
	local y =  substr("`yy'",3,4)
	clear
	insheet using "./rawfiles/`yy'/MCVL`yy'PRESTAC_CDF.txt", delimiter(";")
	quietly do "./rawfiles/pension_format.do"
	save "./rawfiles/`yy'/pension`y'.dta", replace
}

* Second, read and format afiliation files, depending on the flavour
* -------------------------------------------------------------------------
* Old style: 2006-2008
* * * * * * * * * * * * * * 
forvalues yy=2006/2008 {
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
	quietly do "./rawfiles/format_afilianon.do"
	
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge
	
	* Add pension file
	append using "./rawfiles/`yy'/pension`y'.dta"
	
	* Tie up the pension file to the afiliation file
	quietly do "./rawfiles/pension_append.do"
	
	* Changing the end dates of retirement: death
	by id: replace death=death[_n-1] if death==.
	tostring death, replace
	replace dtout = date(death,"YM") if dtout==.
	* Changing the end dates of retirement: ongoing
	replace dtout = td(31dec`yy') if dtout==.
// 	by id: replace year=year[_n-1] if year==.

	save "./rawfiles/afilianon`yy'.dta", replace
}

* New Style, 3 files: 2009-2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * 
forvalues yy=2009/2012 {
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
	append using "./rawfiles/`yy'/pension`y'.dta"

	* Tie up the pension file to the afiliation file
	quietly do "./rawfiles/pension_append.do"
	
	* Changing the end dates of retirement: death
	by id: replace death=death[_n-1] if death==.
	tostring death, replace
	replace dtout = date(death,"YM") if dtout==.
	* Changing the end dates of retirement: ongoing
	replace dtout = td(31dec`yy') if dtout==.
// 	by id: replace year=year[_n-1] if year==.

	save "./rawfiles/afilianon`yy'.dta", replace
}

* New Style, 4 files: 2013-
* * * * * * * * * * * * * * * * * * * * * * * * * * * * 
forvalues yy=2013/2021 {
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
	
	* Record ERTEs within the employment spell
	if `yy'>=2020 {
		quietly do "./rawfiles/format_afilianon_2020.do"		
	}
	else {
		quietly do "./rawfiles/format_afilianon.do"		
	}
	
	
	* Add personal file
	merge m:1 id using "./rawfiles/`yy'/personal`y'.dta"
	drop if _merge==2
	drop _merge
	
	* Add pension file
	append using  "./rawfiles/`yy'/pension`y'.dta"
	
	* Tie up the pension file to the afiliation file
	quietly do "./rawfiles/pension_append.do"
	
	* Changing the end dates of retirement: death
	by id: replace death=death[_n-1] if death==.
	tostring death, replace
	replace dtout = date(death,"YM") if dtout==.
	* Changing the end dates of retirement: ongoing
	replace dtout = td(31dec`yy') if dtout==.
// 	by id: replace year=year[_n-1] if year==.

	save "./rawfiles/afilianon`yy'.dta", replace
}

* * * * * * * * * * * * * * * * * * * * * * * * * * * 
