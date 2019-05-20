*! version 1.2.9  14may2019 JM. Domenech, R. Sesma
/*
SAMPLE SIZE & POWER
**PROPORTIONS
   co1p       Comparison of one proportion to a reference (non equal)
   co2p       Comparison of two proportions (non equal)
   c1pe       Comparison of one proportion to a reference (equivalence)
   c2pe       Comparison of two proportions (equivalence)
   copp       Comparison of paired proportions (matched)
**MEANS
   co1m       Comparison of one mean to a reference (non equal)
   co2m       Comparison of two means (non equal)
   c2me       Comparison of two means (equivalence)
   cokm       Comparison of k means (ANOVA)
**ESTIMATIONS
   ci1p       Estimation of population proportion
   ci2p       Estimation of the difference between 2 proportions
   ci1m       Estimation of population mean
   ci2m       Estimation of the difference between 2 means
**CORRELATIONS
   co1c       Comparison of one correlation to a reference
   co2c       Comparison of two correlations
**MISC
   co2r       Comparison of two risks
   co2i       Comparison of two rates
   ncr        Number of communities (Risk): Intervention trials
*/

program define nsize
	version 12
	// get method name and arguments
	_parse comma lhs rhs : 0
	gettoken type lhs : lhs
	if (trim("`lhs'")!="") print_error "invalid syntax"
	if ("`type'"!="co1p" & "`type'"!="co2p" & "`type'"!="c1pe" &	/*
	*/	"`type'"!="c2pe" & "`type'"!="copp" & "`type'"!="co1m" &	/*
	*/	"`type'"!="co2m" & "`type'"!="c2me" & "`type'"!="cokm" &	/*
	*/	"`type'"!="ci1p" & "`type'"!="ci2p" & "`type'"!="ci1m" &	/*
	*/	"`type'"!="ci2m" & "`type'"!="co1c" & "`type'"!="co2c" &	/*
	*/	"`type'"!="co2r" & "`type'"!="co2i" & "`type'"!="ncr")	print_error "type `type' invalid"

	nsize_`type' `rhs'
end

