
*************************** 2.1 Naming variables ******************************

rename v1 id
rename v2 regi
rename v3 grcot
rename v4 tyco
rename v5 coef
rename v6 alta
rename v7 baja
rename v8 cause
rename v9 disab
rename v10 secon
rename v11 adress
rename v12 ind
rename v13 nwrks
rename v14 altfrst
rename v15 tyrel
rename v16 ett
rename v17 tyemp
rename v18 firm1
rename v19 firm2
rename v20 princ
rename v21 firmdrs
rename v22 mod1dt
rename v23 mod1ty
rename v24 mod1coe
rename v25 mod2dt
rename v26 mod2ty
rename v27 mod2coe
rename v28 mod1tar
rename v29 mod1cot

capture confirm variable v30
if !_rc {
                      rename v30 newind
               }

capture confirm variable v31
if !_rc {
                      rename v31 agr
               }
capture confirm variable v32
if !_rc {
                      rename v32 aut
               }
capture confirm variable v33
if !_rc {
                      rename v33 pdtin
               }
capture confirm variable v34
if !_rc {
                      rename v34 pdtout
               }


*************************** 2.2 Reading dates ******************************

* This generates the variable dtin: date of entry into the registry *
tostring alta, replace format(%20.0f)
gen dtin = date( alta,"YMD")
format dtin %td
* This generates the variable dtout: date of exit from the registry *
tostring baja, replace format(%20.0f)
gen dtout = date(baja,"YMD")
format dtout %td

****************** 2.4 Creating useful variables:	************************

** Distance variables **

* days: duration in days of the observation *
gen days = dtout-dtin+1
* cop: coeficient of part-time job (1 = full time) *
gen cop = coef/1000
replace cop = 1 if coef == 0

* Type of working hours			*
* part: full-time (1) 			*
*       part-time (2)			*
*       discontinous (0) 		*

gen part = 1 if tyco>=109&tyco<=157
replace part = 1 if tyco==100|tyco==189|tyco==101|tyco==457
replace part = 1 if tyco>=401&tyco<=451
replace part = 2 if tyco>=200&tyco<=289
replace part = 2 if tyco>=500&tyco<=557
replace part = 2 if tyco==102|tyco==3|tyco==4|tyco==6|tyco==7
replace part = 0 if tyco>=300&tyco<400
replace part = 0 if tyco>=181&tyco<=186

** Creating an labour market state variable **

gen state = "U" if tyrel>=700&tyrel<800
* Permanent
replace state = "P" if tyco>99&tyco<400
* Temporary
replace state = "T" if tyco > 400 & tyco < 900
* Self-employed
replace state = "A" if regi>500&regi<600
* Other, older temporary contracts:
replace state = "T" if tyco>=4&tyco<8
replace state = "T" if tyco>=14&tyco<18
replace state = "T" if tyco==22|(tyco>=24&tyco<28)
replace state = "T" if tyco>=34&tyco<39
replace state = "T" if tyco>=53&tyco<59
replace state = "T" if tyco==64|(tyco>=66&tyco<69)
replace state = "T" if tyco>=72&tyco<100
* Other, older permanet contracts:
replace state = "P" if tyco==18
replace state = "P" if tyco>0&tyco<4
replace state = "P" if tyco>10&tyco<14
replace state = "P" if tyco==20|tyco==23
replace state = "P" if tyco>=28&tyco<34
replace state = "P" if tyco>=39&tyco<53
replace state = "P" if tyco>=59&tyco<64
replace state = "P" if tyco==65
replace state = "P" if tyco>=69&tyco<72
* All constracts were permanent before 1986
* Non-identified
replace state = "N" if state == ""
* Almost all of the non-identified have no contract type specified
* I'm choosing to call these permanent contracts for now, as half of them 
* happened before 1986 (when temporary contracts were introduced)
replace state = "P" if state=="N"&tyco==0
drop if state=="N"

* inbetween: cases of overlapping jobs. Total overlap = 2 *

sort id dtin dtout
gen inbetween = 0
* 3: Minor overlap at the begining of current spell with the last one *
by id: replace inbetween = 3 if dtin[_n]<dtout[_n-1]&dtout[_n]>dtout[_n-1]&dtin[_n]>=dtin[_n-1]
* 3: Minor overlap at the begining of current spell with the next one *
by id: replace inbetween = 4 if dtin[_n]<dtin[_n+1]&dtout[_n]>dtin[_n+1]&dtout[_n]<=dtout[_n+1]
* 34: combination of both *
by id: replace inbetween = 34 if dtin[_n]<dtin[_n+1]&dtout[_n]>dtin[_n+1]&dtout[_n]<=dtout[_n+1]&dtin[_n]<dtout[_n-1]&dtout[_n]>dtout[_n-1]&dtin[_n]>=dtin[_n-1]
* 2: full overlap *
by id: replace inbetween = 2 if dtin[_n]>=dtin[_n-1]&dtout[_n]<=dtout[_n-1]&id[_n]==id[_n-1]&dtin[_n]!=.

* Drop full overlap spells.
* I do not correct just now for minor overlaps 3 and 4, as I may be interested 
* in recorded spell length by the admin - for exmple, in terms of job tenure.
* I do record a varaible, multiemp, that quantifies how many other simultanaous
* spells did the worker had.
* maqx_dtout: lastest end of spell date
gen max_dtout = dtout
by id: replace max_dtout = max_dtout[_n-1] if dtout[_n]<=max_dtout[_n-1]&dtin[_n]>=dtin[_n-1]
* me: indicator for multuple employmetn spells
gen me = 0
by id: replace me = 1 if max_dtout == max_dtout[_n-1]
* multi_emp: how many multiple jobs/spells a person had
sort id max_dtout dtin
by id max_dtout: gen multi_emp = sum(me)
by id max_dtout: replace multi_emp = multi_emp[_N]

* Record ERTEs
by id max_dtout: gen ERTE = (me[_n+1]==1&tyrel[_n+1]==752&(state=="P"|state=="T"))
by id max_dtout: replace ERTE=1 if tyrel==752&ERTE[_n-1]==1

* For now, keep only if in 2020
gen year_in = year(dtin)

* Drop fully overlapping spells (save 2020 ERTEs)
drop if me==1&(ERTE==0|(ERTE==1&year_in<2020))

* Record end and start of ERTEs
by id max_dtout: gen ERTE_in = dtin[_n+1] if (me[_n+1]==1&tyrel[_n+1]==752&(state=="P"|state=="T"))
format ERTE_in %td
by id max_dtout: gen ERTE_out = dtout[_N] if (me[_n+1]==1&tyrel[_n+1]==752&(state=="P"|state=="T"))
format ERTE_out %td

* Record number of days in ERTE (imperfect mesure, works for now)
by id max_dtout: gen ERTE_days = sum(days) if ERTE==1
by id max_dtout: replace ERTE_days = ERTE_days[_N]-ERTE_days

* Clean up
drop if me==1
drop max_dtout me year_in
sort id dtin dtout

* jobcount: number of jobs the worker had in the current year *
sort id dtin
by id: gen jobcount = _n
order jobcount, after(id)

compress
