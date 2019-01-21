
// rename newind ind_old

gen ind_short = 0

* CNAE 2009

replace ind_short = 1 if ind >= 11 & ind<50	// agriculture

replace ind_short = 2 if ind >= 50 & ind<100	// extraction

replace ind_short = 3 if ind >= 100 & ind<200	// manufactures (primary)

replace ind_short = 4 if ind >= 200 & ind<300	// manufactures (machinery)

replace ind_short = 5 if ind >= 300 & ind<350	// manufactures (detail and repair)

replace ind_short = 6 if ind >= 350 & ind<400   // energy, gas, residual treatment

replace ind_short = 7 if ind >= 400 & ind<450   // construction

replace ind_short = 8 if ind >= 450 & ind<490   // Retail and repairs

replace ind_short = 9 if ind >= 490 & ind<550   // Transport and storage

replace ind_short = 10 if ind >= 550 & ind<580   // Hospitality

replace ind_short = 11 if ind >= 580 & ind<640   // Communication adn programming

replace ind_short = 12 if ind >= 640 & ind<680   // Financial

replace ind_short = 13 if ind >= 680 & ind<690   // Real State

replace ind_short = 14 if ind >= 690 & ind<770   // Professional and scientific services

replace ind_short = 15 if ind >= 770 & ind<840   // Auxiliary services (cleaning, gardening, rental)

replace ind_short = 16 if ind >= 840 & ind<850   // Public Administration

replace ind_short = 17 if ind >= 850 & ind<860   // Education

replace ind_short = 18 if ind >= 860 & ind<900   // Health and Social Services

replace ind_short = 19 if ind >= 900    // Other Services


* CNAE 1993

replace ind_short = 1 if ind_old >= 11 & ind_old <100 & ind ==0	// agriculture

replace ind_short = 2 if ind_old >= 100 & ind_old <150 & ind ==0 // extraction

replace ind_short = 3 if ind_old >= 150 & ind_old <240 & ind ==0 // manufactures (primary)

replace ind_short = 4 if ind_old >= 240 & ind_old <350 & ind ==0 // manufactures (machinery)

replace ind_short = 5 if ind_old >= 350 & ind_old <370 & ind ==0  // manufactures (detail and repair)

replace ind_short = 6 if ind_old >= 370 & ind_old <450 & ind ==0   // energy, gas, residual treatment

replace ind_short = 7 if ind_old >= 450 & ind_old <500 & ind ==0   // construction

replace ind_short = 8 if ind_old >= 500 & ind_old <550 & ind ==0   // Retail and repairs

replace ind_short = 10 if ind_old >= 550 & ind_old <600 & ind ==0  // Hospitality

replace ind_short = 9 if ind_old >= 600 & ind_old <640 & ind ==0  // Transport and storage 

replace ind_short = 12 if ind_old >= 650 & ind_old <700 & ind ==0  // Financial

replace ind_short = 13 if ind_old >= 700 & ind_old <710 & ind ==0  // Real State

replace ind_short = 15 if ((ind_old>=710&ind_old<720)|(ind>=745&ind<749)|ind==14|ind==633) & ind ==0  // Auxiliary services (cleaning, gardening, rental)

replace ind_short = 14 if ((ind_old>=730&ind_old<745)) & ind ==0  // Professional and scientific services

replace ind_short = 16 if ind_old >= 750 & ind_old <800 & ind ==0  // Public Administration

replace ind_short = 17 if ind_old >= 800 & ind_old <850 & ind ==0  // Education

replace ind_short = 18 if ind_old >= 850 & ind_old <900 & ind ==0  // Health and Social Services

replace ind_short = 19 if ind_old >= 900 & ind ==0  // Other Services

replace ind_short = 11 if ind_old >= 640 & ind_old <650 & ind ==0  // Communication and programming
replace ind_short = 11 if ind_old >= 220 & ind_old <230 & ind ==0  // 
replace ind_short = 11 if ind_old >= 720 & ind_old <730 & ind ==0  // 

 label define industry_codes 0 "NA" 1 "Agriculture" 2 "Extractive" 3 "Manufactures (primary)" 4 "Manufactures (machinery)" ///
 5 "Manufactures (detail and repair)" 6 "Energy, gas, residual treatment" 7 "Construction" 8 "Retail and repairs"  ///
 9  "Transport and storage" 10 "Hospitality" 11 "Communication and programming" 12 "Financial" 13 "Real State" ///
 14 "Professional and scientific services" 15 "Auxiliary services (cleaning, gardening, rental)" 16 "Public Administration" ///
 17 "Education" 18 "Health and Social Services" 19 "Other Services"
 
 label values ind_short industry_codes