program define nsize_co1p
	version 12
	syntax [anything], p(numlist max=1 >0 <100) /*
	*/	[p1(numlist max=1 >0 <100) EFfect(numlist max=1)			/*
	*/	 Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n(numlist integer max=1 >1) nst(string)]

	nsize_cop co1p, p(`p') p1(`p1') effect(`effect') alpha(`alpha') beta(`beta') n(`n') nst(`nst')
end

program define nsize_co2p
	version 12
	syntax [anything], p0(numlist max=1 >0 <100) /*
	*/	[p1(numlist max=1 >0 <100) EFfect(numlist max=1)			/*
	*/	 Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n(numlist integer max=1 >1) nst(string)]

	nsize_cop co2p, p(`p0') p1(`p1') effect(`effect') alpha(`alpha') beta(`beta') n(`n') nst(`nst')
end

program define nsize_cop, rclass
	version 12
	syntax anything(name=type), p(numlist max=1 >0 <100) /*
	*/	[p1(numlist max=1 >0 <100) EFfect(numlist max=1)			/*
	*/	 Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n(numlist max=1 >1) nst(string)]

	tempname r
	*Check parameters
	if ("`p1'"!="" & "`effect'"!="") print_error "invalid data -- p1 and effect not compatible"
	if ("`p1'"=="" & "`effect'"=="") print_error "invalid data -- missing p1 or effect"
	if ("`p1'"!="") local effect = `p1' - `p'
	if ("`effect'"!="") local p1 = `effect' + `p'
	if (`effect'==0) print_error "effect() invalid -- invalid number, outside of allowed range"
	if ("`alpha'"=="") local alpha 5
	if ("`beta'"!="" & "`n'"!="") print_error "invalid data -- n and beta not compatible"
	if ("`beta'"=="") local beta 20 15 10

	*Title
	di as res "SAMPLE SIZE & POWER DETERMINATION: " /*
	*/	cond("`type'"=="co1p","One single proportion","Two-independent proportions")
	if ("`nst'"!="") display as text "{bf:STUDY:} `nst'"
	*Header
	di
	if ("`type'"=="co1p") {
		di as text "Proportion (%) of events in: Reference Population= `p'%"
		di as text "Proportion (%) of events in:" _col(44) "Sample= `p1'%"
		di as text "Minimun expected effect size:" _col(40) "Difference= `effect'%"
	}
	*Header
	if ("`type'"=="co2p") {
		di as txt "Proportion (%) of events in:" _col(31) "Group 0 = `p'%"
		di as txt _col(31) "Group 1 = `p1'%"
		di as txt "Minimum expected effect size: Difference= `effect'%"
	}

	local warn1 = (`p'<20 | `p1'<20 | `p'>80 | `p1'>80)
	local warn2 0
	local p = `p'/100
	local p1 = `p1'/100
	local effect = `effect'/100
	local rlbl1 = "Normal"
	local rlbl2 = "Normal corrected"
	local rlbl3 = "ArcoSinus"
	local ccols = cond("`type'"=="co1p","SAMPLE SIZE","SAMPLE SIZE by group")

	if ("`n'"=="") {
		*Sample Size
		*Compute results
		local lfirst 1
		foreach i in 2 1 {
			foreach b of numlist `beta' {
				local a = `alpha'/`i'
				nsize__utils get_nsize `p' `p1' `effect', type("`type'") alpha(`a') beta(`b')
				if (`lfirst') matrix `r' = (r(nn) \ r(nc) \ r(na))
				else matrix `r' = (`r' , (r(nn) \ r(nc) \ r(na)))
				if (r(warn)==1) local warn2=1
				local lfirst 0
			}
		}


		*Print & Store results
		local rlbl nn nc na
		local clbl 80_2 85_2 90_2 80_1 85_1 90_1
		local rows = rowsof(`r')
		local cols = colsof(`r')
		local c = cond(`warn1' | `warn2',"*"," ")
		if (`cols'>2) {
			di as txt _newline _col(23) "{c |}{center 44:`ccols'}"
			di as txt "{ralign 22:Alpha Risk=`alpha'%}{c |}{center 21:Two-Sided Test}{c |}" _col(50) "One-Sided Test"
			di as txt " METHOD{ralign 15:Power}{c |}{ralign 6:80%}{ralign 7:85%}{ralign 7:90%} {c |}{ralign 6:80%}{ralign 7:85%}{ralign 7:90%}"
			di as txt "{hline 22}{c +}{hline 21}{c +}{hline 22}" _c
			foreach i of numlist 1/`rows' {
				di as txt _newline "`rlbl`i''" cond(`i'==1,"`c'","") _col(21) "n {c |}" _c
				local c1 : word `i' of `rlbl'
				foreach j of numlist 1/`cols' {
					di as res %6.0f `r'[`i',`j'] " " cond(`j'==3,"{c |}","") _c
					local c2 : word `j' of `clbl'
					return scalar `c1'_`c2' = `r'[`i',`j']
				}
			}
			di as txt _newline "{hline 22}{c BT}{hline 21}{c BT}{hline 22}"
		}
		else {
			di as txt "Alpha Risk = " `alpha' "%;  Beta Risk = " `beta' "% (Power =  " (100-`beta') "%)"
			di
			di as txt _col(20) "{c |}{center 34:`ccols'}"
			display " METHOD" _col(20) "{c |} Two-Sided Test {c |} One-Sided Test"
			display as text "{hline 19}{c +}{hline 16}{c +}{hline 17}"
			foreach i of numlist 1/`rows' {
				di as txt "`rlbl`i''" cond(`i'==1,"`c'","") _col(20) "{c |}" as res /*
				*/	_col(26) %6.0f `r'[`i',1] _col(37) "{c |}" _col(43) %6.0f `r'[`i',2]
				local c1 : word `i' of `rlbl'
				return scalar `c1'_2 = `r'[`i',1]
				return scalar `c1'_1 = `r'[`i',2]
			}
			di as txt "{hline 19}{c BT}{hline 16}{c BT}{hline 17}"
		}
	}
	else {
		*Power
		*Compute results
		local lfirst 1
		foreach i in 2 1 {
			local a = `alpha'/`i'
			nsize__utils get_power `p' `p1' `effect' `n', type("`type'") alpha(`a')
			if (`lfirst') matrix `r' = (r(pn) \ r(pc) \ r(pa))
			else matrix `r' = (`r' , (r(pn) \ r(pc) \ r(pa)))
			if (r(warn)==1) local warn2=1
			local lfirst 0
		}

		*Print results
		local rlbl pn pc pa
		local rows = rowsof(`r')
		local c = cond(`warn1' | `warn2',"*"," ")
		di as txt "Sample size: " cond("`type'"=="co1p","n","n0 = n1") " = `n'"
		di as txt "Alpha Risk = `alpha'%"
		di
		di as txt _col(19) "{c |}" _col(34) "POWER (%)"
		di as txt " METHOD" _col(19) "{c |} Two-Sided Test {c |} One-Sided Test"
		display as text "{hline 18}{c +}{hline 16}{c +}{hline 17}"
		foreach i of numlist 1/`rows' {
			di as txt "`rlbl`i''" cond(`i'==1,"`c'","") _col(19) "{c |}" _c
			local p1 = `r'[`i',1]
			print_pct `p1', nopercent col(25)
			di as txt _col(36) "{c |}" _c
			local p2 = `r'[`i',2]
			print_pct `p2', nopercent col(42) newline
			local c1 : word `i' of `rlbl'
			return scalar `c1'_2 = `r'[`i',1]
			return scalar `c1'_1 = `r'[`i',2]
		}
		di as txt "{hline 18}{c BT}{hline 16}{c BT}{hline 17}"
	}
	if (`warn1' | `warn2') di as txt "(*)WARNING: Applicability conditions for Normal method not granted"
	local c = cond("`type'"=="co1p","P","P0")
	if (`warn2') di as txt _col(13) "N*`c', N*(1-`c'), N*P1 and N*(1-P1) must be >=10"
	if (`warn1') di as txt _col(13) "`c' and P1 must be >=20 and <=80"
end

program define nsize_c1pe
	version 12
	syntax [anything], p0(numlist max=1 >0 <100) p1(numlist max=1 >0 <100)  		/*
	*/	 delta(numlist max=1) [n(numlist integer max=1 >1) Alpha(numlist max=1 >0 <=50) 	/*
	*/	 NONINF SUPER Beta(numlist max=1 >0 <=50) nst(string)]

	nsize_cpe c1pe, p0(`p0') p1(`p1') delta(`delta') n(`n') alpha(`alpha') /*
	*/	beta(`beta') noninf("`noninf'") super("`super'") nst(`nst')
end

program define nsize_c2pe
	version 12
	syntax [anything], p0(numlist max=1 >0 <100) p1(numlist max=1 >0 <100) delta(numlist max=1) /*
	*/	[NONINF SUPER r(numlist max=1 >0) Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n0(numlist integer max=1 >1) n1(numlist integer max=1 >1) nst(string)]

	nsize_cpe c2pe, p0(`p0') p1(`p1') delta(`delta') n0(`n0') n1(`n1') r(`r')  /*
	*/	alpha(`alpha') beta(`beta') noninf("`noninf'") super("`super'") nst(`nst')
end

program define nsize_cpe, rclass
	version 12
	syntax anything(name=type), p0(numlist max=1 >0 <100) p1(numlist max=1 >0 <100) delta(numlist max=1) /*
	*/	[noninf(string) super(string) r(numlist max=1) Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n(numlist max=1 >1) n0(numlist max=1 >1) n1(numlist max=1 >1) nst(string)]

	tempname res

	*Check parameters
	if (`delta'==0) print_error "delta() invalid -- can't be equal to 0"
	*lim: 1 Non-Inferiority, 2 Superiority, 3 Equivalence
	if ("`noninf'"!="" & "`super'"!="") print_error "noninf and super options are incompatible"
	if ("`noninf'"!="") local lim 1
	else if ("`super'"!="") local lim 2
	else local lim 3
	if ("`alpha'"=="") local alpha 5

	local power = ("`type'"=="c1pe" & "`n'"!="") | ("`type'"=="c2pe" & ("`n1'"!="" | "`n0'"!=""))
	if ("`type'" == "c1pe") {
		if ("`beta'"!="" & "`n'"!="") print_error "options beta and n are incompatible"
	}
	if ("`type'" == "c2pe") {
		if ("`beta'"!="" & ("`n1'"!="" | "`n0'"!="")) print_error "options beta and n1/n0 are incompatible"
		if ("`n1'"!="" & "`n0'"!="" & "`r'"!="") print_error "options n1, n0 and r are incompatible"
		if ("`r'"=="") local r 1		//Default
		if (`power') {
			if ("`n1'"!="" & "`n0'"!="") local r = `n0'/`n1'		//Compute r from n0, n1
			if ("`n0'"=="") local n0 = round(`n1'*`r')				//Compute n0 from n1, r
			if ("`n1'"=="") local n1 = round(`n0'/`r')				//Compute n1 from n0, r
		}
	}

	*Title
	di as res "SAMPLE SIZE & POWER DETERMINATION: " /*
	*/	cond("`type'"=="c1pe","One single proportion (equivalence)", /*
	*/	"Two-independent samples (equivalence)")
	if ("`nst'"!="") display as text "{bf:STUDY:} `nst'"
	*Header
	local c = cond(`lim'==1,"Non-Inferiority",cond(`lim'==2,"Superiority","Equivalence"))
	di
	di as txt "Proportion (%) of events in:    Reference Treatment = `p0'%"
	di as txt "Proportion (%) of events in: Experimental Treatment = `p1'%"
	di as txt "{ralign 51:`c' limit} = `delta'%"

	local p0 = `p0'/100
	local p1 = `p1'/100
	local delta = `delta'/100
	if (`lim'==1) {
		local min1 = max(0,`p1'-`p0')
		local max1 = 1-`p0'
		local min2 = -`p0'
		local max2 = min(0,`p1'-`p0')
		local lok = ((`delta'>`min1' & `delta'<`max1') | (`delta'>`min2' & `delta'<`max2'))
	}
	if (`lim'==2) {
		local min1 = min(0,`p1'-`p0')
		local max1 = max(0,`p1'-`p0')
		local lok = ((`delta'>`min1' & `delta'<`max1'))
	}
	if (`lim'==3) {
		local min1 = abs(`p1'-`p0')
		local max1 = min(5.0,100-`p0')
		local lok = ((abs(`delta')>`min1' & abs(`delta')<`max1'))
	}

	if (`lok') {
		if (!`power') {
			*Sample Size
			*Compute results
			if ("`beta'"=="") local beta 20 15 10
			local lfirst 1
			foreach b of numlist `beta' {
				nsize__utils get_nsize `p0' `p1' `delta', type("`type'") alpha(`alpha') beta(`b') lim(`lim') r(`r')
				if ("`type'"=="c1pe") {
					if (`lfirst') matrix `res' = (r(n))
					else matrix `res' = (`res' , r(n))
				}
				if ("`type'"=="c2pe") {
					if (`lfirst') matrix `res' = (r(n0)\r(n1)\r(n))
					else matrix `res' = (`res' , (r(n0)\r(n1)\r(n)))
				}
				local lfirst 0
			}

			*Print & Store results
			local crows n0 n1 n
			local ccols 80 85 90
			local rows = rowsof(`res')
			local cols = colsof(`res')
			local c = "`c' Test"
			if (`cols'==1) di as txt "Alpha Risk = `alpha'%;  Beta Risk = `beta'% (Power = " (100-`beta') "%)"
			if ("`type'"=="c2pe") di as txt cond(`cols'==1,"Ratio n0/n1","{ralign 51:Ratio n0/n1}") " = `r'"
			if (`cols'>1) {
				di as txt _newline _col(5) "Alpha Risk=`alpha'%{c |} {center 20:`c'}"
				di " METHOD     Power{c |}   80%    85%    90%"
				di as txt "{hline 17}{c +}{hline 21}" _c
				foreach i of numlist 1/`rows' {
					if ("`type'"=="c1pe") {
						di as txt _newline " Normal" _col(16) "n {c |}" _c
						local c1 "n"
					}
					if ("`type'"=="c2pe") {
						if (`i'==1) di as txt _newline " Normal" _col(15) "n0 {c |}" _c
						if (`i'==2) di as txt _newline "{ralign 16:n1} {c |}" _c
						if (`i'==3) di as txt _newline "{ralign 16:Total} {c |}" _c
						local c1 : word `i' of `crows'
					}
					foreach j of numlist 1/`cols' {
						di as res %6.0f `res'[`i',`j'] " " _c
						local c2 : word `j' of `ccols'
						return scalar `c1'_`c2' = `res'[`i',`j']
					}
				}
				di as txt _newline "{hline 17}{c BT}{hline 21}"
			}
			else {
				di as txt _newline "SAMPLE SIZE (Normal method)"
				if ("`type'"=="c1pe") {
					di as txt " `c':  n = " as res %7.0f `res'[1,1]
					return scalar n = `res'[1,1]
				}
				if ("`type'"=="c2pe") {
					di as txt "`c'"
					foreach i of numlist 1/`rows' {
						if (`i'==1) di as txt "{ralign 5:n0} = " as res %7.0f `res'[`i',1]
						if (`i'==2) di as txt "{ralign 5:n1} = " as res %7.0f `res'[`i',1]
						if (`i'==3) di as txt "{ralign 5:Total} = " as res %7.0f `res'[`i',1]
						local c1 : word `i' of `crows'
						return scalar `c1' = `res'[`i',1]
					}
				}
			}
		}
		else {
			*Power
			*Compute results
			if ("`type'"=="c1pe") nsize__utils get_power `p0' `p1' `delta' `n', type("`type'") alpha(`alpha') lim(`lim')
			if ("`type'"=="c2pe") nsize__utils get_power `p0' `p1' `delta' `n0' `n1', type("`type'") alpha(`alpha') lim(`lim')

			*Print & Store results
			if ("`type'"=="c1pe") di as txt "Sample size: n = `n'"
			if ("`type'"=="c2pe") di as txt "Sample size: n0 = `n0'; n1 = `n1' (Ratio n0/n1 = `r')"
			di as txt "Alpha Risk = `alpha'%"
			di
			di as txt "POWER (Normal method)"
			di as text " Power = " _c
			print_pct `r(p)'
			di as txt " (Beta Risk = " _c
			local beta = (100-r(p))
			print_pct `beta'
			di as txt ")"
			return scalar p = r(p)
		}
	}
	else {
		di as txt _newline "{bf:WARNING!} Test not computable -- delta(`delta') must be " _c
		if (`lim'==1) di as txt "on the interval (`min1',`max1') or (`min2',`max2')"
		if (`lim'==2) di as txt "on the interval (`min1',`max1')"
		if (`lim'==3) di as txt "greater than `min1'"
	}
end

program define nsize_copp, rclass
	version 12
	syntax [anything], or(numlist max=1 >1)		/*
	*/	[pd(numlist max=1 >0 <100) p0(numlist max=1 >0 <100) ora(numlist max=1 >1)	/*
	*/	 r(numlist max=1 integer >=1) Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n(numlist integer max=1 >1) nst(string)]

	tempname res t
	*Check parameters
	if (("`pd'"!="") & ("`p0'"!="" | "`ora'"!="")) print_error "options p0 & ora are incompatible with option pd"
	if ("`p0'"!="" & "`ora'"=="") print_error "option ora missing"
	if ("`p0'"=="" & "`ora'"!="") _print_error "option p0 missing"
	if ("`r'"=="") local r 1
	if ("`beta'"!="" & "`n'"!="") print_error "invalid data -- n and beta not compatible"
	if ("`n'"!="" & "`pd'"=="" & "`p0'"=="" & "`ora'"=="") print_error "missing option pd(), p0() or ora()"
	if ("`alpha'"=="") local alpha 5
	if ("`beta'"=="") local beta 20 15 10

	local type 0
	if ("`pd'"!="") {
		local pd = `pd'/100
		local type 1
	}
	if ("`p0'"!="" & "`ora'"!="") {
		local type 2
		local p0 = `p0'/100			//Estimate of the Discordant pairs proportion pd
		local p1 = `or'*`p0'/(1+(`or'-1)*`p0')
		local q1 = 1-`p1'
		local pd = ((`or'+1)*`p0'*(1-`p0')/(1+(`or'-1)*`p0'))*((sqrt(1+4*(`ora'-1)*`p1'*`q1')-1)/(2*(`ora'-1)*`p1'*`q1'))
	}
	if ("`pd'"!="") local diff= `pd'*(`or'-1)/(`or'+1)		//Estimate of the difference of proportions P1-P0

	*Title
	di "{bf:SAMPLE SIZE & POWER: Paired proportions}"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	*Header
	di
	di as txt "Expected Response/Exposure Odds Ratio:    OR = " %5.2f `or'
	if (`type'==1) {
		di as txt "{col 5}Proportion Difference (estimated): P1-P0 = " _c
		local v = `diff'*100
		print_pct `v', astxt newline
		di as txt "{col 8}Proportion of Discordant pairs:    Pd = " _c
		local v = `pd'*100
		print_pct `v' , astxt newline
	}
	if (`type'==2) {
		di as txt "{col 5}Proportion Difference (estimated): P1-P0 = " _c
		local v = `diff'*100
		print_pct `v', astxt newline
		di as txt "{col 5}Proportion of exposed in Controls:    P0 = " _c
		local v = `p0'*100
		print_pct `v', astxt newline
		di as txt "{col 19}Marginal Odds Ratio:   ORa = `ora'"
		di as txt "{col 5}Proportion of Discordant pairs"
		di as txt "{col 15}Fleiss-Levin estimation:    Pd = " _c
		local v = `pd'*100
		print_pct `v', astxt newline
	}
	di as txt "{col 21}Ratio of matching:   1:r = 1:`r'"

	if ("`n'"=="") {
		*Sample Size
		*Compute results
		local lfirst 1
		foreach i of numlist 2 1 {
			foreach b of numlist `beta' {
				local a = `alpha'/`i'
				nsize__utils get_nsize `or', type("copp") alpha(`a') beta(`b') r(`r') pd(`pd')
				if (`lfirst') matrix `res' = r(result)
				else matrix `res' = (`res' , r(result))
				local lfirst 0
			}
		}

		*Print & Store results
		local rows = rowsof(`res')
		local cols = colsof(`res')
		if (`cols'==2) di as txt "{col 5}Risk: Alpha = `alpha'%{col 28}Beta = `beta'% (Power = " 100-`beta' "%)"
		di
		if (`cols'>2) {
			di as txt _col(23) "{c |}" _col(40) "SAMPLE SIZE"
			di as txt "{ralign 22:Alpha Risk=`alpha'%}{c |}{center 21:Two-Sided Test}{c |}{center 21:One-Sided Test}"
			di as txt "METHOD" _col(18) "Power{c |}   80%    85%    90% {c |}   80%    85%    90%"
			di as txt "{hline 22}{c +}{hline 21}{c +}{hline 21}"
		}
		else {
			di as txt _col(23) "{c |}" _col(35) "SAMPLE SIZE"
			di as txt "METHOD" _col(23) "{c |} Two-Sided Test {c |} One-Sided Test"
			di as txt "{hline 22}{c +}{hline 16}{c +}{hline 16}"
		}
		local i1 = cond(`cols'>2,45,40)
		local i2 = cond(`cols'>2,21,16)
		foreach i of numlist 1/`rows' {
			if (`i'==1) {
				di as txt "Normal approach" _col(23) "{c |}" _col(`i1') "{c |}"
				if (`cols'>2) {
					di as txt "{ralign 21:Discordant pairs Nd} {c |}" _c
				}
				else {
					if (`r'==1) di as txt "{ralign 21:Discordant pairs Nd} {c |}" _c
					else di as txt "{ralign 21:Discordant    Cases} {c |}" _c
				}
			}
			if ("`pd'"=="") {
				if (`r'==1) {
					if (`i'==2)	di as txt _newline "Continuity correction" _col(23) "{c |}" _col(`i1') "{c |}"
					if (`i'==2)	di as txt "{ralign 21:Discordant pairs Nd} {c |}" _c
				}
				else {
					if (`i'==3)	di as txt _newline "Continuity correction" _col(23) "{c |}" _col(`i1') "{c |}" _c
					if (`i'==3)	di as txt _newline "{ralign 21:Discordant    Cases} {c |}" _c
					if inlist(`i',2,4)	di as txt _newline "{ralign 21:Discordant Controls} {c |}" _c
				}
			}
			else {
				if (`r'==1) {
					if (`i'==3)	di as txt _newline "Continuity correction" _col(23) "{c |}" _col(`i1') "{c |}" _c
					if (`i'==5)	di as txt _newline "Connett approach*" _col(23) "{c |}" _col(`i1') "{c |}" _c
					if inlist(`i',3,5)	di as txt _newline "{ralign 21:Discordant pairs Nd} {c |}" _c
					if inlist(`i',2,4,6)	di as txt _newline "{ralign 21:Total pairs N } {c |}" _c
				}
				else {
					if (`i'==5)	di as txt _newline "Continuity correction" _col(23) "{c |}" _col(`i1') "{c |}" _c
					if (`i'==9)	di as txt _newline "Connett approach*" _col(23) "{c |}" _col(`i1') "{c |}" _c
					if inlist(`i',5,9)	di as txt _newline "{ralign 21:Discordant    Cases} {c |}" _c
					if inlist(`i',2,6,10) di as txt _newline "{ralign 21:Discordant Controls} {c |}" _c
					if inlist(`i',3,7,11) di as txt _newline "{ralign 21:Total    Cases} {c |}" _c
					if inlist(`i',4,8,12) di as txt _newline "{ralign 21:Total Controls} {c |}" _c
				}
			}

			foreach j of numlist 1/`cols' {
				if (`cols'>2) di as res %6.0f `res'[`i',`j'] " " cond(`j'==3,"{c |}","") _c
				else di as res %10.0f `res'[`i',`j'] _col(40) cond(`j'==1,"{c |}","") _c
			}

			if (`i'==1 & "`pd'"=="" & `r'==1) | (`i'==2 & "`pd'"=="" & `r'>1) |		/*
			*/	(`i'==2 & "`pd'"!="" & `r'==1) | (`i'==4 & "`pd'"!="" & `r'==1) |	/*
			*/	(`i'==4 & "`pd'"!="" & `r'>1) | (`i'==8 & "`pd'"!="" & `r'>1) {
				di as txt _newline "{hline 22}{c +}{hline `i2'}{c +}{hline `i2'}" _c
			}
		}
		di as txt _newline "{hline 22}{c BT}{hline `i2'}{c BT}{hline `i2'}"
		if ("`pd'"!="") di as txt "(*) Recommended method"

		//Stored results
		if (`cols'==2) matrix colnames `res' = TwoSided OneSided
		else matrix colnames `res' = TwoSided_80 TwoSided_85 TwoSided_90 OneSided_80 OneSided_85 OneSided_90
		if ("`pd'"=="") {
			if (`r'==1) local names nd_normal nd_corr
			else local names nd_norm contr_norm cases_corr contr_corr
		}
		else {
			if (`r'==1) local names nd_normal n_normal nd_corr n_corr nd_connett n_connett
			else local names nd_norm dcontr_norm tcases_norm tcontr_norm	///
							dcases_corr dcontr_corr tcases_corr tcontr_corr		///
							dcases_conn dcontr_conn tcases_conn tcontr_conn
		}
		matrix rownames `res' = `names'
		return matrix Size = `res'
	}
	else {
		*Power
		*Compute results
		foreach i of numlist 1/2 {
			local a = `alpha'/`i'
			nsize__utils get_power `or' `n' `r' `pd', type("copp") alpha(`a')
			local p`i' = r(p)
		}

		*Print & Store results
		di as txt _col(3) "Sample Size (Total number of Cases):     n = `n'"
		di as txt _newline "METHOD: Normal (Connett approach)"
		di as txt _newline " Alpha Risk = `alpha'%{col 20}{c |}  POWER"
		di as txt "{hline 19}{c +}{hline 9}"
		di as txt "  Two-Sided Test{col 20}{c |}  " _c
		print_pct `p2', newline
		di as txt "  One-Sided Test{col 20}{c |}  " _c
		print_pct `p1', newline
		di as txt "{hline 19}{c BT}{hline 9}"
		return scalar p2 = `p2'
		return scalar p1 = `p1'
	}
end

program define nsize_co1m
	version 12
	syntax [anything], sd(numlist max=1 >0) /*
	*/	[EFfect(numlist max=1) Alpha(numlist max=1 >0 <=50)			/*
	*/	 Beta(numlist max=1 >0 <=50) n(numlist integer max=1 >1)		/*
	*/	 nst(string)]

	nsize_com co1m, sd(`sd') effect(`effect') alpha(`alpha') beta(`beta') n(`n') nst(`nst')
end

program define nsize_co2m
	version 12
	syntax [anything], sd(numlist max=1 >0) /*
	*/	[EFfect(numlist max=1) Alpha(numlist max=1 >0 <=50)			/*
	*/	 Beta(numlist max=1 >0 <=50) n0(numlist integer max=1 >1)		/*
	*/	 n1(numlist integer max=1 >1) r(numlist max=1 >0) nst(string)]

	nsize_com co2m, sd(`sd') effect(`effect') alpha(`alpha') beta(`beta') n0(`n0') n1(`n1') r(`r') nst(`nst')
end

program define nsize_c2me
	version 12
	syntax [anything], sd(numlist max=1 >0) /*
	*/	[EQlim(numlist max=1 >0) Alpha(numlist max=1 >0 <=50)			/*
	*/	 Beta(numlist max=1 >0 <=50) n(numlist integer max=1 >1)		/*
	*/	 nst(string)]

	nsize_com c2me, sd(`sd') eqlim(`eqlim') alpha(`alpha') beta(`beta') n(`n') nst(`nst')
end

program define nsize_com, rclass
	version 12
	syntax anything(name=type), sd(numlist) /*
	*/	[effect(numlist) eqlim(numlist) r(numlist) alpha(numlist) 	/*
	*/	 beta(numlist) n(numlist) n0(numlist) n1(numlist) nst(string)]

	tempname res

	*Check parameters
	if ("`type'"=="co1m" & "`effect'"=="" & "`n'"=="") print_error "missing option effect or n"
	if ("`type'"=="co2m" & "`effect'"=="" & "`n1'"=="") print_error "missing option effect or n1"
	if ("`type'"=="c2me" & "`eqlim'"=="" & "`n'"=="") print_error "missing option eqlim or n"
	if (("`type'" == "co1m" | "`type'" == "co2m") & ("`effect'"!="")) {
		if (`effect'==0) print_error "effect() invalid -- invalid number, outside of allowed range"
	}
	if ("`type'" == "co2m") {
		if ("`n1'"!="" & "`n0'"!="" & "`r'"!="") print_error "options n1, n0 and r are incompatible"
		if ("`r'"=="") local r 1		//Default
		if ("`n0'"!="" | "`n1'"!="") {
			if ("`n1'"!="" & "`n0'"!="") local r = `n0'/`n1'		//Compute r from n0, n1
			if ("`n0'"=="") local n0 = round(`n1'*`r')				//Compute n0 from n1, r
			if ("`n1'"=="") local n1 = round(`n0'/`r')				//Compute n1 from n0, r
		}
	}
	if ("`alpha'"=="") local alpha 5

	*Title
	if ("`type'" == "co1m") di as txt "{bf:SAMPLE SIZE (MEAN) & POWER DETERMINATION: One sample}"
	if ("`type'" == "co2m") di as txt "{bf:SAMPLE SIZE (MEAN) & POWER DETERMINATION: Two-independent samples}"
	if ("`type'" == "c2me") di as txt "{bf:SAMPLE SIZE (EQUIVALENCE MEANS) & POWER DETERMINATION: Two-independent samples}"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	di
	di as txt "Common standard deviation = `sd'"
	if ("`effect'"!="") di as txt "Minimum expected effect size = `effect'"
	if ("`eqlim'"!="")  di as txt "Equivalence limits = `eqlim'"

	local warning 0
	if ((("`type'"=="co1m" | "`type'"=="c2me") & "`n'"=="") | 	/*
	*/	("`type'"=="co2m" & "`n1'"=="" & "`n0'"=="")) {
		*Sample Size
		*Compute results
		if ("`beta'"=="") local beta 20 15 10
		local lfirst 1
		foreach i of numlist 2 1 {
			foreach b of numlist `beta' {
				if ("`type'"=="co1m" | "`type'"=="co2m") local a = `alpha'/`i'
				else local a = `alpha'
				if ("`type'"=="c2me") local b = `b'/`i'
				nsize__utils get_nsize `sd' `effect' `eqlim', type(`type') alpha(`a') beta(`b') r(`r')
				if ("`type'"=="co1m" | "`type'"=="c2me") {
					if (`lfirst') matrix `res' = (r(n))
					else matrix `res' = (`res' , r(n))
				}
				if ("`type'"=="co2m") {
					if (`lfirst') matrix `res' = (r(n0) \ r(n1) \ r(n))
					else matrix `res' = (`res' , (r(n0) \ r(n1) \ r(n)))
				}
				local lfirst 0
				if r(warn) local warning 1
			}
		}

		*Print results
		local rows = rowsof(`res')
		local cols = colsof(`res')
		local rlbl1 = cond("`type'"=="co2m","n0","n")
		local rlbl2 "n1"
		local rlbl3 "Total"
		local crows = cond("`type'"=="co2m","n0 n1 n","n")
		if (`cols'>2) {
			local ccols = "80_2 85_2 90_2 80_1 85_1 90_1"
			local c = cond("`type'"=="c2me","by group","")
			if ("`type'"=="co2m") di as txt "Ratio n0/n1 = `r'"
			local c1 = cond("`type'"=="c2me","Equivalence Test","Two-Sided Test")
			local c2 = cond("`type'"=="c2me","Non-inferiority Test","One-Sided Test")

			di
			if ("`type'"=="co1m" | "`type'"=="c2me") di as txt _col(15) "{c |}{center 45:SAMPLE SIZE `c'}"
			di as txt "{ralign 14:Alpha Risk=`alpha'%}{c |}{center 22:`c1'}{c |}{center 22:`c2'}"
			di as txt "{ralign 14:Power}{c |}{ralign 6:80}%{ralign 6:85}%{ralign 6:90}% {c |}{ralign 6:80}%{ralign 6:85}%{ralign 6:90}%"
			di as txt "{hline 14}{c +}{hline 22}{c +}{hline 22}" _c
			foreach i of numlist 1/`rows' {
				di as txt _newline "{ralign 13:`rlbl`i''} {c |}" _c
				local c1 : word `i' of `crows'
				foreach j of numlist 1/`cols' {
					di as res %6.0f `res'[`i',`j'] " " cond(`j'==3," {c |}","") _c
					local c2 : word `j' of `ccols'
					return scalar `c1'_`c2' = `res'[`i',`j']
				}
			}
			di as txt _newline "{hline 14}{c BT}{hline 22}{c BT}{hline 22}"
		}
		else {
			local ccols = "2 1"
			local power = 100-`beta'
			di as txt "Alpha Risk = `alpha'%;  Beta Risk = `beta'% (Power = `power'%)"
			if ("`type'"=="co2m") di as txt "Ratio n0/n1 = `r'"
			di
			if ("`type'"=="co1m" | "`type'"=="co2m") {
				di as txt "SAMPLE SIZE"
				if ("`type'"=="co1m") {
					foreach i of numlist 1/`cols' {
						local v = `res'[1,`i']
						di as txt " " cond(`i'==1,"Two","One") "-Sided Test:  N = " %7.0f `v' cond(`v'<30,"*","")
					}
				}
				if ("`type'"=="co2m") {
					di as txt "Two-Sided Test" _col(22) "One-Sided Test" _c
					foreach i of numlist 1/`rows' {
						di as txt _newline "{ralign 5:`rlbl`i''} = " _c
						foreach j of numlist 1/`cols' {
							di as res %6.0f `res'[`i',`j'] cond(`res'[`i',`j']<30,"*","") _c
							if (`j'==1) di as txt _col(22) "{ralign 5:`rlbl`i''} = " _c
						}
					}
					di
				}
			}
			if ("`type'"=="c2me") {
				foreach i of numlist 1/`cols' {
					local v = `res'[1,`i']
					if (`i'==1) di as txt "EQUIVALENCE (Two One-Sided Test)"
					if (`i'==2) di as txt "NON INFERIORITY (One-Sided Test)"
					di as txt " Size by group:  N =" as res %7.0f `v' cond(`v'<30,"*","") /*
					*/			_col(32) as txt "(Total=" as res %7.0f `v'*2 as txt ")"
					if (`i'==1) di
				}
			}
			local c "(*)"
		}

		//Store results
		foreach i of numlist 1/`rows' {
			local c1 : word `i' of `crows'
			foreach j of numlist 1/`cols' {
				local c2 : word `j' of `ccols'
				return scalar `c1'_`c2' = `res'[`i',`j']
			}
		}
	}
	else {
		*Print n/n0/n1
		if ("`type'"=="co1m" | "`type'"=="c2me") {
			di as txt "Sample size" cond("`type'"=="c2me"," (by group)","") /*
			*/			" = `n'" cond(`n'<30,"*","")
			if (`n'<30) local warning 1
		}
		if ("`type'"=="co2m") {
			local c_r = trim(string(`r',"%5.0g"))
			di as txt "Sample size: n0 = `n0'" cond(`n0'<30,"*"," ") /*
			*/			" ; n1 = `n1'" cond(`n1'<30,"*"," ") /*
			*/			"  (Ratio n0/n1 = `c_r')"
			if (`n0'<30 | `n1'<30) local warning 1
		}
		local c "(*)"
		if ((("`type'"=="co1m" | "`type'"=="co2m") & "`effect'"!="") | 	/*
		*/	("`type'"=="c2me" & "`eqlim'"!="")) {
			*Power
			*Compute results
			if ("`type'"=="co1m" | "`type'"=="co2m") {
				foreach i in 2 1 {
					local a = `alpha'/`i'
					nsize__utils get_power `sd' `effect' `n' `n1' `r', type("`type'") alpha(`a')
					local beta`i' = r(beta)
				}
			}
			if ("`type'"=="c2me") {
				nsize__utils get_power `sd' `eqlim' `n', type("`type'") alpha(`alpha')
				local beta1 = r(beta)
				local beta2 = 2*r(beta)
			}

			*Print & Store results
			di as txt "Alpha Risk = `alpha'%"
			di
			di as txt "POWER"
			local pow2 = (100-`beta2')
			di as txt " Two-Sided Test: Pow = " _c
			print_pct `pow2'
			di as txt " (Beta Risk = " _c
			print_pct `beta2'
			di as txt ")"
			local pow1 = (100-`beta1')
			di as txt " One-Sided Test: Pow = " _c
			print_pct `pow1'
			di as txt " (Beta Risk = " _c
			print_pct `beta1'
			di as txt ")"

			return scalar p1 = 100-`beta1'
			return scalar p2 = 100-`beta2'
		}
		else {
			*Effect
			*Compute results
			if ("`beta'"=="") local beta 20 15 10
			local lfirst 1
			foreach b of numlist `beta' {
				foreach i of numlist 2 1 {
					if ("`type'"=="co1m" | "`type'"=="co2m") local a = `alpha'/`i'
					else local a = `alpha'
					if ("`type'"=="c2me") local be = `b'/`i'
					else local be = `b'
					nsize__utils get_effect `sd' `n' `n1' `r', type(`type') alpha(`a') beta(`be')
					local e`i' = r(effect)
				}
				if (`lfirst') matrix `res' = (`e2',`e1')
				else matrix `res' = `res' \ (`e2',`e1')
				local lfirst 0
			}

			*Print results
			local rows = rowsof(`res')
			local cols = colsof(`res')
			local c1 = cond("`type'"=="c2me","Equivalence Test","Two-Sided Test")
			local c2 = cond("`type'"=="c2me","Non-inferiority Test","One-Sided Test")
			local c3 = cond("`type'"=="c2me","Equivalence limits","Minimum effect size")
			if (`rows'>1) {
				local rlbl1 "Power  80%"
				local rlbl2 "85%"
				local rlbl3 "90%"
				di
				di as txt "{ralign 12:Alpha Risk} {c |}{center 21:`c1'}{c |}{center 21:`c2'}"
				di as txt "{ralign 12:= `alpha'%} {c |}{center 21:`c3'}{c |}{center 21:`c3'}"
				di as txt "{hline 13}{c +}{hline 21}{c +}{hline 21}" _c
				foreach i of numlist 1/`rows' {
					di as txt _newline "{ralign 12:`rlbl`i''} {c |} " _c
					foreach j of numlist 1/`cols' {
						di as res %13.3f `res'[`i',`j'] _c
						if (`j'==1) di as txt _col(36) "{c |} " _c
					}
				}
				di as txt _newline "{hline 13}{c BT}{hline 21}{c BT}{hline 21}"
			}
			else {
				di as txt "Alpha Risk = `alpha'%;  Beta Risk = `beta'% (Power = " 100-`beta' "%)"
				di
				di as txt upper("`c3'")
				foreach i of numlist 1/2 {
					di as txt " " cond(`i'==1,"Two","One") "-Sided Test:  " /*
					*/		cond("`type'"=="c2me","Eq","Effect") " = " as res %9.0g `res'[1,`i']
				}
			}

			//Store results
			local crows = cond(`rows'>1,"_80 _85 _90","")
			local ccols = "_2 _1"
			local name = cond("`type'"=="c2me","eq","eff")
			foreach i of numlist 1/`rows' {
				local c1 : word `i' of `crows'
				foreach j of numlist 1/`cols' {
					local c2 : word `j' of `ccols'
					return scalar `name'`c1'`c2' = `res'[`i',`j']
				}
			}
		}
	}
	if (`warning') di as txt "`c'WARNING: Normal assumption required for small size (N<30)"
end

program define nsize_cokm, rclass
	version 12
	syntax [anything], sd(numlist max=1 >0) /*
	*/	[Means(numlist max=12 >0) EFfect(numlist max=1) /*
	*/	 c(numlist integer max=1 >0) nk(numlist integer max=12 >1) nst(string)]

	if ("`means'"=="" & "`effect'"=="" & "`c'"=="") print_error "option means or effect & c missing"
	if ("`means'"!="" & ("`effect'"!="" | "`c'"!="")) print_error "option means is incompatible with effect or c"
	if ("`means'"=="") {
		if ("`effect'"=="" | "`c'"=="") print_error "option effect or c missing"
		if (`effect'==0) ns_print_error "effect() invalid -- invalid number, outside of allowed range"
	}
	local ns : list sizeof nk
	local ms : list sizeof means
	if ("`nk'"!="") {
		if ("`means'"!="" & `ms'!=`ns') print_error "means and nk must have the same number of elements"
		if ("`means'"=="" & `ns'!= 1) print_error "nk() invalid -- list not allowed"
	}

	*Title
	di as txt "{bf:SAMPLE SIZE (MEAN) & POWER: k-independents samples (ANOVA)}"
	if ("`nst'"!="") display as text "{bf:STUDY:} `nst'"

	*Header
	di
	di as txt "Common standard deviation = `sd'"
	if ("`means'"=="") {
		di as txt "Minimum expected effect size = `effect'"
		di as text "Number of pairwise comparisons = `c'"
		if ("`nk'"!="") di as text "Sample size by group = `nk'"
	}
	else {
		if ("`nk'"=="") di as txt "Hypothetical Means:"
		else di as txt _col(15) "Means" _col(24) "n"
		foreach i of numlist 1/`ms' {
			local j = cond(`i'<10,"0`i'","`i'")
			local m : word `i' of `means'
			local n : word `i' of `nk'
			if ("`nk'"=="") di as txt "{ralign 12:Group `j'} = " %9.0g `m'
			else di as txt "Group `j': " %9.0g `m' " " %4.0f `n'
		}
	}

	if ("`nk'"=="") {
		*Sample Size
		*Compute results
		tempname res
		nsize__utils get_nsize `sd' `c' `effect', type(cokm) means(`means')
		matrix `res' = r(result)
		*Print & Store results
		di
		di as txt _col(14) "{c |}" _col(28) "SAMPLE SIZE by group"
		di as txt "{ralign 13:Alpha}{c |}{center 22:Risk=5%}{c |}{center 22:Risk=1%}"
		di as txt "{ralign 13:Power}{c |}    80%    85%    90% {c |}    80%    85%    90%"
		di as txt "{hline 13}{c +}{hline 22}{c +}{hline 22}"
		di as txt "{ralign 12:n} {c |}" _c
		foreach i of numlist 1/6{
			di as res %6.0f `res'[1,`i'] " " cond(`i'==3," {c |}","") _c
		}
		di as txt _newline "{hline 13}{c BT}{hline 22}{c BT}{hline 22}"
		if (r(warning)==1) di as txt "WARNING: Normal assumption required for small size (N<30)"
		local names "80_5 85_5 90_5 80_1 85_1 90_1"
		foreach i of numlist 1/6{
			local n : word `i' of `names'
			return scalar n_`n' = `res'[1,`i']
		}
	}
	else {
		*Power, Print & Store results
		nsize__utils get_power `sd' `c' `effect', type(cokm) means(`means') nk(`nk')
		di
		di as txt "Alpha   Power"
		di as txt "   5%   " _c
		print_pct `r(p5)', newline
		di as txt "   1%   " _c
		print_pct `r(p1)', newline
		return scalar p5 = r(p5)
		return scalar p1 = r(p1)
	}
end

program define nsize_ci1p
	version 12
	syntax [anything], p0(numlist >0 <100) 		/*
	*/	[APre(numlist) ns(numlist integer >1)  	/*
	*/	 cl(numlist >=50 <100) n(numlist integer >1) nst(string)]

	nsize_ci ci1p, p0(`p0') apre(`apre') ns(`ns') cl(`cl') n(`n') nst(`nst')
end

program define nsize_ci2p
	version 12
	syntax [anything], p0(numlist max=1 >0 <100) p1(numlist max=1 >0 <100)	/*
	*/	[APre(numlist) r(numlist max=1 >0) cl(numlist >=50 <100)  	/*
	*/	 n0(numlist max=1 integer >1) n1(numlist max=1 integer >1) nst(string)]

	nsize_ci ci2p, p0(`p0') p1(`p1') apre(`apre') n0(`n0') n1(`n1') r(`r') cl(`cl') nst(`nst')
end

program define nsize_ci1m
	version 12
	syntax [anything], sd(numlist max=1 >0)		/*
	*/	[APre(numlist) ns(numlist max=1 integer >1)  	/*
	*/	 cl(numlist >=50 <100) n(numlist integer >1) nst(string)]

	nsize_ci ci1m, sd(`sd') apre(`apre') ns(`ns') cl(`cl') n(`n') nst(`nst')
end

program define nsize_ci2m
	version 12
	syntax [anything], sd(numlist max=1 >0)		/*
	*/	[APre(numlist) n0(numlist max=1 integer >1) n1(numlist max=1 integer >1)  	/*
	*/	 cl(numlist >=50 <100) r(numlist max=1 >0) nst(string)]

	nsize_ci ci2m, sd(`sd') apre(`apre') n0(`n0') n1(`n1') r(`r') cl(`cl') nst(`nst')
end

program define nsize_ci, rclass
	version 12
	syntax anything(name=type), [p0(numlist) p1(numlist) sd(numlist) 	/*
	*/	apre(numlist) ns(numlist) cl(numlist) n(numlist) 	/*
	*/	n0(numlist) n1(numlist) r(numlist) nst(string)]

	if ("`apre'"!="") {
		local i : list sizeof p0
		if (`i'>1) print_error "p0() invalid -- single number required"
		foreach a of numlist `apre' {
			if ("`type'" == "ci1p" | "`type'" == "ci2p") {
				local t1 = `p0' + `a'
				local t2 = `p0' - `a'
				if (`t1'<=0 | `t1'>=100 | `t2'<= 0 | `t2'>=100) print_error "apre() invalid -- p0 {c 177} apre outside of allowed range"
			}
		}
	}
	if ("`type'" == "ci1p" | "`type'" == "ci1m") {
		if ("`apre'"!="" & "`ns'"!="") print_error "options apre and ns are incompatible"
		if ("`apre'"=="" & "`ns'"=="") print_error "missing option apre or ns"
		if ("`ns'"!="" & "`n'"!="") {
			foreach ni of numlist `ns' {
				if (`n'<=`ni') print_error "n must be greater than ns"
			}
		}
	}
	else {
		if ("`apre'"!="" & ("`n1'"!="" | "`n0'"!="")) print_error "options n1, n0 and apre are incompatible"
		if ("`apre'"=="" & "`n1'"=="" & "`n0'"=="") print_error "missing option apre or n1,n0"
		if ("`n1'"!="" & "`n0'"!="" & "`r'"!="") print_error "options n1, n0 and r are incompatible"
		if ("`r'"=="") local r 1		//Default
		if ("`n0'"!="" | "`n1'"!="") {
			if ("`n0'"!="" | "`n1'"!="") {
				if ("`n1'"!="" & "`n0'"!="") local r = `n0'/`n1'		//Compute r from n0, n1
				if ("`n0'"=="") local n0 = round(`n1'*`r')				//Compute n0 from n1, r
				if ("`n1'"=="") local n1 = round(`n0'/`r')				//Compute n1 from n0, r
			}
		}
	}
	if ("`cl'"=="") {
		if ("`type'"=="ci1p") {
			if ("`apre'"!="") local cl 90 95 99
			if ("`ns'"!="") local cl 95
		}
		if ("`type'"=="ci2p" | "`type'"=="ci2m") local cl 90 95 97.5 99
		if ("`type'"=="ci1m") local cl 90 95 99
	}

	*Title
	if ("`type'" == "ci1p") di as res "SAMPLE SIZE: Estimation of population proportion"
	if ("`type'" == "ci2p") di as res "SAMPLE SIZE: CI of difference between two proportions (independent samples)"
	if ("`type'" == "ci1m") di as res "SAMPLE SIZE: Estimation of population mean"
	if ("`type'" == "ci2m") di as res "SAMPLE SIZE: Difference between two means (independent samples)"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	*Header
	di
	if ("`type'" == "ci1p") {
		if ("`apre'"!="") di as txt "Supposed Population Proportion = `p0'%"
		if ("`ns'"!="") di as txt "Confidence level = `cl'%"
		di as txt "Population Size = " cond("`n'"!="","`n'","INFINITE")
	}
	if ("`type'" == "ci2p") {
		local c = cond(`p0'==50 & `p1'==50,"(conservative option)","")
		di as txt "Supposed proportion of events in Population 0 = `p0'% `c'"
		di as txt "Supposed proportion of events in Population 1 = `p1'% `c'"
		di as txt "Ratio n0/n1 = " trim(string(`r',"%5.0g"))
	}
	if ("`type'" == "ci1m") {
		di as txt "Supposed Standard Deviation = `sd'"
		if ("`ns'"!="") di as txt "Sample Size = `ns'"
		di as txt "Population Size = " cond("`n'"!="","`n'","INFINITE")
	}
	if ("`type'" == "ci2m") {
		di as txt "Supposed Standard Deviation = `sd'"
		di as txt "Ratio n0/n1 = " trim(string(`r',"%5.0g"))
	}
	di as txt "NORMAL method"
	di

	*Compute results
	tempname res t
	if ("`apre'"!="") {
		*Sample Size
		*Compute results
		local nrows : list sizeof apre
		local ncols : list sizeof cl
		local z = cond("`type'"=="ci2p" | "`type'"=="ci2m",3,1)
		matrix `res' = J(`z'*`nrows',`ncols',.)
		local i 1
		foreach a of numlist `apre' {
			local j 1
			foreach c of numlist `cl' {
				nsize__utils get_nsize `p0' `p1' `sd' `a' `c', type("`type'") n(`n') r(`r')
				if ("`type'" == "ci1p" | "`type'" == "ci1m") matrix `res'[`i',`j'] = r(n)
				if ("`type'" == "ci2p" | "`type'" == "ci2m") {
					matrix `res'[`i',`j'] = r(n0)
					matrix `res'[`i'+1,`j'] = r(n1)
					matrix `res'[`i'+2,`j'] = r(n)
				}
				local j = `j'+1
			}
			local i = `i'+`z'
		}

		*Print & Store results
		local rows = rowsof(`res')
		local cols = colsof(`res')
		if ("`type'"=="ci1p") {
			local pos = cond(`cols'==1,22,30)
			di as txt "  PRECISION of CI   {c |}SAMPLE SIZE"
			di as txt "Relative   Absolute {c |}{col `pos'}Confidence level"
			di as txt " ({c 177} e/P){col 15}({c 177} e) {c |}" _c
			if (`cols'>1) {
				di as txt "{ralign 8:90}% {c |}{ralign 8:95}% {c |}{ralign 8:99}%"
				di as txt "{hline 20}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}" _c
			}
			else {
				di as txt "{ralign 9:`cl'}%"
				di as txt "{hline 20}{c +}{hline 16}" _c
			}
			foreach i of numlist 1/`rows' {
				local a : word `i' of `apre'
				di _newline _col(3) as res %5.0g 100*(`a'/`p0') as txt "%" /*
				*/		as res _col(14) %5.0g `a' as txt "% {c |} " _c
				foreach j of numlist 1/`cols' {
					di as res %8.0f `res'[`i',`j'] cond(`j'!=`cols'," {c |} ","") _c
				}
			}
			if (`cols'>1) di as txt _newline "{hline 20}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}"
			else di as txt _newline "{hline 20}{c BT}{hline 16}"
			matrix rownames `res' = `apre'
			matrix colnames `res' = `cl'
		}
		if ("`type'"=="ci1m") {
			local pos = cond(`cols'==1,12,20)
			di as txt _col(11) "{c |}SAMPLE SIZE"
			di as txt "PRECISION {c |}{col `pos'}Confidence level"
			di as txt "of CI({c 177}e) {c |}" _c
			if (`cols'>1) {
				di as txt "{ralign 8:90}% {c |}{ralign 8:95}% {c |}{ralign 8:99}%"
				di as txt "{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}" _c
			}
			else {
				di as txt "{ralign 9:`cl'}%"
				di as txt "{hline 10}{c +}{hline 16}" _c
			}
			foreach i of numlist 1/`rows' {
				local a : word `i' of `apre'
				di _newline as res %9.0g `a' " {c |} " _c
				foreach j of numlist 1/`cols' {
					di as res %8.0f `res'[`i',`j'] cond(`j'!=`cols'," {c |} ","") _c
				}
			}
			if (`cols'>1) di as txt _newline "{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}"
			else di as txt _newline "{hline 10}{c BT}{hline 16}"
			matrix rownames `res' = `apre'
			matrix colnames `res' = `cl'
		}
		if ("`type'"=="ci2p" | "`type'"=="ci2m") {
			local pos = cond(`cols'==1,18,32)
			if (`cols'==1) local line "{hline 16}{c +}{hline 18}"
			else local line "{hline 16}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}"

			di as txt _col(17) "{c |}NUMBER of subjects"
			di as txt "PRECISION" _col(17) "{c |}{col `pos'}Confidence level"
			di as txt "of CI({c 177}d){col 12}Group{c |}" _c
			if (`cols'>1) di as txt "{ralign 8:90}% {c |}{ralign 8:95}% {c |}{ralign 8:97.5}% {c |}{ralign 8:99}%"
			else di as txt "{ralign 9:`cl'}%"
			di as txt "`line'" _c

			local rownames
			local z 1
			foreach a of numlist `apre' {
				di as txt _newline _col(4) as res %5.0g `a' as txt cond("`type'"=="ci2p","%","") _c
				foreach i of numlist 1/3 {
					local c = cond(`i'==1,"n0",cond(`i'==2,"n1","Total"))
					if (`i'>1) di as txt _newline _c
					di as txt _col(11) "{ralign 5:`c'} {c |} " _c
					foreach j of numlist 1/`cols' {
						local row = `i'+3*(`z'-1)
						di as res %8.0f `res'[`row',`j'] cond(`j'<`cols'," {c |} ","") _c
					}
					local rownames = "`rownames' `c'_`a'"
				}
				local z = `z'+1
				if (`row'<`rows') di as txt _newline "`line'" _c
			}
			local line = subinstr("`line'","+","BT",.)
			di as txt _newline "`line'"

			matrix colnames `res' = `cl'
			matrix rownames `res' = `rownames'
		}

		return matrix Size = `res'
	}
	else {
		*Precission of CI (Power)
		*Compute results
		if ("`type'"=="ci1p") {
			local nrows : list sizeof ns
			local ncols : list sizeof p0
			matrix `res' = J(`nrows',`ncols',.)
			local i 1
			foreach ni of numlist `ns' {
				local j 1
				foreach p of numlist `p0' {
					nsize__utils get_power `p' `ni' `cl', type("`type'") nk(`n')
					matrix `res'[`i',`j'] = r(p)
					local j = `j'+1
				}
				local i = `i'+1
			}
		}
		else {
			local i 1
			local ncols : list sizeof cl
			matrix `res' = J(1,`ncols',.)
			foreach c of numlist `cl' {
				if ("`type'"=="ci2p") nsize__utils get_power `p0' `p1' `n1' `r' `c', type("`type'")
				if ("`type'"=="ci1m") nsize__utils get_power `sd' `ns' `c', type("`type'") nk(`n')
				if ("`type'"=="ci2m") nsize__utils get_power `sd' `n1' `r' `c', type("`type'")
				matrix `res'[1,`i'] = r(p)
				local i = `i'+1
			}
		}

		*Print & Store results
		local rows = rowsof(`res')
		local cols = colsof(`res')
		if ("`type'"=="ci1p") {
			di as txt _col(9) "{c |}PRECISION of CI ({c 177}e)"
			di as txt " Sample {c |}Supposed Population Proportion"
			di as txt "   Size {c |}" _c
			foreach p of numlist `p0' {
				di as txt "{ralign 6:`p'}% " _c
			}
			local len = (`cols'*8) - 1
			di as txt _newline "{hline 8}{c +}{hline `len'}" _c
			foreach i of numlist 1/`rows' {
				local ni : word `i' of `ns'
				di as txt _newline %7.0f `ni' " {c |}" _c
				foreach j of numlist 1/`cols' {
					local v = `res'[`i',`j']
					di " " _c
					print_pct `v'
					di " " _c
					*di as res %6.2f `res'[`i',`j'] as txt "% " _c
				}
				if (`i'<`rows') di as txt _newline "{hline 8}{c +}{hline `len'}" _c
				else di as txt _newline "{hline 8}{c BT}{hline `len'}" _c
			}
			di

			matrix rownames `res' = `ns'
			matrix colnames `res' = `p0'
			return matrix Precision = `res'
		}
		if ("`type'"=="ci1m") {
			local pos = cond(`cols'>1,18,10)
			di as txt _col(9) "{c |}PRECISION of CI ({c 177}e)"
			di as txt " Sample {c |}Confidence level"
			di as txt "   Size {c |}" _c
			if (`cols'>1) {
				di as txt "{ralign 8:90}% {c |}{ralign 8:95}% {c |}{ralign 8:99}%"
				di as txt "{hline 8}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}"
			}
			else {
				di as txt "{ralign 9:`cl'}%"
				di as txt "{hline 8}{c +}{hline 16}"
			}
			di as txt %7.0f `ns' " {c |} " _c
			foreach j of numlist 1/`cols' {
				di as res %7.2f `res'[1,`j'] cond(`j'<`cols',"  {c |} ","") _c
			}
			if (`cols'>1) di as txt _newline "{hline 8}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}"
			else di as txt _newline "{hline 8}{c BT}{hline 16}"

			foreach i of numlist 1/`cols' {
				local c : word `i' of `cl'
				local c = subinstr("`c'",".","",.)
				return scalar p_`c' = `res'[1,`i']
			}
		}
		if ("`type'"=="ci2p" | "`type'"=="ci2m") {
			local pos = cond(`cols'>1,25,15)
			di as txt _col(14) "{c |}PRECISION of CI ({c 177}d)"
			di as txt "{ralign 12:Sample} {c |}" _col(`pos') "Confidence level"
			di as txt "Group   Size {c |}" _c
			if (`cols'>1) {
				di as txt "{ralign 6:90}% {c |}{ralign 6:95}% {c |}{ralign 6:97.5}% {c |}{ralign 6:99}%"
				di as txt "{hline 13}{c +}{hline 8}{c +}{hline 8}{c +}{hline 8}{c +}{hline 8}"
			}
			else {
				di as txt "{ralign 9:`cl'}%"
				di as txt "{hline 13}{c +}{hline 16}"
			}
			di as txt " n0 " %8.0f `n0' " {c |} " _c
			foreach i of numlist 1/`cols' {
				if ("`type'"=="ci2p") {
					local v = `res'[1,`i']
					if (`cols'==1) di as txt "   " _c
					print_pct `v'
					di as txt " " _c
				}
				else {
					local fmt = cond(`cols'>1,"%5.2f","%8.2f")
					di as res `fmt' `res'[1,`i'] as txt "  " _c
				}
				di as txt cond(`i'<`cols',"{c |} ","") _c
			}
			di as txt _newline " n1 " %8.0f `n1' " {c |}" _c
			if (`cols'>1) di as txt _col(23) "{c |}" _col(32) "{c |}"_col(41) "{c |}" _c
			if (`cols'>1) di as txt _newline "{hline 13}{c BT}{hline 8}{c BT}{hline 8}{c BT}{hline 8}{c BT}{hline 8}"
			else di as txt _newline "{hline 13}{c BT}{hline 16}"

			foreach i of numlist 1/`cols' {
				local c : word `i' of `cl'
				local c = subinstr("`c'",".","",.)
				return scalar p_`c' = `res'[1,`i']
			}
		}
	}
end

program define nsize_co1c
	version 12
	syntax [anything], cr(numlist max=1 >-1 <1) /*
	*/	[cr1(numlist max=1 >-1 <1) EFfect(numlist max=1 >-1 <1)		/*
	*/	 Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n1(numlist integer max=1 >3) nst(string)]

	nsize_cor co1c, cr(`cr') cr1(`cr1') effect(`effect') alpha(`alpha') beta(`beta') n1(`n1') nst(`nst')
end

program define nsize_co2c
	version 12
	syntax [anything], cr0(numlist max=1 >-1 <1) /*
	*/	[cr1(numlist max=1 >-1 <1) EFfect(numlist max=1 >-1 <1)			/*
	*/	 Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n1(numlist integer max=1 >3) n0(numlist integer max=1 >3) nst(string)]

	nsize_cor co2c, cr0(`cr0') cr1(`cr1') effect(`effect') alpha(`alpha') beta(`beta') n1(`n1') n0(`n0') nst(`nst')
end

program define nsize_cor, rclass
	version 12
	syntax anything(name=type), [cr(numlist) cr0(numlist) 	/*
	*/	cr1(numlist) effect(numlist) alpha(numlist) beta(numlist) 	/*
	*/	n0(numlist) n1(numlist) nst(string)]

	if ("`cr1'"=="" & "`effect'"=="") print_error "option cr1 or effect missing"
	if ("`cr1'"!="" & "`effect'"!="") print_error "options cr1 and effect are incompatible"
	if ("`cr1'"=="" & "`effect'"!="") {
		if ("`type'" == "co1c") local cr1 = `effect' + `cr'
		if ("`type'" == "co2c") local cr1 = `effect' + `cr0'
	}
	if ("`cr1'"!="" & "`effect'"=="") {
		if ("`type'" == "co1c") local effect = `cr1' - `cr'
		if ("`type'" == "co2c") local effect = `cr1' - `cr0'
	}
	if ("`n1'"!="" & "`beta'"!="") print_error "options beta and n1 are incompatible"
	if ("`type'" == "co2c") {
		if ("`n0'"!="") {
			if ("`n1'"=="") print_error "option n1 missing"
			if ("`beta'"!="") print_error "options beta and n0 are incompatible"
		}
	}
	if ("`alpha'"=="") local alpha 5

	*Title & Header
	di as res "SAMPLE SIZE & POWER DETERMINATION: " cond("`type'"=="co1c","One","Two") /*
	*/			" correlation coefficient" cond("`type'"=="co1c","","s")
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	di
	if ("`type'" == "co1c") {
		di as txt "Correlation in a Reference Population R  = `cr'"
		di as txt "Correlation in a Sample               R1 = `cr1'"
		if ("`n1'"!="") di as txt _col(39) "N1 = `n1'"
		di as txt "Minimum expected effect size       (R1-R)= `effect'"
	}
	if ("`type'" == "co2c") {
		di as txt "Correlation in a Sample 0        R0 = `cr0'"
		if ("`n0'"!="") di as txt _col(34) "N0 = `n0'"
		di as txt "Correlation in a Sample 1        R1 = `cr1'"
		if ("`n1'"!="") di as txt _col(34) "N1 = `n1'"
		di as txt "Minimum expected effect size (R1-R0)= `effect'"
	}

	*Compute results
	tempname res
	if ("`n1'"=="") {
		*Sample Size
		*Compute results
		if ("`beta'" == "") local beta 20 15 10
		local first 1
		foreach i of numlist 2 1 {
			foreach b of numlist `beta' {
				local a = `alpha'/`i'
				nsize__utils get_nsize `cr' `cr0' `cr1', type("`type'") alpha(`a') beta(`b')
				if (`first') matrix `res' = (r(n))
				else matrix `res' = (`res',r(n))
				local first 0
			}
		}

		*Print & Store results
		local cols = colsof(`res')
		local c = cond("`type'"=="co2c","SAMPLE SIZE by group","SAMPLE SIZE")
		if (`cols'>2) {
			di
			di as txt _col(14) "{c |}{center 45:`c'}"
			di as txt "Alpha Risk=`alpha'%{c |}{center 22:Two-Sided Test}{c |}{center 22:One-Sided Test}"
			di as txt "{ralign 13:Power}{c |}{ralign 6:80}%{ralign 6:85}%{ralign 6:90}% {c |}{ralign 6:80}%{ralign 6:85}%{ralign 6:90}%"
			display "{hline 13}{c +}{hline 22}{c +}{hline 22}"
			di as txt "{ralign 12:n} {c |}" _c
			foreach i of numlist 1/`cols' {
				di as res %6.0f `res'[1,`i'] cond(`i'==3,"  {c |}"," ") _c
			}
			display _newline "{hline 13}{c BT}{hline 22}{c BT}{hline 22}"

			local cnames "80_2 85_2 90_2 80_1 85_1 90_1"
			foreach i of numlist 1/`cols' {
				local c : word `i' of `cnames'
				return scalar n_`c' = `res'[1,`i']
			}
		}
		else {
			di as txt "Alpha Risk = `alpha'%"
			di as txt "Beta Risk  = `beta'% (Power = " 100-`beta' "%)"
			di
			di as txt "`c'"
			di as txt " Two-Sided Test:  N = " %6.0f as res `res'[1,1]
			di as txt " One-Sided Test:  N = " %6.0f as res `res'[1,2]
			return scalar n2 = `res'[1,1]
			return scalar n1 = `res'[1,2]
		}
	}
	else {
		*Power
		di as txt "Alpha Risk = `alpha'%"
		di
		di as txt "POWER"
		local a = `alpha'/2
		nsize__utils get_power `cr' `cr0' `cr1' `n1' `n0', type("`type'") alpha(`a')
		di as txt " Two-Sided Test: Power= " _c
		print_pct `r(p)', newline
		return scalar p2 = r(p)
		nsize__utils get_power `cr' `cr0' `cr1' `n1' `n0', type("`type'") alpha(`alpha')
		di as txt " One-Sided Test: Power= " _c
		print_pct `r(p)', newline
		return scalar p1 = r(p)
	}
end

program define nsize_ncr, rclass
	version 12
	syntax [anything], vb(numlist max=1 >0) vw(numlist max=1 >0)	/*
	*/	 EFfect(numlist max=1 >0 <1)			/*
	*/	 [Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 nst(string)]

	if ("`alpha'" == "") local alpha 5
	local def = ("`beta'"=="")
	if ("`beta'" == "") local beta 20 15 10

	*Title & Header
	di as res "NUMBER OF COMMUNITIES (RISK): Intervention trials"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	di
	di as txt "Supposed Between Group Variance= " `vb'
	di as txt "Supposed Within Group Variance = " `vw'
	di as txt "Minimum expected effect size = `effect'"
	if (!`def') {
		di as txt "Alpha Risk= `alpha'%"
		di as txt "Beta Risk = `beta'%"
	}

	*Compute results (no power results)
	tempname res
	local first 1
	foreach i of numlist 2 1 {
		foreach b of numlist `beta' {
			local a = `alpha'/`i'
			local v = `vb' + `vw'
			nsize__utils get_nsize `v' `effect', type(ncr) alpha(`a') beta(`b')
			if (`first') matrix `res' = (r(n)\r(nc))
			else matrix `res' = (`res',(r(n)\r(nc)))
			local first 0
		}
	}

	*Print results
	local rows = rowsof(`res')
	local cols = colsof(`res')
	local pos = cond(`def',31,24)
	local c = cond(`def',"Alpha Risk=`alpha'%","")
	local i = cond(`def',22,16)
	di
	di as txt _col(22) "{c |}" _col(`pos') "Number of communities by Group"
	di as txt "{ralign 21:`c'}{c |}{center `i':Two-Sided Test}{c |}{center `i':One-Sided Test}"
	if (`def') {
		di as txt "{ralign 21:Power}{c |}    80%    85%    90% {c |}    80%    85%    90%"
		di "{hline 21}{c +}{hline 22}{c +}{hline 22}" _c
	}
	else {
		di "{hline 21}{c +}{hline 16}{c +}{hline 16}" _c
	}
	foreach i of numlist 1/`rows'{
		local c = cond(`i'==1,"Normal method","Student's correction")
		di as txt _newline "{ralign 20:`c'} {c |}" _c
		foreach j of numlist 1/`cols'{
			local fmt = cond(`def',"%6.0f","%10.0f")
			di as res `fmt' `res'[`i',`j'] " " cond(`j'==`cols'/2,cond(`def',"{col 45}{c |}","{col 39}{c |}"),"") _c
		}
	}
	if (`def') di _newline "{hline 21}{c BT}{hline 22}{c BT}{hline 22}"
	else di _newline "{hline 21}{c BT}{hline 16}{c BT}{hline 16}"

	*Store results
	local ccols "80_2 85_2 90_2 80_1 85_1 90_1"
	foreach i of numlist 1/`rows'{
		foreach j of numlist 1/`cols'{
			if (`def') local c : word `j' of `ccols'
			else local c =cond(`j'==1,2,1)
			if (`i'==1) return scalar n_`c' = `res'[`i',`j']
			else return scalar nc_`c' = `res'[`i',`j']
		}
	}

end

program define nsize_co2r, rclass
	version 12
	syntax [anything], [r0(numlist max=1 >0 <100) r1(numlist max=1 >0 <100) /*
	*/	 rr(numlist max=1 >0) rd(numlist max=1) or(numlist max=1 >0)		/*
	*/	 pe0(numlist max=1 >0 <100) pe1(numlist max=1 >0 <100) r(numlist max=1 >0) 	/*
	*/	 pe(numlist max=1 >0 <100)	/*
	*/	 Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50)	/*
	*/	 n1(numlist integer max=1 >1) n0(numlist integer max=1 >1) 	/*
	*/	 m1(numlist integer max=1 >1) m0(numlist integer max=1 >1) nst(string)]

		*Parameter check
	if ("`r0'"=="" & "`pe0'"=="") print_error "option r0 or pe0 missing"
	if ("`r0'"!="" & "`pe0'"!="") print_error "options r0 and pe0 incompatible"
	local cohort = ("`r0'"!="")
	local cc = ("`pe0'"!="")
	if (`cohort') {
		if ("`pe1'"!="") print_error "options r0 and pe1 incompatible"
		if ("`r1'"=="" & "`rr'"=="" & "`or'"=="" & "`rd'"=="") print_error "missing option or() or r1() or rr() or rd()"
		if ("`r1'"!="" & ("`rr'"!="" | "`or'"!="" | "`rd'"!="")) print_error "option r1() is incompatible with options rr, or, rd"
		if ("`rr'"!="" & ("`r1'"!="" | "`or'"!="" | "`rd'"!="")) print_error "option rr() is incompatible with options r1, or, rd"
		if ("`or'"!="" & ("`r1'"!="" | "`rr'"!="" | "`rd'"!="")) print_error "option or() is incompatible with options r1, rr, rd"
		if ("`rd'"!="" & ("`r1'"!="" | "`rr'"!="" | "`or'"!="")) print_error "option rd() is incompatible with options r1, rr, or"
		if ("`rd'"!="") {
			if (`rd'==0) print_error "rd() invalid -- invalid number, outside of allowed range"
		}
		if ("`m1'"!="" | "`m0'"!="") print_error "options m1 and m0 are incompatible with cohort risk studies"
		local size = ("`n1'"=="" & "`n0'"=="")
		if (!`size' & "`beta'"!="") print_error "option beta is incompatible with power results"
		if ("`n1'"!="" & "`n0'"!="" & "`r'"!="") print_error "option r() is incompatible with options n1, n0"
		if ("`n1'"!="" & "`n0'"!="" & "`pe'"!="") print_error "option pe() is incompatible with options n1, n0"
		if ("`r'"!="" & "`pe'"!="") print_error "option r() is incompatible with option pe()"
		if ("`r'"=="" & "`pe'"!="") local r = (100-`pe')/`pe'		//default
	}
	if (`cc') {
		if ("`r1'"!="" | "`rr'"!="" | "`rd'"!="") print_error "option pe0 is incompatible with options r1, rr, rd"
		if ("`pe'"!="") print_error "option pe() is incompatible with case-control studies"
		if ("`pe1'"=="" & "`or'"=="") print_error "missing option pe1() or or()"
		if ("`pe1'"!="" & "`or'"!="") print_error "option pe1() is incompatible with option or()"
		if ("`n1'"!="" | "`n0'"!="") print_error "options n1 and n0 are incompatible with case-control studies"
		local size = ("`m1'"=="" & "`m0'"=="")
		if (!`size' & "`beta'"!="") print_error "option beta is incompatible with power results"
		if ("`m1'"!="" & "`m0'"!="" & "`r'"!="") print_error "option r() is incompatible with options m1, m0"
	}
	if ("`r'"=="") local r 1
	if ("`alpha'"=="") local alpha 5
	if ("`beta'"=="") local beta 20 15 10
	if (`cohort' & !`size') {
		if ("`n1'"!="" & "`n0'"!="") local r = `n0'/`n1'
		if ("`n1'"!="" & "`n0'"=="") local n0 = `n1'*`r'
		if ("`n1'"=="" & "`n0'"!="") local n1 = `n0'/`r'
		local n0 = ceil(`n0')
		local n1 = ceil(`n1')
	}
	if (`cc' & !`size') {
		if ("`m1'"!="" & "`m0'"!="") local r = `m0'/`m1'
		if ("`m1'"!="" & "`m0'"=="") local m0 = `m1'*`r'
		if ("`m1'"=="" & "`m0'"!="") local m1 = `m0'/`r'
		local m0 = ceil(`m0')
		local m1 = ceil(`m1')
	}
	if (`r'<=0) print_error "r() invalid -- invalid number, outside of allowed range"

	*Title
	di as res "SAMPLE SIZE (RISK) & POWER: Two-independent samples"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	*Header
	if (`cohort') {
		local p0 = `r0'
		if ("`r1'"!="") local p1 = `r1'
		if ("`rd'"!="") local p1 = `rd'+`p0'
		if ("`rr'"!="") local p1 = `rr'*`p0'
	}
	if (`cc') {
		local p0 = `pe0'
		if ("`pe1'"!="") local p1 = `pe1'
	}
	if ("`or'"!="") local p1 = (100*(`p0'/(100-`p0'))*`or')/(((`p0'/(100-`p0'))*`or')+1)
	local rr = `p1'/`p0'
	local or = (`p1'/(100-`p1'))/(`p0'/(100-`p0'))
	local rd = `p1'-`p0'

	di
	if (`cohort') {
		di as txt "Proportion(%) of events in: UnExposed (Group 0)= " trim(string(`p0',"%5.0g")) "%"
		di as txt "                            Exposed   (Group 1)= " trim(string(`p1',"%5.0g")) "%"
		di as txt "Minimum expected: RR= " trim(string(`rr',"%9.0g")) ///
		   ";  OR= "  trim(string(`or',"%9.0g")) ";  RD= "  trim(string(`rd'/100,"%9.0g"))
	}
	if (`cc') {
		di as txt "Proportion of exposed in: Noncases (Group 0)= " trim(string(`p0',"%5.0g")) "%"
		di as txt "                          Cases    (Group 1)= " trim(string(`p1',"%5.0g")) "%"
		di as txt "Minimum expected: OR= " trim(string(`or',"%9.0g"))
	}

	tempname res t

	local warning 0
	local warn 0
	if (`p0'<20 | `p1'<20 | `p0'>80 | `p1'>80) local warning 1
	local c0 = cond(`cohort',"n0","m0")
	local c1 = cond(`cohort',"n1","m1")
	if (`size') {
		*Sample Size
		*Compute results
		local first 1
		foreach i of numlist 2 1 {
			foreach b of numlist `beta' {
				local a = `alpha'/`i'
				nsize__utils get_nsize `p0' `p1' `r' `rd', type(co2r) alpha(`a') beta(`b')
				matrix `t' = (r(n0n)\r(n1n)\r(nn)\r(n0f)\r(n1f)\r(nf)\r(n0a)\r(n1a)\r(na))
				if (`first') matrix `res' = (`t')
				else matrix `res' = (`res',`t')
				local first 0
				if (r(warning)) local warn 1
			}
		}

		*Print results
		if ("`pe'"!="") local pe_text = "(pe= " + string(`pe',"%5.2f") + "%)"
		local rows = rowsof(`res')
		local cols = colsof(`res')
		local i1 = cond(`cols'>2,43,33)
		local i2 = cond(`cols'>2,21,16)
		if (`cols'>2) di as text "Ratio `c0'/`c1' = " trim(string(`r',"%9.0g")) " `pe_text'"
		else di as txt "Alpha Risk = `alpha'%; Beta Risk = `beta'%;  Ratio `c0'/`c1' = " trim(string(`r',"%4.0g")) " `pe_text'"
		di
		di as txt _col(23) "{c |}{center `i1':SAMPLE SIZE}"
		if (`cols'>2) di as txt "{ralign 22:Alpha Risk=`alpha'%}{c |}" _c
		else di as txt " METHOD{col 23}{c |}" _c
		di as txt "{center `i2':Two-Sided Test}{c |}{center `i2':One-Sided Test}"
		if (`cols'>2) di as txt " METHOD{col 18}Power{c |}   80%    85%    90% {c |}   80%    85%    90%"
		if (`cols'>2) di as txt "{hline 22}{c +}{hline 21}{c +}{hline 21}" _c
		else di as txt "{hline 22}{c +}{hline 16}{c +}{hline 16}" _c
		foreach i of numlist 1/`rows'{
			local note = cond(`i'==1 & (`warning' | `warn'),"*","")
			di as txt _newline _c
			if (inlist(`i',1,4,7)) di as txt cond(`i'==1,"Normal`note'",cond(`i'==4,"Normal corrected","ArcoSinus")) _c
			local c = cond(inlist(`i',1,4,7),"`c0'",cond(inlist(`i',2,5,8),"`c1'","Total"))
			di as txt _col(17) "{ralign 5:`c'}" _c
			di as txt " {c |}" _c
			foreach j of numlist 1/`cols'{
				local fmt = cond(`cols'>2,"%6.0f","%11.0f")
				di as res `fmt' `res'[`i',`j'] " " _c
				if (`cols'>2 & `j'==3) di as txt "{c |}" _c
				if (`cols'==2 & `j'==1) di as txt _col(40) "{c |}" _c
			}
			if (inlist(`i',3,6)) {
				if (`cols'>2) di as txt _newline "{hline 22}{c +}{hline 21}{c +}{hline 21}" _c
				else di as txt _newline "{hline 22}{c +}{hline 16}{c +}{hline 16}" _c
			}
		}
		if (`cols'>2) di as txt _newline "{hline 22}{c BT}{hline 21}{c BT}{hline 21}"
		else di as txt _newline "{hline 22}{c BT}{hline 16}{c BT}{hline 16}"

		local nm = cond(`cohort',"n","m")
		matrix rownames `res' = Norm_`c0' Norm_`c1' Norm_`nm' NormCor_`c0' NormCor_`c1' NormCor_`nm' ArcSin_`c0' ArcSin_`c1' ArcSin_`nm'
		if (`cols'>2) matrix colnames `res' = TwoSided_80 TwoSided_85 TwoSided_90 OneSided_80 OneSided_85 OneSided_90
		else matrix colnames `res' = TwoSided OneSided
		return matrix Size = `res'
	}
	else {
		*Power
		*Compute results
		local first 1
		foreach i of numlist 2 1 {
			local a = `alpha'/`i'
			nsize__utils get_power `p0' `p1' `r' `rd' `n1' `m1', type(co2r) alpha(`a')
			matrix `t' = (r(pn)\r(pf)\r(pa))
			if (`first') matrix `res' = (`t')
			else matrix `res' = (`res',`t')
			local first 0
		}
		if (`cohort') {
			if ((`n0'*`p0'/100)<10 | (`n0'*(1-`p0'/100))<10 | (`n1'*`p1'/100)<10 | (`n1'*(1-`p1'/100))<10) local warn 1
		}
		else {
			if ((`m0'*`p0'/100)<10 | (`m0'*(1-`p0'/100))<10 | (`m1'*`p1'/100)<10 | (`m1'*(1-`p1'/100))<10) local warn 1
		}

		*Print results
		if ("`pe'"!="") local pe_text = string(`pe',"%5.2f")
		di as txt "Sample size: `c0' = " cond(`cohort',"`n0'","`m0'") " ; `c1' = "  cond(`cohort',"`n1'","`m1'") /*
		*/			" (Ratio `c0'/`c1' = " trim(string(`r',"%9.0g")) cond("`pe'"!=""," [pe= `pe_text'%])",")")
		di as txt "Alpha Risk = `alpha'%"

		local rows = rowsof(`res')
		local cols = colsof(`res')
		di as txt _col(19) "{c |}{center 33:POWER (%)}"
		di as txt " METHOD" _col(19) "{c |} Two-Sided Test {c |} One-Sided Test "
		di as txt "{hline 18}{c +}{hline 16}{c +}{hline 16}" _c
		foreach i of numlist 1/`rows'{
			local note = cond(`i'==1 & (`warning' | `warn'),"*","")
			di as txt _newline cond(`i'==1,"Normal`note'",cond(`i'==2,"Normal corrected","ArcoSinus")) _c
			di as txt _col(19) "{c |}" _c
			foreach j of numlist 1/`cols'{
				local v = `res'[`i',`j']
				print_pct `v', a(10) nopercent
				if (`j'==1) di as txt _col(36) "{c |}" _c
			}
		}
		di as txt _newline "{hline 18}{c BT}{hline 16}{c BT}{hline 16}"

		matrix rownames `res' = Normal NormalCor ArcoSinus
		matrix colnames `res' = TwoSided OneSided
		return matrix Power = `res'
	}

	if (`warning' | `warn') {
		di as txt "(*)WARNING: Applicability conditions for Normal method not granted"
		if (`warning') di as txt "P0 and P1 must be >=20 and <=80"
		if (`warn') di as txt "`c0'*P0, `c0'*(1-P0), `c1'*P1 and `c1'*(1-P1) must be >=10"
	}

end

program define nsize_co2i, rclass
	version 12
	syntax [anything], i0(numlist max=1 >0) d(numlist max=1 >0) 		/*
	*/	[i1(numlist max=1 >0) id(numlist max=1) ir(numlist max=1 >0)	/*
	*/	 r(numlist max=1 >0) Alpha(numlist max=1 >0 <=50) Beta(numlist max=1 >0 <=50) 	/*
	*/	 n1(numlist integer max=1 >1) n0(numlist integer max=1 >1) nst(string)]

	if ("`i1'"=="" & "`ir'"=="" & "`id'"=="") print_error "missing option i1() or ir() or id()"
	if ("`i1'"!="" & ("`ir'"!="" | "`id'"!="")) print_error "option i1() is incompatible with options ir, id"
	if ("`ir'"!="" & ("`i1'"!="" | "`id'"!="")) print_error "option ir() is incompatible with options i1, id"
	if ("`id'"!="" & ("`i1'"!="" | "`ir'"!="")) print_error "option id() is incompatible with options i1, ir"
	if ("`id'"!="") {
		if (`id'==0) print_error "id() invalid -- invalid number, outside of allowed range"
	}
	if ("`r'"=="") local r 1
	if ("`n1'"!="" | "`n0'"!="") {
		if ("`beta'"!="") print_error "options n1,n0 are incompatible with option beta"
		if ("`n1'"!="" & "`n0'"!="") local r = `n0'/`n1'
		if ("`n1'"!="" & "`n0'"=="") local n0 = `n1'*`r'
		if ("`n1'"=="" & "`n0'"!="") local n1 = `n0'/`r'
		local n1 = ceil(`n1')
		local n0 = ceil(`n0')
	}
	if ("`i1'"!="") {
		local ir = `i1'/`i0'
		local id = `i1'-`i0'
	}
	if ("`id'"!="") {
		local i1 = `id'+`i0'
		local ir = `i1'/`i0'
	}
	if ("`ir'"!="") {
		local i1 = `ir'*`i0'
		local id = `i1'-`i0'
	}
	if (`i1'==`i0') print_error "i0 and i1 can't be equal"
	if ("`alpha'"=="") local alpha 5
	if ("`beta'"=="") local beta 20 15 10

	*Title
	di as res "SAMPLE SIZE (RATE) & POWER: Two-independent samples"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	*Header
	di
	di as txt "Rate of events in: UnExposed (Group 0)= " trim(string(`i0',"%9.0g"))
	di as txt _col(20) "{lalign 9:Exposed} (Group 1)= " trim(string(`i1',"%9.0g"))
	di as txt "                        Mean followup = `d'"
	if ("`n1'"=="") di as txt "{ralign 37:Ratio n0/n1} = " trim(string(`r',"%4.0g"))
	di as txt "Minimum expected: IR= " trim(string(`ir',"%6.0g")) ";   ID= " trim(string(`id',"%9.0g"))

	tempname res t

	local warn 0
	local warning 0
	if (`i0'*`d'<0.2 | `i1'*`d'<0.2 | `i0'*`d'>0.8 | `i1'*`d'>0.8) local warning 1
	if ("`n1'"=="") {
		*Sample Size
		*Compute results
		local first 1
		foreach i of numlist 2 1 {
			foreach b of numlist `beta' {
				local a = `alpha'/`i'
				nsize__utils get_nsize `i0' `i1' `d' `id', type(co2i) alpha(`a') beta(`b') r(`r')
				matrix `t' = (r(n0n)\r(n1n)\r(nn)\r(n0f)\r(n1f)\r(nf)\r(n0a)\r(n1a)\r(na))
				if (`first') matrix `res' = (`t')
				else matrix `res' = (`res',`t')
				local first 0
				if (r(warning)) local warn 1
			}
		}

		*Print results
		local rows = rowsof(`res')
		local cols = colsof(`res')
		local i1 = cond(`cols'>2,43,33)
		local i2 = cond(`cols'>2,21,16)
		if (`cols'==2) di as txt "Alpha Risk = `alpha'%; Beta Risk = `beta'%;   Power = " 100-`beta' "%"
		di
		di as txt _col(23) "{c |}{center `i1':SAMPLE SIZE}"
		if (`cols'>2) di as txt "{ralign 22:Alpha Risk=`alpha'%}{c |}" _c
		else di as txt " METHOD{col 23}{c |}" _c
		di as txt "{center `i2':Two-Sided Test}{c |}{center `i2':One-Sided Test}"
		if (`cols'>2) di as txt " METHOD{col 18}Power{c |}   80%    85%    90% {c |}   80%    85%    90%"
		if (`cols'>2) di as txt "{hline 22}{c +}{hline 21}{c +}{hline 21}" _c
		else di as txt "{hline 22}{c +}{hline 16}{c +}{hline 16}" _c
		foreach i of numlist 1/`rows'{
			local note = cond(`i'==1 & (`warning' | `warn'),"*","")
			di as txt _newline _c
			if (inlist(`i',1,4,7)) di as txt cond(`i'==1,"Normal`note'",cond(`i'==4,"Normal corrected","ArcoSinus")) _c
			local c = cond(inlist(`i',1,4,7),"n0",cond(inlist(`i',2,5,8),"n1","Total"))
			di as txt _col(17) "{ralign 5:`c'}" _c
			di as txt " {c |}" _c
			foreach j of numlist 1/`cols'{
				local fmt = cond(`cols'>2,"%6.0f","%11.0f")
				di as res `fmt' `res'[`i',`j'] " " _c
				if (`cols'>2 & `j'==3) di as txt "{c |}" _c
				if (`cols'==2 & `j'==1) di as txt _col(40) "{c |}" _c
			}
			if (inlist(`i',3,6)) {
				if (`cols'>2) di as txt _newline "{hline 22}{c +}{hline 21}{c +}{hline 21}" _c
				else di as txt _newline "{hline 22}{c +}{hline 16}{c +}{hline 16}" _c
			}
		}
		if (`cols'>2) di as txt _newline "{hline 22}{c BT}{hline 21}{c BT}{hline 21}"
		else di as txt _newline "{hline 22}{c BT}{hline 16}{c BT}{hline 16}"

		matrix rownames `res' = Norm_n0 Norm_n1 Norm_n NormCor_n0 NormCor_n1 NormCor_n ArcSin_n0 ArcSin_n1 ArcSin_n
		if (`cols'>2) matrix colnames `res' = TwoSided_80 TwoSided_85 TwoSided_90 OneSided_80 OneSided_85 OneSided_90
		else matrix colnames `res' = TwoSided OneSided
		return matrix Size = `res'
	}
	else {
		*Power
		*Compute results
		local first 1
		foreach i of numlist 2 1 {
			local a = `alpha'/`i'
			nsize__utils get_power `i0' `i1' `r' `d' `id' `n1', type(co2i) alpha(`a')
			matrix `t' = (r(pn)\r(pf)\r(pa))
			if (`first') matrix `res' = (`t')
			else matrix `res' = (`res',`t')
			local first 0
		}
		if ((`n1'*`i1'*`d')<10 | (`n1'*(1-`i1'*`d'))<10 | (`n0'*`i0'*`d')<10 | (`n0'*(1-`i0'*`d'))<10) local warn 1

		*Print results
		di as txt "Sample size: n0 = `n0' ; n1 = `n1' (Ratio n0/n1 = " trim(string(`r',"%4.0g")) ")"
		di as txt "Alpha Risk = `alpha'%"

		local rows = rowsof(`res')
		local cols = colsof(`res')
		di as txt _col(19) "{c |}{center 33:POWER (%)}"
		di as txt " METHOD" _col(19) "{c |} Two-Sided Test {c |} One-Sided Test "
		di as txt "{hline 18}{c +}{hline 16}{c +}{hline 16}" _c
		foreach i of numlist 1/`rows'{
			local note = cond(`i'==1 & (`warning' | `warn'),"*","")
			di as txt _newline cond(`i'==1,"Normal`note'",cond(`i'==2,"Normal corrected","ArcoSinus")) _c
			di as txt _col(19) "{c |}" _c
			foreach j of numlist 1/`cols'{
				local v = `res'[`i',`j']
				print_pct `v', a(10) nopercent
				if (`j'==1) di as txt _col(36) "{c |}" _c
			}
		}
		di as txt _newline "{hline 18}{c BT}{hline 16}{c BT}{hline 16}"

		matrix rownames `res' = Normal NormalCor ArcoSinus
		matrix colnames `res' = TwoSided OneSided
		return matrix Power = `res'
	}

    if (`warning' | `warn') {
		display as text "(*)WARNING: Applicability conditions for Normal method not granted"
		if (`warning') display as text "I0*D and I1*D must be >=0.2 and <=0.8"
		if (`warn') display as text "N0*I0*D, N0*(1-I0*D), N1*I1*D and N1*(1-I1*D) must be >=10"
	}

end


program define print_pct
	syntax anything, [col(numlist max=1) a(real 5) nopercent astxt newline]
	local p = `anything'
	local fmt = cond(abs(`p')<10,cond(abs(`p')<1,"%`a'.0g","%`a'.2f"),"%`a'.1f")
	local c = cond("`col'"=="","","_col(`col')")
	local as = cond("`astxt'"=="","as res","as txt")

	di `as' `c' `fmt' `p' _c
	if ("`percent'"=="") di as txt "%" _c
	if ("`newline'"!="") di as txt " "
end

program define print_error
	args message
	di as err "`message'"
	exit 198
end
