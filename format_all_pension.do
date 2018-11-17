
* 2005 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2005/PREANON.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2005/pension2005.dta", v(12) replace

* 2006 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2006/PREANON.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2006/pension2006.dta", v(12) replace

* 2007 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2007/PREANON.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2007/pension2007.dta", v(12) replace

* 2008 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2008/PREANON.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2008/pension2008.dta", v(12) replace

* 2009 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2009/MCVL2009PRESTAC_CDF.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2009/pension2009.dta", v(12) replace

* 2010 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2010/MCVL2010PRESTAC_CDF.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2010/pension2010.dta", v(12) replace

* 2011 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2011/MCVL2011PRESTAC_CDF.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2011/pension2011.dta", v(12) replace

* 2012 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2012/MCVL2012PRESTAC_CDF.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2012/pension2012.dta", v(12) replace

* 2013 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2013/MCVL2013PRESTAC_CDF.txt", delimiter(";")
do "./rawfiles/pension_format.do"
saveold "./rawfiles/2013/pension2013.dta", v(12) replace
