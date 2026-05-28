******************************************************************************
* FINE PANEL FILE
******************************************************************************
* Please make sure you have run main_panel.do first

* Select start and end years (make sure the end year is defined the same way as the "./MCVL${end_year}.dta", replace)
global start_year = 2016
global end_year = 2023

* Load file
use "./MCVL_${end_year}.dta", clear

* Dropping old observations
drop if dtout<td(01jan${start_year})
// replace year = ${start_year} if dtout<=td(31dec${start_year})&dtout!=.
replace year = ${start_year} if dtin<td(01jan${start_year})&dtin!=.

* Panel flavour *********************************************

* Options: monthly or quaterly.
* WARNING: if you use the monthly panel, this can take a lot of space (it is not optimized yet)
* For this reason, quaterly is the default
global freq "quarterly"

* Option: label your flows_m
* I like to label them depending on the unemployment expansion flavour. This is entirely optional

global flabel "stu"

* Option: If you picked the stu expansion, you can additionally choose to record 
* non-register unemployment separately into state "U0". If not interested, change to blank

global record_u_separate "yes"

* Panelisation
if "$record_u_separate" == "yes"{
	do  "./panel/${freq}_panel_U0.do"
}
else {
	do  "./panel/${freq}_panel.do"
}


* That's it! check the panel
tab time state

* Export Flows if you like 
do "./panel/export_flows.do"

**********************************************************************
**********************************************************************
