*! version 1.1.4  14apr2020 JM. Domenech, R. Sesma
/*
Association Measures - immediate data
*/

program define stai
	version 12
	syntax anything(id="argument numlist"), /*
	*/	[Data(string) ST(string) Level(numlist max=1 >50 <100) Wilson Exact WAld 	/*
	*/	 Pearson MH R(numlist max=1 >0 <1) PE(numlist max=1 >0 <1) DETail notables	/*
	*/	 NNT(numlist integer max=1 >=0 <=1)  MEthod(string) Zero(string) rare       /*
	*/   RELatsymm nst(string) COrnfield Woolf      /*
	*/   _incall _res(varname) _exp(varname) _time(varname) _by(varname) _touse(varname)]

	tempname chi2 str_values p d str_zero res
	
	*Test options
	if ("`data'"=="") local data "freq"
	if ("`data'"!="" & "`data'"!="freq" & "`data'"!="pt" & "`data'"!="paired") print_error "data() invalid -- invalid value"

	if ("`level'"=="") local level 95

	if ("`data'"=="paired") {
		//PAIRED data, unpaired options are incompatible
		local params "st wilson exact wald pearson mh r pe detail nnt method zero rare"
		foreach par of local params {
			if ("``par''"!="") print_error "`par'() option is not compatible with paired data"
		}
		
		*Print title
		print_title	paired, st(paired) paired `relatsymm' nst(`nst')
		
		*Get data
		local type "paired"
		if ("`relatsymm'"!="") local type "relatsymm"
		if ("`_incall'"!="") getdatafromdataset `type', exp(`_exp') res(`_res') time(`_time') by(`_by') touse(`_touse')
		else getdataimmediate `anything', type(`type')
		matrix `d' = r(data)
		
		*Compute results
		sta__utils get_paired_results, d(`d') level(`level') `relatsymm'
		matrix define `p' = r(p)
		matrix define `res' = r(res)
		matrix define `chi2' = r(chi2)
		
		*Print tables (if asked)
		if ("`tables'"=="") print_paired_tables, d(`d') p(`p') exp(`_exp') res(`_res') `relatsymm'

		*Print estimations
		print_paired_estimations, d(`d') r(`res') level(`level') chi2(`chi2') `relatsymm'
		
		*Store results
		store_paired_results, d(`d') r(`res') chi2(`chi2') `relatsymm'
	}
	else {
		//UNPAIRED data
		if ("`st'"!="" & "`st'"!="cs" & "`st'"!="co" & "`st'"!="ex" & "`st'"!="cc") print_error "st() invalid -- invalid value"
		if ("`st'"=="") local st "cs"
		if ("`data'"=="pt") local st "co"
	
		if ("`wilson'"!="" & ("`exact'"!="" | "`wald'"!="")) print_error "only one of wilson, exact, wald options is allowed"
		if ("`exact'"!="" & "`wald'"!="") print_error "only one of wilson, exact, wald options is allowed"
		if ("`wilson'"!="" | ("`wilson'"=="" & "`exact'"=="" & "`wald'"=="")) local ci = "wilson"	//wilson (default)
		if ("`exact'"!="") local ci = "exact"		//exact
		if ("`wald'"!="") local ci = "wald"		 	//wald

		local or_ci = 0								//Exact OR CI (default)
		if ("`cornfield'"!="") local or_ci = 1		//Cornfield OR CI
		if ("`woolf'"!="") local or_ci = 2		 	//Woolf OR CI
		
		if ("`pearson'"!="" & "`mh'"!="") print_error "pearson and mh options are incompatible"
		if ("`pearson'"!="" | ("`pearson'"=="" & "`mh'"=="")) local chi2_type = 1	//pearson by default
		if ("`mh'"!="") local chi2_type = 2

		if ("`st'"=="cc" & "`r'"!="" & "`pe'"!="") print_error "options r and pe are incompatible -- choose one"
		if ("`st'"!="cc" & "`r'"!="") print_error "option r is only available for case-control studies"
		if ("`pe'"=="") local pe = 0
		if ("`r'"=="") local r = 0
		if ("`st'"!="cc" & "`rare'"!="") print_error "option rare is only available for case-control studies"
		if ("`rare'"!="") local rare_disease 1
		else local rare_disease 0
		if ("`st'"=="cc" & "`rare'"=="" & `r'==0 & `pe'==0 & "`detail'"!="") print_error "for not rare disease, detail results require r or pe"
	
		if ("`st'"!="ex" & "`nnt'"!="") print_error "option nnt is only available for experimental studies"
		if ("`nnt'"!="" & "`by'"!="") print_error "nnt option not compatible with stratified analysis"
		if ("`nnt'"=="") local nnt = -1
	
		if ("`zero'"=="") local zero = "n"				//No zero correction by default
		if ("`zero'"!="" & "`zero'"!="n" & "`zero'"!="c" & "`zero'"!="p" & "`zero'"!="r") print_error "zero() invalid -- invalid value"
	
		if ("`method'"=="") local method = "mh"				//Mantel-Haenszel by default
		if ("`method'"!="" & "`method'"!="mh" & "`method'"!="iv" & "`method'"!="is" & "`method'"!="es") print_error "method() invalid -- invalid value"
			
		if ("`relatsymm'"!="") print_error "relatsymm option only makes sense with paired data"
		
		*Print title
		print_title `data', st(`st') `paired' `relatsymm' nst(`nst')

		*Get data
		if ("`_incall'"!="") getdatafromdataset `data', exp(`_exp') res(`_res') time(`_time') by(`_by') touse(`_touse')
		else getdataimmediate `anything', type(`data')
		matrix `d' = r(data)
		local nstr = r(nstr)
		matrix define `str_values' = r(str_values)

		*Compute results
		local det = 0
		if ("`detail'"!="") local det = 1
		local lzero 0
		sta__utils is_dec, data(`d')		//Is there some decimal value?
		local ldec = r(dec)

		*Get chi2 results before any continuity correction
		if (`nstr'==1) {
			if ("`data'"=="freq") sta__utils get_chi2_fisher, data(`d') type(`chi2_type') st(`st') dec(`ldec')
			if ("`data'"=="pt") sta__utils get_chi2_pt, data(`d')
		}
		else {
			sta__utils get_chi2_str, d(`d') type(`data') str(`str_values')
		}
		matrix define `chi2' = r(chi2)

		if ("`data'"=="freq") {
			if ("`zero'"!="n") {
				sta__utils is_zero, data(`d')		//Is there some zero value?
				local lzero = r(zero)
				if (`lzero') {
					sta__utils zero_correction `zero', d(`d') st(`st') nstr(`nstr') str_values(`str_values')
					matrix `str_zero' = r(str_zero)
					if (`nstr'==1) mata: get_totals("`d'","","freq")
					else mata: get_totals("`d'","`str_values'","freq")
				}
			}
			else {
				if (`nstr'>1) matrix `str_zero' = J(1,`nstr',0)
			}

			*Get proportions
			if (`nstr'==1) sta__utils get_proportions, d(`d') level(`level') method(`ci')
			else sta__utils get_str_props, d(`d') str(`str_values') st(`st') type(`data')
			matrix `p' = r(p)
			
			*Cross-Sectional, Cohort & Experimental studies
			local ldec = (`ldec'==1 | `lzero'==1)
			local rare_disease 0
			if ("`rare'"!="") local rare_disease = 1
			if (`nstr'==1) {
				if ("`st'"!="cc") sta__utils get_cor_results, d(`d') st(`st') level(`level') nnt(`nnt') pe(`pe') dec(`ldec') detail(`det')
				else sta__utils get_cc_results, d(`d') st(`st') level(`level') r(`r') pe(`pe') rare(`rare_disease') dec(`ldec') detail(`det')
			}
			else {
				if ("`st'"!="cc") sta__utils get_scor_results, d(`d') str(`str_values') level(`level') method(`method')
				if ("`st'"=="cc") sta__utils get_scc_results, d(`d') str(`str_values') level(`level') method(`method') or_ci(`or_ci')
			}
			matrix define `res' = r(results)
		}
		else {
			*if (`ldec'==1) print_error "no decimal values allowed"
			local lzero 0
			if (`nstr'>1) matrix `str_zero' = J(1,`nstr',0)
			
			*Get incidence rates
			if (`nstr'==1) sta__utils get_incidence_rates, d(`d') level(`level')
			else sta__utils get_str_props, d(`d') str(`str_values') st(`st') type(`data')
			matrix `p' = r(p)
			
			if (`nstr'==1) sta__utils get_coi_results, d(`d') level(`level') pe(`pe') detail(`det')
			else sta__utils get_scoi_results, d(`d') str(`str_values') level(`level') method(`method')
			matrix define `res' = r(results)			
		}


		*Print tables (if asked)
		if ("`tables'"=="") {
			if (`nstr'==1) {
				print_tables `data', d(`d') p(`p') st(`st') exp(`_exp') res(`_res') time(`_time') /*
				*/ level(`level') method(`ci') r(`r') pe(`pe') lzero(`lzero')
			}
			else {
				print_str_tables `data', d(`d') p(`p') st(`st') nstr(`nstr') str_values(`str_values') /*
				*/ lzero(`lzero') str_zero(`str_zero') exp(`_exp') res(`_res') time(`_time') str(`_by') 
			}
		}

		*Print estimations
		if (`nstr'==1) {
			print_estimations `data', d(`d') res(`res') st(`st') level(`level') chi2_type(`chi2_type') chi2(`chi2') /*
			*/	 nnt(`nnt') lzero(`lzero') zero(`zero') ldec(`ldec') r(`r') pe(`pe') rare(`rare_disease') detail(`det')
		}
		else {
			print_str_estimations `data', d(`d') res(`res') st(`st') str(`_by') nstr(`nstr') str_values(`str_values') /*
			*/	 level(`level') method(`method') chi2(`chi2') lzero(`lzero') str_zero(`str_zero') zero(`zero')
		}
		
		*Store results
		if (`nstr'==1) {
			store_results `data', st(`st') d(`d') res(`res') chi2(`chi2') detail(`det') 	/*
			*/		dec(`ldec') zero(`lzero') nnt(`nnt') r(`r') pe(`pe') p(`p')
		}
		else {
			store_str_results `data', st(`st') d(`d') res(`res') chi2(`chi2') 	/*
			*/		nstr(`nstr') str_values(`str_values') or_ci(`or_ci')
		}
	}
	
end


program define store_paired_results, rclass
	syntax [anything], d(name) r(name) chi2(name) [relatsymm]

	*2x2 table
	return scalar a10 = `d'[1,1]
	return scalar a11 = `d'[1,2]
	return scalar a00 = `d'[2,1]
	return scalar a01 = `d'[2,2]
	
	if ("`relatsymm'"=="") {
		*Difference
		return scalar d = `r'[1,1]
		return scalar lb_d_exact = `r'[1,2]
		return scalar ub_d_exact = `r'[1,3]
		return scalar lb_d_new = `r'[2,2]
		return scalar ub_d_new = `r'[2,3]
		return scalar lb_d_asym = `r'[3,2]
		return scalar ub_d_asym = `r'[3,3]
		return scalar se_d_asym = `r'[3,4]
		return scalar lb_d_asym_cor = `r'[4,2]
		return scalar ub_d_asym_cor = `r'[4,3]
		*Odds Ratio
		return scalar or = `r'[5,1]
		return scalar lb_or_exact = `r'[5,2]
		return scalar ub_or_exact = `r'[5,3]
		return scalar lb_or_wilson = `r'[6,2]
		return scalar ub_or_wilson = `r'[6,3]
		return scalar lb_or_asym = `r'[7,2]
		return scalar ub_or_asym = `r'[7,3]
		return scalar se_or_asym = `r'[7,4]
		
		*Exact Simmetry
		return scalar p_McNemar = `chi2'[1,2]
		return scalar chi2_exact = `chi2'[2,1]
		return scalar p_exact = `chi2'[2,2]
		return scalar chi2_exact_corr = `chi2'[3,1]
		return scalar p_exact_corr = `chi2'[3,2]
		*Test of Association
		return scalar or_assoc = `chi2'[4,1]
		return scalar chi2_assoc = `chi2'[5,1]
		return scalar p_assoc = `chi2'[5,2]
		return scalar chi2_assoc_corr = `chi2'[6,1]
		return scalar p_assoc_corr = `chi2'[6,2]
	}
	else {
		*Prop. Diff. (PD)
		return scalar pd = `r'[1,1]
		return scalar lb_pd_wald = `r'[1,2]
		return scalar ub_pd_wald = `r'[1,3]
		return scalar lb_pd_new = `r'[2,2]
		return scalar ub_pd_new = `r'[2,3]
		*Prop. Ratio (PR)
		return scalar pr = `r'[3,1]
		return scalar lb_pr = `r'[3,2]
		return scalar ub_pr = `r'[3,3]
		return scalar se_pr = `r'[3,3]
		*Odds Ratio (OR)
		return scalar or = `r'[4,1]
		return scalar lb_or = `r'[4,2]
		return scalar ub_or = `r'[4,3]
		return scalar se_or = `r'[4,3]
		*Relative Symmetry
		return scalar chi2 = `chi2'[1,1]
		return scalar p = `chi2'[1,2]
		return scalar chi2_cor = `chi2'[2,1]
		return scalar p_cor = `chi2'[2,2]
	}
	
end

program define store_str_results, rclass
	syntax anything(name=type), st(string) d(name) res(name) chi2(name) nstr(integer) str_values(name) or_ci(real)
	
	*Save Homogeinity results from previous executions
	local pW = r(p_chi2W)
	local chi2W = r(chi2W)
	local pBD = r(p_chi2BD)
	local chi2BD = r(chi2BD)
	
	*2x2 data matrix
	matrix colnames `d' = Stratum Unexposed Exposed TOTAL
	local len = `nstr'+1
	local rnames ""
	foreach i of numlist 1/`len' {
		if ("`type'"=="freq" & "`st'"=="co") local rnames = "`rnames' Cases NonCases TOTAL"
		if ("`type'"=="freq" & "`st'"=="cc") local rnames = "`rnames' Cases Controls TOTAL"
		if ("`type'"=="pt") local rnames = "`rnames' Cases Person-Time"
	}
	matrix rownames `d' = `rnames'
	return matrix Data = `d'
	
	*Ratios (RR,OR,IR) matrix
	tempname r
	matrix `r' = `res'[1..`len',1..5]
	if ("`type'"=="freq" & "`st'"=="co") local c "RR"
	if ("`type'"=="freq" & "`st'"=="cc") local c "OR"
	if ("`type'"=="pt") local c "IR"
	matrix colnames `r' = `c' StdError LowerBound UpperBound Weight
	local rnames ""
	foreach i of numlist 1/`len' {
		local v = `str_values'[1,`i']
		if (`i'<=`nstr') local rnames = "`rnames' Stratum`v'"
		if (`i'>`nstr') local rnames = "`rnames' OVERALL"
		if ("`st'"=="cc" & `or_ci'!=2) {
			matrix `r'[`i',2] = .			//No SE for not Woolf CI
		}
	}
	matrix rownames `r' = `rnames'
	return matrix Ratios = `r'
	
	*Estimations
	matrix `r' = `res'[`nstr'+2..`nstr'+5,1..6]
	matrix colnames `r' = `c' StdError LowerBound UpperBound p Change
	matrix rownames `r' = MH IoV IS ES
	return matrix Estim = `r'
	
	*Chi2
	matrix `chi2' = `chi2'[1..4,1..4]
	matrix colnames `chi2' = Chi2 p Chi2_cor p_cor
	local rnames ""
	local len = `nstr'+2
	foreach i of numlist 1/`len' {
		local v = `str_values'[1,`i']
		if (`i'<=`nstr') local rnames = "`rnames' Stratum`v'"
		if (`i'==`nstr'+1) local rnames = "`rnames' OVERALL"
		if (`i'==`nstr'+2) local rnames = "`rnames' POOLED"
	}
	matrix `chi2' = `chi2'\(`chi2W',`pW',.,.)
	local rnames = "`rnames' Hom_Wald"
	if ("`type'"=="freq" & "`st'"=="cc") matrix `chi2' = `chi2'\(`chi2BD',`pBD',.,.)
	if ("`type'"=="freq" & "`st'"=="cc") local rnames = "`rnames' Hom_BD"

	matrix colnames `chi2' = chi2 p chi2_cor p_cor
	matrix rownames `chi2' = `rnames'
	return matrix Chi2 = `chi2'
end

program define store_results, rclass
	syntax anything(name=type), st(string) d(name) res(name) chi2(name) detail(integer) 	/*
	*/				r(real) pe(real) p(name) dec(integer) zero(integer) nnt(integer)
	
	if ("`type'"=="freq") {
		*2x2 table data
		return scalar a0 = `d'[1,1]
		return scalar a1 = `d'[1,2]
		return scalar m1 = `d'[1,3]
		return scalar b0 = `d'[2,1]
		return scalar b1 = `d'[2,2]
		return scalar m0 = `d'[2,3]
		return scalar n0 = `d'[3,1]
		return scalar n1 = `d'[3,2]
		return scalar n = `d'[3,3]
		
		*estimation results
		if ("`st'"=="cs") {
			*Prevalence difference PD
			return scalar pd = `res'[1,1]
			return scalar lb_pd_new = `res'[1,2]
			return scalar ub_pd_new = `res'[1,3]
			return scalar se_pd_wald = `res'[2,4]
			return scalar lb_pd_wald = `res'[2,2]
			return scalar ub_pd_wald = `res'[2,3]
			*Prevalence ratio PR
			return scalar pr = `res'[3,1]
			return scalar se_pr = `res'[3,4]
			return scalar lb_pr = `res'[3,2]
			return scalar ub_pr = `res'[3,3]
		}
		if ("`st'"=="co" | "`st'"=="ex") {
			*Risk difference RD
			return scalar rd = `res'[1,1]
			return scalar lb_rd_new = `res'[1,2]
			return scalar ub_rd_new = `res'[1,3]
			return scalar se_rd_wald = `res'[2,4]
			return scalar lb_rd_wald = `res'[2,2]
			return scalar ub_rd_wald = `res'[2,3]
			if ("`st'"=="ex" & `nnt'>=0) {
				if (`res'[6,3]<0 & `res'[6,2]>0 & `res'[1,1]==0) return scalar nnt = .
				else return scalar nnt = `res'[6,1]				
				if (`res'[6,2]>0 & `res'[6,3]>0) {
					return scalar lb_nnt = `res'[6,2]
					return scalar ub_nnt = `res'[6,3]
				}
				else {
					return scalar lb_nnt = `res'[6,3]
					return scalar ub_nnt = `res'[6,2]
				}
			}
			*Risk ratio RR
			return scalar rr = `res'[3,1]
			return scalar se_rr = `res'[3,4]
			return scalar lb_rr = `res'[3,2]
			return scalar ub_rr = `res'[3,3]
		}
		*Odds ratio OR
		return scalar or = `res'[4,1]
		if (`dec'==0) {
			if ("`st'"!="cc") {
				return scalar lb_or_corn = `res'[4,2]
				return scalar ub_or_corn = `res'[4,3]
			}
			if ("`st'"=="cc") {
				return scalar lb_or_exact = `res'[4,2]
				return scalar ub_or_exact = `res'[4,3]
				return scalar lb_or_corn = `res'[9,2]
				return scalar ub_or_corn = `res'[9,3]
			}
		}
		return scalar lb_or_woolf = `res'[5,2]
		return scalar ub_or_woolf = `res'[5,3]
		return scalar se_or_woolf = `res'[5,4]
		if ("`st'"=="cc" & (`r'!=0 | `pe'!=0)) {
			*PR, PD for case-control if r or pe external
			return scalar pe = `p'[3,1]
			return scalar r = `res'[1,1]
			return scalar pr = `res'[2,1]
			return scalar pd = `res'[3,1]
		}
		
		if (`detail'==1) {
			*detail results
			if ("`st'"!="cc") {
				*Prop. exposed pop.
				return scalar pe_pop = `res'[7,1]
				*Prevalence/Risk diff. pop.
				if ("`st'"=="cs") {
					return scalar pdp = `res'[8,1]
					return scalar se_pdp = `res'[8,4]
					return scalar lb_pdp = `res'[8,2]
					return scalar ub_pdp = `res'[8,3]
				}
				else {
					return scalar rdp = `res'[8,1]
					return scalar se_rdp = `res'[8,4]
					return scalar lb_rdp = `res'[8,2]
					return scalar ub_rdp = `res'[8,3]
				}
				*Attr./Prev. fraction exp./pop.
				if (`res'[9,4]==1) {
					return scalar afe = `res'[9,1]
					return scalar lb_afe = `res'[9,2]
					return scalar ub_afe = `res'[9,3]
					return scalar afp = `res'[10,1]
					return scalar se_afp = `res'[10,4]
					return scalar lb_afp = `res'[10,2]
					return scalar ub_afp = `res'[10,3]
				}
				if (`res'[9,4]==2) {
					return scalar pfe = `res'[9,1]
					return scalar lb_pfe = `res'[9,2]
					return scalar ub_pfe = `res'[9,3]
					return scalar pfp = `res'[10,1]
					return scalar lb_pfp = `res'[10,2]
					return scalar ub_pfp = `res'[10,3]
				}
			}
			if ("`st'"=="cc") {
				return scalar pdp = `res'[6,1]
				if (`res'[7,4]==1) {
					return scalar afe = `res'[7,1]
					return scalar lb_afe = `res'[7,2]
					return scalar ub_afe = `res'[7,3]
					return scalar afp = `res'[8,1]
					return scalar se_afp = `res'[8,4]
					return scalar lb_afp = `res'[8,2]
					return scalar ub_afp = `res'[8,3]
				}
				if (`res'[7,4]==2) {
					return scalar pfe = `res'[7,1]
					return scalar lb_pfe = `res'[7,2]
					return scalar ub_pfe = `res'[7,3]
					return scalar pfp = `res'[8,1]
					return scalar lb_pfp = `res'[8,2]
					return scalar ub_pfp = `res'[8,3]
				}				
			}
		}
		
		*Chi2
		return scalar chi2 = `chi2'[1,1]
		return scalar p = `chi2'[1,2]
		return scalar chi2_corr = `chi2'[2,1]
		return scalar p_corr = `chi2'[2,2]
		if (`dec'==0 | (`dec'==1 & `zero'==1)) return scalar p_exact = `chi2'[3,2]
	}
	
	if ("`type'"=="pt") {
		*2x2 table data
		return scalar a0 = `d'[1,1]
		return scalar a1 = `d'[1,2]
		return scalar m1 = `d'[1,3]
		return scalar t0 = `d'[2,1]
		return scalar t1 = `d'[2,2]
		return scalar t = `d'[2,3]
		return scalar i0 = `p'[1,1]
		return scalar i1 = `p'[2,1]
		return scalar i = `p'[3,1]
		
		*Incidence rate difference ID
		return scalar id = `res'[1,1]
		return scalar lb_id = `res'[1,2]
		return scalar ub_id = `res'[1,3]
		*Incidence rate ratio IR
		return scalar ir = `res'[2,1]
		return scalar lb_ir_exact = `res'[2,2]
		return scalar ub_ir_exact = `res'[2,3]
		return scalar se_ir = `res'[3,4]
		return scalar lb_ir = `res'[3,2]
		return scalar ub_ir = `res'[3,3]
		
		if (`detail'==1) {
			*detail results
			*Prop. exposed pop.
			return scalar pe_pop = `res'[5,1]
			*Incidence ¡ diff. pop.
			return scalar idp = `res'[6,1]
			return scalar se_idp = `res'[6,4]
			return scalar lb_idp = `res'[6,2]
			return scalar ub_idp = `res'[6,3]
			*Attr./Prev. fraction exp./pop.
			if (`res'[4,4]==1) {
				return scalar afe = `res'[4,1]
				return scalar lb_afe = `res'[4,2]
				return scalar ub_afe = `res'[4,3]
				return scalar afp = `res'[7,1]
				return scalar se_afp = `res'[7,4]
				return scalar lb_afp = `res'[7,2]
				return scalar ub_afp = `res'[7,3]
			}
			if (`res'[4,4]==2) {
				return scalar pfe = `res'[4,1]
				return scalar lb_pfe = `res'[4,2]
				return scalar ub_pfe = `res'[4,3]
				return scalar pfp = `res'[7,1]
				return scalar lb_pfp = `res'[7,2]
				return scalar ub_pfp = `res'[7,3]
			}
		}
		
		*Association Chi2
		return scalar chi2 = `chi2'[1,1]
		return scalar p = `chi2'[1,2]
	}
end

***GET DATA programs
program define getdatafromdataset, rclass
	syntax anything(name=type), exp(varname) res(varname) touse(varname) [time(varname) by(varname)]
	
	tempname f d t total valid str_values
	
	qui count if `touse'	//Count number of total rows
	scalar `total' = r(N)
	
	if ("`by'"!="") {
		qui levelsof `by' if `touse'	//get stratum values
		local values = r(levels)
		mata: st_matrix("`str_values'", strtoreal(tokens(st_local("values"))))
		local nstr = colsof(`str_values')
	}
	else {
		local nstr = 1
		matrix define `str_values' = J(1,1,1)
	}
	
	if ("`type'"=="freq") {
		*Get tabulate data
		if ("`by'"=="") {
			qui tabulate `res' `exp' if `touse', matcell(`f')
			scalar `valid' = r(N)
			
			*Build data matrix
			matrix `d' = J(3,3,.)
			matrix `d'[1,1] = `f'[2,1]		//a0
			matrix `d'[1,2] = `f'[2,2]		//a1
			matrix `d'[2,1] = `f'[1,1]		//b0
			matrix `d'[2,2] = `f'[1,2]		//b1
		}
		else {
			local len = (`nstr'+1)*3
			matrix `d' = J(`len',4,.)
			foreach i of numlist 1/`nstr' {
				local v = `str_values'[1,`i']
				qui tabulate `res' `exp' if `touse' & `by'==`v', matcell(`f')
				
				local r1 = 1 + (`i'-1)*3
				local r2 = `r1'+1
				local r3 = `r1'+2
				matrix `d'[`r1',1] = `v'			//stratum
				matrix `d'[`r1',2] = `f'[2,1]		//a0
				matrix `d'[`r1',3] = `f'[2,2]		//a1
				matrix `d'[`r2',1] = `v'			//stratum
				matrix `d'[`r2',2] = `f'[1,1]		//b0
				matrix `d'[`r2',3] = `f'[1,2]		//b1
				matrix `d'[`r3',1] = `v'			//stratum
			}
			//OVERALL
			qui tabulate `res' `exp' if `touse', matcell(`f')
			scalar `valid' = r(N)
			
			local r1 = (`nstr'*3) + 1
			local r2 = `r1'+1
			local r3 = `r1'+2
			matrix `d'[`r1',2] = `f'[2,1]		//a0
			matrix `d'[`r1',3] = `f'[2,2]		//a1
			matrix `d'[`r2',2] = `f'[1,1]		//b0
			matrix `d'[`r2',3] = `f'[1,2]		//b1
		}
	}
	if ("`type'"=="pt") {
		*Get collapse data
		if ("`by'"=="") {
			preserve
			markout `touse' `exp' `res' `time'
			qui count if `touse'			//Count number of valid cases
			scalar `valid' = r(N)
			qui collapse (sum) __a=`res' (sum) __t=`time' if `touse', by(`exp')
			mkmat __a __t, matrix(`f')
			restore
		
			*Build data matrix
			matrix `d' = J(2,3,.)
			matrix `d'[1,1] = `f'[1,1]		//a0
			matrix `d'[1,2] = `f'[2,1]		//a1
			matrix `d'[2,1] = `f'[1,2]		//T0
			matrix `d'[2,2] = `f'[2,2]		//T1
		}
		else {
			local len = (`nstr'+1)*2
			matrix `d' = J(`len',4,.)
			foreach i of numlist 1/`nstr' {
				local v = `str_values'[1,`i']
				preserve
				qui collapse (sum) __a=`res' (sum) __t=`time' if `touse' & `by'==`v', by(`exp')
				mkmat __a __t, matrix(`f')
				restore
				
				local r1 = 1 + (`i'-1)*2
				local r2 = `r1'+1
				matrix `d'[`r1',1] = `v'			//stratum
				matrix `d'[`r1',2] = `f'[1,1]		//a0
				matrix `d'[`r1',3] = `f'[2,1]		//a1
				matrix `d'[`r2',1] = `v'			//stratum
				matrix `d'[`r2',2] = `f'[1,2]		//T0
				matrix `d'[`r2',3] = `f'[2,2]		//T1
			}
			//OVERALL
			preserve
			markout `touse' `exp' `res' `time'
			qui count if `touse'			//Count number of valid cases
			scalar `valid' = r(N)
			qui collapse (sum) __a=`res' (sum) __t=`time' if `touse', by(`exp')
			mkmat __a __t, matrix(`f')
			restore

			local r1 = (`nstr')*2+1
			local r2 = `r1'+1
			matrix `d'[`r1',2] = `f'[1,1]		//a0
			matrix `d'[`r1',3] = `f'[2,1]		//a1
			matrix `d'[`r2',2] = `f'[1,2]		//T0
			matrix `d'[`r2',3] = `f'[2,2]		//T1
		}
	}
	if ("`type'"=="paired" | "`type'"=="relatsymm") {
		***PAIRED DATA: get tabulate data
		qui tabulate `res' `exp' if `touse', matcell(`f')
		scalar `valid' = r(N)
		
		*Build data matrix
		matrix `d' = J(3,3,.)
		matrix `d'[1,1] = `f'[2,1]		//a0
		matrix `d'[2,1] = `f'[1,1]		//b0
		if ("`type'"=="paired") {
			matrix `d'[1,2] = `f'[2,2]		//a1
			matrix `d'[2,2] = `f'[1,2]		//b1
		}
		if ("`type'"=="relatsymm") {
			matrix `d'[1,2] = `f'[1,2]		//a1
			matrix `d'[2,2] = `f'[2,2]		//b1
		}
		local type "paired"
	}
	if (`nstr'==1) mata: get_totals("`d'","","`type'")
	else mata: get_totals("`d'","`str_values'","`type'")
	
	*Print valid & total cases
	di as txt "Valid observations: " as res `valid' as txt " (" as res %5.1f 100*`valid'/`total' as txt "%)"
	di as txt "Total observations: " as res `total'

	return matrix data = `d'		//Data Matrix
	return scalar nstr = `nstr'		//Number of strata
	return matrix str_values = `str_values'		//Stratum Values Matrix
end

program define getdataimmediate, rclass
	syntax anything(name=data), type(string)

	tempname d t str_values

	*Check inmediate parameters
	local t = "`data'"
	local nstr = 1
	gettoken tok t : t
	while "`tok'" != "" {
		if ("`tok'"!="\") confirm number `tok'
		else local nstr = `nstr'+1
		gettoken tok t : t
	}
	
	*Build stratum matrix
	if (`nstr'>1) {
		matrix define `str_values' = J(1,`nstr',.)
		foreach i of numlist 1/`nstr' {
			matrix `str_values'[1,`i'] = `i'
		}
	}
	else {
		matrix define `str_values' = J(1,1,1)
	}
	
	*Build data matrix: Mata
	mata: get_data_matrix("`data'", "`d'", "`type'")
	if ("`type'"=="relatsymm") {
		local t = `d'[1,2]
		matrix `d'[1,2] = `d'[2,2]
		matrix `d'[2,2] = `t'
	}
	*Get totals
	if (`nstr'==1) mata: get_totals("`d'","","`type'")
	else mata: get_totals("`d'","`str_values'","`type'")

	return matrix data = `d'		//Data Matrix
	return scalar nstr = `nstr'		//Number of strata
	return matrix str_values = `str_values'		//Stratum Values Matrix
end


***PRINT programs
program define print_title
	syntax anything(name=data), st(string) [paired relatsymm nst(string)]

	if ("`paired'"!="") {
		if ("`relatsymm'"!="") di as res "CONFIDENCE INTERVALS FOR MEASURES OF CHANGE (RELATIVE SYMMETRY)"
		else di as res "CONFIDENCE INTERVALS FOR MEASURES OF CHANGE (PAIRED SAMPLES)"
	}
	else {
		if ("`data'"=="freq") {
			local c ""
			if ("`_by'"!="") local c = "STRATIFIED "
			if ("`st'"=="cs") di as res "ASSOCIATION MEASURES: `c'CROSS-SECTIONAL STUDY"
			if ("`st'"=="co") di as res "ASSOCIATION MEASURES: `c'COHORT STUDY"
			if ("`st'"=="ex") di as res "ASSOCIATION MEASURES: `c'EXPERIMENTAL STUDY"
			if ("`st'"=="cc") di as res "ASSOCIATION MEASURES: `c'CASE-CONTROL STUDY"
		}
		if ("`data'"=="pt") {
			di as res "ASSOCIATION MEASURES: `c'COHORT STUDY (RATE)"
		}
	}
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
end

program define print_str_tables
	syntax anything(name=type), d(name) p(name) st(string) nstr(real) str_values(name) lzero(integer) /*
	*/	[str_zero(name) exp(varname) res(varname) time(varname) str(varname)]
	
	if ("`exp'"!="") {
		*Get variable labels for exposure / response-time / stratum variables
		sta__utils get_var_labels `exp', abb_name(21) abb_lbl(10)
		local col_header = r(vname)
		local col_lb1 = r(lbl0)
		local col_lb2 = r(lbl1)
		
		if ("`type'"=="freq") {
			sta__utils get_var_labels `res', abb_name(17) abb_lbl(17)
			local row_header = r(vname)
			local row_lb1 = r(lbl1)
			local row_lb2 = r(lbl0)
		}
		if ("`type'"=="pt") {
			sta__utils get_varlabel `exp', len(21)
			local col_header = r(label)
			sta__utils get_varlabel `res', len(17)
			local row_lb1 = r(label)
			sta__utils get_varlabel `time', len(17)
			local row_lb2 = r(label)
		}
		
		sta__utils get_var_labels `str', abb_name(17) abb_lbl(17)
		local str_name = r(vname)
	}
	else {
		*Default labels for immediate calls
		local col_header ""
		local col_lb1 = "Unexposed"
		local col_lb2 = "Exposed"
		local row_header ""
		local row_lb1 "Cases"
		local row_lb2 "NonCases"
		if ("`st'"=="cc") local row_lb2 "Controls"
		if ("`type'"=="pt") local row_lb2 "Person-time"
		local str_name ""
	}
	
	
	*Print header an column labels
	di ""
	if ("`col_header'"!="" & "`type'"!="pt") di as res "{lalign 17:`str_name'} {c |}{center 21:`col_header'}{c |}"
	if ("`col_header'"!="" & "`type'"=="pt") di as res _col(19) "{c |}{center 21:`col_header'}{c |}"
	if ("`type'"=="freq") di as txt "{bf:{ralign 17:`row_header'}} {c |}{ralign 10:`col_lb1'}{c |}{ralign 10:`col_lb2'}{c |}{ralign 9:TOTAL} {c |}"
	if ("`type'"=="pt") di as txt "{bf:{ralign 17:`str_name'}} {c |}{ralign 10:`col_lb1'}{c |}{ralign 10:`col_lb2'}{c |}{ralign 9:TOTAL} {c |}"
	di as txt "{hline 18}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 14}" _c
	
	local k 1
	local istr 1
	local len = rowsof(`d')
	foreach i of numlist 1/`len' {
		local v = `d'[`i',1]		//Stratum value
		
		if (`k'==1 & `v'<. & "`exp'"!="") di as txt _n "{lalign 17:`r(lbl`v')'}" _c
		if (`k'==1 & `v'<. & "`exp'"=="") di as txt _n "{lalign 17:Stratum `v'}" _c
		if (`k'==1 & `v'==.) di as txt _n "{lalign 17:OVERALL}" _c
		if (`k'==1) di as txt _col(19) "{c |}" _col(30) "{c |}" _col(41) "{c |}" _col(52) "{c |}" _c
		
		if ("`type'"=="freq") {
			*Zero correction
			local z " "
			if (`istr' <= `nstr' & `str_zero'[1,`istr']==1) local z "*"
			if (`istr' > `nstr' & `lzero'==1) local z "*"
			
			if (`k'<3) di as txt _n "{ralign 17:`row_lb`k''} {c |} " _c
			if (`k'==3) di as txt _n _col(19) "{c LT}{hline 10}{c +}{hline 10}{c +}{hline 10}{c RT}" _c
			if (`k'==3) di as txt _n "{ralign 17:TOTAL} {c |} " _c
			di as res %8.0g `d'[`i',2] " {c |} " %8.0g `d'[`i',3] " {c |} " %8.0g `d'[`i',4] " {c |}" _c
			if (`k'==1 & "`st'"=="cc") di as txt " Pe1= " as res %8.0g `p'[`istr',1] "`z'" _c
			if (`k'==2 & "`st'"=="cc") di as txt " Pe0= " as res %8.0g `p'[`istr',2] "`z'" _c
			if (`k'==3 & "`st'"=="cc") di as txt " OR = " as res %8.0g `p'[`istr',3] "`z'" _c
			if (`k'==3 & "`st'"!="cc") di as txt " Pe= " as res %9.0g `p'[`istr',1] "`z'" _c
			
			if (`k'<3) {
				local k = `k'+1
			}
			else {
				if ("`st'"!="cc") {
					di as txt _n "{ralign 17: Risk proportion} {c |} " _c
					di as res %8.0g `p'[`istr',2] " {c |} " %8.0g `p'[`istr',3] " {c |} " %8.0g `p'[`istr',4] " {c |} " _c
					di as txt "RR= " as res %9.0g `p'[`istr',5] "`z'" _c
				}
				
				if (`i'!=`len') di as txt _n "{hline 18}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 14}" _c
				if (`i'==`len') di as txt _n "{hline 18}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 14}"
				
				local k 1
				local istr = `istr'+1
			}		
		}
		if ("`type'"=="pt") {
			di as res _n "{ralign 17:`row_lb`k''} {c |} " _c
			di as res %8.0g `d'[`i',2] " {c |} " %8.0g `d'[`i',3] " {c |} " %8.0g `d'[`i',4] " {c |}" _c
			if (`k'==2) di as txt " Pe= " as res %9.0g `p'[`istr',1] "`z'" _c
			
			if (`k'<2) {
				local k = `k'+1
			}
			else {
				di as txt _n _col(19) "{c LT}{hline 10}{c +}{hline 10}{c +}{hline 10}{c RT}" _c

				di as txt _n "{ralign 17:Incidence Rate} {c |}" _c
				di as res %9.0g `p'[`istr',2] " {c |}" %9.0g `p'[`istr',3] " {c |}" %9.0g `p'[`istr',4] " {c |}" _c
				di as txt " IR= " as res %9.0g `p'[`istr',5] _c
			
				if (`i'!=`len') di as txt _n "{hline 18}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 14}" _c
				if (`i'==`len') di as txt _n "{hline 18}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 14}"
				
				local k 1
				local istr = `istr'+1
			}		

		}
	}

end

program define print_tables
	syntax anything(name=type), d(name) st(string) p(name) lzero(integer) level(real) /*
	*/	method(string) r(real) pe(real) [exp(varname) res(varname) time(varname)]
	
	if ("`exp'"!="") {
		*Get variable labels for exposure / response /time variables
		sta__utils get_var_labels `exp', abb_name(21) abb_lbl(10)
		local col_header = r(vname)
		local col_lb1 = r(lbl0)
		local col_lb2 = r(lbl1)
		
		if ("`type'"=="freq") {
			sta__utils get_var_labels `res', abb_name(17) abb_lbl(17)
			local row_header = r(vname)
			local row_lb1 = r(lbl1)
			local row_lb2 = r(lbl0)
		}
		if ("`type'"=="pt") {
			sta__utils get_varlabel `exp', len(21)
			local col_header = r(label)
			sta__utils get_varlabel `res', len(17)
			local row_lb1 = r(label)
			sta__utils get_varlabel `time', len(17)
			local row_lb2 = r(label)
		}
	}
	else {
		//Defaults labels for immediate calls
		local row_header
		local col_header
		if ("`st'"!="ex" | "`type'"=="pt") {
			local col_lb1 = "Unexposed "
			local col_lb2 = "Exposed "
			local row_lb1 = "Cases"
			if ("`type'"=="freq") local row_lb2 = "NonCases"
			if ("`type'"=="pt") local row_lb2 = "Person-time"
			if ("`type'"=="freq" & "`st'"=="cc") local row_lb2 "Controls"				
		}
		else {
			local row_lb1 = "Events"
			local row_lb2 = "NonEvents"
			local col_lb1 = "Treat.0 "
			local col_lb2 = "Treat.1 "
		}
	}
	local col_lb3 = "TOTAL "
	local col_lb4 = "`level'% CI (" + upper(substr("`method'",1,1)) + substr("`method'",2,.) + ")"
	local row_lb3 = "TOTAL"
	if ("`type'"=="pt") local st "co"

	local z " "
	if (`lzero'==1) local z "*"
	
	*Print header an column labels
	if ("`res'"!="") di as txt _n _col(19) "{c |}{bf:{center 21:`exp'}}" _col(41) "{c |}" _c
	if ("`res'"=="" & (("`st'"=="cs" | "`st'"=="cc"))) di ""
	if ("`st'"=="cs" | "`st'"=="cc") di as txt _col(52) "{c |}  Exposed proportion" _c
	foreach i of numlist 0/4 {
		if (`i'==0) di as res _n "{ralign 17:`row_header'} " _c
		else if (`i'>0 & `i'<4) di as txt "{c |}{ralign 10:`col_lb`i''}" _c 
		else if (`i'==4 & ("`st'"=="cs" | "`st'"=="cc")) di as txt "{c |}  `col_lb`i''" _c 
	}
	di _n "{hline 18}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}" _c
	if ("`st'"=="cs" | "`st'"=="cc") di "{c +}{hline 23}" _c
	*Table body
	local end 3
	if ("`type'"=="pt") local end 2
	foreach i of numlist 1/`end' {
		di as txt _n "{ralign 17:`row_lb`i''}" _c
		foreach j of numlist 1/3 {
			di as res " {c |} " %8.0g `d'[`i',`j'] _c
		}
		if ("`st'"=="cs" | ("`st'"=="cc" & `i'<3)) {
			di as res " {c |} " %8.0g `p'[`i',1] "`z'"
			di _col(19) "{c |}" _col(30) "{c |}" _col(41) "{c |} " _col(52) as txt "{c |} (" /*
			*/		as res %-8.0g `p'[`i',2] as txt " to " as res %8.0g `p'[`i',3] as txt ")" _c
		}
		if ("`st'"=="cc" & `i'==3) di " {c |}" _c
		if (`i'==2) {
			di _n "{hline 18}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}" _c
			if ("`st'"=="cs" | "`st'"=="cc") di "{c +}{hline 23}" _c
		}
	}
	*Footer
	if ("`st'"=="cs" | "`st'"=="co" | "`st'"=="ex") {
		if ("`st'"=="cs") local c "Prevalence"
		if ("`st'"=="co" | "`st'"=="ex") local c "Risk"
		if ("`type'"=="pt") local c "Incidence rate"
		if (("`st'"=="co" | "`st'"=="ex") & "`type'"!="pt") di _n _col(19) "{c |}" _col(30) "{c |}" _col(41) "{c |}" _c
		foreach i of numlist 1/3 {
			if (`i'==1) di as txt _n "{ralign 17:`c'} {c |} " _c
			if (`i'==2) di as txt _n %4.0g `level' "% CI" _col(13) "Lower {c |} " _c
			if (`i'==3) di as txt _n " (" upper(substr("`method'",1,1)) lower(substr("`method'",2,.)) ")" _col(13) "Upper {c |} " _c
			local c_z " "
			if (`i'==1) local c_z "`z'"
			if ("`type'"=="freq") local ini 4
			if ("`type'"=="freq") local end 6
			if ("`type'"=="pt") local ini 1
			if ("`type'"=="pt") local end 3
			foreach j of numlist `ini'/`end' {
				if (`j'<`end') di as res %8.0g `p'[`j',`i'] "`c_z'{c |} " _c
				if ("`st'"=="cs" & `j'==`end')  di as res %8.0g `p'[`j',`i'] "`c_z'{c |}" _c
				if ("`type'"=="pt" & `j'==`end')  di as res %8.0g `p'[`j',`i'] "`c_z'" _c
			}
		}
	}
	*Special case: case-control + additional information
	if ("`st'"=="cc" & (`r'!=0 | `pe'!=0)) {
		sta__utils get_risk_odds, data(`d') r(`r') pe(`pe')
		di "  " %-8.0g r(pext) " (`r(text)')"
		matrix `p'[3,1] = r(pext)		//save for later: stored results need that value
		di _col(19) "{c |}" _col(30) "{c |}" _col(41) "{c |}" _col(52) "{c |}"
		di as txt "{ralign 17:Odds} {c |} " as res %8.0g r(o0) "`z'{c |} " %8.0g r(o1) "`z'{c |} " %8.0g r(odds) "`z'{c |}"
		di as txt "{ralign 17:Proportions} {c |} " as res %8.0g r(r0) "`z'{c |} " %8.0g r(r1) "`z'{c |} " %8.0g r(re) "`z'{c |}"
	}
	di ""
	
end

program define print_paired_tables
	syntax [anything], d(name) p(name) [exp(varname) res(varname) relatsymm]
	
	if ("`exp'"!="") {
		*Get variable labels for exposure / response variables
		sta__utils get_var_labels `exp', abb_name(23) abb_lbl(10)
		local col_header = r(vname)
		local col_lb1 = r(lbl0)
		local col_lb2 = r(lbl1)
		
		if ("`relatsymm'"=="") {
			local row_header = ""
			sta__utils get_var_labels `res', abb_name(18) abb_lbl(10)
			local c1 = substr("`res'",1,9)
			local c2 = substr("`res'",10,.)
			local row_lb1 = r(lbl1)
			local row_lb2 = r(lbl0)			
		}
		else {
			local row_header = "CHANGE of"
			local c1 = abbrev("`res'",16)
			local c2 = abbrev("`exp'",13)
			local row_lb1 = "Yes"
			local row_lb2 = "No"
		}
	}
	else {
		*Default labels for immediate calls
		local col_header "Response of exp. X"
		local col_lb1 "(-) "
		local col_lb2 "(+) "

		local row_header ""
		if ("`relatsymm'"=="") {
			local c1 "Response of"
			local c2 " exposure Y"
			local row_lb1 "(+)"
			local row_lb2 "(-)"
		}
		else {
			local c1 "CHANGE of Y"
			local c2 "   versus X"
			local row_lb1 "Yes"
			local row_lb2 " No"
		}
	}
	local row_lb3 "TOTAL"
	
	if ("`exp'"=="") di ""
	di as txt _col(22) "{c |}{bf:{center 21: `col_header'}}{c |}"
	di as txt "{bf:{lalign 20:`row_header'}} {c |}{ralign 10:`col_lb1'}{c |}{ralign 10:`col_lb2'}{c |}    TOTAL  Proportion"
	di as txt "{hline 21}{c +}{hline 10}{c +}{hline 10}{c +}{hline 21}" _c
	foreach i of numlist 1/3 {
		if (`i'<3) {
			if ("`relatsymm'"=="" & "`exp'"!="") di as txt _n "{bf:{lalign 9:`c`i''}} " _c
			if ("`relatsymm'"=="" & "`exp'"=="") di as txt _n "{bf:{lalign 11:`c`i''}} " _c
			if ("`relatsymm'"!="" & `i'==1) di as txt _n "{bf:{lalign 16:`c`i''}} " _c
			if ("`relatsymm'"!="" & `i'==2 & "`exp'"!="") di as txt _n "vs {bf:{lalign 13:`c`i''}} " _c
			if ("`relatsymm'"!="" & `i'==2 & "`exp'"=="") di as txt _n "{bf:{lalign 16:`c`i''}} " _c
			if ("`relatsymm'"=="" & "`exp'"!="") di as txt "{ralign 10:`row_lb`i''} {c |} " _c
			if ("`relatsymm'"=="" & "`exp'"=="") di as txt "{ralign 8:`row_lb`i''} {c |} " _c
			if ("`relatsymm'"!="") di as txt "{ralign 3:`row_lb`i''} {c |} " _c
		}
		if (`i'==3) di as txt _n "{hline 21}{c +}{hline 10}{c +}{hline 10}{c +}{hline 21}" _c
		if (`i'==3) di as txt _n "{ralign 20:`row_lb`i''} {c |} " _c
		foreach j of numlist 1/3 {
			di as res %8.0g `d'[`i',`j'] _c
			if (`j'<3) di as txt " {c |} " _c
		}
		if (`i'==1) di as res _col(57) %9.0g `p'[1,1] _c
		if ("`relatsymm'"=="" & `i'==2) di as res _col(57) %9.0g `p'[1,3] _c
	}
	if ("`relatsymm'"=="") di as txt _n "{ralign 20:Proportion} {c |} " _c
	if ("`relatsymm'"=="") di as res %8.0g `p'[1,4] _col(33) "{c |} " %8.0g `p'[1,2] " {c |}"
	if ("`relatsymm'"!="") di as txt _n "{ralign 20:Prop. of changes} {c |} " _c
	if ("`relatsymm'"!="") di as res %8.0g `p'[1,2] " {c |} " %8.0g `p'[1,3] " {c |}"

end

program define print_str_estimations
	syntax anything(name=type), d(name) res(name) st(string) nstr(real) str_values(name) level(real) method(string) /*
	*/	 chi2(name) lzero(integer) zero(string) [str_zero(name) str(varname)]

	local str_label ""
	if ("`str'"!="") {
		sta__utils get_varlabel `str', len(17)
		local str_label = r(label)
	}
	
	*Print stratum data & estimations
	di ""
	di "{hline 18}{c TT}{hline 44}{c TT}{hline 15}"
	di as txt "{bf:{ralign 17:`str_label'}} {c |}" _c
	if ("`type'"=="freq" & "`st'"!="cc") di as txt "{ralign 10:RR}" _c
	if ("`type'"=="freq" & "`st'"=="cc") di as txt "{ralign 10:OR}" _c
	if ("`type'"=="pt") di as txt "{ralign 10:IR}" _c
	di as txt "  Std. Err.  [`level'% Conf. Interval] {c |} " _col(71) upper("`method'") " Weight" _c
	di _n "{hline 18}{c +}{hline 44}{c +}{hline 15}" _c
	
	if ("`str'"!="") sta__utils get_var_labels `str', abb_name(17) abb_lbl(17)
	local len = rowsof(`res')
	foreach i of numlist 1/`len' {
		if (`i'<=`nstr') local v = `str_values'[1,`i']
		
		local z " "
		if (`i'<=`nstr' & `str_zero'[1,`i']==1) local z "*"
		if (`i'>`nstr' & `lzero'==1) local z "*"

		if (`i'<=`nstr' & "`str'"!="") di as txt _n "{ralign 17:`r(lbl`v')'} {c |} " _c
		if (`i'<=`nstr' & "`str'"=="") di as txt _n "{ralign 17:Stratum `v'} {c |} " _c
		if (`i'==`nstr'+1) di _n "{hline 18}{c +}{hline 44}{c +}{hline 15}" _c
		if (`i'==`nstr'+1) di as txt _n "{ralign 17:OVERALL     Crude} {c |} " _c
		if (`i'==`nstr'+2) di _n "{hline 18}{c +}{hline 44}{c +}{hline 15}" _c
		if (`i'==`nstr'+2) di as txt _n "{ralign 17:M-H Combined} {c |} " _c
		if (`i'==`nstr'+3) di as txt _n "{ralign 17:Inv. of Variance} {c |} " _c
		if (`i'==`nstr'+4) di as txt _n "{ralign 17:Internal Std.} {c |} " _c
		if (`i'==`nstr'+5) di as txt _n "{ralign 17:External Std.} {c |} " _c
		
		local or_ci = `res'[`i',7]
		di as res %9.0g `res'[`i',1] "`z' " _c
		if ((`i'>`nstr'+1 | "`st'"!="cc") | ("`st'"=="cc" & `i'<=`nstr'+1 & `or_ci'==2)) di as res %9.0g `res'[`i',2] _c
		di as res _col(43) %9.0g `res'[`i',3] "  " %9.0g `res'[`i',4] " {c |} " _c
		if (`i'<=`nstr') di as res _col(71) %9.0g `res'[`i',5] _c
		if (`i'==`nstr'+1) di as txt "  Sig.  Change" _c
		if (`i'>`nstr'+1) {
			di as res %6.4f `res'[`i',5] "  " _c
			local p = `res'[`i',6]
			print_pct `p'
		}
		if (`i'<=`nstr'+1 & "`type'"=="freq" & "`st'"=="cc") di as txt cond(`or_ci'==0," (Exact)",cond(`or_ci'==1," (Cornfield)"," (Woolf)")) _c
		
		if (`res'[`i',1]<1) {
			*Reciprocals
			di as txt _n "{ralign 17:reciprocal} {c |} " _c
			di as res %9.0g 1/`res'[`i',1] "`z' " %9.0g _c
			di as res _col(43) %9.0g 1/`res'[`i',4] "  " %9.0g 1/`res'[`i',3] " {c |} " _c
		}
	}
	di _n "{hline 18}{c BT}{hline 44}{c BT}{hline 15}" _c
	
	*Print MH Chi2
	di ""
	di "{hline 18}{c TT}{hline 16}"
	di as txt "{bf:{ralign 17:`str_label'}} {c |}  MH chi2   Sig."
	di "{hline 18}{c +}{hline 16}" _c
	local len = rowsof(`chi2')
	foreach i of numlist 1/`len' {
		if (`i'<=`nstr') local v = `str_values'[1,`i']
		
		if (`i'<=`nstr' & "`str'"!="") di as txt _n "{ralign 17:`r(lbl`v')'} {c |} " _c
		if (`i'<=`nstr' & "`str'"=="") di as txt _n "{ralign 17:Stratum `v'} {c |} " _c
		if (`i'==`nstr'+1) di _n "{hline 18}{c +}{hline 16}" _c
		if (`i'==`nstr'+1) di as txt _n "{ralign 17:OVERALL     Crude} {c |} " _c
		if (`i'==`nstr'+2) di as txt _n "{ralign 17:POOLED} {c |} " _c
		di as res %8.0g `chi2'[`i',1] "  " %5.3f `chi2'[`i',2] _c
		di as res _n _col(19) "{c |} " %8.0g `chi2'[`i',3] "  " %5.3f `chi2'[`i',4] as txt" Corrected" _c
	}
	di _n "{hline 18}{c +}{hline 16}"
	
	*Print Homogeneity results
	sta__utils get_homogeneity, d(`d') r(`res') type(`type') st(`st') str(`str_values') method(`method')
	di as txt "HOMOGENEITY  Wald {c |} " as res %8.0g r(chi2W) "`z' " %5.3f r(p_chi2W) as txt upper(" `method'")
	if ("`type'"=="freq" & "`st'"=="cc") di as txt "{ralign 17: Breslow-Day} {c |} " as res %8.0g r(chi2BD) "`z' " %5.3f r(p_chi2BD) as txt " MH"
	di "{hline 18}{c BT}{hline 16}"
	
	*Print continuity correction warning
	if (`lzero'==1) {
		if ("`zero'"=="c") di as txt "(*)Computed with a constant continuity correction (k=0.5)"
		if ("`zero'"=="p") di as txt "(*)Computed with a proportional continuity correction"
		if ("`zero'"=="r") di as txt "(*)Computed with a reciprocal continuity correction"
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


program define print_estimations
	syntax anything(name=type), d(name) res(name) st(string) level(real) chi2_type(integer) chi2(name) nnt(integer) /*
	*/	lzero(integer) zero(string) ldec(integer) r(real) pe(real) rare(integer) detail(integer)

	tempname a1 a0 rr b1 or
	
	di ""
	di as txt "{hline 22}{c TT}{hline 12}{c TT}{hline 31}"
	di as txt "{txt}{col 23}{c |}{col 26}Estimate{col 36}{c |} Std. Err.  [`level'% Conf. Interval]"
	di as txt "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
	
	sta__utils get_note		//Get ASCII value for note Recommended CI
	local note = r(note)

	if ("`type'"=="freq") {
		local z " "
		if (`lzero'==1) local z "*"
		
		local rlabel1 = cond("`st'"=="cs","Prev. Diff. (PD)","Risk Diff. (RD)")
		local note1 "Newcombe{c `note'}"
		local rlabel2
		local note2 "Wald"
		local rlabel3 = cond("`st'"=="cs","Prev. Ratio (PR)","Risk Ratio (RR)")
		local note3
			
		if ("`st'"!="cc") {
			*Print Risk/Prevalence Difference & Ratio
			foreach i of numlist 1/3 {
				local fmt = cond(`i'==1,"res","txt")

				di as txt _n "{ralign 21: `rlabel`i''} {c |} " _c
				if (inlist(`i',1,3)) di as res %9.0g `res'[`i', 1] "`z' {c |} " _c
				else di _col(36) "{c |} " _c
				if (inlist(`i',2,3)) di as res %9.0g `res'[`i', 4] "  " _c
				else di _col(49) _c
				di as res %9.0g `res'[`i',2] " " %9.0g `res'[`i',3] as `fmt' " `note`i''" _c
				*reciprocal
				if (`i'==3 & `res'[`i',1]<1) di as txt _n "{ralign 21:reciprocal} {c |} " /*
				*/			as res %9.0g 1/`res'[3,1] _col(36) "{c |}" /*
				*/ 			_col(49) %9.0g 1/`res'[3,3] " " %9.0g 1/`res'[3,2] _c

				if (`i'==2 & `detail'==1) {
					*If asked, print detail results
					scalar `a1' = `d'[1,2]
					scalar `a0' = `d'[1,1]
					scalar `rr' = `res'[3,1]

					di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
					*Proportion of exposed in the population
					di as txt _n "{ralign 21: Prop. exposed pop.} {c |} " _c
					di as res %9.0g `res'[7,1] "`z' {c |} " _c
					if (`pe'==0) di as res "(estimated)" _c
					else di as res "(external)" _c
					
					*Risk / Prevalence difference in the population
					if ("`st'"=="cs") di as txt _n "{ralign 21:Prev. Diff. pop.} {c |} " _c
					else di as txt _n "{ralign 21:Risk Diff. pop.} {c |} " _c
					di as res %9.0g `res'[8,1] "`z' {c |} " _c
					if (`pe'==0) di as res %9.0g `res'[8,4] "  " _c
					else di _col(49) _c
					di as res %9.0g `res'[8,2] " " %9.0g `res'[8,3] _c

					*Attributable / Preventable fraction in exposed / population
					local c9 = "exp."
					local c10 = "pop."
					foreach j of numlist 9/10 {
						if (`res'[9,4]==1) di as txt _n "{ralign 21:Attr. Frac. `c`j''} {c |} " _c
						if (`res'[9,4]==2) di as txt _n "{ralign 21:Prev. Frac. `c`j''} {c |} " _c
						di as res %9.0g `res'[`j',1] "`z' {c |} " _c
						if (`j'==10 & `res'[10,4]<.) di as res %9.0g `res'[`j',4] "  " _c
						else di _col(49) _c
						if (`res'[`j',2]<. | `res'[`j',3]<.) di as res  %9.0g `res'[`j',2] " " %9.0g `res'[`j',3] _c
					}

					di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
				}
				
				*For experimental studies, print number needed to treat if asked
				if (`i'==2 & "`st'"=="ex" & `nnt'>=0) print_nnt, res(`res') lzero(`lzero') detail(`detail')				
			}
		}

		*Odds ratio
		local note1 = cond(`ldec'==1,"Woolf",cond("`st'"=="cc","Exact{c `note'}","Cornfield{c `note'}"))
		local fmt = cond(`ldec'==1,"txt","res")

		local c_or = cond("`st'"=="cs","POR","OR")		
		di as txt _n "{ralign 21:Odds Ratio (`c_or')} {c |} " as res %9.0g `res'[4,1] "`z' {c |} " _c
		if (`ldec'==0) di as res _col(49) %9.0g `res'[4,2] " " %9.0g `res'[4,3] as `fmt' " `note1'" _c
		else di as res %9.0g `res'[5,4] "  " %9.0g `res'[5,2] " " %9.0g `res'[5,3] as `fmt' " `note1'" _c
		if (`ldec'==0 & "`st'"=="cc") di as res _n _col(23) "{c |}" _col(36) "{c |} " _col(49) /*
		*/	%9.0g `res'[9,2] " " %9.0g `res'[9,3] as txt " Cornfield" _c
		if (`ldec'==0) di as res _n _col(23) "{c |}" _col(36) "{c |} " %9.0g `res'[5,4] "  " /*
		*/	%9.0g `res'[5,2] " " %9.0g `res'[5,3] as txt " Woolf" _c
		*reciprocal
		if (`res'[4,1]<1) {
			di as txt _n "{ralign 21:reciprocal} {c |} " as res %9.0g 1/`res'[4,1] "  {c |} " _c
			if (`ldec'==0) di as res _col(49) %9.0g 1/`res'[4,3] " " %9.0g 1/`res'[4,2] as `fmt' " `note1'" _c
			else di as res _col(49) %9.0g 1/`res'[5,3] " " %9.0g 1/`res'[5,2] as `fmt' " `note1'" _c
			if (`ldec'==0 & "`st'"=="cc") di as res _n _col(23) "{c |}" _col(36) "{c |} " /*
			*/	_col(49) %9.0g 1/`res'[9,3] " " %9.0g 1/`res'[9,2] as txt " Cornfield" _c
			if (`ldec'==0) di as res _n _col(23) "{c |}" _col(36) "{c |} " /*
			*/	_col(49) %9.0g 1/`res'[5,3] " " %9.0g 1/`res'[5,2] as txt " Woolf" _c		
		}
		di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c

		if ("`st'"=="cc") {
			*Case-Control studies: Pop. Risk, RR, RD if possible
			if (`r'!=0 | `pe'!=0) {
				local rlabel1 "Population Risk"
				local rlabel2 "Proportion Ratio (PR)"
				local rlabel3 "Proportion Diff. (PD)"
				local c = cond(`r'!=0,"(external)","(estimated)")
				foreach i of numlist 1/3 {
					di as txt _n "{ralign 21:`rlabel`i''} {c |} " as res %9.0g `res'[`i',1] _c
					if (`i'==1) di "`z' {c |} `c'" _c
					else di "`z' {c |}" _c
				}
				if (`detail'==1) di as txt _n "Prop. Diff. pop. (PDp){c |} " as res %9.0g `res'[6,1] "`z' {c |}" _c
				di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
			}
				
			if (`detail'==1) {
				local c7 = "exp."
				local c8 = "pop."
				foreach j of numlist 7/8 {
					if (`res'[7,4]==1) di as txt _n "{ralign 21: Attr. Frac. `c`j''} {c |} " _c
					if (`res'[7,4]==2) di as txt _n "{ralign 21: Prev. Frac. `c`j''} {c |} " _c
					di as res %9.0g `res'[`j',1] "`z' {c |} " _c
					if (`j'==8 & `res'[8,4]<.) di as res %9.0g `res'[`j',4] "  " _c
					else di _col(49) _c
					if (`res'[`j',2]<. | `res'[`j',3]<.) di as res  %9.0g `res'[`j',2] " " %9.0g `res'[`j',3] _c
					if (`j'==7 & `ldec'==0 & (`res'[`j',2]<. | `res'[`j',3]<.)) di as txt " Exact" _c
					if (`j'==7 & `ldec'==1 & (`res'[`j',2]<. | `res'[`j',3]<.)) di as txt " Woolf" _c
				}
				di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
			}
		}
		
		*Print Association Chi2
		local c1 =cond(`chi2_type'==1,"","Chi2")
		local rlabel1 = cond(`chi2_type'==1,"Pearson Chi2","Mantel-Haenszel")
		local rlabel2 = "Corrected"
		local rlabel3 = "Fisher Exact Test"
		
		di as txt _n "Association  `chi'" _col(23) "{c |}" _col(36) "{c |}"_c
		foreach i of numlist 1/3 {
			local c2 = cond(`chi2'[3,1]==1 & `i'==1,"**","")
			if (`i'<3 | (`ldec'==0 | (`ldec'==1 & `lzero'==1))) {
				di as txt _n "{ralign 21:`rlabel`i''} {c |} " _c
				if (`i'<3) di as res %9.0g `chi2'[`i',1] "`c2'" _c
				di _col(36) "{c |}" _c
				di as txt " p= " as res %6.4f `chi2'[`i',2] as txt " (2-sided)"  _c
			}
		}
		di as txt _n "{hline 22}{c BT}{hline 12}{c BT}{hline 10}"
	}
	if ("`type'"=="pt") {
		**Person-time data
		*Print Incidence rate Difference (ID) & Incidence rate Ratio (IR)
		local rlabel1 "Inc. rate Diff. (ID)"
		local rlabel2 "Inc. rate Ratio (IR)"
		local rlabel3
			
		foreach i of numlist 1/3 {
			di as txt _n "{ralign 21: `rlabel`i''} {c |} " _c
			if (inlist(`i',1,2)) di as res %9.0g `res'[`i', 1] "  {c |} " _c
			else di _col(36) "{c |} " _c
			if (inlist(`i',1,3)) di as res %9.0g `res'[`i', 4] "  " _c
			else di _col(49) _c
			di as res %9.0g `res'[`i',2] " " %9.0g `res'[`i',3] _c
			if (`i'==2) di as res " Exact{c `note'}" _c
			if (`i'==1) di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
		}
		
		if (`detail'==1) {
			local c4 "exp."
			local c7 "pop."
			foreach i of numlist 4/7 {
				if (inlist(`i',4,7) & `res'[4,4]==1) di as txt _n "{ralign 21: Attr. Frac. `c`i''} {c |} " _c
				if (inlist(`i',4,7) & `res'[4,4]==2) di as txt _n "{ralign 21: Prev. Frac. `c`i''} {c |} " _c
				if (`i'==5) di as txt _n "{ralign 21: Prop. exposed pop.} {c |} " _c
				if (`i'==6) di as txt _n "{ralign 21: Inc. Diff. pop.(IDp)} {c |} " _c
				di as res %9.0g `res'[`i',1] "  {c |} " _c
				if (`i'==5 & `res'[`i',2]==1) di as txt "(estimated)" _c
				else if (`i'==5 & `res'[`i',2]==0) di as txt "(external)" _c
				else if (inlist(`i',6,7) & `res'[`i',4]<.) di as res %9.0g `res'[`i',4] "  " _c
				else di _col(49) _c
				if (`i'!=5 & (`res'[`i',2]<. | `res'[`i',3]<.)) di as res %9.0g `res'[`i',2] " " %9.0g `res'[`i',3] _c
				if (`i'==4) di as txt " Exact" _c
				if (inlist(`i',4,7)) di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
			}
		}
		else {
			di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
		}


		*Print Association Chi2
		local c = cond(`chi2'[1,3]==1,"**","")
		di as txt _n "{ralign 21:Mantel-Haenszel Chi2} {c |} " _c
		di as res %9.0g `chi2'[1,1] "`c'" _col(36) "{c |}" _c
		di as txt " p= " as res %6.4f `chi2'[1,2] as txt " (2-sided)"  _c
		di as txt _n "{hline 22}{c BT}{hline 12}{c BT}{hline 10}"
	}
	
	*Print WARNINGS
	di as txt "{c `note'}Recommended CI"
	if ("`type'"=="freq" & `lzero'==1) {
		if ("`zero'"=="c") di as txt "(*)Computed with a constant continuity correction (k=0.5)"
		if ("`zero'"=="p") di as txt "(*)Computed with a proportional continuity correction"
		if ("`zero'"=="r") di as txt "(*)Computed with a reciprocal continuity correction"
	}
	if (`chi2'[3,1]==1) di as txt "(**)WARNING: Small samples for Association Chi-Square"

end

program define print_paired_estimations
	syntax [anything], d(name) r(name) chi2(name) level(real) [relatsymm]
	
	sta__utils get_note		//Get ASCII value for note Recommended CI
	local note = r(note)
	
	local a0 = `d'[1,1]
	local a1 = `d'[1,2]
	local b0 = `d'[2,1]
	local b1 = `d'[2,2]

	di
	di "{hline 21}{c TT}{hline 12}{c TT}{hline 32}"
	di as txt _col(22) "{c |}  Estimate  {c |} Std. Err.  [`level'% Conf. Interval]"
	di "{hline 21}{c +}{hline 12}{c +}{hline 32}" _c
	
	if ("`relatsymm'"=="") {
		local row_headers "Difference" "Pr(Y+)-Pr(X+)" " " " "
		local notes Exact Newcombe Asymptotic A.correct.
		*Difference
		foreach i of numlist 1/4 {
			local c : word `i' of "`row_headers'"
			di as txt _n "{ralign 20:`c'} {c |} " _c
			if (`i'==1) di as res %9.0g `r'[`i',1] "  {c |} " _c
			else di _col(35) "{c |} " _c
			if (`i'==3) di as res %9.0g `r'[`i',4] "  " _c
			else di _col(48) _c
			di as res %9.0g `r'[`i',2] "  " %9.0g `r'[`i',3] " " _c 

			local c : word `i' of `notes'
			di as txt "`c'" _c
			if (`i'==2) di as txt "{c `note'}" _c
			if (`i'==4) di as txt _n _col(22) "{c |}" _col(35) "{c |}" _c
		}
		
		*Odds ratio
		di as txt _n "{ralign 20:Odds ratio (OR)} {c |} " _c
		if (`b1'>0) di as res %9.0g `r'[5,1] "  {c |} " _c
		else di as res " infinity  {c |} " _c
		if (`b1'>0) di as res _col(48) %9.0g `r'[5,2] "  " %9.0g `r'[5,3] _c
		else di as res %9.0g `r'[5,2] "   infinity" _c
		di as txt " Exact" _c
		di as txt _n "{ralign 20:(exposure-disease)} {c |}" _col(35) "{c |} " _c
		if (`b1'>0) di as res _col(48) %9.0g `r'[6,2] "  " %9.0g `r'[6,3] _c
		else di as res %9.0g `r'[6,2] "   infinity" _c
		di as txt " Wilson{c `note'}" _c
		if (`a0'>0 & `b1'>0) di as res _n _col(22) "{c |}" _col(35) "{c |} " %9.0g `r'[7,4] "  " /*
		*/		%9.0g `r'[7,2] "  " %9.0g `r'[7,3] as txt " Asymptotic" _c
		if (`r'[5,1]<1) {
			di as txt _n "{ralign 20:reciprocal} {c |} " as res %9.0g 1/`r'[5,1] "  {c |} " 	/*
			*/			_col(48) %9.0g 1/`r'[5,3] "  " %9.0g 1/`r'[5,2] as txt " Exact" _c
			di as res _n _col(22) "{c |}" _col(35) "{c |} " _col(48) %9.0g 1/`r'[6,3] "  " %9.0g 1/`r'[6,2] as txt " Wilson" _c
			di as res _n _col(22) "{c |}" _col(35) "{c |} " _col(48) %9.0g 1/`r'[7,3] "  " %9.0g 1/`r'[7,2] as txt " Asymptotic" _c
		}
		if (`a0'==0) {
			di as txt _n "{ralign 20:reciprocal} {c |}  {bf:infinity}  {c |} "  /*
			*/			as res %9.0g 1/`r'[5,3] "   infinity" as txt " Exact" _c
			di as res _n _col(22) "{c |}" _col(35) "{c |} " %9.0g 1/`r'[6,3] "   infinity" as txt " Wilson" _c
		}
		di _n "{hline 21}{c +}{hline 12}{c +}{hline 32}" _c
		
		*Exact simmetry & Test of Association
		local row_headers "McNemar matched-pair" "Chi-Square" "Corrected" "OR" "Chi-Square" "Corrected"
		foreach i of numlist 1/6 {
			if (`i'==1) di as txt _n "{ralign 20:EXACT SYMMETRY} {c |} " _col(35) "{c |}" _c
			if (`i'==4) di as txt _n "{ralign 20:TEST OF ASSOCIATION} {c |} " _col(35) "{c |}" _c
			local c : word `i' of "`row_headers'"
			di as txt _n "{ralign 20:`c'} {c |} " _c
			if (`chi2'[`i',1]<.) di as res %9.0g `chi2'[`i',1] _c
			if (`i'==2 & `chi2'[`i',3]==1 & `chi2'[`i',1]<.) di as txt "*" _c
			if (`i'==5 & `chi2'[`i',3]==1 & `chi2'[`i',1]<.) di as txt "**" _c
			di as txt _col(35) "{c |}" _c
			if (`i'!=4) di as txt " p = " as res %6.4f `chi2'[`i',2] _c
			if (`i'==1) di as txt " (Exact)" _c
			if (`i'==3) di as txt _n "{hline 21}{c +}{hline 12}{c +}{hline 11}" _c
		}
	}
	else {
		local row_headers "Prop. Diff. (PD)" " " "Prop. Ratio (PR)" "Odds ratio (OR)"
		local notes Wald Newcombe Asymptotic Asymptotic
		*Prop. difference (PD), Prop. ratio (PR), Odds ratio (OR)
		foreach i of numlist 1/4 {
			local c : word `i' of "`row_headers'"
			di as txt _n "{ralign 20:`c'} {c |} " _c
			if (`i'==1) di as res %9.0g `r'[`i',1] "  " _c
			if (`i'==2) di as txt _col(35) _c
			if (`i'==3) {
				if (`a1'>0 & `a0'>0) di as res %9.0g `r'[`i',1] "  " _c
				if (`a1'==0) di as res %9.0g 0 "  "_c
				if (`a0'==0) di as res " infinity  " _c
			}
			if (`i'==4) {
				if (`a1'>0 & `a0'>0 & `b1'>0 & `b0'>0) di as res %9.0g `r'[`i',1] "  " _c
				if (`a1'==0) di as res %9.0g 0 "  "_c
				if (`a0'==0 | `b1'==0 | `b0'==0) di as res " infinity  " _c
			}
			di as txt "{c |} " _c
			local c : word `i' of `notes'
			if (`i'<3 | (`i'==3 & `a1'>0 & `a0'>0) | (`i'==4 & `a1'>0 & `a0'>0 & `b1'>0 & `b0'>0)) {
				if (`i'==3 | `i'==4) di as res %9.0g `r'[`i',4] "  " _c
				else di _col(48) _c
				di as res %9.0g `r'[`i',2] "  " %9.0g `r'[`i',3] as txt " `c'" _c
			}
			if (`i'==2) di as txt "{c `note'}" _c
			if (`i'>2 & `r'[`i',1]<1) di as txt _n "{ralign 20:reciprocal} {c |} " as res %9.0g 1/`r'[`i',1] /*
			*/		"  {c |} " _col(48) %9.0g 1/`r'[`i',3] "  " %9.0g 1/`r'[`i',2] _c
			if ((`i'==3 | `i'==4) & `a1'==0) di as txt _n "{ralign 20:reciprocal} {c |}  infinity" _col(35) "{c |}" _c			
		}
		di _n "{hline 21}{c +}{hline 12}{c +}{hline 32}" _c
		
		*Relative simmetry
		local row_headers "Chi-Square" "Corrected" "OR"
		foreach i of numlist 1/2 {
			if (`i'==1) di as txt _n "{ralign 20:RELATIVE SYMMETRY} {c |} " _col(35) "{c |}" _c
			local c : word `i' of "`row_headers'"
			di as txt _n "{ralign 20:`c'} {c |} " _c
			di as res %9.0g `chi2'[`i',1] _c
			if (`i'==1 & `chi2'[`i',3]==1) di as txt "**" _c
			di as txt _col(35) "{c |}" _c
			di as txt " p = " as res %6.4f `chi2'[`i',2] _c
		}
	}
	di as txt _n "{hline 21}{c BT}{hline 12}{c BT}{hline 11}"
	*Notes
	di as txt "{c `note'}Recommended CI"
	if ("`relatsymm'"=="" & `chi2'[2,3]==1) di as txt "(*)WARNING: Small samples for McNemar matched-pair test"
	if (("`relatsymm'"=="" & `chi2'[5,3]==1) | ("`relatsymm'"!="" & `chi2'[1,3]==1)) /*
	*/		di as txt "(**)WARNING: Small samples for Association Chi-Square"

end

program define print_nnt
	syntax [anything], res(name) lzero(integer) detail(integer)

	tempname nn lb ub
	scalar `nn' = `res'[6,1]
	scalar `lb' = `res'[6,2]
	scalar `ub' = `res'[6,3]

	local z " "
	if (`lzero'==1) local z "*"

	local p = `lb'>0 & `ub'>0
	local n = `lb'<0 & `ub'<0
	local np = `ub'<0 & `lb'>0
	local zero = (`res'[1,1]==0)
	
	*Print NNT and bounds
	if (`detail'==0) di as txt _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c
	
	di as txt _n "Number needed to treat{c |} " as res _c
	if (`np'==1 & `zero'==1) di as res "{ralign 9:infinity}  {c |}" _c
	else di as res %9.0g `nn' "`z' {c |}" _c
	if (`p'==1) di as res _col(46) %9.0g `lb' as txt " to " as res %9.0g `ub' _c
	else  di as res _col(46) %9.0g `ub' as txt " to " as res %9.0g `lb' _c
	di as txt " Newcombe" _c
	if (`p'==1) di as txt _n "{ralign 21:Benefit (NNTB)} {c |}" _col(36) "{c |}" _c
	if (`n'==1) di as txt _n "{ralign 21:Harm (NNTH)} {c |}" _col(36) "{c |}" /*
	*/			as res _col(46) %9.0g abs(`ub') as txt " to " as res %9.0g abs(`lb') _c
	if (`np'==1) di as txt _n "{ralign 21:Benefit (NNTB)} {c |}" _col(36) "{c |}" /*
	*/			as res _col(46) %9.0g `lb' as txt " to " as res "infinity" _c
	if (`np'==1) di as txt _n "{ralign 21:Harm (NNTH)} {c |}" _col(36) "{c |}" /*
	*/			as res _col(46) %9.0g abs(`ub') as txt " to " as res "infinity" _c
	display as text _n "{hline 22}{c +}{hline 12}{c +}{hline 31}" _c	
	
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end


version 12
mata:
void get_totals(string scalar data, string scalar stratum, string scalar type)
{
	real matrix d, str, sub, t
	real scalar i, val, len
	
	if (type=="freq" | type=="paired") len = 3
	if (type=="pt") len = 2
	
	d = st_matrix(data)
	if (stratum != "") {
		str = st_matrix(stratum)
		for (i=1; i<=cols(str); i++) {
			sub = select(d, d[.,1] :== str[1,i])[(1\2),(2,3)]
			t = rowsum(sub)
			d[1+(i-1)*len,4] = t[1,1]		//m1
			d[2+(i-1)*len,4] = t[2,1]		//m0/T
			if (type=="freq") {
				t = colsum(sub)
				d[3+(i-1)*len,2] = t[1,1]		//n0
				d[3+(i-1)*len,3] = t[1,2]		//n1
				d[3+(i-1)*len,4] = t[1,1]+t[1,2]		//n=n1+n0
			}
		}
		//OVERALL
		sub = select(d, d[.,1] :== .)[(1\2),(2,3)]
		t = rowsum(sub)
		d[cols(str)*len+1,4] = t[1,1]		//m1
		d[cols(str)*len+2,4] = t[2,1]		//m0/T
		if (type=="freq") {
			t = colsum(sub)
			d[cols(str)*len+3,2] = t[1,1]		//n0
			d[cols(str)*len+3,3] = t[1,2]		//n1
			d[cols(str)*len+3,4] = t[1,1]+t[1,2]		//n=n1+n0
		}
	}
	else {
		t = rowsum(d[(1\2),(1,2)])
		d[1,3] = t[1,1]		//m1
		d[2,3] = t[2,1]		//m0/T
		if (type=="freq" | type=="paired" | type=="relatsymm") {
			t = colsum(d[(1\2),(1,2)])
			d[3,1] = t[1,1]		//n0
			d[3,2] = t[1,2]		//n1
			d[3,3] = t[1,1]+t[1,2]		//n=n1+n0
		}
	}
	
	st_matrix(data,d)
}
end

version 12
mata:
void get_data_matrix(string scalar data, string scalar m, string scalar type)
{
	string matrix t
	real matrix d, st
	real scalar i, len, str, rows, cols, j
	real scalar a1, a0, b1, b0
	string scalar c
	
	if (type=="freq" | type=="paired" | type=="relatsymm") len = 3
	if (type=="pt") len = 2
	
	t = tokens(data,"\")
	str = (cols(t)+1)/2		//Number of strata

	//Build void data matrix
	if (str==1) {
		rows = len
		cols = 3
		offset = 0
	}
	else {
		rows = len*(str+1)
		cols = 4
		offset = 1
	}
	d = J(rows,cols,.)
	//Populate matrix with immediate data
	a1 = 0
	a0 = 0
	b1 = 0 
	b0 = 0
	i = 1
	for (j=1; j<=cols(t); j++) {
		c = t[1,j]
		if (c!="\") {
			st = strtoreal(tokens(c))
			if (str>1) {
				d[1+(i-1)*len,1] = i			//stratum
				d[2+(i-1)*len,1] = i			//stratum
				if (type=="freq") d[3+(i-1)*len,1] = i			//stratum
			}
			d[1+(i-1)*len,2+offset] = st[1,1]		//a1
			d[1+(i-1)*len,1+offset] = st[1,2]		//a0
			d[2+(i-1)*len,2+offset] = st[1,3]		//b1/t1
			d[2+(i-1)*len,1+offset] = st[1,4]		//b0/t0
			//OVERALL summatories
			if (str>1) {
				a1 = a1 + st[1,1]
				a0 = a0 + st[1,2]
				b1 = b1 + st[1,3]
				b0 = b0 + st[1,4]
			}
			
			i = i + 1
		}
	}
	//OVERALL
	if (str>1) {
		d[1+str*len,2+offset] = a1
		d[1+str*len,1+offset] = a0
		d[2+str*len,2+offset] = b1
		d[2+str*len,1+offset] = b0
	}
	
	st_matrix(m,d)
}
end
