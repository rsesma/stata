*! version 1.1.2  17jan2019 JM. Domenech, R. Sesma

program define cohenkapi, rclass
	version 12
	syntax anything(id="argument numlist"), /*
	*/	[Wilson Exact WAld Level(numlist max=1 >50 <100) ordered nst(string) /*
	*/	 _vy(varname) _vx(varname) _values(numlist)]

	tempname d t r agr

	if ("`level'"=="") local level 95
	if ("`wilson'"=="" & "`exact'"=="" & "`wald'"=="") local method = 1
	*Check parameters
	if ("`wilson'"!="" & ("`exact'"!="" | "`wald'"!="")) print_error "only one of wilson, exact, wald options is allowed"
	if ("`exact'"!="" & "`wald'"!="") print_error "only one of wilson, exact, wald options is allowed"
	if ("`wilson'"!="") local method = 1
	if ("`exact'"!="") local method = 2
	if ("`wald'"!="") local method = 3

	*Build data matrix
	local k 0
	tokenize `anything', parse("\")
	while "`*'" != "" {
		if ("`1'"!="\") {
			local ++k
			local r`k' `1'
		}
		macro shift
	}
	foreach i of numlist 1/`k' {
		tokenize `r`i''
		while "`*'" != "" {
			confirm integer number `1'
			macro shift
		}
		mata: st_matrix("`t'",strtoreal(tokens(st_local("r`i'"))))
		if (colsof(`t')!=`k')  print_error "the data matrix must be squared; the number of categories must be constant"
		if (`i'==1) matrix `d' = `t'
		else matrix `d' = `d' \ `t'
	}
	if (rowsof(`d')!=`k')  print_error "the data matrix must be squared; the number of categories must be constant"
	*If there's no errors, add totals to data matrix
	mata: st_matrix("`t'", (st_matrix("`d'"), rowsum(st_matrix("`d'"))))
	mata: st_matrix("`t'", (st_matrix("`t'")\ colsum(st_matrix("`t'"))))

	local k = colsof(`d')			//Number of categories
	if (`k'<2) print_error "too few rating categories"
	if (`k'>9) print_error "too much rating categories"
	if (`k'==2 & "`ordered'"!="") print_error "ordered option not applicable for 2 categories"

	*Get labels
	local len = 11*`k'
	local rtitle = cond("`_vy'"=="","RatingY",abbrev("`_vy'",10))
	local ctitle = cond("`_vx'"=="","RatingX",abbrev("`_vx'",`len'))
	foreach i of numlist 1/`k' {
		if ("`_vy'"=="") {
			local lbl`i' = "`i'"
		}
		else {
			local v : word `i' of `_values'
			local lbl`i' : label (`_vy') `v' 10
		}
	}

	*Print title
	di "{bf:KAPPA & WEIGHTED KAPPA}"
	if ("`nst'"!="") di as text "{bf:STUDY:} `nst'"

	*Print table
	di
	di as txt _col(12) "{c |}{center `len':`ctitle'}"
	di as txt "{ralign 10:`rtitle'} {c |}" _c
	foreach i of numlist 1/`k' {
		di "{ralign 11:`lbl`i''}" _c
	}
	di " {c |}{ralign 11:Total}"
	di "{hline 11}{c +}{hline `len'}{hline 1}{c +}{hline 11}" _c
	local z = `k'+1
	foreach i of numlist 1/`z' {
		if (`i'<`z') di _newline as txt "{ralign 10:`lbl`i''} {c |} " _c
		else di _newline as txt "{ralign 10:Total} {c |} " _c
		foreach j of numlist 1/`z' {
			di as res %10.0g `t'[`i',`j'] cond(`j'==`k'," {c |} "," ") _c
		}
		if (`i'==`k') di _newline "{hline 11}{c +}{hline `len'}{hline 1}{c +}{hline 11}" _c
	}

	mata: get_results("`d'", "`r'", "`ordered'"!="", `level')

	local warning 0
	if (`k'>2) {
		*nxn table: general case
		*Print of kappa, observed agreement, standard errors and ci
		di as txt _newline _newline "{hline 12}{c TT}{hline 9}{c TT}{hline 8}{c TT}{hline 17}{c TT}{hline 8}{c TT}{hline 17}"
		di as txt "{col 13}{c |} Observed{c |}{col 32}{c |}  Standard Error {c |}{col 55}p{col 59}{c |} " %4.0g `level' "% Asymptotic"
		di as txt "{col 6}Weight {c |}Agreement{c |}  Kappa {c |}{col 37}SE0 {c |}{col 46}SE1 {c |}  value {c |}  Conf. Interval"
		di as txt "{hline 12}{c +}{hline 9}{c +}{hline 8}{c +}{hline 8}{c +}{hline 8}{c +}{hline 8}{c +}{hline 17}" _c

		*Get labels
		local rlab1 = "UnWeighted "
		if ("`ordered'"!="") {
			local rlab2 = "Lineal "
			local rlab3 = "Quadratic "
		}
		else {
			foreach i of numlist 1/`k' {
				local z = `i'+1
				local rlab`z' = "`lbl`i''-R"
			}
		}

		local len = rowsof(`r')
		foreach i of numlist 1/`len' {
			di as txt _newline "{ralign 12:`rlab`i''}{c |}" _c
			foreach j of numlist 1/7 {
				if (`j'<=5) di as txt " " _c
				local fmt = cond(`j'>5,"%7.4f","%6.4f")
				local v = `r'[`i',`j']
				if (`j'==1) print_pct `v'
				else di as res `fmt' `v' _c
				if (`j'==1) di as txt " " _c
				if (`j'<=5) di as txt " {c |}" _c
				if (`j'==6) di as txt " to" _c
			}
			if (`i'==1 & "`ordered'"=="") {
				di as txt _newline "{hline 12}{c +}{hline 9}{c +}{hline 8}{c +}{hline 8}{c +}{hline 8}{c +}{hline 8}{c +}{hline 17}" _c
				di as txt _newline "{ralign 12:Categories:}{c |}{col 23}{c |}{col 32}{c |}{col 41}{c |}{col 50}{c |}{col 59}{c |}" _c
			}
			if (`r'[`i',6]<-1 | `r'[`i',7]>1) {
				di as txt "*" _c
				local warning 1
			}
		}
		di as txt _newline "{hline 12}{c BT}{hline 9}{c BT}{hline 8}{c BT}{hline 8}{c BT}{hline 8}{c BT}{hline 8}{c BT}{hline 17}"

		*Stored results
		local names "po kappa se0 se1 p lb ub"
		if ("`ordered'"!="") {
			local weights "u l q"
			foreach i of numlist 1/3 {
				local w : word `i' of `weights'
				foreach j of numlist 1/7 {
					local n : word `j' of `names'
					return scalar `n'_`w' = `r'[`i',`j']
				}
			}
		}
		else {
			local rnames
			foreach i of numlist 2/`len' {
				local rnames = "`rnames' `rlab`i''"
			}
			foreach j of numlist 1/7 {
				local n : word `j' of `names'
				return scalar `n' = `r'[1,`j']
			}
			matrix `t' = `r'[2..`len',1..7]
			matrix rownames `t' = `rnames'
			matrix colnames `t' = `names'
			return matrix Categories = `t'
		}
	}
	else {
		*2x2 table: particular case
		*unweighted kappa, standard error an ci
		di as txt _newline _newline "{hline 8}{c TT}{hline 17}{c TT}{hline 8}{c TT}{hline 20}"
		di as txt "{col 9}{c |}  Standard Error {c |}{col 32}p{col 36}{c |}{col 39} " %4.0g `level' "% Asymptotic"
		di as txt "  kappa {c |}    SE0 {c |}    SE1 {c |}  value {c |} Confidence Interval"
		di as txt "{hline 8}{c +}{hline 8}{c +}{hline 8}{c +}{hline 8}{c +}{hline 20}"
		foreach j of numlist 2/7 {
			local fmt = cond(`j'>5,"%7.4f","%6.4f")
			di as txt " " _c
			di as res `fmt' `r'[1,`j'] _c
			if (`j'<=5) di as txt " {c |}" _c
			if (`j'==6) di as txt "  to" _c
		}
		if (`r'[1,6]<-1 | `r'[1,7]>1) {
			di as txt "*" _c
			local warning 1
		}
		di as txt _newline "{hline 8}{c BT}{hline 8}{c BT}{hline 8}{c BT}{hline 8}{c BT}{hline 20}"

		local n11 = `d'[1,1]
		local n12 = `d'[1,2]
		local n21 = `d'[2,1]
		local n22 = `d'[2,2]
		local n = `n11'+`n12'+`n21'+`n22'

		*Specific Agreement positive
		local a = 2*`n22'
		local b = (2*`n22' + `n21' + `n12')
		get_cip `a' `b', method(`method') level(`level')
		matrix `agr' = (r(p),r(lb),r(ub))

		*Specific Agreement negative
		local a = 2*`n11'
		local b = 2*`n11' + `n21' + `n12'
		get_cip `a' `b', method(`method') level(`level')
		matrix `agr' = `agr' \ (r(p),r(lb),r(ub))

		*Global Agreement
		local a = `n11' + `n22'
		local b = `n'
		get_cip `a' `b', method(`method') level(`level')
		matrix `agr' = `agr' \ (r(p),r(lb),r(ub))

		*Kappa min & max
		local ga = r(p)/100
		local kmin = (`ga'-1)/(`ga'+1)		//Lantz & Nebenzahl (1996) for 2x2 table only
		local kmax = (`ga'^2)/((1-`ga')^2+1)
		matrix `agr' = `agr' \ (`kmin',.,.) \ (`kmax',.,.)

		*Observed disagreement and Bias; BAK & PABAK
		local d12 = 100*`n12'/`n'
		local d21 = 100*`n21'/`n'
		local bias = `d21' - `d12'
		local m = (`n12' + `n21')/2
		local m1 = `n11' + `m'
		local n1 = `n11' + `m'
		local m2 = `n22' + `m'
		local n2 = `n22' + `m'
		local po= (`n11' + `n22')/`n'
		local pe= ((`m1'*`n1')/`n' + (`m2'*`n2')/`n')/`n'
		local bak = (`po'-`pe')/(1-`pe')
		local pi_p = 100*(2*`n22' + `n21' + `n12')/(2*`n')
		local pi_a = 100*(2*`n11' + `n21' + `n12')/(2*`n')
		local pi = `pi_p' - `pi_a'
		local pabak = 2*`po' - 1

		local lbl1 = "Specific Agreement (+)"
		local lbl2 = "Specific Agreement (-)"
		local lbl3 = "Global Agreement (+)"
		local lbl4 = "kappa  minimum "
		local lbl5 = "maximum "
		local c = cond(`method'==1,"Wilson",cond(`method'==2,"Exact","Wald"))

		di
		di as txt "{hline 22}{c TT}{hline 10}{c TT}{hline 28}"
		di as txt "{col 23}{c |} Estimate {c |} " %4.0g `level' "% Confidence Interval"
		di as txt "{hline 22}{c +}{hline 10}{c +}{hline 28}" _c
		foreach i of numlist 1/5 {
			di as txt _newline "{ralign 22:`lbl`i''}{c |}  " _c
			foreach j of numlist 1/3 {
				local v = `agr'[`i',`j']
				if (`v'<.) {
					if (`i'<=3) print_pct `v'
					else di as res %7.4f `v' _c
					if (`i'<=3) di " " _c
				}
				if (`j'==1) di as txt " {c |} " _c
				if (`i'<=3 & `j'==2) di as txt " to " _c
				if (`i'<=3 & `j'==3) di as txt " (`c')" _c
			}
			if (`i'==2) di as txt _newline "{hline 22}{c +}{hline 10}{c +}{hline 28}" _c
		}
		di as txt _newline "{hline 22}{c BT}{hline 10}{c BT}{hline 28}"

		tempname od
		matrix `od' = ((`d21',`d12',`bias',`bak')\(`pi_p',`pi_a',`pi',`pabak'))
		di
		foreach i of numlist 1/2 {
			if (`i'==1) {
				di as txt "Observed Disagreement {c |}    Bias  {c |} Bias adjusted kappa"
				di as txt "{col 9}X-Y+     X+Y- {c |}   Index  {c |}    BAK"
				di as txt "{hline 22}{c +}{hline 10}{c +}{hline 28}"
			}
			if (`i'==2) {
				di as txt "{hline 22}{c +}{hline 10}{c +}{hline 28}"
				di as txt _col(4) "Observed Agreement {c |}Prevalence{c |} Prev. & Bias adjusted kappa"
				di as txt _col(10) "(+)      (-) {c |}   Index  {c |}  PABAK"
				di as txt "{hline 22}{c +}{hline 10}{c +}{hline 28}"
			}
			foreach j of numlist 1/4 {
				local v = `od'[`i',`j']
				if (`j'==1) print_pct `v', col(7)
				if (`j'==2) print_pct `v', col(16)
				if (`j'==2) di as txt " {c |}  " _c
				if (`j'==3) print_pct `v'
				if (`j'==4) di as res _col(34) "{c |} " %6.4f `v'
			}
		}
		di as txt "{hline 22}{c BT}{hline 10}{c BT}{hline 28}"

		*Stored results
		local names "po kappa se0 se1 p lb ub"
		foreach j of numlist 2/7 {
			local n : word `j' of `names'
			return scalar `n' = `r'[1,`j']
		}
		local names "agr_p agr_n agr"
		foreach i of numlist 1/3 {
			local n : word `i' of `names'
			foreach j of numlist 1/3 {
				local pre = cond(`j'==2,"lb_",cond(`j'==3,"ub_",""))
				return scalar `pre'`n' = `agr'[`i',`j']
			}
		}
		return scalar kappa_min = `kmin'
		return scalar kappa_max = `kmax'
		return scalar obs_dis_p = `d21'
		return scalar obs_dis_n = `d12'
		return scalar bias = `bias'
		return scalar bak = `bak'
		return scalar obs_agr_p = `pi_p'
		return scalar obs_agr_n = `pi_a'
		return scalar pi = `pi'
		return scalar pabak = `pabak'
	}
	if (`warning'==1) di as txt "(*)Out of range"

end

program define print_pct
	syntax anything, [col(numlist max=1) nopercent]
	local p = `anything'
	local fmt = cond(abs(`p')<10,cond(abs(`p')<1,"%5.0g","%5.2f"),"%5.1f")
	if ("`col'"=="") di as res `fmt' `p' _c
	else di as res _col(`col') `fmt' `p' _c
	if ("`percent'"=="") di as txt "%" _c
end

program define get_cip, rclass
	syntax anything, method(integer) level(real)

	tokenize `anything'
	local a `1'
	local b `2'

	local alpha = (`level'+100)/200
	local z = invnormal(`alpha')

	local p = `a'/`b'
	if (`method'==1) {
		local wa = 2*`a' + `z'^2
		local wb = `z' * sqrt(`z'^2 + 4*`a'*(`b'-`a')/`b')
		local wc = 2*(`b' + `z'^2)
		local lb = (`wa'-`wb')/`wc'
		local ub = (`wa'+`wb')/`wc'
	}
	if (`method'==2) {
		local lb 0
		local ub 1
		if (`a'>0) local lb = `a'/(`a'+(`b'-`a'+1)*invF(2*(`b'-`a'+1),2*`a',`alpha'))
		if (`b'>`a') local ub = (`a'+1)/((`a'+1)+((`b'-`a')/invF(2*(`a'+1),2*(`b'-`a'),`alpha')))
	}
	if (`method'==3) {
		local se = sqrt(`p'*(1-`p')/`b')
		local lb = `p' - `z'*`se'
		local ub = `p' + `z'*`se'
	}

	return scalar p = 100*`p'
	return scalar lb = 100*`lb'
	return scalar ub = 100*`ub'
	return scalar warn = (`lb'<0 | `ub'>1)
end

program define print_error
	args message
	display in red "`message'"
	exit 198
end


version 12
mata:
void get_results(string scalar data, string scalar result, real scalar ordered, real scalar level)
{
	real matrix d, r
	real scalar k, i, a1, a0, b1, b0

	d = st_matrix(data)		//Stata matrix with frequency results
	k = rows(d)
	r = get_kappa("unw", d, k, level)					//Unweighted kappa
	if (ordered==1) {
		r = r \ get_kappa("lin", d, k, level)			//Weighted: lineal
		r = r \ get_kappa("quad", d, k, level)			//Weighted: quadratic
	}
	else {
		//Partial 2x2 tables
		for (i=1; i<=k; i++) {
			a1 = d[i,i]
			a0 = rowsum(d)[i] - a1
			b1 = colsum(d)[i] - a1
			b0 = sum(d) - (a1+a0+b1)
			r = r \ get_kappa("unw",(a1,b1\a0,b0),2,level)
		}
	}
	st_matrix(result,r)
}
end

version 12
mata:
real matrix get_kappa(string scalar type, real matrix d, real matrix k, real scalar level)
{
	real matrix	p, w, wi, wj
	real rowvector pi_, p_i
	real scalar kappa, n, po, pe, se0, z, sig, se1
	real scalar i, j

	//Compute weighted kappa results as described in
	//Statistical Methods for Rates and Proportions, Joseph L. Fleiss (chapter 18)
	n = sum(d)				//Total n
	p = d :/ n				//proportion pi matrix
	pi_ = rowsum(p)			//row totals
	p_i = colsum(p)'		//column totals

	//Weights (18.31 & 18.30 formulas)
	w = J(k,k,.)
	for (i=1; i<=k; i++) {
		for (j=1; j<=k; j++) {
			if (type=="unw") w[i,j] = (i==j)				//Unweighted
			if (type=="lin") w[i,j] = 1- (abs(i-j))/(k-1)	//Linear
			if (type=="quad") w[i,j] = 1- ((i-j)/(k-1))^2	//Quadratic
		}
	}

	//Observed (po) & chance-expected (pe) proportion of agreement (18.27 & 18.28)
	po = 0
	pe = 0
	for (i=1; i<=k; i++) {
		for (j=1; j<=k; j++) {
			po = po + w[i,j]*p[i,j]
			pe = pe + w[i,j]*pi_[i]*p_i[j]
		}
	}

	kappa = (po - pe)/(1-pe)	//Weighted Kappa (18.29)

	//Compute wi and wj summatories (18.33 & 18.34)
	wi = J(1,k,0)
	wj = J(1,k,0)
	for (i=1; i<=k; i++) {
		for (j=1; j<=k; j++) {
			wi[1,i] = wi[1,i] + p_i[j]*w[i,j]
			wj[1,i] = wj[1,i] + pi_[j]*w[j,i]
		}
	}

	//SE0 (18.32)
	se0 = 0
	for (i=1; i<=k; i++) {
		for (j=1; j<=k; j++) {
			se0 = se0 + pi_[i]*p_i[j]*(w[i,j]-(wi[1,i]+wj[1,j]))^2
		}
	}
	se0 = sqrt(se0 - pe^2)/((1-pe)*sqrt(n))

	z = kappa / se0				//z value (18.35)

	//SE1 (18.36)
	se1=0
	for (i=1; i<=k; i++) {
		for (j=1; j<=k; j++) {
			se1 = se1 + p[i,j]*(w[i,j]-(wi[1,i]+wj[1,j])*(1-kappa))^2
		}
	}
	se1 = sqrt(se1-(kappa-pe*(1-kappa))^2)/((1-pe)*sqrt(n))
	lb = kappa - invnormal((level+100)/200)*se1
	ub = kappa + invnormal((level+100)/200)*se1

	return((100*po,kappa,se0,se1,2*(1-normal(abs(z))),lb,ub))
}
end
