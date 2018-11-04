*! version 1.1.1  23jun2017 JM. Domenech, R. Sesma
/*
cir: Confidence interval for Pearson/Spearman's correlation 
*/

program define cir, byable(recall)
	version 12
	syntax varlist(min=2 max=2 numeric) [if] [in], /*
		*/	[PEarson SPearman Rho(numlist max=1 >=-1 <=1) /*
		*/	 by(varname numeric) Level(numlist max=1 >50 <100) nst(string)]
	
	if ("`pearson'"=="" & "`spearman'"=="") local pearson = "pearson"
	
	marksample touse			//Mark observations [if/in]

	//Get results; use pearson/spearman command to obtain rho and N, and call ciri
	if ("`by'"=="") {
		if ("`pearson'"!="") qui correlate `varlist' if `touse'
		if ("`spearman'"!="") qui spearman `varlist' if `touse'
		ciri r(rho) r(N), rho(`rho') `pearson' `spearman' level(`level') nst(`nst')
	}
	else {
		quietly levelsof `by' if `touse', local(levels)
		local nlevels : word count `levels'
		if (`nlevels'!=2) {
			di in red "by() variable must be binary" 
			exit 198
		}
		
		tempname r1 n1 r0 n0
		forvalues i = 1/2 {
			local val : word `i' of `levels'
			if ("`pearson'"!="") qui correlate `varlist' if `touse' & `by'==`val'
			if ("`spearman'"!="") qui spearman `varlist' if `touse' & `by'==`val'
			local j = `i'-1
			scalar `r`j'' = r(rho)
			scalar `n`j'' = r(N)
		}
		ciri `r1' `n1' `r0' `n0', rho(`rho') `pearson' `spearman' level(`level') nst(`nst')
	}
end
