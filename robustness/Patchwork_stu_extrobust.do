***********************************************************
* Patchwork STU expansion - expansion robustness check
***********************************************************
use "../Patchwork_midpoint.dta", clear

* Sample Selection ***********************************************************

* Uncomment your option:

* OPTION 1: include obs from 2003 onwards. Lighter version.

* Include 2003
by id: drop if dtout[_n+1]<td(01jan2003)
replace year = 2004 if dtout<td(01jan2005)
expand 2 if dtout>td(01jan2005)&dtin<td(01jan2005)&year==2005, gen(y04)
replace year=2004 if y04==1
drop y04
drop if state ==""

replace year = 2003 if dtout<td(01jan2004)
expand 2 if dtout>td(01jan2004)&dtin<td(01jan2004)&year==2004, gen(y03)
replace year=2003 if y03==1
drop y03
drop if state ==""

gen old_obs = 0

* If you are keeping the sample from 2004/2003 onwards:
replace old_obs = 1 if year(dtout)<2003
replace old_obs = 1 if year(dtout)<2003

* OPTION 2 : include all observations. May be more innacurate the further back it's used.

// gen old_obs = 0
// * Change year (necessary for expansion to work right)
// replace year = year(dtout) if year(dtout)<2005
// replace old_obs = 1 if year(dtout)<2005

saveold "./MCVL0313_stu.dta", replace version(12)
* Robustness checks
******************************************************************************
* 2 years
quietly do "./coru_stu_rob2y.do"
drop if dtout<td(01jan2003)
quietly do  "../panel/quarterly_panel_U0.do"
do "./panel/robustness/export_flows_stu_y2.do"

* 4 years
use "./MCVL0313_stu.dta", clear
quietly do "./coru_stu_rob4y.do"
drop if dtout<td(01jan2003)
quietly do  "../panel/quarterly_panel_U0.do"
do "./panel/robustness/export_flows_stu_y4.do"

* 5 years
use "./MCVL0313_stu.dta", clear
quietly do "./coru_stu_rob5y.do"
drop if dtout<td(01jan2003)
quietly do  "../panel/quarterly_panel_U0.do"
do "./panel/robustness/export_flows_stu_y5.do"

* 10 years
use "./MCVL0313_stu.dta", clear
quietly do "./coru_stu_rob10y.do"
drop if dtout<td(01jan2003)
quietly do  "../panel/quarterly_panel_U0.do"
do "./panel/robustness/export_flows_stu_y10.do"
