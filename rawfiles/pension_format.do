* Naming variables
rename v1 id
rename v2 p_year
rename v3 p_id
rename v4 p_type
rename v5 p_situ
rename v6 disab_degree
rename v7 dtdisab
rename v8 norma_sovi
rename v9 minimun_type
rename v10 p_reg
rename v11 p_dt
rename v12 p_base
rename v13 p_perct_base
rename v14 p_bonus_years
rename v15 p_count_years
rename v16 p_inc_base
rename v17 p_inc_extra1
rename v18 p_inc_extra2
rename v19 p_inc_extra3
rename v20 p_income_m
rename v21 p_cause
rename v22 p_dtsitu
rename v23 p_region
rename v24 p_people_cause
rename v25 p_international_rate
rename v26 p_divorce_rate
rename v27 p_total_rate
rename v28 p_kind
rename v29 p_coef
rename v30 p_widow_orphan
rename v31 p_other_pension
rename v32 p_inc_extra
rename v33 p_inc_inflation
rename v34 p_income_y
capture rename v35 p_year_brth_survivor
capture rename v36 p_limit
capture rename v37 p_max_coef
capture rename v38 p_work_compatibility
capture rename v39 p_dtlegal
capture rename v40 p_years_contributed
capture rename v41 p_contribution_period
capture rename v42 p_share_contribution
capture rename v43 p_maternity_extra
capture rename v44 p_percentage_maternity_extra
capture rename v45 p_coef_parcial

* Drop variables of no interest
drop v*

* Redefine income in euros (per month)
replace p_base = p_base/100
replace p_inc_extra1 = p_inc_extra1/100
replace p_inc_extra2 = p_inc_extra2/100
replace p_inc_extra3 = p_inc_extra3/100
replace p_income = p_income/100

* Formating dates
tostring p_dt, replace format(%20.0f)
gen p_dtin = date( p_dt,"YM")
format p_dtin %td

* Reformating type of pension - no widows or orfans
replace p_type = "01" if p_type=="J1"
replace p_type = "02" if p_type=="J2"
replace p_type = "03" if p_type=="J3"
replace p_type = "04" if p_type=="J4"
replace p_type = "05" if p_type=="J5"
destring p_type, replace

drop if p_type > 29

* Only first date counts (and if it is after 2004)
drop if p_year<2004
sort id p_year
by id: drop if _n != 1

* Simplify pension formats
replace p_type = 1 if p_type==1|p_type==2|p_type==4|(p_type>=10&p_type<=12)|p_type==14
replace p_type = 2 if p_type==3|p_type==13|p_type==18
replace p_type = 3 if p_type==21
replace p_type = 4 if p_type>=22&p_type<=24
replace p_type = 5 if p_type==25

label define pension_codes 1 "Disability" ///
2 "Parcial disability" ///
3 "Retirement" ///
4 "Early Retirement" ///
5 "Parcial Retirement" ///

label values p_type pension_codes
