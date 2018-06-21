* 2005 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2005/BLOQUE5.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
destring tyco, replace
destring disabl, replace
saveold "./rawfiles/2005/fiscal05.dta", replace

* 2006 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2006/DATOS_FISCALES.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2006/fiscal06.dta", replace

* 2007 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2007/DATOS_FISCALES.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2007/fiscal07.dta", replace

* 2008 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2008/MCVL2008FISCAL_CDF.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2008/fiscal08.dta", replace

* 2009 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2009/MCVL2009FISCAL_CDF.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2009/fiscal09.dta", replace

* 2010 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2010/MCVL2010FISCAL_CDF.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2010/fiscal10.dta", replace

* 2011 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2011/MCVL2011FISCAL_CDF.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2011/fiscal11.dta", replace

* 2012 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2012/MCVL2012FISCAL_CDF.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2012/fiscal12.dta", replace

* 2013 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
import delimited "./rawfiles/2013/MCVL2013FISCAL_CDF.txt", delimiter(";") 
do "./rawfiles/fiscal_format.do"
saveold "./rawfiles/2013/fiscal13.dta", replace
