use "./Patchwork_midpoint.dta", clear

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


* 3 Unemployment Expansions
******************************************************************************
* Uncomment to select your option

quietly do "./coru_none.do"		// Only registered

******************************************************************************

* 4 Making into a Panel
******************************************************************************

* Select start year

* 2004
// replace year = 2004 if dtout<td(01jan2005)&dtout!=.
// drop if dtout<td(01jan2004)

* 2003
drop if dtout<td(01jan2003)

* Panel flavour *********************************************

* Transform into quarterly panel
do  "./panel/quarterly_panel_U0.do"

* Flows
do "./panel/export_flows_none_q.do"

**********************************************************************
**********************************************************************
