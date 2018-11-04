*! version 1.1.3  22oct2018 JM. Domenech, R. Sesma

/*
statmis: missing statistics
*/

program define statmis, rclass
	version 12
	syntax [varlist] [if] [in], [excluded nst(string)]

	tempname res values freq tmp

	*Drop _NMiss variable if exists
	capture confirm variable _NMiss
	if (!_rc) drop _NMiss
	
	*Delete _NMiss of the variable list
	local nmis "_NMiss"
	local varlist : list varlist - nmis
	
	*Build the list of variables; excluded param means all variables EXCEPT those of varlist
	if ("`excluded'"=="") qui ds `varlist'
	else qui ds `varlist', not
	local vlist = r(varlist)
	
	if ("`vlist'"==".") {
		display in red "no variables selected" 
		exit 198
	}
	
	marksample touse, novarlist

	*Check for missing values by variable
	local vmiss				//List of temporary variables with missing count
	foreach v of varlist `vlist'{
		tempvar `v'_miss
		local vmiss : list vmiss | `v'_miss
		
		capture confirm numeric variable `v'
		if (_rc==0) {
			qui generate ``v'_miss' = missing(`v') if `touse' & `v'<.z		//On numeric vars .z is Not Applicable, not missing
		}
		else {
			qui generate ``v'_miss' = missing(`v') if `touse'
		}
	}
	*Total missing values by subject: _NMiss variable
	qui egen _NMiss = rowtotal(`vmiss') if `touse'
	label variable _NMiss "Total missing values by subject"
	qui tabulate _NMiss if `touse', matrow(`values') matcell(`freq')		//_NMiss statistics
	local n = r(N)			//Total number of subjects

	*Build results matrix
	local first 1
	foreach v of varlist `vlist'{
		capture confirm numeric variable `v'
		local str = cond(_rc!=0,"str","")
		
		count_miss `v' `touse', `str'
		if (`first') matrix define `res' = r(res)
		else matrix define `res' = `res' \ r(res)
		local first 0
	}

	*Print results
	di as res "STATISTICS OF MISSING VALUES"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	di
	di as txt "{col 14}{c |}{col 19}Missing values{col 37}{c |}{col 40}Not{col 45}{c |}  Valid values"
	di as txt "    Variable {c |} System  User Percent {c |} Appl.{col 45}{c |}  Freq. Percent{col 67}Mean{col 79}Min{col 90}Max"
	di as txt "{hline 13}{c +}{hline 22}{c +}{hline 7}{c +}{hline 47}" _c
	
	local rows = rowsof(`res')
	local cols = colsof(`res')
	foreach i of numlist 1/`rows' {
		local v : word `i' of `vlist'
		local name = abbrev("`v'",12)
		di as txt _newline "{ralign 12:`name'} {c |} " _c
		
		capture confirm numeric variable `v'
		local str = (_rc!=0)

		local f : format `v'
		local f = subinstr("`f'","-","",.)
		local daily = substr("`f'",1,3)=="%td"		//date-daily variable
		local clock = substr("`f'",1,3)=="%tc"		//clock-daily variables
		di as res %6.0f `res'[`i',1] " " _c
		if (!`str') di %5.0f `res'[`i',2] " " _c
		di _col(30) %6.2f `res'[`i',3] " {c |} " _c
		if (!`str') di %5.0f `res'[`i',4] _c
		di _col(45) "{c |} " _c
		di as res %6.0f `res'[`i',5] "  " %6.2f `res'[`i',6] " " _c
		if (!`str' & !`daily' &!`clock') di %9.0g `res'[`i',7] _c
		if (!`str' & !`daily' &!`clock') di _col(73) %9.0g `res'[`i',8] "  " %9.0g `res'[`i',9] _c
		if (`daily') di _col(72) %tdDD/NN/CCYY `res'[`i',8] " " %tdDD/NN/CCYY `res'[`i',9] _c
	}

	mata: st_matrix("`tmp'",colsum(st_matrix("`res'")))
	local nsys = `tmp'[1,1]			//Total number of sysmis
	local nuser = `tmp'[1,2]		//Total number of user-missing
	local na = `tmp'[1,4]			//Total number of Not Appl.
	local nval = `tmp'[1,5]			//Total number of valid values
	local pmiss = 100*(`nsys'+`nuser')/(`nsys'+`nuser'+`nval')		//Percent of missing values
	local pvalid = 100*(`nval')/(`nsys'+`nuser'+`nval')				//Percent of valid values
	
	di as txt _newline "{hline 13}{c +}{hline 22}{c +}{hline 7}{c +}{hline 47}"
	di as txt "{ralign 12:Total} {c |} " as res %6.0f `nsys' " " %5.0f `nuser'    /*
			*/  _col(30) %6.2f `pmiss' _col(37) "{c |}" %6.0f `na' _col(45) "{c |} "  /*
			*/  %6.0f `nval' _col(55) %6.2f `pvalid'
			  
	di
	di as res "Total missing values by subject"
	di as txt "{ralign 12:_NMiss} {c |}{ralign 11:Freq.} Percent"
	di as txt "{hline 13}{c +}{hline 19}"
	local len = rowsof(`values')
	foreach i of numlist 1/`len'{
		di as txt %12.0f `values'[`i',1] " {c |} " as res %9.0f `freq'[`i',1] _col(28) %6.2f 100*`freq'[`i',1]/`n'
	}
	di as txt "{hline 13}{c +}{hline 19}"
	di as txt _col(8) "Total {c |} " %9.0f `n' _col(28) "100.00"
	
	di
	di as txt "A new variable named {bf:_NMiss} has been added to the dataset."
	di as txt "It can be used to identify and drop observations with missing values"

	return scalar nsysmis = `nsys'
	return scalar nuser = `nuser'
	return scalar nmissing = `nsys' + `nuser'
	return scalar pmissing = `pmiss'
	return scalar na = `na'
	return scalar nvalid = `nval'
	return scalar pvalid = `pvalid'
	
end

program define count_miss, rclass
	version 12
	syntax varlist, [str]

	tokenize `varlist'
	local v `1'
	local touse `2'
	
	tempname r
	matrix define `r' = J(1,9,.)
	quietly {
		qui count if `touse' & !missing(`v')	//Count # of valid values
		matrix `r'[1,5] = r(N)
		if ("`str'"=="") {
			*Numeric/Date var
			count if `touse' & `v'==.			//Count # of sysmis
			matrix `r'[1,1] = r(N)
			count if `touse' & `v'>. & `v'<.z	//Count # of usermis
			matrix `r'[1,2] = r(N)
			local ntotal = `r'[1,1]+`r'[1,2]+`r'[1,5]			//Total number of expected values (without the Not Applicables)
			matrix `r'[1,3] = 100*(`r'[1,1]+`r'[1,2])/`ntotal'	//% of missing values
			count if `touse' & `v'==.z			//Count #  of not applicable
			matrix `r'[1,4] = r(N)
					
			su `v' if `touse' 		//Get mean, minimum and maximum for each numeric/date variable using summarize
			matrix `r'[1,7] = r(mean)
			matrix `r'[1,8] = r(min)
			matrix `r'[1,9] = r(max)
		}
		else {
			*String var
			qui count if `touse' & missing(`v')		//Count # of sysmis
			matrix `r'[1,1] = r(N)
			local ntotal = `r'[1,1]+`r'[1,5]		//Total number of expected values
			matrix `r'[1,3] = 100*(`r'[1,1])/`ntotal'	//% of missing values			
		}
		matrix `r'[1,6] = 100*`r'[1,5]/`ntotal'			//% of valid values	
	}
	
	return matrix res = `r'	
end
