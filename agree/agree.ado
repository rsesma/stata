*! version 1.1.8  30sep2019 JM. Domenech, R. Sesma

/*
Agreement: Passing-Bablok & Bland-Altman methods
*/

program agree, byable(recall) sortpreserve rclass
	version 12
	syntax varlist(min=2 max=2 numeric) [if] [in], /*
	*/	[pb ba Level(numlist max=1 >=50 <100) pct line list id(varname numeric) ci nst(string)]

	tempvar yx xy yx2 yxpct diff ai ai_lo ai_up sort d r cusumi sort idv s
	tempname D S N R A bias sd t z lo up se bias_se


	if ("`pb'"!="" & "`ba'"!="") print_error "invalid data -- only one of ba, pb is possible"
	if ("`pb'"=="" & "`ba'"=="") local ba "ba"		// Bland-Altman is the default
	if ("`level'"=="") local level 95
	if ("`ba'"!="" & "`ci'"!="") print_error "ci option not allowed for Bland-Altman method"
	if ("`ba'"!="" & "`list'"!="") print_error "list option not allowed for Bland-Altman method"
	if ("`list'"=="" & "`id'"!="") print_error "id() option is only necessary for list option"
	if ("`pb'"!="" & "`pct'"!="") print_error "pct option not allowed for Passing-Bablok method"
	if ("`pb'"!="" & "`line'"!="") print_error "ci option not allowed for Passing-Bablok method"

	// x, y variables
	tokenize `varlist'
	local x `2'
	local y `1'
	if ("`x'"=="`y'") print_error "invalid data -- var X and var Y must be different"

	marksample touse, novarlist			// ifin marksample
	qui count if `touse'
	local ncases = r(N)					// total number of cases
	if (`ncases'==0) print_error "no observations"

	local ngraph
	local ntitle
	if _by() {
		*If by() get by number and title modifier for graphs
		local nby = _byindex()
		local ngraph = "_`nby'"
		local ntitle = "(by group `nby')"
	}

	quietly {
		* temporary variables
		gen `yx' = `y' - `x'
		gen `yx2' = (`y' + `x')/2
		gen `yxpct' = 100*(`yx'/`x')
		label variable `yx' "Y-X"
	    label variable `yxpct' "(Y-X) in % of X"

		* descriptive statistics
		matrix `N' = J(4,1,`ncases')
		tabstat `y' `x' `yx' `yxpct' if `touse', statistics(count median mean min max sd) save
		matrix `S' = r(StatTotal)'
		* valid miss obs
		mata: st_matrix("`D'",(st_matrix("`S'")[.,1], (st_matrix("`N'") :- st_matrix("`S'")[.,1]), st_matrix("`N'")))
		if ("`ba'"!="") {
			* Bland-Altman descriptive statistics: + mean sd ci
			matrix `D' = (`D', `S'[1...,3], `S'[1...,6])		// mean sd from tabstat
			matrix `D' = (`D'[1..2,1...], J(2,2,.))			// keep only 2 rows, add ci columns
			local i 1
			foreach v of varlist `y' `x' {
				ci `v' if `touse'				// use ci command to get conf. int.
				matrix `D'[`i',6] = r(lb)
				matrix `D'[`i',7] = r(ub)
				local ++i
			}
			matrix colnames `D' = Valid Miss Obs Mean StdDev MeanLB MeanUB
			matrix rownames `D' = Y X
		}
		* Passing-Bablok descriptive statistics: + median mean min max sd from tabstat
		if ("`pb'"!="") {
			matrix `D' = (`D', `S'[1...,2..6])
			matrix colnames `D' = Valid Miss Obs Median Mean Minimum Maximum StdDev
			matrix rownames `D' = Y X Y-X (Y-X)/X
		}
	}

	* valid number of cases
	markout `touse' `y' `x'				// exclude missing values of list vars
	qui count if `touse'
	local nvalid = `r(N)'
	return scalar N = `nvalid'			// save
	return scalar level = `level'		// save

	if ("`ba'"!="") {
		*** BLAND-ALTMAN METHOD
		* print title
		di as res _n "AGREEMENT: BLAND-ALTMAN METHOD"
		if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

		* descriptive statistics
		di _n as txt "Bland-Altman: Descriptive Statistics (listwise)"
		di "{hline 71}"
		di as txt "Variable    Valid  Miss   Obs      Mean  Std. Dev. [`level'% Conf. Interval]" _c
		foreach i of numlist 1/2 {
			if (`i'==1) di as txt _n "Y: " as res abbrev("`y'",8) _col(13) _c
			if (`i'==2) di as txt _n "X: " as res abbrev("`x'",8) _col(13) _c
			foreach j of numlist 1/7 {
				local fmt = cond(`j'<4,"%5.0f","%9.0g")
				di as res `fmt' `D'[`i',`j'] cond(`j'==4 | `j'==5,"  "," ") _c
			}
		}
		di _n "{hline 71}"
		di as txt "Valid number of cases (listwise): {bf:`nvalid'}"

		* Bland-Altman: absolute/percentage values of bias & LoA
		qui gen `diff' = 100*`yx'/`yx2'
		local tmp = cond("`pct'"=="",1,2)
		foreach i of numlist 1/`tmp' {
			di _n as txt "Bland-Altman: " cond(`i'==1,"Absolute","Percentage") _c
			di as txt " values of Bias & Limits of Agreement (LoA)"
			di "{hline 75}"

			if (`i'==1) {
				qui ttest `y' == `x' if `touse', level(`level')
				scalar `bias' = r(mu_1) - r(mu_2)
				scalar `sd' = r(se)*sqrt(r(N_1))
			}
			if (`i'==2) {
				qui ttest `diff' == 0 if `touse', level(`level')
				scalar `bias' = r(mu_1)
				scalar `sd' = r(sd_1)
			}
			scalar `t' = invttail(`r(df_t)',(100-`level')/200)
			scalar `z' = invnormal((100+`level')/200)
			scalar `bias_se' = r(se)
			scalar `lo' = `bias' - `z'*`sd'
			scalar `up' = `bias' + `z'*`sd'
			scalar `se' = `sd'*sqrt(3/r(N_1))
			local title = cond(`i'==1,"Diff. (Y-X):   Bias","100*(Y-X)/[(X+Y)/2]")

			di as txt "Parameter             Estimate  Std. Dev.   Std. Err.  [`level'% Conf. Interval]"
			di as txt "`title'  " as res %9.0g `bias' "  " % 9.0g `sd' "   " %9.0g `bias_se' _c
			di as res _col(57) %9.0g `bias' - `t'*`bias_se' " " %9.0g `bias' + `t'*`bias_se'
			di as txt _col(11) "Lower LoA  " as res %9.0g `lo' _col(45) %9.0g `se' _c
			di as res _col(57) %9.0g `lo' - `t'*`se' " " %9.0g `lo' + `t'*`se'
			di as txt _col(11) "Upper LoA  " as res %9.0g `up' _col(45) %9.0g `se' _c
			di as res _col(57) %9.0g `up' - `t'*`se' " " %9.0g `up' + `t'*`se'
			di "{hline 75}"

			*Number of cases over and under the interval of agreement
			qui count if `touse' & `yx' > `up'
			local nover = r(N)
			qui count if `touse' & `yx' < `lo'
			local nunder = r(N)
			local pover : di %5.2f (`nover'/`nvalid')*100 "%"
			local punder : di %5.2f (`nunder'/`nvalid')*100 "%"
			di as txt "Cases over limit = `nover'" " (" trim("`pover'") ")"
			di as txt "Cases under limit = `nunder'" " (" trim("`punder'") ")"
			if (`i'==1) {
				* spearman & lin concordance
				qui spearman `yx' `yx2' if `touse', stats(p)
				di as txt "Spearman correlation between (Y-X) and (X+Y)/2: r= " as res %7.4f `r(rho)' _c
				di as txt " (p= " as res %6.4f `r(p)' as txt ")"
				return scalar rho = `r(rho)'		// save
				return scalar p_rho = `r(p)'
				_lin, y(`y') x(`x') touse(`touse')
				return scalar lin = `r(lin)'			// save
			}
			di "{hline 75}"

			* save results
			local c = cond(`i'==1,"","_pct")
			return scalar mean`c' = `bias'
			return scalar mean_se`c' = `bias_se'
			return scalar LoA_lo`c' = `lo'
			return scalar LoA_up`c' = `up'
			return scalar LoA_se`c' = `se'
			return scalar nunder`c' = `nunder'
			return scalar nover`c' = `nover'

			* graphic: Bland-Altman
			local vx = cond(`i'==1,"`yx'","`diff'")
			local name = cond(`i'==1,"abs","pct")
			local title = cond(`i'==1,"Difference (Y-X)","100*(Y-X)/Average")
			local reg = cond("`line'"=="","","(lfit `vx' `yx2')")
			graph twoway (scatter `vx' `yx2', mfcolor(none) msize(medlarge) mcolor(black)) `reg'	/*
			*/	(function y = `bias', range(`x') lcolor(black) lpattern(solid))			/*
			*/	(function y = `up', range(`x') lcolor(black) lpattern(dash))	/*
			*/	(function y = `lo', range(`x') lcolor(black) lpattern(dash)) 			/*
			*/	(function y = 0, range(`x') lcolor(black) lpattern(dash_dot)) if `touse', 			/*
			*/	legend(off) ytitle("`title'", size(medium) margin(vsmall)) /*
			*/  xtitle("Average (X+Y)/2", size(medium) margin(small))	/*
			*/	title("Bland-Altman Agreement `ntitle'", size(medium) color(black) margin(medium))  /*
			*/  name("ba_`name'`ngraph'", replace)
		}

		* test of normality
		di as txt _n "Tests of Normality (Y-X)   Statistic    p-value"
		di as txt "{hline 47}"
		qui swilk `yx' if `touse'
		di as txt "Shapiro-Wilk" _col(29) "W = " as res %7.4f `r(W)' "  " %6.4f `r(p)'
		return scalar W = `r(W)'			// save
		return scalar p_W = `r(p)'
		qui su `yx' if `touse', detail
		local skew = r(skewness)
		local kurt = r(kurtosis)-3
		qui sktest `yx' if `touse'
		di as txt "Skewness" _col(28) "Sk = " as res %7.4f `skew' "  " %6.4f `r(P_skew)'
		di as txt "Kurtosis-3" _col(28) "Ku = " as res %7.4f `kurt' "  " %6.4f `r(P_kurt)'
		di as txt "Skewness & Kurtosis" _col(26) "Chi2 = " as res %7.4f `r(chi2)' "  " %6.4f `r(P_chi2)'
		di as txt "{hline 47}"
		return scalar sk = `skew'			// save
		return scalar p_sk = `r(P_skew)'
		return scalar ku = `kurt'
		return scalar p_ku = `r(P_kurt)'
		return scalar chi2 = `r(chi2)'
		return scalar p_chi2 = `r(P_chi2)'
	}

	if ("`pb'"!="") {
		*** PASSING-BABLOK METHOD
		* print title
		di as res _n "AGREEMENT: PASSING-BABLOK METHOD"
		if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

		* descriptive statistics
		di _n as txt "Passing-Bablok: Descriptive Statistics (listwise)"
		di "{hline 80}"
		di as txt "Variable    Valid  Miss   Obs    Median      Mean   Minimum   Maximum  Std. Dev." _c
		foreach i of numlist 1/4 {
			if (`i'==1) di as txt _n "Y: " as res abbrev("`y'",8) _col(13) _c
			if (`i'==2) di as txt _n "X: " as res abbrev("`x'",8) _col(13) _c
			if (`i'==3) di as txt _n "Y-X" _col(13) _c
			if (`i'==4) di as txt _n "100*(Y-X)/X" _col(13) _c
			foreach j of numlist 1/8 {
				local val = `D'[`i',`j']
				local fmt = cond(`j'<4,"%5.0f","%9.0g")
				if (`i'<4) {
					di as res `fmt' `val' cond(`j'==7,"  "," ") _c
				}
				else {
					if (`j'>3) local fmt = cond(abs(`val')<10,cond(abs(`val')<1,"%8.5g","%8.2f"),"%8.1f")
					di as res `fmt' `val' cond(`j'>3,"%","") cond(`j'==7,"  "," ") _c
				}
			}
		}
		di _n "{hline 80}"
		di as txt "Valid number of cases (listwise): {bf:`nvalid'}"

		* Passing-Bablok results: use Mata to compute b
	    mata: getpbcoef("`x'","`y'",`level',"`R'","`touse'")
	    local b = `R'[1,1]			//Put Mata results in Stata macros
	    local b_lo = `R'[1,2]
	    local b_up = `R'[1,3]

	    * compute the i elements for the a estimation; use tabstat median
	    quietly {
	        gen `ai' = `y' - `b'*`x'
	        gen `ai_lo' = `y' - `b_up'*`x'
	        gen `ai_up' = `y' - `b_lo'*`x'
	        tabstat `ai' `ai_lo' `ai_up' if `touse', statistics(median) save
	        matrix `A' = r(StatTotal)
	    }
	    local a = `A'[1,1]
	    local a_lo = `A'[1,2]
	    local a_up = `A'[1,3]

	    * correction for inverse confidence interval
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

		* print passing-bablock regression line results
	    di as txt _n "Passing-Bablok: Regression Line (Y = A + B*X)"
	    di as txt "{hline 48}"
	    di as txt " A = " as res %9.0g `a' as txt "  (`level'% CI: " as res %9.0g `a_lo' as txt " to " as res %9.0g `a_up' as txt ")"
	    di as txt " B = " as res %9.0g `b' as txt "  (`level'% CI: " as res %9.0g `b_lo' as txt " to " as res %9.0g `b_up' as txt ")"
	    di as txt "{hline 48}"

	    * save results
	    return scalar a = `a'
	    return scalar a_lb = `a_lo'
	    return scalar a_ub = `a_up'
	    return scalar b = `b'
	    return scalar b_lb = `b_lo'
	    return scalar b_ub = `b_up'

		* linearity test, cusum
	    quietly {
	        gen `s' = _n
	        label variable `s' "Ident."
	        * Di distances
	        gen `d' = (`y' + (1/`b')*`x' - `a')/sqrt(1+1/(`b'^2)) if `touse'
	        sort `touse' `d'					// sort to compute the number of points
	        count if `touse' & (`y' > `a'+`b'*`x')
	        local l_sup = r(N)					// number of points with Yi > a + bXi
	        count if `touse' & (`y' < `a'+`b'*`x')
	        local l_inf = r(N)					// number of points with Yi < a + bXi
	        * ri scores
	        gen `r' = 0 if `touse'
	        replace `r' = sqrt(`l_inf'/`l_sup') if `touse' & (`y' > `a'+`b'*`x')
	        replace `r' = -sqrt(`l_sup'/`l_inf') if `touse' & (`y' < `a'+`b'*`x')
	        gen `cusumi' = sum(`r') if `touse'		// cumulative sum
	        replace `cusumi' = abs(`cusumi') if `touse'
	        summarize `cusumi' if `touse'
	        local cusum = r(max)					// the maximum value marks the test
	        sort `s'
	    }
	    local sqrl = sqrt(`l_sup'+1)
	    if (`cusum'>1.63*`sqrl') local c "p < 0.01"
	    if ((`cusum'<=1.63*`sqrl') & (`cusum'>1.36*`sqrl')) local c "p < 0.05"
	    if ((`cusum'<=1.36*`sqrl') & (`cusum'>1.22*`sqrl')) local c "p < 0.10"
	    if ((`cusum'<=1.22*`sqrl') & (`cusum'>1.07*`sqrl')) local c "p < 0.20"
	    if (`cusum'<=1.07*`sqrl') local c "p > 0.20"
	    di as txt "Linearity Test (CUSUM Test for deviation from linearity):   {bf:`c'}"
	    return local cusum = "`c'"				// save
		_lin, y(`y') x(`x') touse(`touse')
		return scalar lin = `r(lin)'			// save

		* graphic: Passing-Bablok
	    local cilo
	    local ciup
	    if ("`ci'"!="") {
	        local cilo "(function y = `a_lo' +  `b_lo' * x, range(`x') lcolor(black) lpattern(dash))"
	        local ciup "(function y = `a_up' +  `b_up' * x, range(`x') lcolor(black) lpattern(dash))"
	    }
	    graph twoway (scatter `y' `x', mfcolor(none) msize(medlarge) mcolor(black)) `cilo' `ciup'	/*
	    */	(function y = `a' +  `b' * x, range(`x') lcolor(black) lpattern(solid)) if `touse',		/*
	    */	legend(off) ytitle("`y'", size(medium) margin(vsmall))		/*
	    */	xtitle("`x'", size(medium) margin(small))		/*
	    */	title("Passing Bablok Regression line `ntitle'", size(medium) color(black) margin(medium)) /*
	    */	name("pb`ngraph'", replace)

		* list input data
	    if ("`list'"!="") {
	        local id_list = cond("`id'"=="","`s'","`id'")
	        sort `touse' `id_list'
	        tabdisp `id_list' if `touse', cellvar( `x' `y' `yx' `yxpct')
	    }
	}

	return matrix Stats = `D'		// save
end


program _lin, rclass
	syntax [anything], y(varname) x(varname) touse(varname)

	tempvar xy
	tempname lin

	* Lin, L,(1989) A concordance correlation coefficient to evaluate reproductivity,Biometrics, 45:255-268
	foreach v of varlist `y' `x' {
		qui su `v' if `touse'
		local m`v' = r(mean)
		local v`v' = r(Var)
	}
	qui gen `xy' = (`x' - `m`x'')*(`y' - `m`y'')
	qui su `xy' if `touse'
	scalar `lin' = 2*(`r(sum)'/(`r(N)'-1))/(`v`x'' + `v`y'' + (`m`x''-`m`y'')^2)

	di as txt "Lin's Concordance Correlation coeff. of Absolute Agreement = " as res %6.4f `lin'

	return scalar lin = `lin'
end

program define print_error
	args message
	display in red "`message'"
	exit 198
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
