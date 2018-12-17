*! version 1.1.5  ?dec2018 JM. Domenech, R. Sesma

/*
Agreement: Passing-Bablok & Bland-Altman methods
*/

program agree, byable(recall) sortpreserve rclass
	version 12
	syntax varlist(min=2 max=2 numeric) [if] [in], /*
	*/	[PB BA BOth Level(numlist max=1 >=50 <100) list id(varname numeric) pbgraph(string) nst(string)]

	tempvar yx xy yx2 diff ai ai_lo ai_up sort d r cusumi sort idv  s
	tempname st res A

	if ("`pb'"!="" & "`ba'"!="" | "`pb'"!="" & "`both'"!="" | /*
	*/	"`ba'"!="" & "`both'"!="") print_error "invalid data -- only one of pb, ba, both is needed"
	if ("`pb'"=="" & "`ba'"=="" & "`both'"=="") local show 0
	if ("`both'"!="") local show 0
	if ("`pb'"!="") local show 1
	if ("`ba'"!="") local show 2
	if ("`level'"=="") local level 95
	if (`show'==2 & "`list'"!="") print_error "list option not allowed for ba option"
	if ("`list'"=="" & "`id'"!="") print_error "id() option is only necessary with list option"
	if ("`pbgraph'"!="" & "`pbgraph'"!="reg" & "`pbgraph'"!="ci" & "`pbgraph'"!="both") print_error "pbgraph() invalid"

	//X, Y variables
	tokenize `varlist'
	local x `2'
	local y `1'
	if ("`x'"=="`y'") print_error "invalid data -- var X and var Y must be different"

	marksample touse, novarlist			//ifin marksample
	qui count if `touse'
	local ncases = r(N)					//total number of cases
	if (`ncases'==0) print_error "no observations"

	di as res _n "AGREEMENT: " _c
	if (`show'==0) di "PASSING-BABLOK & BLAND-ALTMAN METHODS"
	if (`show'==1) di "PASSING-BABLOK METHOD"
	if (`show'==2) di "BLAND-ALTMAN METHOD"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	quietly {
		gen `yx' = `y' - `x'
		gen `yx2' = (`y' + `x')/2
		gen `diff' = 100*`yx'/`yx2'

		*Lin, L,(1989) A concordance correlation coefficient to evaluate reproductivity,Biometrics, 45:255-268.
		su `x'
		local meanx = r(mean)
		local varx = r(Var)
		su `y'
		local meany = r(mean)
		local vary = r(Var)
		gen `xy' = (`x' - `meanx')*(`y' - `meany')
		su `xy' if `touse'
		local sxy = r(sum)
		local lin = 2*(`sxy'/(`r(N)'-1))/(`varx' + `vary' + (`meanx'-`meany')^2)
	}

	* descriptive statistics
	if (`show'<2) {
		* passing-bablok
	}
	if (`show'==2) {
		* bland-altman
		di _n as txt "Bland-Altman: Descriptive Statistics (listwise)"
		di "{hline 71}"
		di as txt "Variable    Valid  Miss   Obs      Mean  Std. Dev. [`level'% Conf. Interval]"
		foreach v of varlist `y' `x' {
			qui su `v' if `touse'
			local m = r(mean)
			local sd = r(sd)
			local n = r(N)
			qui ci `v' if `touse', level(`level')
			di as txt cond("`v'"=="`y'","Y: ","X: ") as res abbrev("`v'",8) _col(13) _c
			di %5.0f `n' " " %5.0f (`ncases' - `n') " " %5.0f `ncases' " " _c
			di %9.0g `m' "  " %9.0g `sd' "  " %9.0g `r(lb)' " " %9.0g `r(ub)'
		}
		di "{hline 71}"
	}

	if (`show'==2 | `show'==0) {
		* bland-altman: absolute values of bias & LoA
		tempname bias sd t z lo up se
		qui ttest `y' == `x' if `touse', level(`level')
		scalar `t' = invttail(`r(df_t)',(100-`level')/200)
		scalar `z' = invnormal((100+`level')/200)
		scalar `bias' = r(mu_1) - r(mu_2)
		scalar `sd' = r(se)*sqrt(r(N_1))
		scalar `lo' = `bias' - `z'*`sd'
		scalar `up' = `bias' + `z'*`sd'
		scalar `se' = `sd'*sqrt(3/r(N_1))

		di _n as txt "Bland-Altman: Absolute values of Bias & Limits of Agreement (LoA) "
		di "{hline 71}"
		di as txt "Parameter   Obs   Estimate  Std. Dev.   Std. Err.  [`level'% Conf. Interval]"
		di as txt "Y-X: Bias " as res %5.0f `r(N_1)' "  " %9.0g `bias' "  " % 9.0g `sd' "   " %9.0g `r(se)' _c
		di as res _col(53) %9.0g `bias' - `t'*`r(se)' " " %9.0g `bias' + `t'*`r(se)'
		di as txt "Lower LoA " as res %5.0f `r(N_1)' "  " %9.0g `lo' _col(41) %9.0g `se' _c
		di as res _col(53) %9.0g `lo' - `t'*`se' " " %9.0g `lo' + `t'*`se'
		di as txt "Upper LoA " as res %5.0f `r(N_1)' "  " %9.0g `up' _col(41) %9.0g `se' _c
		di as res _col(53) %9.0g `up' - `t'*`se' " " %9.0g `up' + `t'*`se'
		di "{hline 71}"

		* bland-altman: percentage values of bias & LoA
		qui ttest `diff' == 0 if `touse', level(`level')
		scalar `t' = invttail(`r(df_t)',(100-`level')/200)
		scalar `z' = invnormal((100+`level')/200)
		scalar `bias' = r(mu_1)
		scalar `sd' = r(sd_1)
		scalar `lo' = `bias' - `z'*`sd'
		scalar `up' = `bias' + `z'*`sd'
		scalar `se' = `sd'*sqrt(3/r(N_1))

		di _n as txt "Bland-Altman: Percentage values of Bias & Limits of Agreement (LoA) "
		di "{hline 71}"
		di as txt "Parameter   Obs   Estimate  Std. Dev.   Std. Err.  [`level'% Conf. Interval]"
		di as txt "Y-X: Bias " as res %5.0f `r(N_1)' "  " %9.0g `bias' "  " % 9.0g `sd' "   " %9.0g `r(se)' _c
		di as res _col(53) %9.0g `bias' - `t'*`r(se)' " " %9.0g `bias' + `t'*`r(se)'
		di as txt "Lower LoA " as res %5.0f `r(N_1)' "  " %9.0g `lo' _col(41) %9.0g `se' _c
		di as res _col(53) %9.0g `lo' - `t'*`se' " " %9.0g `lo' + `t'*`se'
		di as txt "Upper LoA " as res %5.0f `r(N_1)' "  " %9.0g `up' _col(41) %9.0g `se' _c
		di as res _col(53) %9.0g `up' - `t'*`se' " " %9.0g `up' + `t'*`se'
		di "{hline 71}"

		* spearman & lin concordance
		qui spearman `yx' `yx2' if `touse', stats(p)
		di as txt "Spearman correlation between (Y-X) and (X+Y)/2: r= " as res %7.4f `r(rho)' _c
		di as txt " (p= " as res %6.4f `r(p)' as txt ")"
		di as txt "Lin's Concordance Correlation coeff. of Absolute Agreement = " as res %6.4f `lin'
		di "{hline 71}"

		* test of normality
		di as txt _n "Tests of Normality (Y-X)   Statistic    p-value"
		di as txt "{hline 47}"
		qui swilk `yx' if `touse'
		di as txt "Shapiro-Wilk" _col(29) "W = " as res %7.4f `r(W)' "  " %6.4f `r(p)'
		qui su `yx' if `touse', detail
		local skew = r(skewness)
		local kurt = r(kurtosis)-3
		qui sktest `yx' if `touse'
		di as txt "Skewness" _col(28) "Sk = " as res %7.4f `skew' "  " %6.4f `r(P_skew)'
		di as txt "Kurtosis-3" _col(28) "Ku = " as res %7.4f `kurt' "  " %6.4f `r(P_kurt)'
		di as txt "Skewness & Kurtosis" _col(26) "Chi2 = " as res %7.4f `r(chi2)' "  " %6.4f `r(P_chi2)'
		di as txt "{hline 47}"
	}


