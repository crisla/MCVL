

* FORMAT AFILIATION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 

local y =  substr("${end_year}",3,4)

* First, formal the personal file, containing all the demographic variables
* -------------------------------------------------------------------------
clear
insheet using "./rawfiles/${end_year}/MCVL${end_year}PERSONAL_CDF.txt", delimiter(";")
do "./rawfiles/personal_format.do"
save "./rawfiles/${end_year}/personal`y'.dta", replace
	
* Then the pension file, containing retirement and pension information
* -------------------------------------------------------------------------
clear
insheet using "./rawfiles/${end_year}/MCVL${end_year}PRESTAC_CDF.txt", delimiter(";")
quietly do "./rawfiles/pension_format.do"
save "./rawfiles/${end_year}/pension`y'.dta", replace

* Second, read and format afiliation files, depending on the flavour
* -------------------------------------------------------------------------
* New Style, 4 files: 2013-2024

local y =  substr("${end_year}",3,4)
forvalues i=1/4{
	clear 
	insheet using "./rawfiles/${end_year}/MCVL${end_year}AFILIAD`i'_CDF.txt", delimiter(";")
	save "./rawfiles/${end_year}/afilianon`y'`i'.dta", replace
}

use "./rawfiles/${end_year}/afilianon`y'1.dta"
forvalues i=2/4{		
	append using "./rawfiles/${end_year}/afilianon`y'`i'.dta"
}
	
* Record ERTEs within the employment spell
quietly do "./rawfiles/format_afilianon_2020.do"		

* Add personal file
merge m:1 id using "./rawfiles/${end_year}/personal`y'.dta"
drop if _merge==2
drop _merge
	
* Add pension file
append using  "./rawfiles/${end_year}/pension`y'.dta"
	
* Tie up the pension file to the afiliation file
quietly do "./rawfiles/pension_append.do"
	
* Changing the end dates of retirement: death
by id: replace death=death[_n-1] if death==.
tostring death, replace
replace dtout = date(death,"YM") if dtout==.
* Changing the end dates of retirement: ongoing
replace dtout = td(31dec${end_year}) if dtout==.


save "./rawfiles/afilianon${end_year}.dta", replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * 