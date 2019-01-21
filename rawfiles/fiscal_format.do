rename v1 id
rename v2 firm1
rename v3 firm2
rename v4 region
rename v5 key
rename v6 subkey
rename v7 moneyin
rename v8 reten
rename v9 espec
rename v10 ingref
rename v11 ingrep
rename v12 cm
rename v13 birthdt
rename v14 fam
rename v15 disabl
rename v16 tyco
rename v17 jlenght
rename v18 mobility
rename v19 red1
rename v20 red2
rename v21 pen
rename v22 fdan
rename v23 kids31
rename v24 kids32
rename v25 kidsall1
rename v26 kidsall2
rename v27 kidsdis1
rename v28 kidsdis2
rename v29 kidsdis3
rename v30 kidsdis4
rename v31 kidsdis5
rename v32 kidsdis6
rename v33 allkids
rename v34 grand1
rename v35 grand2
rename v36 grand3
rename v37 grand4
rename v38 grandis1
rename v39 grandis2
rename v40 grandis3
rename v41 grandis4
rename v42 grandis5
rename v43 grandis6
rename v44 allgrand

replace moneyin = moneyin/100
replace reten = reten/100
replace espec = espec/100
replace ingref = ingref/100
replace ingrep = ingrep/100


by id, sort: gen entry = _n
order entry, after(id)
egen entrycount = count(id), by (id)
egen totalmoney = sum(moneyin), by (id)
egen totalesp = sum(espec), by (id)
