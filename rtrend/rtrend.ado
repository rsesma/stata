*! version 1.2.5  23oct2018 JM. Domenech, R. Sesma
/*
rtrend: Trend Test using current data
*/

program define rtrend, rclass
	version 12
	syntax varlist(min=2 max=3 numeric) [if] [in], /*
	*/	[Data(string) ST(string) Zero(string) Level(numlist max=1 >50 <100)  /*
	*/	 metric(numlist >=0) RC(string) NOne Wilson Exact WAld BY(varname) nst(string)]

	tempname E R M f d r T
	tempvar strat
	
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
	if ("`level'"=="") local level 95

	*Reference category
	if ("`rc'"=="") local rc = "f"
	if ("`rc'"!="f" & "`rc'"!="l" & "`rc'"!="p" & "`rc'"!="s") print_error "rc() invalid -- invalid value" 

	*Zero cell correction
	if ("`zero'"=="") local zero = "n"
	if ("`zero'"!="n" & "`zero'"!="c" & "`zero'"!="p" & "`zero'"!="r") print_error "zero() invalid -- invalid value" 

	*Variables
	local nvars : word count `varlist'
	if (`nvars'==3 & "`data'"!="pt") print_error "wrong number of variables"
	
	tokenize `varlist'
	local res `1'						//Response (row) variable
	local exp `2'						//Exposure (column) variable
	if ("`data'"=="pt") local time `3'	//Time variable (for person-time data)
	else local time ""

	*Mark observations [if/in]
	marksample touse, novarlist
	qui count if `touse'
	local total = r(N)
	if (`total'==0) print_error "no data selected"
	
	*Get variable values
	qui levelsof `res' if `touse', local(t)			//Response variable
	mata: st_matrix("`R'",strtoreal(tokens(st_local("t"))))
	local rk = colsof(`R')

	qui levelsof `exp' if `touse', local(t)			//Exposure variable
	mata: st_matrix("`E'",strtoreal(tokens(st_local("t"))))
	local ek = colsof(`E')
	
	if ("`metric'"!="") local t `metric'	//metric by default: exposure values
	mata: st_matrix("`M'",strtoreal(tokens(st_local("t"))))
	local c = colsof(`M')
	
	local lk2 0
	if ("`data'"=="freq") {
		if (`rk'!=2 & `ek'!=2) print_error "exposure or response variable must be binary"
		if (`rk'==2) {
			//default situation: binary response variable, exposure with k(>=2) categories
			if (`ek'<2) print_error "exposure variable must have k>=2 categories"
			if (`R'[1,1]!=0 | `R'[1,2]!=1) print_error "the response variable must be binary (0,1)"
		}
		if (`rk'>2 & `ek'==2) {
			//special situation: binary exposure variable, response with k(>2) categories
			if (`type'==3) print_error "the response variable must be binary for case-control studies"
			if ("`by'"!="") print_error "the response variable must be binary for stratified studies"
			local lk2 1
			if (`E'[1,1]!=0 | `E'[1,2]!=1) print_error "the exposure variable must be binary (0,1)"
			if ("`metric'"=="") {
				matrix `M' = `R'
				local c = `rk'
			}
		}
	}
	if ("`data'"=="pt") {
		if (`rk'!=2 | `ek'<2) print_error "response variable must be binary and exposure variable must have k>=2 categories"
		if (`R'[1,1]!=0 | `R'[1,2]!=1) print_error "the response variable must be binary (0,1)"
	}
	if (!`lk2' & colsof(`E')!=`c') print_error "the number of elements of metric() must be equal to the number of categories of the exposure variable"	
	if (`lk2' & colsof(`R')!=`c') print_error "the number of elements of metric() must be equal to the number of categories of the response variable"	
	
	*Print header
	di as res "TREND TEST " _c
	if ("`data'"=="freq" & `type'!=2) di as res "(Risk data)"
	if ("`data'"=="freq" & `type'==2) di as res "(Prevalence data)"
	if ("`data'"=="pt") di as res "(Person-time data)"
	if ("`nst'"!="") di as txt "{bf:STUDY}: `nst'"
	di
	
	*Print variable data
	local l: variable label `res'
	di as txt "{bf:Response} variable: {bf:`res'}" cond("`l'"!=""," - `l'","")
	local dic: value label `res' 
	local len = colsof(`R')
	foreach i of numlist 1/`len' {
		if (!`lk2') local l = cond(`i'==1,"NonCases:","Cases:")
		if (`lk2') local l = cond(`i'==1,"Categories:","")
		local v = `R'[1,`i']
		local lbl : label (`res') `v'
		di as txt "{ralign 18:`l'} " `v' "{tab}" _c
		if (`lk2' & "`metric'"!="") di as txt "(" `M'[1,`i'] ") " _c
		if ("`dic'"!="") di as txt "`lbl'"
		else di as txt ""
	}

	di
	local l: variable label `exp'
	di as txt "{bf:Exposure} variable: {bf:`exp'}" cond("`l'"!=""," - `l'","")
	local dic: value label `exp' 
	local len = colsof(`E')
	local cat = `len'
	foreach i of numlist 1/`len' {
		if (!`lk2') local l = cond(`i'==1,"Categories:","")
		if (`lk2') local l = cond(`i'==1,"NonExposed:","Exposed:")
		local v = `E'[1,`i']
		local lbl : label (`exp') `v'
		di as txt "{ralign 18:`l'} " `v' "{tab}" _c
		if (!`lk2' & "`metric'"!="") di as txt "(" `M'[1,`i'] ") " _c
		if ("`dic'"!="") di as txt "`lbl'"
		else di as txt ""
	}
	
	if ("`data'"=="pt") {
		di
		local l: variable label `time'
		di as txt "{bf:Person-Time} variable: {bf:`time'}" cond("`l'"!=""," - `l'","")
	}
	
	*Stratum variable
	if ("`by'"=="") qui g `strat' = 1
	else qui g `strat' = `by'
	qui levelsof `strat' if `touse', local(stratum)
	if ("`by'"!="") {
		di
		local l: variable label `by'
		di as txt "{bf:Stratum} variable: {bf:`by'}" cond("`l'"!=""," - `l'","")		
		local dic: value label `by' 
	}
	
	if (`lk2') {
		//special situation: binary exposure variable, response with k(>2) categories: change roles to compute
		local tmp `res'
		local res `exp'
		local exp `tmp'
	}
	
	*Number of valid/total cases
	if ("`data'"=="freq") {
		qui tab `exp' `res' if `touse'
		local valid = r(N)				//Number of valid cases
	}
	if ("`data'"=="pt") {
		markout `touse' `exp' `res' `time'
		qui count if `touse'			//Count number of valid cases
		local valid = r(N)
	}
	di
	di as txt "Valid cases: " as res `valid' as txt " (" as res %5.1f 100*`valid'/`total' as txt "%)"
	di as txt "Total cases: " as res `total'
	return scalar N = `valid'
	
	*Get data
	local nstr : word count `stratum'
	if (`nstr'>1) local nstr = `nstr'+1
	foreach i of numlist 1/`nstr' {
		if (`i'<`nstr') {
			local s : word `i' of `stratum'
			if ("`data'"=="freq") local tab_filter "& `strat'==`s'"
			if ("`data'"=="pt") {
				local collapse_by "`strat' `exp'"
				local mkmat_if "if `strat'==`s'"
			}
		}
		else {
			if ("`data'"=="freq") local tab_filter ""			
			if ("`data'"=="pt") {
				local collapse_by "`exp'"
				local mkmat_if ""
			}
		}
		
		if ("`data'"=="freq") {
			qui tab `exp' `res' if `touse' `tab_filter', matcell(`f') chi2
			local chi2Pearson = r(chi2)		//Get Pearson chi2 from tabulate
			*Build data matrix from tabulate data and metric
			matrix colnames `f' = b a
			matrix `d' = `M'',`f'[.,"a"],`f'[.,"b"]
		
			*Compute results
			rtrend__utils get_results_freq `type' `stat', d(`d') method(`ci_method') level(`level') rc(`rc') zero(`zero') k2(`lk2')
			matrix `r' = r(results)
		}
		if ("`data'"=="pt") {
			preserve
			qui collapse (sum) __a = `res' __t = `time' if `touse', by(`collapse_by')
			qui mkmat __a __t `mkmat_if', matrix(`f')
			restore
			*Build data matrix from collapse data and metric
			matrix `d' = `M'',`f'
			local chi2Pearson = .		//No chi2 Pearson / deviation from linearity on person-time data
			
			*Compute results
			local printci = ("`exact'"!="")
			rtrend__utils get_results_pt, d(`d') level(`level') rc("`rc'") printci(`printci')
			matrix `r' = r(results)
		}
		matrix `f'`i' = `r'
		
		*Print results
		di
		if (`nstr'>1) {
			if (`i'<`nstr') {
				if ("`dic'"!="") local lbl : label (`by') `s'
				else local lbl ""
				di as res "STRATUM `i': `s'" _col(15) "`lbl'"
			}
			else {
				di as res "OVERALL"
			}
		}
		rtrend__utils print_results `data' `type' `stat', r(`r') method(`ci_method') level(`level') `ic' /*
		*/	rc("`rc'") chi2P(`chi2Pearson') nstr(`nstr') zero(`zero') k2(`lk2')	str(`i')
		
		*Store results
		rtrend__utils store_results `data' `type' `stat', r(`r') str(`i') nstr(`nstr') chi2P(`chi2Pearson') k2(`lk2')
		return add
	}
	
	*if strata, compute, print and store adjusted results
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

