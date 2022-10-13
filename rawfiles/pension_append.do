

* New state: Retired (R)
sort id jobcount dtin
replace state = "R" if state=="" & p_type!=.
replace dtin = p_dtin if state=="R"

* Cause 58 - retirement
by id: replace state="R" if cause[_n-1]==58&state=="U"&(state[_n+1]!="P"&state[_n+1]!="T"&state[_n+1]!="A")
drop if cause==81 &state=="R"

*Adjust dates of entry to retirement: those in partial retirament count as employed
by id: replace dtin=dtout[_n-1] if cause[_n-1]==58&dtin<dtout[_n-1]&state=="R"

* Adjustment for contributive unemployment (unemployed about to retire)
by id: replace state = "R" if regi==140&(state[_n+1]=="R")

* Likely retirement - afiliated because of retirement
by id: gen diff_days_in = dtin[_n+1]-dtin
gen likely_retired = 0
by id: replace likely_retired = 1 if state[_n+1]=="R"&dtin[_n+1]<=dtout[_n]&p_type[_n+1]==3
by id: replace likely_retired=0 if abs(diff_days_in)>30
drop if likely_retired==1