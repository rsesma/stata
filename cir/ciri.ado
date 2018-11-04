*! version 1.1.1  23jun2017 JM. Domenech, R. Sesma
/*
ciri: Confidence interval for Pearson/Spearman's correlation (immediate command)
If numlist has 2 elements, the CI for the correlation is computed
If numlist has 2 elements and the Rho option is specified, the correlation 
			is compared to a hypothetical sample
If numlist has 4 elements, the CI for comparing 2 correlations is computed
*/

program define ciri, rclass
	version 12
	syntax anything(id="argument numlist"), /*
		*/ [PEarson SPearman Rho(numlist max=1 >=-1 <=1) /*
		*/	Level(numlist max=1 >50 <100) nst(string)]

	tempname r1 n1 r0 n0 w se rd t p lo up lo0 up0
	
	*Tokenize & test parameters
    local len : word count `anything'
	if (`len' != 2 & `len' != 4) print_error "argument numlist must have 2 or 4 elements" 
	
	tokenize `anything'
	scalar `r1' = `1'
	scalar `n1' = `2'
	if (`r1'<-1 | `r1'>1) print_error "invalid data -- coefficient out of range"
	if (`n1'<=3) print_error "invalid data -- sample size out of range"
	local diff = (`len'==4)
	if (`diff') {
		scalar `r0' = `3'
		scalar `n0' = `4'
		if (`r0'<-1 | `r0'>1) print_error "invalid data -- coefficient out of range"
		if (`n0'<=3) print_error "invalid data -- sample size out of range"
	}
	
	local hypo = ("`rho'"!="")
	if (`len'==4 & `hypo'==1) print_error "too much options -- rho() is incompatible with comparing two correlations"
	if ("`pearson'"!="" & "`spearman'"!="") print_error "pearson and spearman options are incompatible" 
	if ("`pearson'"=="" & "`spearman'"=="") local type = 1		//Pearson by default
	if ("`pearson'"!="") local type = 1
	if ("`spearman'"!="") local type = 2
	
	if ("`level'"=="") local level 95
	
	if (`type'==1) local title = "Pearson"
	if (`type'==2) local title = "Spearman"
	local ntab = length("`title'")+2

	*Print header
	di
	if (`diff'==0 & `hypo'==0) di as res "CONFIDENCE INTERVAL FOR " upper("`title'") " CORRELATION"
	if (`diff'==0 & `hypo'==1) di as res "COMPARING A CORRELATION WITH A HYPOTETICAL VALUE"
	if (`diff'==1) di as res "CONFIDENCE INTERVAL FOR COMPARING TWO " upper("`title'") " CORRELATIONS"
	if ("`nst'"!="") display as text "{bf:STUDY:} `nst'"
	
	*Compute & print results
	scalar `w' = ln(sqrt((1+`r1')/(1-`r1')))
	scalar `se'= 1/sqrt(`n1'-3)
	getci `w' `se', level(`level')
	scalar `lo' = r(lo)
	scalar `up' = r(up)

	if (`diff'==0 & `hypo'==0) {
		*Conf. Interval for one correlation
		di as txt "`title' Correlation: r = " as res %7.5f `r1'
        di as txt _col(`ntab') "Sample size: n = " as res `n1'
		di
		di as txt "`level'% CI of r:  " as res %7.5f `lo' as txt "  to  " as res %7.5f `up'

		*For one correlation, use Student's t for the signification
		scalar `t' = `r1'*sqrt(`n1'-2)/sqrt(1-`r1'^2)
		if (`r1'<1) scalar `p' = min(2*ttail(`n1'-2,abs(`t')),1)
		else if (`r1'>=1 & `r1'<.) scalar `p' = 0
		else if (`r1'==.) scalar `p' = .
		di as txt "Significance: t=  " as res %4.2f `t' as txt "    p= " as res %7.5f `p'
		
		return scalar rho = `r1'
		return scalar lb_rho = `lo'
		return scalar ub_rho = `up'
		return scalar p = `p'
		return scalar N = `n1'
	}
	if (`diff'==0 & `hypo'==1) {
		di as txt "Hypothetical: Rho = " as res %6.4f `rho'
		di as txt "{ralign 19:`title' Corr.: r =} " as res %6.4f `r1' /*
			*/	as txt " (`level'% CI: " as res %6.4f `lo' /*
			*/	as txt " to " as res %6.4f `up' as txt ")"
		di as txt "{ralign 19:Sample size: n =} " as res `n1'

		scalar `rd' = `r1' - `rho'
		scalar `w' = ln(sqrt((1+`r1')/(1-`r1'))) - ln(sqrt((1+`rho')/(1-`rho')))
		getci `w' `se', level(`level')
		di
		di as txt "Difference: r-Rho = " as res %7.5f `rd'
		di as txt " " %4.0g `level' "% CI of Diff.: " as res %7.5f r(lo) /*
			*/	as txt "  to  " as res %7.5f r(up)
		di as txt "Significance (two-sided test):  z=  " as res %4.2f r(z) as txt "  p= " as res %7.5f r(p)
		
		return scalar rho = `r1'
		return scalar lb_rho = `lo'
		return scalar ub_rho = `up'
		return scalar rd = `rd'
		return scalar lb_rd = r(lo)
		return scalar ub_rd = r(up)
		return scalar p = r(p)
		return scalar N = `n1'		
	}
	if (`diff'==1) {
		di as txt "Sample 1: r1 = " as res %6.4f `r1' as txt /*
			*/	" (`level'% CI: " as res %6.4f `lo' as txt " to " /*
			*/ 	as res %6.4f `up' as txt ")"
		di as txt "          n1 = " as res `n1'

		scalar `w' = ln(sqrt((1+`r0')/(1-`r0')))
		scalar `se'= 1/sqrt(`n0'-3)
		getci `w' `se', level(`level')
		scalar `lo0' = r(lo)
		scalar `up0' = r(up)
		di as txt "Sample 0: r0 = " as res %6.4f `r0' as txt /*
			*/	" (`level'% CI: " as res %6.4f `lo0' as txt " to " /*
			*/ 	as res %6.4f `up0' as txt ")"
		di as txt "          n0 = " as res `n0'
		
		scalar `w' = ln(sqrt((1+`r1')/(1-`r1'))) - ln(sqrt((1+`r0')/(1-`r0')))
		scalar `se'= sqrt(1/(`n1'-3) + 1/(`n0'-3))
		scalar `rd'= `r1' - `r0'
		getci `w' `se', level(`level')
		di
		di as txt "Difference: r1-r0= " as res %7.5f `rd'
		di as txt "  `level'% CI of Diff.: " as res %7.5f r(lo) /*
			*/	as txt "  to  " as res %7.5f r(up)
		di as txt "Significance (two-sided test):  z=  " as res %4.2f r(z) as txt "  p= " as res %7.5f r(p)
		
		return scalar rho1 = `r1'
		return scalar lb_rho1 = `lo'
		return scalar ub_rho1 = `up'
		return scalar N1 = `n1'
		return scalar rho0 = `r0'
		return scalar lb_rho0 = `lo0'
		return scalar ub_rho0 = `up0'
		return scalar N0 = `n0'
		return scalar rd = `rd'
		return scalar lb_rd = r(lo)
		return scalar ub_rd = r(up)
		return scalar p = r(p)
	}
	return scalar level = `level'
end

program define getci, rclass
	syntax anything, level(numlist max=1 >50 <100)

	tempname w se z_alpha wl wu z
	
	tokenize `anything'
	scalar `w' = `1'
	scalar `se'= `2'

	scalar `z_alpha' = invnormal((`level'+100)/200)
	scalar `wl' = `w' - `z_alpha'*`se'
	scalar `wu' = `w' + `z_alpha'*`se'
	scalar `z' = `w'/`se'
	return scalar lo = (exp(2*`wl')-1)/(exp(2*`wl')+1)
	return scalar up = (exp(2*`wu')-1)/(exp(2*`wu')+1)
	return scalar z = `z'
	return scalar p = 2*(1-normal(abs(`z')))
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end
