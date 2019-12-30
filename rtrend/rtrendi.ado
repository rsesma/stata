*! version 1.2.7  30dec2019 JM. Domenech, R. Sesma
/*
rtrendi: Trend Test - inmediate command
*/

program define rtrendi, rclass
	version 12
	syntax anything(id="argument numlist"), /*
	*/	[Data(string) ST(string) Zero(string) Level(numlist max=1 >50 <100) /*
	*/	 RC(string) NOne Wilson Exact WAld nst(string)]

	tempname D d r f
	
	*Data type
	if ("`data'"=="") local data = "freq"
	if ("`data'"!="freq" & "`data'"!="pt") print_error "data() invalid -- invalid value"
	
	if ("`data'"=="pt" & "`st'"!="") print_error "st() option not compatible with person-time data"
	
	*Type of study & statistic
	if ("`st'"=="") local st = "co rr"
	rtrend__utils test_st `st'
	if (r(error)) print_error "st() invalid -- invalid value"
	local type = r(type)
	local stat = r(stat)

	*CI method & level
	if ("`none'"!="" & ("`exact'"!="" | "`wald'"!="" | "`wilson'"!="")) print_error "only one of none, wilson, exact, wald options is allowed"
	if ("`wilson'"!="" & ("`exact'"!="" | "`wald'"!="")) print_error "only one of none, wilson, exact, wald options is allowed"
	if ("`exact'"!="" & "`wald'"!="") print_error "only one of none, wilson, exact, wald options is allowed"
	if ("`none'"=="" & "`wilson'"=="" & "`exact'"=="" & "`wald'"=="") local ci_method 0
	if ("`none'"!="") local ci_method 0		//no ci for proportions
	if ("`wilson'"!="") local ci_method 1	//Wilson method
	if ("`exact'"!="") local ci_method 2	//Exact method
	if ("`wald'"!="") local ci_method 3		//Wald method
	if ("`data'"=="pt" & "`wilson'"!="") print_error "wilson option not compatible with person-time data"
	if ("`data'"=="pt" & "`wald'"!="") print_error "wald option not compatible with person-time data"
	if ("`level'"=="") local level 95

	*Reference category
	if ("`rc'"=="") local rc = "f"
	if ("`rc'"!="f" & "`rc'"!="l" & "`rc'"!="p" & "`rc'"!="s") print_error "rc() invalid -- invalid value" 

	*Zero cell correction
	if ("`zero'"=="") local zero = "n"
	if ("`zero'"!="n" & "`zero'"!="c" & "`zero'"!="p" & "`zero'"!="r") print_error "zero() invalid -- invalid value" 

	*Get & check data
	local ldec 0
	local count0 0
	local count 0
	local len : word count `anything'
	foreach i of numlist 1/`len' {
		local n : word `i' of `anything'
		if ("`n'"!="\") {
			confirm number `n'
			if (`n'<0) print_error "data invalid -- all the values must be >=0"
			if (mod(`n',1)!=0) local ldec 1
			local count = `count'+1
		}
		else {
			if (`count0'>0 & `count'!=`count0') print_error "data invalid -- metric and a, n|b|t numlists must have the same number of elements"
			local count0 = `count'
			local count 0
		}
	}
	rtrend__utils get_tokens `anything', type(`type') data("`data'")
	matrix `D' = r(data)
	local nstr = r(nstr)

	*Print header
	di as res "TREND TEST " _c
	if ("`data'"=="freq" & `type'!=2) di as res "(Risk data)"
	if ("`data'"=="freq" & `type'==2) di as res "(Prevalence data)"
	if ("`data'"=="pt") di as res "(Person-time data)"
	if ("`nst'"!="") di as txt "{bf:STUDY}: `nst'"

	if (`nstr'>1) local nstr = `nstr'+1
	foreach i of numlist 1/`nstr' {
		*Build data matrix from immediate data
		mata: st_matrix("`d'",select(st_matrix("`D'"), st_matrix("`D'")[.,4] :== `i')[.,(1..3)])

		if ("`data'"=="freq" & !`ldec') {
			mata: st_local("a",invtokens(strofreal(st_matrix("`d'")[.,2]')))
			mata: st_local("b",invtokens(strofreal(st_matrix("`d'")[.,3]')))
			preserve
			qui tabi `a' \ `b', chi2			//use tabi to calculate chi2 pearson
			restore
			local chi2Pearson = r(chi2)
		}
		else {
			local chi2Pearson = .
		}
		
		*Compute results
		if ("`data'"=="freq") rtrend__utils get_results_freq `type' `stat', d(`d') method(`ci_method') level(`level') rc(`rc') zero(`zero') k2(0)
		if ("`data'"=="pt") {
			local printci = ("`exact'"!="")
			rtrend__utils get_results_pt, d(`d') level(`level') rc("`rc'") printci(`printci')
		}
		matrix `r' = r(results)
		matrix `f'`i' = `r'
		
		*Print results
		di
		if (`nstr'>1) {
			if (`i'<`nstr') di as res "STRATUM `i'"
			else di as res "OVERALL"
		}
		rtrend__utils print_results `data' `type' `stat', r(`r') method(`ci_method') level(`level') /*
		*/	rc("`rc'") chi2P(`chi2Pearson') str(`i') nstr(`nstr') zero(`zero') k2(0)
		
		*Store results
		rtrend__utils store_results `data' `type' `stat', r(`r') str(`i') nstr(`nstr') chi2P(`chi2Pearson') k2(0)
		return add
	}
	
	*if strata, compute and print adjusted results
	if (`nstr'>1) {
		rtrend__utils compute_adj `data' `stat', f(`f') type(`type') nstr(`nstr') level(`level') rc("`rc'") zero("`zero'")
		matrix `r' = r(results)
		rtrend__utils print_res_adj `data' `type' `stat', r(`r') level(`level') rc("`rc'") nstr(`nstr') zero("`zero'")
		rtrend__utils store_results_adj `data' `type' `stat', r(`r') nstr(`nstr')
		return add
	}
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end
