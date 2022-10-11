
* FORMAT PERSONAL FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 

* Old style: 2005-2008
forvalues yy=2006/2008 {
	local y =  substr("`yy'",3,4)
	di `y'
	clear
	insheet using "./rawfiles/`yy'/PERSANON.trs", delimiter(";")
	do "./rawfiles/personal_format.do"
	save "./rawfiles/`yy'/personal`y'.dta", replace
}

* New style: 2009-2020
forvalues yy=2009/2020 {
	local y =  substr("`yy'",3,4)
	di `y'
	clear
	insheet using "./rawfiles/`yy'/MCVL`yy'PERSONAL_CDF.txt", delimiter(";")
	do "./rawfiles/personal_format.do"
	save "./rawfiles/`yy'/personal`y'.dta", replace
}

* * * * * * * * * * * * * * * * * * * * * * * * * * 