

* FORMAT ALL FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 


* First, formal the personal file, containing all the demographic variables
* -------------------------------------------------------------------------

forvalues yy= $start_year / $end_year {
	local y =  substr("`yy'",3,4)
	
	* First check we have not been here before
	capture confirm file "./rawfiles/afilianon`yy'.dta"
	if _rc != 0 {
      clear 
	
	* FORMAT PERSONAL FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 
	capture confirm file "./rawfiles/`yy'/personal`y'.dta"
	if _rc != 0 {
      clear 
	  
	  if inrange(`yy', 2006, 2008) {
		insheet using "./rawfiles/`yy'/PERSANON.trs", delimiter(";")
		quietly do "./rawfiles/personal_format.do"
		save "./rawfiles/`yy'/personal`y'.dta", replace
	  }
	  else {
	  	insheet using "./rawfiles/`yy'/MCVL`yy'PERSONAL_CDF.txt", delimiter(";")
		quietly do "./rawfiles/personal_format.do"
		save "./rawfiles/`yy'/personal`y'.dta", replace
	  }
  }
	else {
      display "Personal file for `yy' already exists, skipping."
  }

  
  * FORMAT PENSION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 
  capture confirm file "./rawfiles/`yy'/pension`y'.dta"
	if _rc != 0 {
      clear 
	  
	  if inrange(`yy', 2006, 2008) {
		insheet using "./rawfiles/`yy'/PREANON.trs", delimiter(";")
		quietly do "./rawfiles/pension_format.do"
		save "./rawfiles/`yy'/pension`y'.dta", replace
	  }
	  
	  else {
	  	insheet using "./rawfiles/`yy'/MCVL`yy'PRESTAC_CDF.txt", delimiter(";")
		if `yy' < 2017{
			quietly do "./rawfiles/pension_format.do"
		}
		else {
			quietly do "./rawfiles/pension_format17.do"
		}
		
		save "./rawfiles/`yy'/pension`y'.dta", replace
	  }
  }
	else {
      display "Pension file for `yy' already exists, skipping."
  }

  
  * FORMAT AFILIATION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 
	* Now with afiliation file
	  
	  if inrange(`yy', 2006, 2008) {
	  	* 3 pieces
		forvalues i=1/3{
			clear 
			insheet using "./rawfiles/`yy'/AFILANON`i'.trs", delimiter(";")
			save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
			}
		* Append all pieces
		use "./rawfiles/`yy'/afilianon`y'1.dta"
		forvalues i=2/3{		
			append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
			}
	  }
	  
	  else if inrange(`yy', 2009, 2012) {
		*3 pieces, different format
		forvalues i=1/3{
			clear 
			insheet using "./rawfiles/`yy'/MCVL`yy'AFILIAD`i'_CDF.txt", delimiter(";")
			save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
			}
		* Append all pieces
		use "./rawfiles/`yy'/afilianon`y'1.dta"
		forvalues i=2/3{		
			append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
			}
	  }
		
	  else {
		* 4 pieces, new format
		forvalues i=1/4{
			clear 
			insheet using "./rawfiles/`yy'/MCVL`yy'AFILIAD`i'_CDF.txt", delimiter(";")
			save "./rawfiles/`yy'/afilianon`y'`i'.dta", replace
		}
		* Append all pieces
		use "./rawfiles/`yy'/afilianon`y'1.dta"
		forvalues i=2/4{		
			append using "./rawfiles/`yy'/afilianon`y'`i'.dta"
			}			
		}
	
		
	* Big format
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
  
  else {
      display "Afiliation file for `yy' already exists, skipping."
  }
  
  * Clean up
  if inrange(`yy', 2006, 2008) {
	  	* 3 pieces
		forvalues i=1/3{
			erase "./rawfiles/`yy'/afilianon`y'`i'.dta"
			}
  }
	else{
		forvalues i=1/4{
			erase "./rawfiles/`yy'/afilianon`y'`i'.dta"
		}
	}
  
  display "Year `yy' Done."
  
  // end of year loop
  
}

