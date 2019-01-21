
gen ind_short = 0

* CNAE 2009

replace ind_short = 1 if year >= 2009 & ind >= 11 & ind<50	// agriculture

replace ind_short = 2 if year >= 2009 & ind >= 50 & ind<100	// extraction

replace ind_short = 3 if year >= 2009 & ind >= 100 & ind<200	// manufactures (primary)

replace ind_short = 4 if year >= 2009 & ind >= 200 & ind<300	// manufactures (machinery)

replace ind_short = 5 if year >= 2009 & ind >= 300 & ind<350	// manufactures (detail and repair)

replace ind_short = 6 if year >= 2009 & ind >= 350 & ind<400   // energy, gas, residual treatment

replace ind_short = 7 if year >= 2009 & ind >= 400 & ind<450   // construction

replace ind_short = 8 if year >= 2009 & ind >= 450 & ind<490   // Retail and repairs

replace ind_short = 9 if year >= 2009 & ind >= 490 & ind<550   // Transport and storage

replace ind_short = 10 if year >= 2009 & ind >= 550 & ind<580   // Hospitality

replace ind_short = 11 if year >= 2009 & ind >= 580 & ind<640   // Communication adn programming

replace ind_short = 12 if year >= 2009 & ind >= 640 & ind<680   // Financial

replace ind_short = 13 if year >= 2009 & ind >= 680 & ind<690   // Real State

replace ind_short = 14 if year >= 2009 & ind >= 690 & ind<770   // Professional and scientific services

replace ind_short = 15 if year >= 2009 & ind >= 770 & ind<840   // Auxiliary services (cleaning, gardening, rental)

replace ind_short = 16 if year >= 2009 & ind >= 840 & ind<850   // Public Administration

replace ind_short = 17 if year >= 2009 & ind >= 850 & ind<860   // Education

replace ind_short = 18 if year >= 2009 & ind >= 860 & ind<900   // Health and Social Services

replace ind_short = 19 if year >= 2009 & ind >= 900    // Other Services


* CNAE 1993

replace ind_short = 1 if ind >= 11 & ind <100 & ind != 14 & year < 2009	// agriculture

replace ind_short = 2 if ind >= 100 & ind <150 & year < 2009 // extraction

replace ind_short = 3 if ind >= 150 & ind <240 & year < 2009 // manufactures (primary)

replace ind_short = 4 if ind >= 240 & ind <350 & year < 2009 // manufactures (machinery)

replace ind_short = 5 if ind >= 350 & ind <370 & year < 2009  // manufactures (detail and repair)

replace ind_short = 6 if ind >= 370 & ind <450 & year < 2009   // energy, gas, residual treatment

replace ind_short = 7 if ind >= 450 & ind <500 & year < 2009   // construction

replace ind_short = 8 if ind >= 500 & ind <550 & year < 2009   // Retail and repairs

replace ind_short = 10 if ind >= 550 & ind <600 & year < 2009  // Hospitality

replace ind_short = 9 if ind >= 600 & ind <640 & ind!=633 & year < 2009  // Transport and storage 

replace ind_short = 12 if ind >= 650 & ind <700 & year < 2009  // Financial

replace ind_short = 13 if ind >= 700 & ind <710 & year < 2009  // Real State

replace ind_short = 15 if ((ind>=710&ind<720)|(ind>=745&ind<749)|ind==14|ind==633) & year < 2009  // Auxiliary services (cleaning, gardening, rental)

replace ind_short = 14 if ((ind>=730&ind<745)) & year < 2009  // Professional and scientific services

replace ind_short = 16 if ind >= 750 & ind <800 & year < 2009  // Public Administration

replace ind_short = 17 if ind >= 800 & ind <850 & year < 2009  // Education

replace ind_short = 18 if ind >= 850 & ind <900 & year < 2009  // Health and Social Services

replace ind_short = 19 if ind >= 900 & year < 2009  // Other Services

replace ind_short = 11 if ind >= 640 & ind <650 & year < 2009  // Communication and programming
replace ind_short = 11 if ind >= 220 & ind <230 & year < 2009  // 
replace ind_short = 11 if ind >= 720 & ind <730 & year < 2009  // 

 label define industry_codes 0 "NA" 1 "Agriculture" 2 "Extractive" 3 "Manufactures (primary)" 4 "Manufactures (machinery)" ///
 5 "Manufactures (detail and repair)" 6 "Energy, gas, residual treatment" 7 "Construction" 8 "Retail and repairs"  ///
 9  "Transport and storage" 10 "Hospitality" 11 "Communication and programming" 12 "Financial" 13 "Real State" ///
 14 "Professional and scientific services" 15 "Auxiliary services (cleaning, gardening, rental)" 16 "Public Administration" ///
 17 "Education" 18 "Health and Social Services" 19 "Other Services"
 
 label values ind_short industry_codes
