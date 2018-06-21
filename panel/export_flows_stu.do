


* Stocks * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
log using stocks_ss_all.smcl,replace
tab time state
log close
translate stocks_ss_all.smcl stocks_ss_all.log,replace

// * Stocks (by age) - pre 2008
// log using stocks_ss_age_all.smcl,replace
// tab age state if age>19&age<61&post08==0&state!="R"&state!="A"
// log close
// translate stocks_ss_age_all.smcl stocks_ss_age_m.log,replace
//
// * Stocks (by age) - post 2008
// log using stocks_ss_age_bad.smcl,replace
// tab age state if age>19&age<61&post08==1&state!="R"&state!="A"
// log close
// translate stocks_ss_age_bad.smcl stocks_ss_age_bad.log,replace

* Stocks by age groups
log using stocks_ss_age_all.smcl,replace
tab time state if age>16&age<=30
tab time state if age>30&age<=50
tab time state if age>50&age<=65
log close
translate stocks_ss_age_all.smcl stocks_ss_age_all.log,replace

* Stocks by sex
log using stocks_ss_sex_all.smcl,replace
tab time state if sex==1
tab time state if sex==2
log close
translate stocks_ss_sex_all.smcl stocks_ss_sex_all.log,replace

* Flows (by state) * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
log using flows_ss_u_all.smcl,replace
tab time flow if state=="U"&length(flow)==2
log close
translate flows_ss_u_all.smcl flows_ss_u_all.log,replace

log using flows_ss_t_all.smcl,replace
tab time flow if state=="T"&length(flow)==2
log close
translate flows_ss_t_all.smcl flows_ss_t_all.log,replace

log using flows_ss_p_all.smcl,replace
tab time flow if state=="P"&length(flow)==2
log close
translate flows_ss_p_all.smcl flows_ss_p_all.log,replace

log using flows_ss_0_all.smcl,replace
tab time flow if state=="0"&length(flow)==2
log close
translate flows_ss_0_all.smcl flows_ss_0_all.log,replace

* Flows (by state and age) * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Pre 2008
// log using flows_age_all.smcl,replace
// foreach s in "0" "P" "T" "U"{
//  	tab age flow if age>19&age<61&state=="`s'"&post08==0
//  }
//  *
//  log close
//  translate flows_age_all.smcl flows_age_q.log,replace
//
//  * Post 2008
// log using flows_age_bad.smcl,replace
// foreach s in "0" "P" "T" "U"{
//  	tab age flow if age>19&age<61&state=="`s'"&post08==1
//  }
//  *
//  log close
//  translate flows_age_bad.smcl flows_age_bad_q.log,replace
*
