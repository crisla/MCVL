
************************* 2.1 Naming variables *****************************

* To know what do they mean, please read the official variable file included *

rename v1 id
rename v2 birth
rename v3 sex
rename v4 nationality
rename v5 birth_region
rename v6 first_job_region
rename v7 living_region
rename v8 death
rename v9 country_birth
rename v10 education
drop v11


gen dtbirth = date( birth,"YM")
format dtbirth %td
gen age = (td(01jan2004) - dtbirth)/365

************************* 2.2 Atack of the clones **************************
sort id
gen clone =2 if id==id[_n-1]
replace clone=1 if clone[_n+1]==2
replace clone=0 if clone==.
* Same age: CLONE ZAP! *
drop if age==age[_n-1]&clone==2
replace clone=0 if clone==1&id!=id[_n+1]
* If dead, drop *
drop if death!=0 &clone!=0
replace clone=0 if clone==1&id!=id[_n+1]
replace clone=0 if clone==2&id!=id[_n-1]
* If minor, drop *
drop if clone!=0 &age<16
replace clone=0 if clone==1&id!=id[_n+1]
replace clone=0 if clone==2&id!=id[_n-1]
* Just drop all the clones left randomly *
drop if clone==2
replace clone=0 if clone==1&id!=id[_n+1]
drop if clone==1

drop clone
