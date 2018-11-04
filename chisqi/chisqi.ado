*! version 1.0.9  11may2018 JM. Domenech, R. Sesma
/*
chisqi: chi square comparisons
It receives n numlists, the first being the categorical distribution, 
and then the observed cases of each sample:
cat_distrib \ sample_1 \ sample_2 \ ... \ sample_n
*/

program define chisqi, rclass
	version 12
	syntax anything(id="argument numlist"), [Labels(string) nst(string)]

	tempname d s
	
	*Check data and build data matrix
	local len : word count `anything'
	foreach i of numlist 1/`len' {
		local n : word `i' of `anything'
		if ("`n'"!="\") confirm integer number `n'
	}
	mata: get_data("`anything'","`d'")
	if ("`error'"=="1") print_error "data invalid -- at least one sample of observed cases is needed"
	if ("`error'"=="2") print_error "data invalid -- all the numlists must have the same number of elements"
	
	*Category labels
	mata: s=get_submatrix("`d'","`s'",1)
	local ncat = rowsof(`s')
	if ("`labels'"!="") {
		local len : word count `labels'
		if (`len'!=rowsof(`s')) print_error "wrong number of elements in labels"
	}
	foreach i of numlist 1/`ncat' {
		if ("`labels'"!="") local lbl`i' : word `i' of `labels'
		else local lbl`i' = "`i'"
	}
	local warning 0
	
	*Print header
	di
	di as res "Goodness of fit Chi-squared test"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	di
	di as txt _col(19) "Theoretical  {ralign 8:Cases}  {ralign 8:Cases}  {ralign 8:Cases}  {ralign 8:Pearson}"
	di as txt "Sample  Categories  {ralign 9:distrib.}  {ralign 8:Observed}  {ralign 8:Expected}  {ralign 8:Residual}  {ralign 8:Chi2}"
	*Compute results for each sample
	foreach i of numlist 1/`nsamples' {
		mata: get_results("`d'",`i',"`s'")
		if ("`warn'"=="1") local warning 1
		di as txt %5.0f `i' _c
		foreach j of numlist 1/`ncat' {
			di as txt _col(9) "{ralign 10:`lbl`j''}   " _c
			foreach k of numlist 1/4 {
				local v = `s'[`j',`k']
				local fmt = cond(`k'<3,"%8.0g","%8.1f")
				if (`k'==1) print_pct `v', col(25)
				else di as res `fmt' `v' "  " _c
				if (`k'==1) di " " _c
			}
			local chi2_`i' = `s'[1,6]
			if (`j'<`ncat') di
			else di as res %8.0g `chi2_`i''
		}
		local df_`i' = `ncat'-1
		local p_`i' = 1- chi2(`df_`i'',`chi2_`i'')
		di as txt _col(14) "Total" _col(27) as res "100" as txt "% " /*
		*/ as res %8.0g `s'[1,5] _col(62) as txt "p= " as res %5.3f `p_`i''
		di
	}
	
	if (`nsamples'>1) {
		*If there are more than 1 sample, print OVERALL results
		local chi2 = 0
		local df = 0
		forvalues i = 1/`nsamples' {
			local chi2 = `chi2' + `chi2_`i''
			local df = `df' + `df_`i''
			
			return scalar chi2_`i' = `chi2_`i''
			return scalar p_`i' = `p_`i''
		}
		local p = 1- chi2(`df',`chi2')
		
		di as txt cond(`warning'==1,"WARNING: Expected frequencies < 5","") /*
		*/	_col(52) "OVERALL:" _col(62) as res %8.0g `chi2'
		di as txt _col(62) "p= " as res %5.3f `p'
		
		return scalar chi2 = `chi2'
		return scalar p = `p'
	}
	else {
		if (`warning'==1) display as text "WARNING: Expected frequencies < 5"		//Print warning small samples

		return scalar chi2 = `chi2_1'
		return scalar p = `p_1'
	}

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


version 12
mata:
void get_data (string scalar s, string scalar res)
{
	string matrix t
	string matrix d
	real matrix r
	real vector c, tmp
	real scalar i, n
	string scalar err
	
	err="0"
	t = tokens(s,"\")
	for (i=1; i<=cols(t); i++) {
		if (t[i]!="\") {
			if (rows(d)==0) d = t[i]
			else d = d \ t[i]
		}
	}
	
	if (rows(d)>=2) {
		c = strtoreal(tokens(d[1]))'
		n = rows(c)
		for (i=2; i<=rows(d); i++) {
			tmp = strtoreal(tokens(d[i]))'
			if (n==rows(tmp)) {
				if (rows(r)==0) r = J(rows(c),1,i-1), c, tmp
				else r = r \ J(rows(c),1,i-1), c, tmp
			}
			else {
				err="2"
				break
			}
		}
	}
	else {
		err="1"
	}

	st_local("error",err)
	st_local("nsamples",strofreal(rows(d)-1))
	st_matrix(res,r)
}
end

version 12
mata:
real matrix get_submatrix(string scalar data, string scalar sub, real scalar val)
{
	real matrix d, s
	d = st_matrix(data)
	s = select(d, d[.,1] :== val)
	if (sub!="") st_matrix(sub,s)
	return(s)
}
end

version 12
mata:
void get_results(string scalar data, real scalar val, string scalar res)
{
	real matrix d, s, results
	real rowvector t, e, r, chi2
	real scalar sum_cat, n
	string scalar warn
	
	d = st_matrix(data)
	s = get_submatrix(data,"",val)
	sum_cat = sum(s[.,2])
	n = sum(s[.,3])
	t = (100 :* (s[.,2] :/ sum_cat))		//Theoretical distribution
	e = n :* t :/ 100						//Expected cases
	r = s[.,3] :- e							//Residual cases
	chi2 = r:^2 :/ e						//Chi2 summatory terms
	warn = "0"
	for (i=1; i<=rows(e); i++) {
		if (e[i]<5) warn="1"
	}
	st_local("warn",warn)
	st_matrix(res,(t,s[.,3],e,r,J(rows(s),1,n),J(rows(s),1,sum(chi2))))
}
end

