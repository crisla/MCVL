
quietly do "./format_all_personal.do"

* 2005 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear 
insheet using "./rawfiles/2005/AFILANON1.txt", delimiter(";")
save "./rawfiles/2005/afilianon051.dta", replace
clear
insheet using "./rawfiles/2005/AFILANON2.txt", delimiter(";")
save "./rawfiles/2005/afilianon052.dta", replace
clear
insheet using "./rawfiles/2005/AFILANON3.txt", delimiter(";")
save "./rawfiles/2005/afilianon053.dta", replace
clear
use "./rawfiles/2005/afilianon051.dta"
append using "./rawfiles/2005/afilianon052.dta"
append using "./rawfiles/2005/afilianon053.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2005/personal05.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2005.dta", version (13) replace

* 2006 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2006/AFILANON1.txt", delimiter(";")
save "./rawfiles/2006/afilianon061.dta", replace
clear
insheet using "./rawfiles/2006/AFILANON2.txt", delimiter(";")
save "./rawfiles/2006/afilianon062.dta", replace
clear
insheet using "./rawfiles/2006/AFILANON3.txt", delimiter(";")
save "./rawfiles/2006/afilianon063.dta", replace
clear
use "./rawfiles/2006/afilianon061.dta"
append using "./rawfiles/2006/afilianon062.dta"
append using "./rawfiles/2006/afilianon063.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2006/personal06.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2006.dta", version (13) replace

* 2007 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2007/AFILANON1.txt", delimiter(";")
save "./rawfiles/2007/afilianon071.dta", replace
clear
insheet using "./rawfiles/2007/AFILANON2.txt", delimiter(";")
save "./rawfiles/2007/afilianon072.dta", replace
clear
insheet using "./rawfiles/2007/AFILANON3.txt", delimiter(";")
save "./rawfiles/2007/afilianon073.dta", replace
clear
use "./rawfiles/2007/afilianon071.dta"
append using "./rawfiles/2007/afilianon072.dta"
append using "./rawfiles/2007/afilianon073.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2007/personal07.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2007.dta", version (13) replace

* 2008 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2008/MCVL2008AFILIAD1_CDF.txt", delimiter(";")
save "./rawfiles/2008/afilianon081.dta", replace
clear
insheet using "./rawfiles/2008/MCVL2008AFILIAD2_CDF.txt", delimiter(";")
save "./rawfiles/2008/afilianon082.dta", replace
clear
insheet using "./rawfiles/2008/MCVL2008AFILIAD3_CDF.txt", delimiter(";")
save "./rawfiles/2008/afilianon083.dta", replace
clear
use "./rawfiles/2008/afilianon081.dta"
append using "./rawfiles/2008/afilianon082.dta"
append using "./rawfiles/2008/afilianon083.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2008/personal08.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2008.dta", version (13) replace

* 2009 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2009/MCVL2009AFILIAD1_CDF.txt", delimiter(";")
save "./rawfiles/2009/afilianon091.dta", replace
clear
insheet using "./rawfiles/2009/MCVL2009AFILIAD2_CDF.txt", delimiter(";")
save "./rawfiles/2009/afilianon092.dta", replace
clear
insheet using "./rawfiles/2009/MCVL2009AFILIAD3_CDF.txt", delimiter(";")
save "./rawfiles/2009/afilianon093.dta", replace
clear
use "./rawfiles/2009/afilianon091.dta"
append using "./rawfiles/2009/afilianon092.dta"
append using "./rawfiles/2009/afilianon093.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2009/personal09.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2009.dta", version (13) replace

* 2010 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2010/MCVL2010AFILIAD1_CDF.txt", delimiter(";")
save "./rawfiles/2010/afilianon101.dta", replace
clear
insheet using "./rawfiles/2010/MCVL2010AFILIAD2_CDF.txt", delimiter(";")
save "./rawfiles/2010/afilianon102.dta", replace
clear
insheet using "./rawfiles/2010/MCVL2010AFILIAD3_CDF.txt", delimiter(";")
save "./rawfiles/2010/afilianon103.dta", replace
clear
use "./rawfiles/2010/afilianon101.dta"
append using "./rawfiles/2010/afilianon102.dta"
append using "./rawfiles/2010/afilianon103.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2010/personal10.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2010.dta", version (13) replace

* 2011 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2011/MCVL2011AFILIAD1_CDF.txt", delimiter(";")
save "./rawfiles/2011/afilianon111.dta", replace
clear
insheet using "./rawfiles/2011/MCVL2011AFILIAD2_CDF.txt", delimiter(";")
save "./rawfiles/2011/afilianon113.dta", replace
clear
insheet using "./rawfiles/2011/MCVL2011AFILIAD3_CDF.txt", delimiter(";")
save "./rawfiles/2011/afilianon113.dta", replace
clear
use "./rawfiles/2011/afilianon111.dta"
append using "./rawfiles/2011/afilianon113.dta"
append using "./rawfiles/2011/afilianon113.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2011/personal11.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2011.dta", version (13) replace

* 2012 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2012/MCVL2012AFILIAD1_CDF.txt", delimiter(";")
save "./rawfiles/2012/afilianon121.dta", replace
clear
insheet using "./rawfiles/2012/MCVL2012AFILIAD2_CDF.txt", delimiter(";")
save "./rawfiles/2012/afilianon122.dta", replace
clear
insheet using "./rawfiles/2012/MCVL2012AFILIAD3_CDF.txt", delimiter(";")
save "./rawfiles/2012/afilianon123.dta", replace
clear
use "./rawfiles/2012/afilianon121.dta"
append using "./rawfiles/2012/afilianon122.dta"
append using "./rawfiles/2012/afilianon123.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2012/personal12.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2013.dta", version (13) replace

* 2013 * * * * * * * * * * * * * * * * * * * * * * * * * * 
clear
insheet using "./rawfiles/2013/MCVL2013AFILIAD1_CDF.txt", delimiter(";")
save "./rawfiles/2013/afilianon131.dta", replace
clear
insheet using "./rawfiles/2013/MCVL2013AFILIAD2_CDF.txt", delimiter(";")
save "./rawfiles/2013/afilianon132.dta", replace
clear
insheet using "./rawfiles/2013/MCVL2013AFILIAD3_CDF.txt", delimiter(";")
save "./rawfiles/2013/afilianon133.dta", replace
clear
insheet using "./rawfiles/2013/MCVL2013AFILIAD4_CDF.txt", delimiter(";")
save "./rawfiles/2013/afilianon134.dta", replace
clear
use "./rawfiles/2013/afilianon131.dta"
append using "./rawfiles/2013/afilianon132.dta"
append using "./rawfiles/2013/afilianon133.dta"
append using "./rawfiles/2013/afilianon134.dta"

do "./rawfiles/format_afilianon.do"

* Add personal file
merge m:1 id using "./rawfiles/2013/personal13.dta"
drop if _merge==2
drop _merge

saveold "./rawfiles/afilianon2013.dta", version (12) replace
