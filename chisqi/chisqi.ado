*! version 1.1.0  16sep2019 JM. Domenech, R. Sesma
/*
chisqi: chi square comparisons
It receives n numlists, the first being the categorical distribution, 
and then the observed cases of each sample:
cat_distrib \ sample_1 \ sample_2 \ ... \ sample_n
*/

program define chisqi, rclass
	version 12
	syntax anything(id="argument numlist"), [Labels(string) nst(string)]

	tempname R S total chi2_over p_over
	
	*Check data
	local len : word count `anything'
	local first 1
	foreach i of numlist 1/`len' {
		local n : word `i' of `anything'
		if ("`n'"!="\") {
			if (`first') confirm number `n'			// theoretical distr. can be decimal
			else confirm integer number `n'			// cases observed must be integer
		} 
		else {
			local first 0					// after the first \, list of cases observed
		}
	}
	if (`first') print_error "data invalid -- at least one sample of observed cases is needed"
	
	mata: get_results("`anything'","`R'","`chi2_over'","`p_over'")
	
	if (`error') print_error "data invalid -- all the numlists must have the same number of elements"
	
	*Category labels
	if ("`labels'"!="") {
		local len : word count `labels'
		if (`len'!=`ncat') print_error "wrong number of elements in labels"
	}
	foreach i of numlist 1/`ncat' {
		if ("`labels'"!="") local lbl`i' : word `i' of `labels'
		else local lbl`i' = "`i'"
		local lbl`i' = substr("`lbl`i''",1,10)		// labels up to 10 chars
	}

	*Print header
	di as res _n "Goodness of fit Chi-squared test"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	di as txt _n _col(19) "Theoretical  {ralign 8:Cases}  {ralign 8:Cases}  {ralign 8:Cases}  {ralign 8:Pearson}"
	di as txt "Sample  Categories  {ralign 9:distrib.}  {ralign 8:Observed}  {ralign 8:Expected}  {ralign 8:Residual}  {ralign 8:Chi2}"
	*Print results for each sample
	foreach i of numlist 1/`nsamples' {
		matrix `S' = `R'_`i'
		di as txt %5.0f `i' _c
		foreach j of numlist 1/`ncat' {
			di as txt _col(9) "{ralign 10:`lbl`j''}   " _c
			foreach k of numlist 1/4 {
				local v = `S'[`j',`k']
				local fmt = cond(`k'>2,"%8.1f","%8.0g")
				if (`k'==1) print_pct `v', col(25)
				else di as res `fmt' `v' "  " _c
				if (`k'==1) di " " _c
			}
			local chi2_`i' = `S'[1,6]
			if (`j'<`ncat') di
			else di as res %8.0g `chi2_`i''
		}
		local p_`i' = `S'[1,7]
		di as txt _col(14) "Total" _col(27) as res "100" as txt "% " /*
		*/ as res %8.0g `S'[1,5] _col(62) as txt "p= " as res %5.3f `p_`i''
		di
		
		* stored results
		if (`nsamples'>1) {
			return scalar chi2_`i' = `chi2_`i''
			return scalar p_`i' = `p_`i''
		}
	}
	
	* print warning small samples
	di as txt cond(`warning'==1,"WARNING: Expected frequencies < 5","") _c
	if (`nsamples'>1) {
		* if there are more than 1 sample, print OVERALL results
		di as txt _col(52) "OVERALL:" _col(62) as res %8.0g `chi2_over'
		di as txt _col(62) "p= " as res %5.3f `p_over' _c
	}
	di

	* stored results
	return scalar chi2 = `chi2_over'
	return scalar p = `p_over'
	
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end

program define print_pct
	syntax anything, [col(numlist max=1) nopercent]
	local p = `anything' * 100
	local fmt = cond(abs(`p')<10,cond(abs(`p')<1,"%5.0g","%5.2f"),"%5.1f")
	if ("`col'"=="") di as res `fmt' `p' _c
	else di as res _col(`col') `fmt' `p' _c
	if ("`percent'"=="") di as txt "%" _c
end


version 12
mata:
void get_results(string scalar data, string scalar results, string scalar res_chi2, string scalar res_p)
{
	string matrix d
	real matrix D, O, E, R, res
	real scalar n, ncat, chi2, p
	real scalar chi2_over, df_over
	real scalar err, warn
	
	err = 0
	warn = 0
	d = tokens(data,"\")
	d = select(d, d[1,.]:!="\")			// erase the "\"
	
	// theoretical distribution 
	D = strtoreal(tokens(d[1,1]))'
	D = D :/ sum(D)
	ncat = rows(D)						// number of categories
	
	chi2_over = 0
	df_over = 0
	for (i=2; i<=cols(d); i++) {
		O = strtoreal(tokens(d[1,i]))'		// observed frequencies
		if (rows(O) == ncat) {
			n = sum(O)
			E = D :* n						// expected frequencies
			R = O :- E
			chi2 = sum(R:^2 :/ E)
			p = 1- chi2(ncat - 1,chi2)
			res = D, O, E, R, J(ncat,1,n), J(ncat,1,chi2), J(ncat,1,p)
			st_matrix( results + "_" + strofreal(i-1), res)
			
			chi2_over = chi2_over + chi2
			df_over = df_over + (ncat - 1)
		}
		else {
			err = 1				// all the numlist must have the same number of elements
			exit
		}
	}
	for (i=1; i<=rows(E); i++) {
		if (E[i]<5) warn=1
	}

	st_local("ncat", strofreal(ncat))				// number of categories
	st_local("nsamples", strofreal(cols(d)-1))		// number of samples
	st_local("error", strofreal(err))				// error and warning
	st_local("warning", strofreal(warn))
	
	st_numscalar(res_chi2, chi2_over)
	st_numscalar(res_p, (1- chi2(df_over, chi2_over)))
}
end