/*
	*Print the number of valid and missing values for each variable
	qui tabstat `x' `y' if `touse', s(count) save
	matrix `st' = r(StatTotal)
	di
	di as txt "{ralign 14:Variable} {c |} {ralign 8:Valid}   {ralign 8:Missing}"
	di as txt "{hline 15}{c +}{hline 21}"
	di as txt %12s abbrev("`x'",12) " X {c |} " as res %8.0g `st'[1,1] "   " %8.0g (`ncases'-`st'[1,1])
	di as txt %12s abbrev("`y'",12) " Y {c |} " as res %8.0g `st'[1,2] "   " %8.0g (`ncases'-`st'[1,2])
	display as text "{hline 15}{c BT}{hline 21}"

	markout `touse' `x' `y'				//Exclude missing values of list vars
	qui count if `touse'
	local nvalid = r(N)
	di as txt "Valid number of cases (listwise): " as res `nvalid'
	return scalar N = `nvalid'

	*Descriptive statistics of X and Y
	quietly {
		generate `yx' = `y' - `x' if `touse'
		generate `yxpct' = 100*(`yx'/`x') if `touse'
		tabstat `x' `y' `yx' `yxpct' if `touse', statistics(median mean min max sd) save
		matrix `st' = r(StatTotal)
		generate `yx2' = (`y' + `x')/2 if `touse'
	}

	if (`show'<=1) {
		matrix rownames `st' = Median Mean Minimum Maximum StdDev
		matrix colnames `st' = X Y Y-X (Y-X)/X
		*Passing-Bablok results: use Mata to compute b
		mata: getpbcoef("`x'","`y'",`level',"`res'","`touse'")
		local b = `res'[1,1]			//Put Mata results in Stata macros
		local b_lo = `res'[1,2]
		local b_up = `res'[1,3]

		*Compute the i elements for the a estimation; use tabstat median
		quietly {
			gen `ai' = `y' - `b'*`x' if `touse'
			gen `ai_lo' = `y' - `b_up'*`x' if `touse'
			gen `ai_up' = `y' - `b_lo'*`x' if `touse'
			tabstat `ai' `ai_lo' `ai_up' if `touse', statistics(median) save
			matrix `A' = r(StatTotal)
		}
		local a = `A'[1,1]
		local a_lo = `A'[1,2]
		local a_up = `A'[1,3]

		*Correction for inverse confidence interval
		if (`b_lo'>`b_up') {
			local t = `b_up'
			local b_up = `b_lo'
			local b_lo = `t'
		}
		if (`a_lo'>`a_up') {
			local t = `a_up'
			local a_up = `a_lo'
			local a_lo = `t'
		}

		*Linearity test, cusum
		quietly {
			gen `s' = _n
			*Di distances
			gen `d' = (`y' + (1/`b')*`x' - `a')/sqrt(1+1/(`b'^2)) if `touse'
			sort `touse' `d'					//Sort to compute the number of points
			count if `touse' & (`y' > `a'+`b'*`x')
			local l_sup = r(N)			//Number of points with Yi > a + bXi
			count if `touse' & (`y' < `a'+`b'*`x')
			local l_inf = r(N)			//Number of points with Yi < a + bXi
			*ri scores
			gen `r' = 0 if `touse'
			replace `r' = sqrt(`l_inf'/`l_sup') if `touse' & (`y' > `a'+`b'*`x')
			replace `r' = -sqrt(`l_sup'/`l_inf') if `touse' & (`y' < `a'+`b'*`x')
			gen `cusumi' = sum(`r') if `touse'		//Cumulative sum
			replace `cusumi' = abs(`cusumi') if `touse'
			summarize `cusumi' if `touse'
			local cusum = r(max)					//The maximum value marks the test
			sort `s'
		}

		//Print passing-bablock results
		local rlbl1 "Median"
		local rlbl2 "Mean"
		local rlbl3 "Minimum"
		local rlbl4 "Maximum"
		local rlbl5 "Std. Dev."
		di
		di as txt "Statistics {c |} {ralign 9:X} {c |} {ralign 9:Y} {c |} {ralign 9:Y-X} {c |} 100*(Y-X)/X"
		di as txt "{hline 11}{c +}{hline 11}{c +}{hline 11}{c +}{hline 11}{c +}{hline 12}" _c
		foreach i of numlist 1/5 {
			di as txt _newline "{ralign 10:`rlbl`i''} {c |} " _c
			foreach j of numlist 1/4 {
				local v = `st'[`i',`j']
				if (`j'<4) di as res %9.0g `v' " {c |} " _c
				else print_pct `v', col(55)
			}
		}
		di as txt _newline "{hline 11}{c BT}{hline 11}{c BT}{hline 11}{c BT}{hline 11}{c BT}{hline 12}"
		di
		di as txt "{bf:Passing-Bablok Regression Line} (Y = A + B*X):"
        di as txt " A =" as res %9.0g `a' as txt "  (`level'% CI: " as res %9.0g `a_lo' as txt " to " as res %9.0g `a_up' as txt ")"
		di as txt " B =" as res %9.0g `b' as txt "  (`level'% CI: " as res %9.0g `b_lo' as txt " to " as res %9.0g `b_up' as txt ")"
		return scalar a = `a'
		return scalar a_lb = `a_lo'
		return scalar a_ub = `a_up'
		return scalar b = `b'
		return scalar b_lb = `b_lo'
		return scalar b_ub = `b_up'

		di
		local sqrl = sqrt(`l_sup'+1)
		local c
		if (`cusum'>1.63*`sqrl') local c "p < 0.01"
		if ((`cusum'<=1.63*`sqrl') & (`cusum'>1.36*`sqrl')) local c "p < 0.05"
		if ((`cusum'<=1.36*`sqrl') & (`cusum'>1.22*`sqrl')) local c "p < 0.10"
		if ((`cusum'<=1.22*`sqrl') & (`cusum'>1.07*`sqrl')) local c "p < 0.20"
		if (`cusum'<=1.07*`sqrl') local c "p > 0.20"
		di as txt "Linearity Test (CUSUM Test for deviation from linearity):   " as res "`c'"
		return local cusum = "`c'"

		if ("`list'"!="") {
			if ("`id'"=="") {
				generate `idv' = _n
				label variable `idv' "Ident."
				local id_list `idv'
			}
			else {
				local id_list `id'
			}
			label variable `yx' "Y-X"
			label variable `yxpct' "(Y-X) in % of X"
			sort `touse' `id_list'
			tabdisp `id_list' if `touse', cellvar( `x' `y' `yx' `yxpct')
		}
	}

	local ngraph
	local ntitle
	if _by() {
		*If by() get by number and title modifier for graphs
		local nby = _byindex()
		local ngraph = "_`nby'"
		local ntitle = "(by group `nby')"
	}

	if (`show'==2 | `show'==0) {
		*Bland-Altman Agreement
		local ba = `st'[2,3]
		local ba_lo = `ba' - invnormal((`level'+100)/200)*`st'[5,3]
		local ba_up = `ba' + invnormal((`level'+100)/200)*`st'[5,3]

		*Number of cases over and under the interval of agreement
		qui count if `touse' & `yx' > `ba_up'
		local nover = r(N)
		qui count if `touse' & `yx' < `ba_lo'
		local nunder = r(N)
		local pover = (`nover'/`nvalid')*100
		local punder = (`nunder'/`nvalid')*100

		*Print Bland-Altman Interval of Agreement
		di
		di as txt "{bf:Bland-Altman Interval of Agreement}"
		di as txt "{hline 62}"
		di as txt "{ralign 17:Mean of Y-X} = " as res %9.0g `ba' as txt " (`level'% CI: " /*
			*/		as res %9.0g `ba_lo' as txt " to " as res %9.0g `ba_up' as txt ")"
		di as txt "{ralign 17:Cases over limit} = " as res %5.0f `nover' as txt " (" _c
		print_pct `pover'
		di as txt ")"
		di as txt "{ralign 17:Cases under limit} = " as res %5.0f `nunder' as txt " (" _c
		print_pct `punder'
		di as txt ")"
		di as txt "{hline 62}"

		return scalar mean = `ba'
		return scalar mean_lb = `ba_lo'
		return scalar mean_ub = `ba_up'
		return scalar nover = `nover'
		return scalar nunder = `nunder'

		*Spearman correlation & Tests of normality
		quietly {
			spearman `yx' `yx2' if `touse', stats(p)
			local rho = r(rho)
			local p = r(p)
			summarize `yx' if `touse', detail
			local skew = r(skewness)
			local kurt = r(kurtosis)-3
			swilk `yx' if `touse'
			local W = r(W)
			local sw_p = r(p)
			sktest `yx' if `touse'
			local P_skew = r(P_skew)
			local P_kurt = r(P_kurt)
			local chi2 = r(chi2)
			local P_chi2 = r(P_chi2)
		}

		di as txt "Spearman correlation between (Y-X) and (X+Y)/2: r= " as res %7.4f `rho' as txt " (p= " as res %6.4f `p' as txt ")"
	}

	*Lin, L,(1989) A concordance correlation coefficient to evaluate reproductivity,Biometrics, 45:255-268.
	quietly {
		*st matrix has the tabstab results
		local meanx = `st'[2,1]
		local meany = `st'[2,2]
		local varx = `st'[5,1]^2
		local vary = `st'[5,2]^2
		gen `xy' = (`x' - `meanx')*(`y' - `meany') if `touse'
		sum `xy' if `touse'
		local sxy = r(sum)
		local lin = 2*(`sxy'/(`nvalid'-1))/(`varx' + `vary' + (`meanx'-`meany')^2)
	}
	return scalar lin = `lin'
	di as txt _newline "{bf:Lin's Concordance Correlation coeff.} of Absolute Agreement = " as res %6.4f `lin'

	if (`show'==2 | `show'==0) {
		di as txt _newline "Tests of Normality (Y-X)             p-value"
		di as txt "{hline 44}"
		di as txt "Shapiro-Wilk{ralign 14:W} = " as res %7.4f `W' "  " %6.4f `sw_p'
		di as txt "Skewness{ralign 18:Sk} = " as res %7.4f `skew' "  " %6.4f `P_skew'
		di as txt "Kurtosis-3{ralign 16:Ku} = " as res %7.4f `kurt' "  " %6.4f `P_kurt'
		di as txt "Skewness & Kurtosis{ralign 7:Chi2} = " as res %7.4f `chi2' "  " %6.4f `P_chi2'
		di as txt "{hline 44}"

		return scalar rho = `rho'
		return scalar p_rho = `p'
		return scalar W = `W'
		return scalar p_W = `sw_p'
		return scalar sk = `skew'
		return scalar p_sk = `P_skew'
		return scalar ku = `kurt'
		return scalar p_ku = `P_kurt'
		return scalar chi2 = `chi2'
		return scalar p_chi2 = `P_chi2'


		//Graphic: Bland-Altman (always)
		graph twoway (scatter `yx' `yx2', mfcolor(none) msize(medlarge) mcolor(black)) 	/*
		*/	(function y = `ba', range(`x') lcolor(black) lpattern(solid))			/*
		*/	(function y = `ba_up', range(`x') lcolor(black) lpattern(dash))	/*
		*/	(function y = `ba_lo', range(`x') lcolor(black) lpattern(dash)) 			/*
		*/	(function y = 0, range(`x') lcolor(black) lpattern(dash_dot)) if `touse', 			/*
		*/	legend(off) ytitle("Difference (Y-X)", size(medium) margin(vsmall)) /*
		*/  xtitle("Average (X+Y)/2", size(medium) margin(small))	/*
		*/	title("Bland-Altman Agreement `ntitle'", size(medium) color(black) margin(medium))  /*
		*/  name("bland_altman`ngraph'", replace)
	}

	//Graphic: Passing-Bablok (if asked)
	if ("`pbgraph'"!="" & (`show'<=1)) {
		if ("`pbgraph'"=="reg") {
			graph twoway (scatter `y' `x', mfcolor(none) msize(medlarge) mcolor(black)) 	/*
			*/	(function y = `a' +  `b' * x, range(`x') lcolor(black) lpattern(solid)) if `touse',		/*
			*/	legend(off) ytitle("`y'", size(medium) margin(vsmall))		/*
			*/	xtitle("`x'", size(medium) margin(small))		/*
			*/	title("Passing Bablok Regression line `ntitle'", size(medium) color(black) margin(medium)) /*
			*/	name("passing_bablok`ngraph'", replace)
		}
		if ("`pbgraph'"=="ci") {
			graph twoway (scatter `y' `x', mfcolor(none) msize(medlarge) mcolor(black)) 	/*
			*/	(function y = `a_lo' +  `b_lo' * x, range(`x') lcolor(black) lpattern(dash))	 	/*
			*/	(function y = `a_up' +  `b_up' * x, range(`x') lcolor(black) lpattern(dash)) if `touse', 	/*
			*/	legend(off) ytitle("`y'", size(medium) margin(vsmall))		/*
			*/	xtitle("`x'", size(medium) margin(small))		/*
			*/	title("Passing Bablok Regression line `ntitle'", size(medium) color(black) margin(medium)) /*
			*/	name("passing_bablok`ngraph'", replace)
		}
		if ("`pbgraph'"=="both") {
			graph twoway (scatter `y' `x', mfcolor(none) msize(medlarge) mcolor(black)) 	/*
			*/	(function y = `a' +  `b' * x, range(`x') lcolor(black) lpattern(solid))				/*
			*/	(function y = `a_lo' +  `b_lo' * x, range(`x') lcolor(black) lpattern(dash))	 	/*
			*/	(function y = `a_up' +  `b_up' * x, range(`x') lcolor(black) lpattern(dash)) if `touse', 	/*
			*/	legend(off) ytitle("`y'", size(medium) margin(vsmall))		/*
			*/	xtitle("`x'", size(medium) margin(small))		/*
			*/	title("Passing Bablok Regression line `ntitle'", size(medium) color(black) margin(medium)) /*
			*/	name("passing_bablok`ngraph'", replace)
		}
	}

	if (`show'<=1) return matrix Stats = `st'
	return scalar level = `level'
	*/
end

program define print_pct
	syntax anything, [col(numlist max=1) nopercent]
	local p = `anything'
	local fmt = cond(abs(`p')<10,cond(abs(`p')<1,"%5.0g","%5.2f"),"%5.1f")
	if ("`col'"=="") di as res `fmt' `p' _c
	else di as res _col(`col') `fmt' `p' _c
	if ("`percent'"=="") di as txt "%" _c
end

program define print_error
	args message
	display in red "`message'"
	exit 198
end

program print_lin
	args lin
	di as txt _newline "{bf:Lin's Concordance Correlation coeff.} of Absolute Agreement = " as res %6.4f `lin'
end

version 12
mata:
void getpbcoef(string scalar varx, string scalar vary, real scalar level, string scalar res, string scalar touse)
{
	real matrix	X, Y, S, R
	real scalar i, j, len, lfirst
	real scalar Sij, Sk
	real scalar N, K, even
	real scalar b, c, M1, M2, l, u

	//Get X, Y data from current dataset
	X = st_data(., varx, touse)
	Y = st_data(., vary, touse)

	//Compute the Sij elements (Passing and Bablok, J. Clin. Chem. Clin. Biochem. / Vol.21,1983 / No.11, pg.711)
	lfirst = 1
	len = rows(X)
	for (i=1; i<=len; i++) {
		for (j=i+1; j<=len; j++) {
			//Measurements with Xi = Xj or Yi = Yj do not contribute to the estimation of B
			if (Y[i]!=Y[j] & X[i]!=X[j]) {
				Sij = (Y[i] - Y[j]) / (X[i] - X[j])
				//Any Sij with a value of -1 is also disregarded
				if (Sij!=-1) {
					Sk = (Sij<-1)
					if (lfirst == 1) {
						S = (Sij,Sk)
						lfirst = 0
					}
					else {
						S = S \ (Sij,Sk)
					}
				}
			}
		}
	}
	S = sort(S,1)			//Sort the Sij results
	N = rows(S)				//N: total number of slopes Sij
	K = colsum(S)[1,2]		//K: number of Sij < -1
	even = (mod(N,2)==0)	//N is even?

	//b is estimated by the shifted median of the S[i] (Passing and Bablok, pg.712)
	if (even==1) b = 1/2*(S[N/2+K,1] + S[N/2+1+K,1])	//N is even
	else b = S[(N+1)/2+K,1]						//N is odd
	//Two-sided confidence interval for b (len is the number of nonmissing cases)
	c = invnormal((level+100)/200) * sqrt((len*(len-1)*(2*len+5))/18)
	M1 = round((N - c)/2)
	M2 = N - M1 + 1
	l = S[M1+K,1]
	u = S[M2+K,1]

	//Save results in Stata matrix
	st_matrix(res,(b,l,u))
}
end
