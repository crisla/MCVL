******************************************************************************
* PATCHWORK FILE - PREP FOR PANEL - ONE FILE VERSION
******************************************************************************
clear

global path = "C:\Users\clm96\Documents\Research\MCVL"
cd $path

* 1. Load up your file
******************************************************************************

* Select latest year in sample
global end_year = 2020

* Select first year for panel
* WARNING: The further back in the past, the less representative the panel becomes.
* Use Patchwork_prelim.do to join all files for good representativity.
global first_year = 2013

use "MCVL_${end_year}"

* Clean up unuseful variables
drop p_*
drop ind_dummy*


* 2 Panellise
******************************************************************************

* Drop observations outside the window
drop if year(dtout)<$first_year

* Year consistent with panel
gen year = year(dtout)

* Panelize - extend spell for each year that it lasts
gen newobs = 0
replace newobs = year-max(year(dtin),$first_year) if year>$first_year

expand newobs+1, gen(new_panel_obs)

sort id jobcount dtin dtout new_panel_obs
by id jobcount: replace year = max(year(dtin),$first_year) if new_panel_obs==0&new_panel_obs[_n+1]==1
by id jobcount: replace year = year[_n-1]+1 if new_panel_obs==1

* Keep track of original dates of start and exit
gen dtin_org = dtin
gen dtout_org = dtout

* Change dates of start and exit
by id jobcount: replace dtout = mdy(12,31,year) if newobs>0&year<year(dtout)
by id jobcount: replace dtin = mdy(1,1,year) if newobs>0&year>year(dtin)&year>$first_year

* Save space
compress

* Quarterly panel
do "./panel/quarterly_panel.do"

* Save
save "MCVL_panelQ_${first_year}${end_year}"




