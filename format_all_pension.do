* FORMAT PENSION FILES * * * * * * * * * * * * * * * * * * * * * * * * * * 

* Old style: 2005-2008
forvalues yy=2006/2008 {
	local y =  substr("`yy'",3,4)
	clear
	insheet using "./rawfiles/`yy'/PREANON.trs", delimiter(";")
	do "./rawfiles/pension_format.do"
	save "./rawfiles/`yy'/pension`y'.dta", replace
}

* New style: 2009-2020
forvalues yy=2009/2020 {
	local y =  substr("`yy'",3,4)
	clear
	insheet using "./rawfiles/`yy'/MCVL`yy'PRESTAC_CDF.txt", delimiter(";")
	do "./rawfiles/pension_format.do"
	save "./rawfiles/`yy'/pension`y'.dta", replace
}

* * * * * * * * * * * * * * * * * * * * * * * * * * * 