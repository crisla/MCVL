
* Stocks * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
log using stocks_ss_none_Q2.log,replace
tab time state
log close

// * Stocks (by age) - pre 2008
// log using stocks_ss_age_none.smcl,replace
// tab age state if age>19&age<61&post08==0&state!="R"&state!="A"
// log close
// translate stocks_ss_age_none.smcl stocks_ss_age_m.log,replace
//
// * Stocks (by age) - post 2008
// log using stocks_ss_age_bad.smcl,replace
// tab age state if age>19&age<61&post08==1&state!="R"&state!="A"
// log close
// translate stocks_ss_age_bad.smcl stocks_ss_age_bad.log,replace

replace age = year - year(dtbirth)
* Stocks by age groups
log using stocks_ss_age_none_Q2.log,replace
tab time state if age>16&age<=30
tab time state if age>30&age<=50
tab time state if age>50&age<=65
log close

* Stocks by sex
log using stocks_ss_sex_none_Q2.log,replace
tab time state if sex==1
tab time state if sex==2
log close

* Flows (by state) * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
log using flows_ss_u_none_Q2.log,replace
tab time flow if state=="U"&length(flow)==2
log close

log using flows_ss_t_none_Q2.log,replace
tab time flow if state=="T"&length(flow)==2
log close

log using flows_ss_p_none_Q2.log,replace
tab time flow if state=="P"&length(flow)==2
log close

log using flows_ss_0_none_Q2.log,replace
tab time flow if state=="0"&length(flow)==2
log close

* Flows (by state and age) * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Pre 2008
// log using flows_age_none08.log,replace
// foreach s in "0" "P" "T" "U"{
//  	tab age flow if age>19&age<61&state=="`s'"
//  }
//  *
//  log close

//
//  * Post 2008
// log using flows_age_bad.smcl,replace
// foreach s in "0" "P" "T" "U"{
//  	tab age flow if age>19&age<61&state=="`s'"&post08==1
//  }
//  *
//  log close
//  translate flows_age_bad.smcl flows_age_bad_Q2.log,replace
*
