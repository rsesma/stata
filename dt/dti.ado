*! version 1.1.9  26jun2020 JM. Domenech, R. Sesma
/*
dti: Diagnostics Tests (immediate command)
For cross-sectional and case-control studies 4 elements are provided: a1 a0 b1 b0
for bayes theorem 2 elements (sensibility and specificity) or 4 elements (a1 a0 b1 b0) are provided
*/

program define dti, rclass
	version 12
	syntax anything(id="argument numlist"), /*
		*/ [ST(string)  Wilson Exact WAld P(numlist min=1 >0 <100)   /*
		*/	m1(numlist integer max=1 >0) n(numlist integer max=1 >0) /*
		*/  Level(numlist max=1 >50 <100) nst(string)                /*
		*/  _test(string) _vtest(string) _ref(string) _vref(string)  /*
		*/  _total(integer 0) _valid(integer 0)]

	*Study type
	if ("`st'"=="") local st = "cs"
	if ("`st'"!="cs" & "`st'"!="cc" & "`st'"!="bt") print_error "st() invalid -- invalid value"

	*Tokenize & test parameters
	tokenize `anything'
    local len : word count `anything'
	if (`len'!=2 & `len'!=4) print_error "argument numlist must have 2 or 4 elements"
	if (`len'==2 & "`st'"!="bt") print_error "2 elements numlist is for Bayes Theorem study type, st(bt)"
	if (`len'==2) {
		local se = `1'/100
		local sp = `2'/100
		confirm number `se'
		confirm number `sp'
		if (`se'<=0 | `se'>=1) print_error "sensitivity invalid -- out of range"
		if (`sp'<=0 | `sp'>=1) print_error "specificity invalid -- out of range"
	}
	if (`len'==4) {
		confirm integer number `1'
		confirm integer number `2'
		confirm integer number `3'
		confirm integer number `4'
		local a1 = `1'
		local a0 = `2'
		local b1 = `3'
		local b0 = `4'
		foreach i of numlist `a1' `a0' `b1' `b0' {
			if (`i'<0) print_error "'`i'' found where positive integer expected"
		}

		local n1 = `a1' + `b1'
		local n0 = `a0' + `b0'
		local m1t = `a1' + `a0'
		local m0 = `b1' + `b0'
		local nt = `a1' + `a0' + `b1' + `b0'
	}
	if ("`wilson'"=="" & "`exact'"=="" & "`wald'"=="") local method = "wilson"
	if ("`wilson'"!="" & ("`exact'"!="" | "`wald'"!="")) print_error "only one of wilson, exact, wald options is allowed"
	if ("`exact'"!="" & "`wald'"!="") print_error "only one of wilson, exact, wald options is allowed"
	if ("`wilson'"!="") local method = "wilson"
	if ("`exact'"!="") local method = "exact"
	if ("`wald'"!="") local method = "wald"
	if ("`level'"=="") local level 95
	if (("`m1'"!="" | "`n'"!="") & ("`st'"!="cc")) print_error "m1(), n() option is only allowed for case-control studies, st(cc)"
	if (("`m1'"!="" & "`n'"=="") | ("`m1'"=="" & "`n'"!="")) print_error "missing option m1() or n()"
	if ("`m1'"!="" & "`n'"!="") {
		if (`m1'>=`n') print_error "n must be greater than m1"
	}
	if ("`st'"=="bt" & "`p'"=="") print_error "p() option is necessary for bayes theorem, st(bt)"

	*Print & compute results
	di
	if ("`st'"=="cs") di as res "DIAGNOSTIC TESTS: CROSS-SECTIONAL STUDY"
	if ("`st'"=="cc") di as res "DIAGNOSTIC TESTS: CASE-CONTROL STUDY"
	if ("`st'"=="bt") di as res "DIAGNOSTIC TESTS: BAYES THEOREM"
	if ("`nst'"!="") display as text "{bf:STUDY:} `nst'"
	if (`_total'!=0) {
		*Data call: cases summary
		di as txt "Valid cases: " as res `_valid' as txt " (" as res %5.1f 100*`_valid'/`_total' as txt "%)"
		di as txt "Total cases: " as res `_total'
	}
	di

	*Table data
	if ("`_ref'"=="") {
		local coltitle = "Reference Criterion"
		local col1 = "NonCases"
		local col2 = "Cases"
		local rowtitle = "Diagnostic Test"
		local row1 = "Positive"
		local row2 = "Negative"
	}
	else {
		local coltitle = abbrev("`_ref'",21)
		tokenize `_vref'
		local col1: label (`_ref') `1'
		local col1 = abbrev("`col1'",9)
		local col2: label (`_ref') `2'
		local col2 = abbrev("`col2'",9)
		local rowtitle = abbrev("`_test'",16)
		tokenize `_vtest'
		local row1: label (`_test') `2'
		local row1 = abbrev("`row1'",16)
		local row2: label (`_test') `1'
		local row2 = abbrev("`row2'",16)
	}

	if ("`st'"=="cs" | ("`st'"=="bt" & `len'==4)) {
		di as txt _col(18) "{c |}{center 21:{bf:`coltitle'}}{c |}"
		di as txt "{ralign 16:{bf:`rowtitle'}} {c |}{ralign 9:`col1'} {c |}{ralign 9:`col2'} {c |}" _col(45) "TOTAL"
		di as txt "{hline 17}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}"
		di as txt "{ralign 16:`row1'} {c |} " as res %8.0f `b1' " {c |} " %8.0f `a1' " {c |} " %8.0f `n1'
		di as txt "{ralign 16:`row2'} {c |} " as res %8.0f `b0' " {c |} " %8.0f `a0' " {c |} " %8.0f `n0'
		di as txt "{hline 17}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}"
		di as txt _col(12) "TOTAL {c |} " as res %8.0f `m0' " {c |} " %8.0f `m1t' " {c |} " %8.0f `nt'
	}
	if ("`st'"=="cc") {
		if ("`m1'"=="" & "`n'"=="") {
			di as txt _col(18) "{c |}{center 21:{bf:`coltitle'}}"
			di as txt "{ralign 16:{bf:`rowtitle'}} {c |}{ralign 9:`col1'} {c |}{ralign 9:`col2'}"
			di as txt "{hline 17}{c +}{hline 10}{c +}{hline 10}"
			di as txt "{ralign 16:`row1'} {c |} " as res %8.0f `b1' " {c |} " %8.0f `a1'
			di as txt "{ralign 16:`row2'} {c |} " as res %8.0f `b0' " {c |} " %8.0f `a0'
			di as txt "{hline 17}{c +}{hline 10}{c +}{hline 10}"
			di as txt _col(12) "TOTAL {c |} " as res %8.0f `m0' " {c |} " %8.0f `m1t'
		}
		else {
			di as txt _col(20) "{c |}{center 21:{bf:`coltitle'}}" _col(42) "{c |}"
			di as txt "{ralign 18:{bf:`rowtitle'}} {c |}{ralign 9:`col1'} {c |}{ralign 9:`col2'}" _col(42) "{c |}"
			di as txt "{hline 19}{c +}{hline 10}{c +}{hline 10}{c RT}"
			di as txt "{ralign 18:`row1'} {c |} " as res %8.0f `b1' " {c |} " %8.0f `a1' " {c |}"
			di as txt "{ralign 18:`row2'} {c |} " as res %8.0f `b0' " {c |} " %8.0f `a0' " {c |}"
			di as txt "{hline 19}{c +}{hline 10}{c +}{hline 10}{c RT}"
			di as txt _col(14) "TOTAL {c |} " as res %8.0f `m0' " {c |} " %8.0f `m1t' " {c |} " as txt _col(47) "TOTAL"
			di as txt _col(20) "{c LT}{hline 10}{c +}{hline 10}{c +}{hline 10}"
			di as txt " POPULATION SAMPLE {c |} " as res %8.0f (`n'-`m1') " {c |} " %8.0f `m1' " {c |} " %8.0f `n'
		}
	}

	if ("`st'"=="cs" | "`st'"=="cc") {
		tempname r pr
		quietly {
			cii `m1t' `a1', level(`level') `method'				//Sensitivity
			local se = r(mean)
			matrix `r' = (100*r(mean), 100*r(lb), 100*r(ub))
			cii `m0' `b0', level(`level') `method'				//Specificity
			local sp = r(mean)
			matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
			cii `m0' `b1', level(`level') `method'				//False positive
			matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
			cii `m1t' `a0', level(`level') `method'				//False negative
			matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
			csi `a1' `b1' `a0' `b0', level(`level')				//Likelihood Ratio (+)
			matrix `r' = `r' \ (r(rr), r(lb_rr), r(ub_rr))
			csi `a0' `b0' `a1' `b1', level(`level')				//Likelihood Ratio (-)
			matrix `r' = `r' \ (r(rr), r(lb_rr), r(ub_rr))
			local lcont = ("`st'"=="cs") | ("`st'"=="cc" & ("`m1'"!="" & "`n'"!=""))
			if ("`st'"=="cs") {
				csi `a1' `b1' `a0' `b0', level(`level') or		//Odds ratio
				if (r(or)<.) {
					matrix `r' = `r' \ (r(or), r(lb_or), r(ub_or))
				}
				else {
					* if or is not computable, neither is the ci
					matrix `r' = `r' \ (., ., .)
				}

				cii `nt' `m1t', level(`level') `method'			//Prevalence
				matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
				cii `n1' `a1', level(`level') `method'			//Predictive value (+)
				matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
				cii `n0' `b0', level(`level') `method'			//Predictive value (-)
				matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
				local t = `a1' + `b0'
				cii `nt' `t', level(`level') `method'			//Efficiency
				matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
			}
			if ("`st'"=="cc" & ("`m1'"!="" & "`n'"!="")) {
				cii `n' `m1', level(`level') `method'			//Prevalence
				local prev = r(mean)
				matrix `r' = `r' \ (100*r(mean), 100*r(lb), 100*r(ub))
				getpv `prev' `se' `sp' `m1t' `m0' `n', level(`level') ext			//Predictive value (+), (-)
				matrix `r' = `r' \ (r(pvp), r(lbp), r(ubp))
				matrix `r' = `r' \ (r(pvn), r(lbn), r(ubn))
				local eff = (`prev'*`se'+(1-`prev')*`sp')*100						//Efficiency
				matrix `r' = `r' \ (`eff',.,.)
			}

		}

		di
		di as txt "{hline 19}{c TT}{hline 10}{c TT}{hline 28}"
		di as txt _col(20) "{c |} Estimate {c |} `level'% Confidence Interval"
		di as txt "{hline 19}{c +}{hline 10}{c +}{hline 28}" _c

		local m = proper("`method'")
		local c1 "Sensitivity"
		local c2 "Specificity"
		local c3 "False positive"
		local c4 "False negative"
		foreach i of numlist 1/4 {
			di as txt _newline "{ralign 18:`c`i''} {c |} " _c
			foreach j of numlist 1/3 {
				local v = `r'[`i',`j']
				local col = cond(`j'==1,23,cond(`j'==2,35,46))
				if (`j'==1) print_pct `v', col(`col')
				else print_pct `v', col(`col') nopercent
				if (`j'==1) di "  {c |}" _c
				if (`j'==2) di as txt " to " _c
			}
			di as txt " (`m')" _c
		}

		local c5 "Likelihood Ratio +"
		local c6 "-"
		foreach i of numlist 5/6 {
			di as txt _newline "{ralign 18:`c`i''} {c |} " _c
			foreach j of numlist 1/3 {
				local v = `r'[`i',`j']
				di as res %7.0g `v' _c
				if (`j'==1) di "  {c |} " _c
				if (`j'==2) di as txt " to " _c
			}
			if (`r'[`i',1]<1) {
				*LR+, LR- inverses
				local sign = cond(`i'==5,"+","-")
				di as txt _newline "{ralign 18:inverse `sign'} {c |} "   /*
				*/ as res %7.0g 1/`r'[`i',1] "  {c |} " %7.0g 1/`r'[`i',3] 	 /*
				*/ as txt " to " as res %7.0g 1/`r'[`i',2] _c
			}
		}

		if ("`st'"=="cs") {
			di as txt _newline "{ralign 18:Odds ratio} {c |} "   /*
				*/ as res %7.0g `r'[7,1] "  {c |} " %7.0g `r'[7,2] 	 /*
				*/ as txt " to " as res %7.0g `r'[7,3] _c
		}

		if (`lcont') {
			di as txt _newline "{hline 19}{c +}{hline 10}{c +}{hline 28}" _c
			local c1 "Sample prevalence"
			local c2 "Predictive value +"
			local c3 "-"
			local c4 "Efficiency"

			local ini = cond("`st'"=="cs",8,7)
			local fin = rowsof(`r')
			local count 1
			foreach i of numlist `ini'/`fin' {
				di as txt _newline "{ralign 18:`c`count''} {c |} " _c
				foreach j of numlist 1/3 {
					local v = `r'[`i',`j']
					local col = cond(`j'==1,23,cond(`j'==2,35,46))
					if (`v'<.) {
						if (`j'==1) print_pct `v', col(`col')
						else print_pct `v', col(`col') nopercent
					}
					if (`j'==1) di "  {c |}" _c
					if (`j'==2 & `v'<.) di as txt " to " _c
				}

				if ("`st'"=="cs" | `i'==`ini') di as txt " (`m')" _c
				if ("`st'"=="cc" & `i'>`ini' & `i'<`fin') di as txt " (Asymp)*" _c

				local count = `count' + 1
			}
		}
		di as txt _newline "{hline 19}{c BT}{hline 10}{c BT}{hline 28}"
		if ("`st'"=="cc" & `lcont') {
			di as txt "(*) Monsour, Evans & Kupper. Stat Med.1991;443-56."
			di as txt "(*) Assumed constant Sensibility and Specificity"
		}

		if ("`p'"!="") {
			di
			di as txt "  Pre-test   {c |}{rcenter 45:Predictive values of disease*}"
			di as txt " Probability {c |}{rcenter 45:(`level'% Asympt. Confidence Interval)}"
			di as txt " of disease  {c |}{rcenter 22:Positive}{c |}{rcenter 22:Negative}"
			di as txt "{hline 13}{c +}{hline 22}{c +}{hline 22}"

			tempname pr
			local first 1
			foreach i in `p' {
				getpv `i'/100 `se' `sp' `m1t' `m0' `nt', level(`level')
				if (`first') matrix `pr' = (`i',r(pvp),r(lbp),r(ubp),r(pvn),r(lbn),r(ubn))
				else matrix `pr' = `pr' \ (`i',r(pvp),r(lbp),r(ubp),r(pvn),r(lbn),r(ubn))
				local first 0

				di as res _col(6) %5.0g `i' as txt "%" _col(14) "{c |}"  		/*
				*/	as res _col(19) %6.0g r(pvp) as txt "%" _col(37) "{c |}" 	/*
				*/	as res _col(40) %6.0g r(pvn) as txt "%"
				di as txt _col(14) "{c |}" _col(18) "(" as res %6.0g r(lbp) 	/*
				*/	as txt " to "  as res %6.0g r(ubp) as txt ")" _col(37) "{c |}" /*
				*/	_col(39) "(" as res %6.0g r(lbn) as txt " to " as res %6.0g r(ubn) as txt ")"
			}
			di as txt "{hline 13}{c BT}{hline 22}{c BT}{hline 22}"
			di as txt "(*) Assumed constant Sensibility and Specificity"
		}
	}

	if ("`st'"=="bt") {
		if (`len'==4) {
			qui cii `m1t' `a1', level(95) wilson		//Sensitivity
			local se = r(mean)
			qui cii `m0' `b0', level(95) wilson			//Specificity
			local sp = r(mean)
		}
		local fp = (1-`sp')
		local fn = (1-`se')
		local lrp = `se'/(1-`sp')
		local lrn = (1-`se')/`sp'

		local se_pct = 100*`se'
		local sp_pct = 100*`sp'
		local fp_pct = 100*`fp'
		local fn_pct = 100*`fn'

		if (`len'==4) di
		di as txt "{ralign 14:Sensibility} = " _c
		print_pct `se_pct'
		di as txt "{ralign 22:Likelihood Ratio +} = " as res %7.0g `lrp'

		di as txt "{ralign 14:Specificity} = " _c
		print_pct `sp_pct'
		if (`lrp'>=1 & `lrn'<1) di as txt "{ralign 22:-} = " as res %7.0g `lrn'
		else di as txt "{ralign 22:inverse +} = " as res %7.0g 1/`lrp'

		di as txt "{ralign 14:False positive} = " _c
		print_pct `fp_pct'
		if (`lrp'>=1 & `lrn'<1) di as txt "{ralign 22:inverse -} = " as res %7.0g 1/`lrn'
		else di as txt "{ralign 22:-} = " as res %7.0g `lrn'

		di as txt "{ralign 14:False negative} = " _c
		print_pct `fn_pct'
		if (`lrp'<1 & `lrn'<1) di as txt "{ralign 22:inverse -} = " as res %7.0g 1/`lrn'
		else di as txt " "

		di
		di as txt "(Pre-test Prob.){c |} (Post-test Probability) {c |} Correctly  {c |}"
		di as txt "  Hypothetical  {c |}    Predictive Values*   {c |} classified {c |}"
		di as txt "   Prevalence   {c |}  Positive  {c |}  Negative  {c |}(Efficiency){c |}"
		di as txt "{hline 16}{c +}{hline 12}{c +}{hline 12}{c +}{hline 12}{c RT}"

		tempname pr
		local first 1
		foreach i in `p' {
			getpv_bayes `i'/100 `se' `sp'
			if (`first') matrix `pr' = (`i',r(pvp),r(pvn),r(eff))
			else matrix `pr' = `pr' \ (`i',r(pvp),r(pvn),r(eff))
			local first 0

			di as res _col(7) %6.0g `i' as txt "%" _col(17) "{c |}" 	/*
			*/		_col(20) as res %7.0g r(pvp) as txt "%" _col(30) "{c |}" 	/*
			*/		_col(33) as res %7.0g r(pvn) as txt "%" _col(43) "{c |}" 	/*
			*/		_col(46) as res %7.0g r(eff) as txt "%" _col(56) "{c |}"
		}
		di as txt "{hline 16}{c BT}{hline 12}{c BT}{hline 12}{c BT}{hline 12}{c BRC}"
		di as txt "(*) Assumed constant Sensibility and Specificity"
	}

	*Stored results
	if ("`st'"!="bt" | ("`st'"=="bt" & `len'==4)) {
		return scalar a1= `a1'
		return scalar b1= `b1'
		return scalar a0= `a0'
		return scalar b0= `b0'
		return scalar m1= `m1t'
		return scalar m0= `m0'
		if ("`st'"=="cs" | "`st'"=="bt") {
			return scalar n1= `n1'
			return scalar n0= `n0'
			return scalar n= `nt'
		}
		if ("`st'"=="cc" & "`m1'"!="" & "`n'"!="") {
			return scalar m1_sample= `m1'
			return scalar m0_sample= `n' - `m1'
			return scalar n_sample= `n'
		}
	}
	if ("`st'"=="cs" | "`st'"=="cc") {
		local i 1
		foreach res in se sp fp fn lrp lrn {
			return scalar `res' = `r'[`i',1]
			return scalar lb_`res' = `r'[`i',2]
			return scalar ub_`res' = `r'[`i',3]
			local ++i
		}
		if ("`st'"=="cs") {
			return scalar or = `r'[7,1]
			return scalar lb_or = `r'[7,2]
			return scalar ub_or = `r'[7,3]
		}
		if ("`st'"=="cs" | ("`st'"=="cc" & ("`m1'"!="" & "`n'"!=""))) {
			local i = cond("`st'"=="cs",8,7)
			foreach res in pre pvp pvn eff {
				return scalar `res' = `r'[`i',1]
				if ("`res'"!="eff" | ("`res'"=="eff" & "`st'"=="cs")) {
					return scalar lb_`res' = `r'[`i',2]
					return scalar ub_`res' = `r'[`i',3]
				}
				local ++i
			}
		}
		if ("`p'"!="") {
			matrix colnames `pr' = prob positive lb_pos ub_pos negative lb_neg ub_neg
			return matrix P = `pr'
		}
	}
	if ("`st'"=="bt") {
		return scalar se = 100*`se'
		return scalar sp = 100*`sp'
		return scalar fp = 100*`fp'
		return scalar fn = 100*`fn'
		return scalar lrp = `lrp'
		return scalar lrn = `lrn'
		matrix colnames `pr' = prev pvp pvn eff
		return matrix P = `pr'
	}
	return scalar level = `level'

end

program define print_pct
	syntax anything, [col(numlist max=1) nopercent]
	local p = `anything'
	local fmt = "%5.1f"
	if (abs(`p')<10) {
		local fmt = "%5.2f"
		if (abs(`p')<1) {
			local fmt = "%5.0g"
			if (abs(`p')<0.01 & abs(`p')>0) {
				local fmt = "%5.3f"
			}
		}
	}
	*local fmt = cond(abs(`p')<10,cond(abs(`p')<1,"%5.0g","%5.2f"),"%5.1f")
	if ("`col'"=="") di as res `fmt' `p' _c
	else di as res _col(`col') `fmt' `p' _c
	if ("`percent'"=="") di as txt "%" _c
end

program define getpv, rclass
	version 12
	syntax anything(id="argument numlist"), Level(numlist max=1 >50 <100) [ext noic]

	tempname sigp sep sign sen z temp

	*Predictive Values for a given prevalence by Monsour, Evans y Kupper, 1991
	tokenize `anything'
	local p = `1'
	local se = `2'
	local sp = `3'
	local m1 = `4'
	local m0 = `5'
	local n = `6'

	scalar `z' = invnormal((`level'+100)/200)
	scalar `temp' = 0
	if ("`ext'"!="") scalar `temp' = 1/(`n'*`p'*(1-`p'))

	scalar `sigp' = (1-`sp')*(1-`p')/(`se'*`p')
	return scalar pvp = 100*(1/(1+`sigp'))
	scalar `sign' = (1-`se')*`p'/(`sp'*(1-`p'))
	return scalar pvn = 100*(1/(1+`sign'))
	if ("`noic'"=="") {
		scalar `sep' = sqrt((1-`se')/(`m1'*`se') + (`sp')/(`m0'*(1-`sp')) + `temp')
		return scalar ubp = 100*(1/(1+(`sigp'*exp(-`z'*`sep'))))
		return scalar lbp = 100*(1/(1+(`sigp'*exp(`z'*`sep'))))
		scalar `sen' = sqrt(`se'/(`m1'*(1-`se')) + (1-`sp')/(`m0'*`sp') + `temp')
		return scalar ubn = 100*(1/(1+(`sign'*exp(-`z'*`sen'))))
		return scalar lbn = 100*(1/(1+(`sign'*exp(`z'*`sen'))))
	}
end

program define getpv_bayes, rclass
	version 12
	syntax anything(id="argument numlist")

	tempname pvp pvn

	*Predictive Values for a given prevalence - Bayes theorem
	tokenize `anything'
	local p = `1'
	local se = `2'
	local sp = `3'

	scalar `pvp' = ((`p'*`se')/(`p'*`se'+(1-`p')*(1-`sp')))
	scalar `pvn' = (((1-`p')*`sp')/((1-`p')*`sp'+`p'*(1-`se')))
	return scalar pvp = 100*`pvp'
	return scalar pvn = 100*`pvn'
	return scalar eff = 100*(`p'*`se'+(1-`p')*`sp')
end

program define print_error
	args message
	display in red "`message'"
	exit 198
end
