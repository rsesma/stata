*! version 1.1.6 30sep2019 JM. Domenech, R. Sesma

/*
statmis: missing statistics
*/

program define statmis, rclass
	version 12
	syntax [varlist] [if] [in], [excluded GENerate(name) NOGENerate NOREPort nst(string)]

	tempname V F
	tempvar nmis

	if ("`generate'"!="" & "`nogenerate'"!="") {
		di in red "options -generate()- and -nogenerate- may not be specified together"
		exit 198
	}
	
	qui {
		* build the list of variables; exclude total missing values by subject variable of the list
		local not = cond("`excluded'"=="","",", not")			// excluded param means all variables EXCEPT those of varlist
		ds `varlist' `not'
		if ("`r(varlist)'"=="") {
			noisily di in red "no variables selected"
			exit 198
		}
		ds `r(varlist)', not(varl "Total missing values by subject")
		local vlist = r(varlist)
		
		* selection
		marksample touse, novarlist
		count if `touse'
		local ntot = r(N)			// total number of rows
		if (`ntot'==0) {
			noisily di in red "no observations"
			exit 198
		}
		
		ds `vlist', not(type str#)			// list of numeric variables
		local vnum = "`r(varlist)'"
		
		ds `vlist', has(type str#)			// list of string variables
		local vstr = "`r(varlist)'"
		
		ds `vlist', has(format %td*)		// list of daily variables
		local vdaily = "`r(varlist)'"
		
		ds `vlist', has(format %tc*)		// list of clock variables
		local vclock = "`r(varlist)'"
		
		// generate nmis variable with number of missing per observation
		local rlist
		if ("`vnum'"!="") {
			foreach v of varlist `vnum' {
				tempname vr
				recode `v' (.z=0), generate(`vr')			// to exclude .z values (NA) from the count, recode .z to 0
				local rlist `rlist' `vr'
			}
		}
		egen `nmis' = rowmiss(`rlist' `vstr') if `touse'
	}

	preserve
	qui keep if `touse'
	
	*Print results
	di as res "STATISTICS OF MISSING VALUES"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	
	if ("`noreport'"=="") {
		di
		di as txt "{col 14}{c |}{col 19}Missing values{col 37}{c |}{col 40}Not{col 45}{c |}  Valid values"
		di as txt "    Variable {c |} System  User Percent {c |} Appl.{col 45}{c |}  Freq. Percent{col 67}Mean{col 79}Min{col 90}Max"
		di as txt "{hline 13}{c +}{hline 22}{c +}{hline 7}{c +}{hline 47}" _c
		local nsys 0
		local num 0
		local nval 0
		local nna 0
		foreach v of varlist `vlist'{
			local name = abbrev("`v'",12)
			di as txt _newline "{ralign 12:`name'} {c |} " _c
			
			* count number of missings, sysmis, usermis, not applicable (.z) and valid values
			local lnum : list v in vnum
			qui count if missing(`v')	// count # of missing values
			local mis = r(N)
			qui count if !missing(`v')	// count # of valid values
			local val = r(N)
			if (`lnum') {
				* numeric/date var
				qui count if `v'>. & `v'<.z			// count # of usermis
				local um = r(N)
				qui count if `v'==.z				// count # of not applicables (.z)
				local na = r(N)
				local sys = `mis' - `um' - `na'		// # of sysmis
			}
			else {
				* string variable
				local sys = `mis'					// # of sysmis
				local um = 0						// string variables don't have user-mising or not applicables
				local na = 0
				local ntotal = `sys'+`val'			// total number of expected values
				local pct_miss = 100*(`sys') / `ntotal'			//% of missing values			
			}
			local ntotal = `sys'+`um'+`val'		// total number of expected values (without the Not Applicables)
			local pct_miss = 100*(`sys' + `um') / `ntotal'	// % of missing values
			local pct_val = 100*`val'/`ntotal'				// % of valid values	

			di as res %6.0f `sys' _c
			if (`lnum') di _col(23) %5.0f `um' _c
			di _col(30) %6.2f `pct_miss' _col(37) "{c |}" _c
			if (`lnum') di _col(39) %5.0f `na' _c
			di _col(45) "{c |}" _c
			di _col(47) %6.0f `val' _col(55) %6.2f `pct_val' _c
			
			local tc : list v in vclock
			local td : list v in vdaily
			if (`lnum' & !`tc') {
				qui sum `v'
				if (`td') di _col(72) %tdDD/NN/CCYY `r(min)' " " %tdDD/NN/CCYY `r(max)' _c
				else di _col(62) %9.0g `r(mean)' "  " %9.0g `r(min)' "  " %9.0g `r(max)' _c
			}
			
			local nsys = `nsys' + `sys'
			local num = `num' + `um'
			local nval = `nval' + `val'
			local nna = `nna' + `na'
		}
		di as txt _newline "{hline 13}{c +}{hline 22}{c +}{hline 7}{c +}{hline 47}"
		local pmiss = 100*(`nsys'+`num')/(`nsys'+`num'+`nval')		// percent of missing values
		local pvalid = 100*(`nval')/(`nsys'+`num'+`nval')			// percent of valid values
		di as txt "{ralign 12:Total} {c |} " as res %6.0f `nsys' " " %5.0f `num'    /*
				*/  _col(30) %6.2f 100 * (`nsys'+`num')/(`nsys'+`num'+`nval') 		/*
				*/	_col(37) "{c |}" %6.0f `nna' _col(45) "{c |} " %6.0f `nval'  	/*
				*/  _col(55) %6.2f 100*`nval'/(`nsys'+`num'+`nval')
	}
	
	local vname = cond("`generate'"=="","_NMiss","`generate'")
	
	* total missing values table
	di
	di as res "Total missing values by subject"
	local t = cond(("`nogenerate'"==""),"`vname'","")
	di as txt "{ralign 12:`t'} {c |}{ralign 11:Freq.} Percent"
	di as txt "{hline 13}{c +}{hline 19}"
	qui tabulate `nmis', matrow(`V') matcell(`F')		// _NMiss statistics
	local len = rowsof(`V')
	foreach i of numlist 1/`len'{
		di as txt %12.0f `V'[`i',1] " {c |} " as res %9.0f `F'[`i',1] _col(28) %6.2f 100*`F'[`i',1]/`ntot'
	}
	di as txt "{hline 13}{c +}{hline 19}"
	di as txt _col(8) "Total {c |} " %9.0f `ntot' _col(28) "100.00"
	
	restore
	
	if ("`nogenerate'"=="") {
		quietly {
			capture drop `vname'
			gen `vname' = `nmis'
			label variable `vname' "Total missing values by subject"
		}
		di
		di as txt "A new variable named {bf:`vname'} has been added to the dataset."
		di as txt "It can be used to identify and drop observations with missing values"
	}
	
	if ("`noreport'"=="") {
		return scalar nsysmis = `nsys'
		return scalar nuser = `num'
		return scalar nmissing = `nsys' + `num'
		return scalar pmissing = `pmiss'
		return scalar na = `nna'
		return scalar nvalid = `nval'
		return scalar pvalid = `pvalid'
	}
end
