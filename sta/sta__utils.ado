*! version 1.1.5  17mar2021
program sta__utils
	version 12.0
	gettoken subcmd 0 : 0
	`subcmd' `0'
end


program genCommand
	syntax , clsname(string)
	local dlg .`clsname'
	local cmdstring cmd
	
	local command ""
	forvalues i = 1/8 {
		if ("``dlg'.data.ed_a1`i'.value'"=="" | "``dlg'.data.ed_a0`i'.value'"=="" | /*
		*/	"``dlg'.data.ed_b1`i'.value'"=="" | "``dlg'.data.ed_b0`i'.value'"=="" ) {
			continue, break
		}
		else {
			if (`i'>1) local command "`command' \ "
		}

		local command "`command' ``dlg'.data.ed_a1`i'.value'"
		local command "`command' ``dlg'.data.ed_a0`i'.value'"
		local command "`command' ``dlg'.data.ed_b1`i'.value'"
		local command "`command' ``dlg'.data.ed_b0`i'.value'"		
	}
	
	`dlg'.`cmdstring'.value = "`command'"
end


program define get_proportions, rclass
	syntax [anything], d(name) level(real) method(string)

	tempname p
	matrix `p' = J(6,3,.)
	
	*Exposed proportions
	local a = `d'[1,2]
	local b = `d'[1,3]
	get_ci `a' `b', level(`level') method(`method') r(`p') row(1)
	local a = `d'[2,2]
	local b = `d'[2,3]
	get_ci `a' `b', level(`level') method(`method') r(`p') row(2)
	local a = `d'[3,2]
	local b = `d'[3,3]
	get_ci `a' `b', level(`level') method(`method') r(`p') row(3)
	
	*Prevalences
	local a = `d'[1,1]
	local b = `d'[3,1]
	get_ci `a' `b', level(`level') method(`method') r(`p') row(4)
	local a = `d'[1,2]
	local b = `d'[3,2]
	get_ci `a' `b', level(`level') method(`method') r(`p') row(5)
	local a = `d'[1,3]
	local b = `d'[3,3]
	get_ci `a' `b', level(`level') method(`method') r(`p') row(6)
		
	return matrix p = `p'
end

program define get_str_props, rclass
	syntax [anything], d(name) str(name) st(string) type(string)

	tempname s p
	local nstr = colsof(`str')+1		//+1: OVERALL
	matrix `p' = J(`nstr',5,.)
	
	foreach i of numlist 1/`nstr' {
		if (`i'!=`nstr') local v = `str'[1,`i']
		else local v = .
		mata: get_submatrix("`d'", "`s'", `v')
		if ("`type'"=="freq") {
			if ("`st'"!="cc") {
				local a1 = `s'[1,2]
				local a0 = `s'[1,1]
				local n1 = `s'[3,2]
				local n0 = `s'[3,1]
				local m1 = `s'[1,3]
				local n = `s'[3,3]
				matrix `p'[`i',1] = `n1'/`n'		//Pe Proportion of Exposed
				matrix `p'[`i',2] = `a0'/`n0'		//r0 Risk Unexposed
				matrix `p'[`i',3] = `a1'/`n1'		//r1 Risk Exposed
				matrix `p'[`i',4] = `m1'/`n'		//r Total Risk
				matrix `p'[`i',5] = `p'[`i',3]/`p'[`i',2]		//RR Risk Ratio = r1/r0
			}
			else {
				local a1 = `s'[1,2]
				local a0 = `s'[1,1]
				local b1 = `s'[2,2]
				local b0 = `s'[2,1]
				local m1 = `s'[1,3]
				local m0 = `s'[2,3]
				matrix `p'[`i',1] = `a1'/`m1'		//Pe1 Proportion of Cases Exposed
				matrix `p'[`i',2] = `b1'/`m0'		//Pe0 Proportion of Controls Exposed
				matrix `p'[`i',3] = (`a1'/`b1')/(`a0'/`b0')		//OR Odds Ratio = (a1/b1)/(a0/b0)
			}
		}
		if ("`type'"=="pt") {
			local a1 = `s'[1,2]
			local a0 = `s'[1,1]
			local t1 = `s'[2,2]
			local t0 = `s'[2,1]
			local m1 = `s'[1,3]
			local t = `s'[2,3]
			
			matrix `p'[`i',1] = `t1'/`t'		//Pe Proportion of Exposed in the population
			matrix `p'[`i',2] = `a0'/`t0'		//i0 Incidence rate UnExposed
			matrix `p'[`i',3] = `a1'/`t1'		//i1 Incidence rate Exposed
			matrix `p'[`i',4] = `m1'/`t'		//i Incidence rate Total
			matrix `p'[`i',5] = `p'[`i',3]/`p'[`i',2]		//IR Incidence rate Ratio = i1/i0
		}
	}

	return matrix p = `p'
end

program define get_incidence_rates, rclass
	syntax [anything], d(name) level(real)

	tempname p
	matrix `p' = J(3,3,.)
	
	local i = `d'[1,1]
	local t = `d'[2,1]
	get_ci `i' `t', level(`level') method("exact_i") r(`p') row(1)
	local i = `d'[1,2]
	local t = `d'[2,2]
	get_ci `i' `t', level(`level') method("exact_i") r(`p') row(2)
	local i = `d'[1,3]
	local t = `d'[2,3]
	get_ci `i' `t', level(`level') method("exact_i") r(`p') row(3)
		
	return matrix p = `p'
end

program define get_ci, rclass
	syntax anything, level(real) method(string) [r(name) row(integer 0)]
	
	tempname a b wa wb wc se z alpha p lb ub	
	tokenize `anything'
	scalar `a' = `1'
	scalar `b' = `2'

	scalar `alpha' = (`level'+100)/200
	scalar `z' = invnormal(`alpha')
	
	scalar `p' = `a'/`b'
	if ("`method'"=="wilson") {
		scalar `wa' = 2*`a' + `z'^2
		scalar `wb' = `z' * sqrt(`z'^2 + 4*`a'*(`b'-`a')/`b')
		scalar `wc' = 2*(`b' + `z'^2)
		scalar `lb' = (`wa'-`wb')/`wc'
		scalar `ub' = (`wa'+`wb')/`wc'
	}
	if ("`method'"=="exact") {
		scalar `lb' = 0
		scalar `ub' = 1
		if (`a'>0) scalar `lb' = `a'/(`a'+(`b'-`a'+1)*invF(2*(`b'-`a'+1),2*`a',`alpha'))
		if (`b'>`a') scalar `ub' = (`a'+1)/((`a'+1)+((`b'-`a')/invF(2*(`a'+1),2*(`b'-`a'),`alpha')))
	}
	if ("`method'"=="exact_i") {
		scalar `lb' = 0
		scalar `ub' = 1
		if (`a'>0) scalar `lb' = invchi2(2*`a',1-`alpha')/(2*`b')
		if (`b'>`a') scalar `ub' = invchi2(2*(`a'+1),`alpha')/(2*`b')
	}
	if ("`method'"=="wald") {
		scalar `se' = sqrt(`p'*(1-`p')/`b')
		scalar `lb' = `p' - `z'*`se'
		scalar `ub' = `p' + `z'*`se'
	}

	if ("`r'"!="") {
		matrix `r'[`row',1] = `p'
		matrix `r'[`row',2] = `lb'
		matrix `r'[`row',3] = `ub'
	}
	
	return scalar p = `p'
	return scalar lb = `lb'
	return scalar ub = `ub'
end

program define get_scor_results, rclass
	syntax [anything], d(name) str(name) method(string) level(real)
	
	tempname r s se rr z var
	
	local nstr = colsof(`str')+1		//+1: OVERALL
	local len = `nstr'+4
	matrix `r' = J(`len',6,.)
	
	local n_mh = 0
	local d_mh = 0
	local n_semh = 0
	local n_iov = 0
	local d_iov = 0
	local d_is = 0
	local n_seis = 0
	local n_es = 0
	local n_sees = 0
	foreach i of numlist 1/`nstr' {
		if (`i'<`nstr') local val = `str'[1,`i']
		else local val = .
		mata: get_submatrix("`d'", "`s'", `val')
		
		*RR + CI for each stratum
		get_rr, data(`s') level(`level')
		matrix `r'[`i',1] = r(rr)
		matrix `r'[`i',2] = r(se)
		matrix `r'[`i',3] = r(lb)
		matrix `r'[`i',4] = r(ub)
		
		if (`i'<`nstr') {
			local a1 = `s'[1,2]
			local a0 = `s'[1,1]
			local m1 = `s'[1,3]
			local n1 = `s'[3,2]
			local n0 = `s'[3,1]
			local n = `s'[3,3]

			*Weights
			if ("`method'"=="mh") matrix `r'[`i',5] = `a0'*`n1'/`n'
			if ("`method'"=="iv") matrix `r'[`i',5] = 1/r(se)^2
			if ("`method'"=="is") matrix `r'[`i',5] = 1/`n1'
			if ("`method'"=="es") matrix `r'[`i',5] = 1/`n0'
			
			*Estimation summatories
			*Mantel-Haenszel
			local n_mh = `n_mh' + (`a1'*`n0')/`n'
			local d_mh = `d_mh' + (`a0'*`n1')/`n'
			local n_semh = `n_semh' + ((`m1'*`n1'*`n0')/`n'^2 - (`a1'*`a0')/`n')
			*Inverse of Variance
			scalar `var' = r(se)^2
			local n_iov = `n_iov' + ln(r(rr))/`var'
			local d_iov = `d_iov' + 1/`var'
			*Internal standardization
			local d_is = `d_is' + (`n1'*`a0')/`n0'
			local n_seis = `n_seis' + `a1'^2*`var'
			*External standardization
			local n_es = `n_es' + (`n0'*`a1')/`n1'
			local n_sees = `n_sees' + `var'*((`n0'*`a1')/`n1')^2
		}
	}
	
	scalar `z' = invnormal((`level'+100)/200)

	mata: get_submatrix("`d'", "`s'", .)		//Get OVERALL submatrix
	foreach i of numlist 1/4 {
		if (`i'==1) {
			*Mantel-Haenszel RR
			scalar `rr' = `n_mh'/`d_mh'
			scalar `se' = sqrt(`n_semh'/(`n_mh'*`d_mh'))
		}
		if (`i'==2) {
			*Inverse of Variance RR
			scalar `rr' = exp(`n_iov'/`d_iov')
			scalar `se' = 1/sqrt(`d_iov')
		}
		if (`i'==3) {
			*Internal standardization
			local a1o = `s'[1,2]
			scalar `rr' = `a1o'/`d_is'
			scalar `se' = sqrt(`n_seis'/`a1o'^2)
		}
		if (`i'==4) {
			*External standardization
			local a0o = `s'[1,1]
			scalar `rr' = `n_es'/`a0o'
			scalar `se' = sqrt(`n_sees'/`n_es'^2)
		}
		matrix `r'[`nstr'+`i',1] = `rr'
		matrix `r'[`nstr'+`i',2] = `se'
		matrix `r'[`nstr'+`i',3] = `rr'*exp(-`z'*`se')
		matrix `r'[`nstr'+`i',4] = `rr'*exp(`z'*`se')
		matrix `r'[`nstr'+`i',5] = 2*(1 - normal(abs(ln(`rr')/`se')))		//Sig.
		matrix `r'[`nstr'+`i',6] = abs((`rr' - `r'[`nstr',1])/`rr')*100		//Change
	}

	return matrix results = `r'
end

program define get_scc_results, rclass
	syntax [anything], d(name) str(name) method(string) level(real) or_ci(real)
	
	tempname r s se or z var
	
	local nstr = colsof(`str')+1		//+1: OVERALL
	local len = `nstr'+4
	matrix `r' = J(`len',7,.)
	
	local n_mh 0
	local d_mh 0
	local pr 0
	local psqr 0
	local qs 0
	local rn 0
	local sn 0
	local n_iov 0
	local d_iov 0
	local d_is 0
	local n_seis 0
	local n_es 0
	local n_sees 0
	foreach i of numlist 1/`nstr' {
		if (`i'<`nstr') local val = `str'[1,`i']
		else local val = .
		mata: get_submatrix("`d'", "`s'", `val')
		
		*OR + CI for each stratum
		is_dec, data(`s')
		local ldec = r(dec)
		get_or, data(`s') level(`level') st("cc") dec(`ldec')
		matrix `r'[`i',1] = r(or)
		matrix `r'[`i',2] = r(se)
		if (`or_ci'==0 & !`ldec') {
			matrix `r'[`i',3] = r(lbc)
			matrix `r'[`i',4] = r(ubc)
			matrix `r'[`i',7] = 0			//Exact OR CI
		}
		if (`or_ci'==1 & !`ldec') {
			matrix `r'[`i',3] = r(lbcorn)	
			matrix `r'[`i',4] = r(ubcorn)
			matrix `r'[`i',7] = 1			//Cornfield OR CI
		}
		if (`or_ci'==2 | `ldec') {
			matrix `r'[`i',3] = r(lbw)
			matrix `r'[`i',4] = r(ubw)
			matrix `r'[`i',7] = 2			//Woolf OR CI			
		}
		
		if (`i'<`nstr') {
			local a1 = `s'[1,2]
			local a0 = `s'[1,1]
			local b1 = `s'[2,2]
			local b0 = `s'[2,1]
			local n1 = `s'[3,2]
			local n0 = `s'[3,1]
			local n = `s'[3,3]

			*Weights
			if ("`method'"=="mh") matrix `r'[`i',5] = `a0'*`b1'/`n'
			if ("`method'"=="iv") matrix `r'[`i',5] = 1/r(se)^2
			if ("`method'"=="is") matrix `r'[`i',5] = 1/`b1'
			if ("`method'"=="es") matrix `r'[`i',5] = 1/`b0'
			
			*Estimation summatories
			*Mantel-Haenszel
			local n_mh = `n_mh' + (`a1'*`b0')/`n'
			local d_mh = `d_mh' + (`a0'*`b1')/`n'
			local pi = (`a1'+`b0')/`n'
			local qi = (`a0'+`b1')/`n'
			local ri = (`a1'*`b0')/`n'
			local si = (`a0'*`b1')/`n'
			local pr = `pr' + `pi'*`ri'
			local psqr = `psqr' + (`pi'*`si' + `qi'*`ri')
			local qs = `qs' + `qi'*`si'
			local rn = `rn' + `ri'
			local sn = `sn' + `si'
			*Inverse of Variance
			scalar `var' = r(se)^2
			local n_iov = `n_iov' + ln(r(or))/`var'
			local d_iov = `d_iov' + 1/`var'
			*Internal standardization
			local d_is = `d_is' + (`b1'*`a0')/`b0'
			local n_seis = `n_seis' + `a1'^2*`var'
			*External standardization
			local n_es = `n_es' + (`b0'*`a1')/`b1'
			local n_sees = `n_sees' + `var'*((`b0'*`a1')/`b1')^2
		}
	}
	
	scalar `z' = invnormal((`level'+100)/200)

	mata: get_submatrix("`d'", "`s'", .)		//Get OVERALL submatrix
	foreach i of numlist 1/4 {
		if (`i'==1) {
			*Mantel-Haenszel OR
			scalar `or' = `n_mh'/`d_mh'
			scalar `se' = sqrt(`pr'/(2*(`rn'^2)) + `psqr'/(2*`rn'*`sn') + `qs'/(2*(`sn'^2)))
		}
		if (`i'==2) {
			*Inverse of Variance RR
			scalar `or' = exp(`n_iov'/`d_iov')
			scalar `se' = 1/sqrt(`d_iov')
		}
		if (`i'==3) {
			*Internal standardization
			local a1o = `s'[1,2]
			scalar `or' = `a1o'/`d_is'
			scalar `se' = sqrt(`n_seis'/`a1o'^2)
		}
		if (`i'==4) {
			*External standardization
			local a0o = `s'[1,1]
			scalar `or' = `n_es'/`a0o'
			scalar `se' = sqrt(`n_sees'/`n_es'^2)
		}
		matrix `r'[`nstr'+`i',1] = `or'
		matrix `r'[`nstr'+`i',2] = `se'
		matrix `r'[`nstr'+`i',3] = `or'*exp(-`z'*`se')
		matrix `r'[`nstr'+`i',4] = `or'*exp(`z'*`se')
		matrix `r'[`nstr'+`i',5] = 2*(1 - normal(abs(ln(`or')/`se')))		//Sig.
		matrix `r'[`nstr'+`i',6] = abs((`or' - `r'[`nstr',1])/`or')*100		//Change
	}

	
	return matrix results = `r'
end

program define get_scoi_results, rclass
	syntax [anything], d(name) str(name) method(string) level(real)
	
	tempname r s se ir z var
	
	local nstr = colsof(`str')+1		//+1: OVERALL
	local len = `nstr'+4
	matrix `r' = J(`len',6,.)
	
	local n_mh = 0
	local d_mh = 0
	local n_semh = 0
	local n_iov = 0
	local d_iov = 0
	local d_is = 0
	local n_seis = 0
	local n_es = 0
	local n_sees = 0
	foreach i of numlist 1/`nstr' {
		if (`i'<`nstr') local val = `str'[1,`i']
		else local val = .
		mata: get_submatrix("`d'", "`s'", `val')
		
		*OR + CI for each stratum
		get_ir, data(`s') level(`level')
		matrix `r'[`i',1] = r(ir)
		matrix `r'[`i',2] = r(se)
		matrix `r'[`i',3] = r(lb)
		matrix `r'[`i',4] = r(ub)
		
		if (`i'<`nstr') {
			local a1 = `s'[1,2]
			local a0 = `s'[1,1]
			local m1 = `s'[1,3]
			local t1 = `s'[2,2]
			local t0 = `s'[2,1]
			local t = `s'[2,3]

			*Weights
			if ("`method'"=="mh") matrix `r'[`i',5] = `a0'*`t1'/`t'
			if ("`method'"=="iv") matrix `r'[`i',5] = 1/r(se)^2
			if ("`method'"=="is") matrix `r'[`i',5] = 1/`t0'
			if ("`method'"=="es") matrix `r'[`i',5] = 1/`t1'

			*Estimation summatories
			*Mantel-Haenszel
			local n_mh = `n_mh' + (`a1'*`t0')/`t'
			local d_mh = `d_mh' + (`a0'*`t1')/`t'
			local n_semh = `n_semh' + ((`m1'*`t1'*`t0')/`t'^2)
			*Inverse of Variance
			scalar `var' = r(se)^2
			local n_iov = `n_iov' + ln(r(ir))/`var'
			local d_iov = `d_iov' + 1/`var'
			*Internal standardization
			local d_is = `d_is' + (`t1'*`a0')/`t0'
			local n_seis = `n_seis' + `t1'^2*`a0'/`t0'^2
			*External standardization
			local n_es = `n_es' + (`t0'*`a1')/`t1'
			local n_sees = `n_sees' + `t0'^2*`a1'/`t1'^2
		}
	}
	
	scalar `z' = invnormal((`level'+100)/200)

	mata: get_submatrix("`d'", "`s'", .)		//Get OVERALL submatrix
	foreach i of numlist 1/4 {
		if (`i'==1) {
			*Mantel-Haenszel RR
			scalar `ir' = `n_mh'/`d_mh'
			scalar `se' = sqrt(`n_semh'/(`n_mh'*`d_mh'))
		}
		if (`i'==2) {
			*Inverse of Variance RR
			scalar `ir' = exp(`n_iov'/`d_iov')
			scalar `se' = 1/sqrt(`d_iov')
		}
		if (`i'==3) {
			*Internal standardization
			local a1o = `s'[1,2]
			scalar `ir' = `a1o'/`d_is'
			scalar `se' = sqrt(1/`a1o' + `n_seis'/`d_is'^2)
		}
		if (`i'==4) {
			*External standardization
			local a0o = `s'[1,1]
			scalar `ir' = `n_es'/`a0o'
			scalar `se' = sqrt(`n_sees'/`n_es'^2 + 1/`a0o')
		}
		matrix `r'[`nstr'+`i',1] = `ir'
		matrix `r'[`nstr'+`i',2] = `se'
		matrix `r'[`nstr'+`i',3] = `ir'*exp(-`z'*`se')
		matrix `r'[`nstr'+`i',4] = `ir'*exp(`z'*`se')
		matrix `r'[`nstr'+`i',5] = 2*(1 - normal(abs(ln(`ir')/`se')))		//Sig.
		matrix `r'[`nstr'+`i',6] = abs((`ir' - `r'[`nstr',1])/`ir')*100		//Change
	}

	return matrix results = `r'
end

program define get_cor_results, rclass
	syntax [anything], d(name) st(string) level(real) nnt(integer) pe(real) dec(integer) detail(integer)

	tempname res data serd p rdp se lb ub rd r1 r0 serd a1 a0 n1 n0 n z rr serr m1
	tempname afe lb_afe ub_afe afp lb_afp ub_afp pfe lb_pfe ub_pfe pfp lb_pfp ub_pfp se_afp 
	matrix define `res' = J(10,4,.)
	
	matrix colnames `res' = statistic lb ub
	matrix rownames `res' = rd_newcombe rd_wald rr or_cornfield or_woolf nnt pe RDp Fe Fp
	
	*Risk/Prevalence Difference
	get_rd, data(`d') level(`level')
	matrix `res'[1,1] = r(rd)
	matrix `res'[1,2] = r(lbn)
	matrix `res'[1,3] = r(ubn)
	matrix `res'[2,2] = r(lbw)
	matrix `res'[2,3] = r(ubw)
	matrix `res'[2,4] = r(se)
	scalar `serd' = r(se)
		
	*Risk/Prevalence Ratio
	get_rr, data(`d') level(`level')
	matrix `res'[3,1] = r(rr)
	matrix `res'[3,2] = r(lb)
	matrix `res'[3,3] = r(ub)
	matrix `res'[3,4] = r(se)
	scalar `serr' = r(se)

	*Odds ratio
	get_or, data(`d') dec(`dec') st(`st') level(`level')
	matrix `res'[4,1] = r(or)
	matrix `res'[4,2] = r(lbc)
	matrix `res'[4,3] = r(ubc)
	matrix `res'[5,2] = r(lbw)
	matrix `res'[5,3] = r(ubw)
	matrix `res'[5,4] = r(se)

	*Number Needed to Treat
	if (("`st'"=="ex" | "`st'"=="co") & `nnt'>=0) {
		matrix `res'[6,1] = 1/`res'[1,1]
		matrix `res'[6,2] = 1/`res'[1,3]
		matrix `res'[6,3] = 1/`res'[1,2]
	}
	
	*Detail results (Cuadro 2-2 pg.66 "Estudios de cohortes" (2015) Delgado M, Llorca J, Doménech JM 
	if (`detail'==1) {
		scalar `a1' = `d'[1,2]
		scalar `n1' = `d'[3,2]
		scalar `m1' = `d'[1,3]
		scalar `a0' = `d'[1,1]
		scalar `n0' = `d'[3,1]
		scalar `n' = `d'[3,3]
		scalar `z' = invnormal((`level'+100)/200)
		scalar `rr' = `res'[3,1]
		
		*Proportion of exposed in the population
		if (`pe'==0) scalar `p' = `n1'/`n'			//Default: Proportion of Exposed, n1/n
		else scalar `p' = `pe'						//External Proportion of Exposed
		matrix `res'[7,1] = `p'

		*Risk difference in population (RDp)
		scalar `rd' = `res'[1,1]
		scalar `rdp' = `p' * `rd'
		if (`pe'==0) {
			scalar `r1' = `a1'/`n1'
			scalar `r0' = `a0'/`n0'
			scalar `se' = sqrt(`rd'^2*`n1'* `n0'/`n' + `n1'^2*`serd'^2)/`n'
			scalar `lb' = `rdp' - `z'*`se'
			scalar `ub' = `rdp' + `z'*`se'
		}
		else {
			scalar `lb' = `pe'*`res'[2,2]
			scalar `ub' = `pe'*`res'[2,3]
			scalar `se' = .
		}
		matrix `res'[8,1] = `rdp'
		matrix `res'[8,2] = `lb'
		matrix `res'[8,3] = `ub'
		matrix `res'[8,4] = `se'

		*Attributable fraction in exposed (AFe)
		scalar `lb' = `res'[3,2]
		scalar `ub' = `res'[3,3]
		scalar `afe' = 1-1/`rr'			//1-1/rr
		scalar `lb_afe' = 1-1/`lb'		//1-1/rrlb
		scalar `ub_afe' = 1-1/`ub'		//1-1/rrub

		*Preventable fraction in exposed (PFe)
		scalar `pfe' = 1-`rr'			//1-rr
		scalar `lb_pfe' = 1-`ub'		//1-rrub
		scalar `ub_pfe' = 1-`lb'		//1-rrlb

		*Attributable fraction in population (AFp)
		scalar `afp' = (`p'*(`rr'-1))/(1+`p'*(`rr'-1))
		if (`pe'==0) {
			scalar `se_afp' = (`afp'/(1-`afp'))*sqrt(`serr'^2/(`rr'-1)^2 + 2/(`a1'*(`rr'-1)) + `a0'/(`a1'*`m1'))
			scalar `lb_afp' = 1 - (1-`afp')*exp(`z'*`se_afp')
			scalar `ub_afp' = 1 - (1-`afp')*exp(-`z'*`se_afp')
		}
		else {
			scalar `lb_afp' = `p'*(`lb'-1)/(1+`p'*(`lb'-1))
			scalar `ub_afp' = `p'*(`ub'-1)/(1+`p'*(`ub'-1))
			scalar `se_afp' = .
		}

		*Preventable fraction in population (PFp)
		scalar `pfp' = 1-1/(1-`afp')
		scalar `lb_pfp' = 1-1/(1-`lb_afp')
		scalar `ub_pfp' = 1-1/(1-`ub_afp')
		
		if (`a1'==0) {
			matrix `res'[9,4] = 2 			//Prev. type
			matrix `res'[9,1] = `pfe'
			matrix `res'[10,1] = `pfp'
		}
		else if (`a0'==0) {
			matrix `res'[9,4] = 1 			//Attr. type
			matrix `res'[9,1] = `afe'
			matrix `res'[10,1] = `afp'
		}
		else if (`rr'<1) {
			matrix `res'[9,4] = 2 			//Prev. type
			matrix `res'[9,1] = `pfe'
			matrix `res'[9,2] = `lb_pfe'
			matrix `res'[9,3] = `ub_pfe'
			matrix `res'[10,1] = `pfp'
			matrix `res'[10,2] = `lb_pfp'
			matrix `res'[10,3] = `ub_pfp'
		}
		else if (`rr'>=1) {
			matrix `res'[9,4] = 1 			//Attr. type
			matrix `res'[9,1] = `afe'
			matrix `res'[9,2] = `lb_afe'
			matrix `res'[9,3] = `ub_afe'
			matrix `res'[10,1] = `afp'
			matrix `res'[10,2] = `lb_afp'
			matrix `res'[10,3] = `ub_afp'
			matrix `res'[10,4] = `se_afp'
		}

	}
	
	return matrix results = `res'
end

program define get_cc_results, rclass
	syntax [anything], d(name) st(string) level(real) r(real) pe(real) dec(integer) detail(integer) rare(integer)
	
	tempname res a1 a0 m1 b1 b0 m0 re pext rr rd or z
	tempname afe lb_afe ub_afe pfe lb_pfe ub_pfe afp lb_afp ub_afp pfp lb_pfp ub_pfp se_afp
	
	matrix define `res' = J(9,4,.)
	
	matrix colnames `res' = statistic lb ub
	matrix rownames `res' = re rr rd or or_woolf RDp Fe Fp or_corn

	scalar `a0' = `d'[1,1]
	scalar `a1' = `d'[1,2]
	scalar `m1' = `d'[1,3]
	scalar `b0' = `d'[2,1]
	scalar `b1' = `d'[2,2]
	scalar `m0' = `d'[2,3]
	
	if (`r'!=0 | `pe'!=0) {
		*Population risk
		get_rp_ext, data(`d') r(`r') pe(`pe')
		scalar `re' = r(re)
		scalar `pext' = r(pext)
		matrix `res'[1,1] = `re'
		
		*Risk Ratio (RR)
		scalar `rr' = (`a1'/`a0')/(`pext'/(1-`pext'))
		matrix `res'[2,1] = `rr'
		*Risk difference (RD)
		scalar `rd' = `re'*(`rr'-1)/(`pext'*(`rr'-1)+1)
		matrix `res'[3,1] = `rd'
		*Risk difference in the population (RDp)
		matrix `res'[6,1] = `pext'*`rd'
	}
	
	*Odds ratio
	get_or, data(`d') dec(`dec') st(`st') level(`level')
	scalar `or' = r(or)
	matrix `res'[4,1] = r(or)
	matrix `res'[4,2] = r(lbc)
	matrix `res'[4,3] = r(ubc)
	matrix `res'[5,2] = r(lbw)
	matrix `res'[5,3] = r(ubw)
	matrix `res'[5,4] = r(se)
	matrix `res'[9,2] = r(lbcorn)
	matrix `res'[9,3] = r(ubcorn)
	
	*Detail results (Cuadro 2-1 pg.68 "Estudios de casos y controles" (2015) Delgado M, Llorca J, Doménech JM 
	if (`detail'==1) {
		scalar `z' = invnormal((`level'+100)/200)
	
		*Attributable/Preventable fraction in exposed (AFe/PFe)
		if (`rare'==1) {
			*Rare disease
			scalar `afe' = (`or'-1)/`or'
			scalar `pfe' = (1-`or')
			if (`dec'==0) {
				*If possible compute Exact CI
				scalar `lb_afe' = (r(lbc)-1)/r(lbc)
				scalar `ub_afe' = (r(ubc)-1)/r(ubc)				
				scalar `lb_pfe' = (1-r(ubc))
				scalar `ub_pfe' = (1-r(lbc))
			}
			else {
				*With decimal values, use Wald CI (Exact not available)
				scalar `lb_afe' = (r(lbw)-1)/r(lbw)
				scalar `ub_afe' = (r(ubw)-1)/r(ubw)	
				scalar `lb_pfe' = (1-r(ubw))
				scalar `ub_pfe' = (1-r(lbw))
			}
		}
		else {
			scalar `afe' = (`rr'-1)/`rr'
			scalar `pfe' = (1-`rr')
			scalar `lb_afe' = .
			scalar `ub_afe' = .
			scalar `lb_pfe' = .
			scalar `ub_pfe' = .
		}
		
		*Attributable fraction in population (AFp)
		scalar `afp' = (`a1'/`m1')*`afe'
		if (`rare'==1) scalar `re' = 0
		scalar `se_afp' = (1-`afp')^2*(1-`re')*((`b0'*`m1')/(`a0'*`m0'))*sqrt(`a1'/(`a0'*`m1')+`b1'/(`b0'*`m0'))
		scalar `lb_afp' =  1/(1+((1-`afp')/`afp')*exp(`z'*`se_afp'/((1-`afp')*`afp')))
		scalar `ub_afp' =  1/(1+((1-`afp')/`afp')*exp(-`z'*`se_afp'/((1-`afp')*`afp')))
		
		*Preventable fraction in population (PFp)
		if (`rare'==1) scalar `pext' = `b1'/`m0'
		scalar `pfp' = `pext'*`pfe'
		scalar `lb_pfp' =  1-(1/(1-`lb_afp'))
		scalar `ub_pfp' =  1-(1/(1-`ub_afp'))
		
		if (`a0'==0 | `b1'==0) {
			matrix `res'[7,4] = 1		//Attr. type
			matrix `res'[7,1] = `afe'
			matrix `res'[8,1] = `afp'
		}
		else if (`or'>1) {
			matrix `res'[7,4] = 1		//Attr. type
			matrix `res'[7,1] = `afe'
			matrix `res'[7,2] = `lb_afe'
			matrix `res'[7,3] = `ub_afe'
			matrix `res'[8,1] = `afp'
			matrix `res'[8,2] = `lb_afp'
			matrix `res'[8,3] = `ub_afp'
			matrix `res'[8,4] = `se_afp'
		}
		else if (`or'<=1) {
			matrix `res'[7,4] = 2		//Prev. type
			matrix `res'[7,1] = `pfe'
			matrix `res'[7,2] = `lb_pfe'
			matrix `res'[7,3] = `ub_pfe'
			matrix `res'[8,1] = `pfp'
			matrix `res'[8,2] = `lb_pfp'
			matrix `res'[8,3] = `ub_pfp'
		}
	}
	return matrix results = `res'
end

program define get_coi_results, rclass
	syntax [anything], d(name) level(real) pe(real) detail(integer)
	
	tempname res z id seid ir seir idp p lb_idp ub_idp se_idp
	tempname afp lb_afp ub_afp afe lb_afe ub_afe pfp lb_pfp ub_pfp pfe lb_pfe ub_pfe se_afp
	
	matrix define `res' = J(7,4,.)
	
	matrix colnames `res' = statistic lb ub
	matrix rownames `res' = id ir_exact ir_wald idp pe fe fp

	local a0 = `d'[1,1]
	local a1 = `d'[1,2]
	local m1 = `d'[1,3]
	local t0 = `d'[2,1]
	local t1 = `d'[2,2]
	local t = `d'[2,3]
	scalar `z' = invnormal((`level'+100)/200)
	
	*Results (Cuadro 2-3 pg.82 "Estudios de cohortes" (2015) Delgado M, Llorca J, Doménech JM
	*Incidence rate Difference (ID)
	scalar `id' = (`a1'/`t1') - (`a0'/`t0')
	scalar `seid' = sqrt(`a1'/`t1'^2 + `a0'/`t0'^2)
	matrix `res'[1,1] = `id'
	matrix `res'[1,2] = `id' - `z'*`seid'
	matrix `res'[1,3] = `id' + `z'*`seid'
	matrix `res'[1,4] = `seid'

	*Incidence rate Ratio (IR)
	get_ir, data(`d') level(`level')
	scalar `ir' = r(ir)
	scalar `seir' = r(se)
	matrix `res'[2,1] = r(ir)
	matrix `res'[2,2] = r(lbe)
	matrix `res'[2,3] = r(ube)
	matrix `res'[3,2] = r(lb)
	matrix `res'[3,3] = r(ub)
	matrix `res'[3,4] = `seir'
	
	if (`detail'==1) {
		*Attributable Fraction Exposed (AFe)
		scalar `afe' = (`ir'-1)/`ir'
		scalar `lb_afe' = (r(lbe)-1)/r(lbe)
		scalar `ub_afe' = (r(ube)-1)/r(ube)
		*Preventable Fraction Exposed (PFe)
		scalar `pfe' = 1-`ir'
		scalar `lb_pfe' = 1-r(lbe)
		scalar `ub_pfe' = 1-r(ube)
		
		if (`pe'>0) {
			*external pe
			scalar `p' = `pe'
			local pest = 0
			*Incidence rate diff. in the population
			scalar `idp' = `pe'*`id'
			scalar `lb_idp' = `pe'*`res'[1,2]
			scalar `ub_idp' = `pe'*`res'[1,3]
			scalar `se_idp' = .
			*Attributable Fraction Population (AFp)
			scalar `afp' = (`pe'*(`ir'-1))/(`pe'*(`ir'-1)+1)
			scalar `lb_afp' = (`pe'*(r(lbe)-1))/(`pe'*(r(lbe)-1)+1)
			scalar `ub_afp' = (`pe'*(r(ube)-1))/(`pe'*(r(ube)-1)+1)
			scalar `se_afp' = .
		}
		else {
			*estimated pe: the sample represents the population
			scalar `p' = (`t1'/`t')
			local pest = 1
			*Incidence rate diff. in the population
			scalar `idp' = (`m1'/`t') - (`a0'/`t0')
			scalar `se_idp' = sqrt((`id'^2*`t1'*`t0')/`t' + `t1'^2*`seid'^2)/`t'
			scalar `lb_idp' = `idp' - `z'*`se_idp'
			scalar `ub_idp' = `idp' + `z'*`se_idp'
			*Attributable Fraction Population (AFp)
			scalar `afp' = `afe'*`a1'/`m1'
			scalar `se_afp' = (`afp'/(1-`afp'))*sqrt((`seir'/(`ir'-1))^2 + 2/(`a1'*(`ir'-1)) + `a0'/(`a1'*`m1'))
			scalar `lb_afp' = 1 - (1-`afp')*exp(`z'*`se_afp')
			scalar `ub_afp' = 1 - (1-`afp')*exp(-`z'*`se_afp')
		}
		*Preventable Fraction Population (PFp)
		scalar `pfp' = `pfe'*`t1'/`t'
		scalar `lb_pfp' = 1 - 1/(1-`lb_afp')
		scalar `ub_pfp' = 1 - 1/(1-`ub_afp')
		
		matrix `res'[6,1] = `idp'
		matrix `res'[6,2] = `lb_idp'
		matrix `res'[6,3] = `ub_idp'
		matrix `res'[6,4] = `se_idp'
		matrix `res'[5,1] = `p'
		matrix `res'[5,2] = `pest'
		if (`afe'>=0) {
			matrix `res'[4,4] = 1			//Attr.		
			matrix `res'[4,1] = `afe'
			matrix `res'[4,2] = `lb_afe'
			matrix `res'[4,3] = `ub_afe'
			matrix `res'[7,1] = `afp'
			matrix `res'[7,2] = `lb_afp'
			matrix `res'[7,3] = `ub_afp'
			matrix `res'[7,4] = `se_afp'
		}
		if (`pfe'>0) {
			matrix `res'[4,4] = 2			//Prev.
			matrix `res'[4,1] = `pfe'
			matrix `res'[4,2] = `lb_pfe'
			matrix `res'[4,3] = `ub_pfe'
			matrix `res'[7,1] = `pfp'
			matrix `res'[7,2] = `lb_pfp'
			matrix `res'[7,3] = `ub_pfp'
		}
	}
	
	return matrix results = `res'
end

program define get_rd, rclass
	syntax [anything], data(name) level(real)

	tempname a1 n1 a0 n0 z f0 f1 w0 w1 l0 l1 u0 u1 d e se r1 r0 rd lbn ubn lbw ubw

	scalar `a1' = `data'[1,2]
	scalar `n1' = `data'[3,2]
	scalar `a0' = `data'[1,1]
	scalar `n0' = `data'[3,1]

	scalar `z' = invnormal((`level'+100)/200)
	
	*Risk difference and CI
	scalar `r1' = `a1'/`n1'
	scalar `r0' = `a0'/`n0'
    scalar `rd' = `r1' - `r0'
	
	*Newcombe-Wilson CI
	scalar `f0' = `a0'^2 /(`n0'^2 + `n0'*`z'^2)
	scalar `f1' = `a1'^2 /(`n1'^2 + `n1'*`z'^2)
	scalar `w0' = (2*`a0' + `z'^2)/(2*(`n0' + `z'^2))
	scalar `w1' = (2*`a1' + `z'^2)/(2*(`n1' + `z'^2))
	scalar `l0' = `w0' - sqrt(`w0'^2 - `f0')
	scalar `l1' = `w1' - sqrt(`w1'^2 - `f1')
	scalar `u0' = `w0' + sqrt(`w0'^2 - `f0')
	scalar `u1' = `w1' + sqrt(`w1'^2 - `f1')
	scalar `d' = sqrt((`r1'-`l1')^2 + (`u0'-`r0')^2)
	scalar `e' = sqrt((`u1'-`r1')^2 + (`r0'-`l0')^2)
	scalar `lbn' = `rd' - `d'
	scalar `ubn' = `rd' + `e'
		
	*Wald CI
	scalar `se' = sqrt(`r1'*(1-`r1')/`n1' + `r0'*(1-`r0')/`n0')
	scalar `lbw' = `rd' - `se'*`z'
	scalar `ubw' = `rd' + `se'*`z'
	
	return scalar rd = `rd'
	return scalar se = `se'
	return scalar lbn = `lbn'
	return scalar ubn = `ubn'
	return scalar lbw = `lbw'
	return scalar ubw = `ubw'
end

program define get_rr, rclass
	syntax [anything], data(name) level(real)
	
	tempname a0 n0 a1 n1 se z rr ub lb
	
	scalar `a1' = `data'[1,2]
	scalar `n1' = `data'[3,2]
	scalar `a0' = `data'[1,1]
	scalar `n0' = `data'[3,1]

	scalar `z' = invnormal((`level'+100)/200)
	
	*Risk Ratio and CI.
	scalar `rr'=(`a1'/`n1')/(`a0'/`n0')
    scalar `se' = sqrt((1/`a0')-(1/`n0')+(1/`a1')-(1/`n1'))
    scalar `ub' = `rr'*exp(`z'*`se')
	scalar `lb' = `rr'*exp(-`z'*`se')
	
	return scalar rr = `rr'
	return scalar se = `se'
	return scalar lb = `lb'
	return scalar ub = `ub'
end

program define get_or, rclass
	syntax [anything], data(name) level(real) st(string) dec(integer)
		
	tempname se z or lbw ubw lbc ubc lbcorn ubcorn

	local a1 = `data'[1,2]
	local b1 = `data'[2,2]
	local a0 = `data'[1,1]
	local b0 = `data'[2,1]
		
	scalar `z' = invnormal((`level'+100)/200)
	
	*Odds Ratio and CI (Wald)
	scalar `or'=(`a1'/`b1')/(`a0'/`b0')
    scalar `se' = sqrt((1/`a0')+(1/`b0')+(1/`a1')+(1/`b1'))
    scalar `ubw' = `or'*exp(`z'*`se')
	scalar `lbw' = `or'*exp(-`z'*`se')

	return scalar or = `or'
	return scalar se = `se'
	return scalar lbw = `lbw'
	return scalar ubw = `ubw'

	*Odds Ratio CI Exact/Cornfield (if not decimal parameters)
	scalar `lbc' = .
	scalar `ubc' = .
	scalar `lbcorn' = .
	scalar `ubcorn' = .
	if (`dec'==0) {	
		preserve
		if ("`st'"=="cc") {
			qui cci `a1' `a0' `b1' `b0'	//OR exact CI
			scalar `lbc' = r(lb_or)
			scalar `ubc' = r(ub_or)
			restore
			preserve
			qui cci `a1' `a0' `b1' `b0', cornfield	//OR cornfield CI
			scalar `lbcorn' = r(lb_or)
			scalar `ubcorn' = r(ub_or)			
		}
		else {
			quietly csi `a1' `a0' `b1' `b0', or		//OR cornfield CI
			scalar `lbc' = r(lb_or)
			scalar `ubc' = r(ub_or)
		}
		restore
		
	}
	return scalar lbc = `lbc'
	return scalar ubc = `ubc'
	return scalar lbcorn = `lbcorn'
	return scalar ubcorn = `ubcorn'

end

program define get_ir, rclass
	syntax [anything], data(name) level(real)
		
	tempname se z ir

	local a1 = `data'[1,2]
	local t1 = `data'[2,2]
	local a0 = `data'[1,1]
	local t0 = `data'[2,1]
		
	scalar `z' = invnormal((`level'+100)/200)

	*Incidence rate Ratio (IR)
	scalar `ir' = (`a1'/`t1') / (`a0'/`t0')
	scalar `se' = sqrt(1/`a1'+1/`a0')
	return scalar ir = `ir'
	return scalar se = `se'
	return scalar lb = `ir'*exp(-`z'*`se')
	return scalar ub = `ir'*exp(`z'*`se')
	qui iri `a1' `a0' `t1' `t0'				//Compute exact IR CI using Stata iri command
	return scalar lbe = r(lb_irr)
	return scalar ube = r(ub_irr)
end

program define get_risk_odds, rclass
	syntax [anything], data(name) r(real) pe(real)

	tempname a1 a0 m1 b1 b0 m0 re pext odds o0 o1 r0 r1

	get_rp_ext, data(`data') r(`r') pe(`pe')	
	scalar `re' = r(re)
	scalar `pext' = r(pext)
	
	scalar `a1' = `data'[1,2]
	scalar `a0' = `data'[1,1]
	scalar `m1' = `data'[1,3]	
	scalar `b1' = `data'[2,2]
	scalar `b0' = `data'[2,1]
	scalar `m0' = `data'[2,3]

	*Risk and Odds
	scalar `odds'= `re'/(1-`re') 
	scalar `o0'= `odds'*(`a0'/`m1')/(`b0'/`m0')
	scalar `o1'= `odds'*(`a1'/`m1')/(`b1'/`m0')
	scalar `r0'= `o0'/(1+`o0')
	scalar `r1'= `o1'/(1+`o1')
	
	return scalar pext = `pext'
	return scalar re = `re'
	return scalar odds = `odds'
	return scalar o0 = `o0'
	return scalar o1 = `o1'
	return scalar r0 = `r0'
	return scalar r1 = `r1'
	
	if (`pe'!=0) return local text = "external"
	else return local text = "estimated"
end

program define get_rp_ext, rclass
	syntax [anything], data(name) r(real) pe(real)

	tempname a1 a0 m1 b1 b0 m0 re pext

	scalar `a1' = `data'[1,2]
	scalar `a0' = `data'[1,1]
	scalar `m1' = `data'[1,3]	
	scalar `b1' = `data'[2,2]
	scalar `b0' = `data'[2,1]
	scalar `m0' = `data'[2,3]
	
	if (`r'!=0) {
		scalar `re' = `r'
		scalar `pext' = (`a1'/`m1')*`re' + (`b1'/`m0')*(1-`re')
	}
	if (`pe'!=0) {
		scalar `pext' = `pe'
		scalar `re' = (`pext'-(`b1'/`m0'))/((`a1'/`m1')-(`b1'/`m0'))
	}	
	return scalar pext = `pext'
	return scalar re = `re'
end

program define get_chi2_str, rclass
	syntax [anything], d(name) type(string) str(name)
	
	tempname r s chi
	
	local nstr = colsof(`str')+1		//+1: OVERALL
	local len = `nstr'+1				//POOLED
	matrix `r' = J(`len',5,.)
	
	*Association Chi-square for each stratum and POOLED chi2 summatories
	local a1 = 0
	local ex = 0
	local v = 0
	foreach i of numlist 1/`nstr' {
		if (`i'<`nstr') local val = `str'[1,`i']
		else local val = .
		mata: get_submatrix("`d'", "`s'", `val')
		
		if ("`type'"=="freq") get_chi2_fisher, data(`s') type(2) st("co") dec(1)
		if ("`type'"=="pt") get_chi2_pt, data(`s')
		matrix `chi' = r(chi2)
		matrix `r'[`i',1] = `chi'[1,1]		//chi2
		matrix `r'[`i',2] = `chi'[1,2]		//p
		matrix `r'[`i',3] = `chi'[2,1]		//chi2 corrected
		matrix `r'[`i',4] = `chi'[2,2]		//p corrected
		if ("`type'"=="freq") matrix `r'[`i',5] = `chi'[3,2]		//warning
		if ("`type'"=="pt") matrix `r'[`i',5] = `chi'[1,3]		//warning
		
		*POOLED chi2 summatories
		if (`i'<`nstr') {
			local a1 = `a1' + `s'[1,2]
			local m1 = `s'[1,3]
			if ("`type'"=="freq") {
				local n1 = `s'[3,2]
				local n0 = `s'[3,1]
				local m0 = `s'[2,3]
				local n = `s'[3,3]
				local ex = `ex'	+ `n1'*`m1'/`n'
				local v = `v' + (`n1'*`n0'*`m1'*`m0')/((`n')^2*(`n'-1))
			}
			if ("`type'"=="pt") {
				local t1 = `s'[2,2]
				local t0 = `s'[2,1]
				local t = `s'[2,3]
				local ex = `ex'	+ `t1'*`m1'/`t'
				local v = `v' + (`t1'*`t0'*`m1')/(`t')^2
			}
		}
	}

	
	*POOLED chi2
	local chi2 = (`a1'-`ex')^2/`v'
	local p = chi2tail(1,`chi2')
	matrix `r'[`nstr'+1,1] = `chi2'
	matrix `r'[`nstr'+1,2] = `p'
	*Corrected
	local chi2 = (abs(`a1'-`ex')-0.5)^2/`v'
	if (abs(`a1'-`ex')<0.5) local chi2 = 0
	local p = chi2tail(1,`chi2')
	matrix `r'[`nstr'+1,3] = `chi2'
	matrix `r'[`nstr'+1,4] = `p'
	
	return matrix chi2 = `r'
end

program define get_homogeneity, rclass
	syntax [anything], d(name) r(name) type(string) st(string) str(name) method(string)
	
	tempname s
	
	local nstr = colsof(`str')
	
	local chi2W = 0
	local chi2BD = 0
	if ("`method'"=="mh") local ref = `r'[`nstr'+2,1]
	if ("`method'"=="iv") local ref = `r'[`nstr'+3,1]
	if ("`method'"=="is") local ref = `r'[`nstr'+4,1]
	if ("`method'"=="es") local ref = `r'[`nstr'+5,1]
	foreach i of numlist 1/`nstr' {
		*Homogeneity Wald
		local ratio = `r'[`i',1]
		local se = `r'[`i',2]
		local chi2W = `chi2W' + (ln(`ratio') - ln(`ref'))^2/(`se'^2)

		*Homogeneity Breslow & Day (only for case-control data)
		if ("`type'"=="freq" & "`st'"=="cc") {
			local val = `str'[1,`i']
			mata: get_submatrix("`d'", "`s'", `val')
			local a1 = `s'[1,2]
			local n1 = `s'[3,2]
			local n0 = `s'[3,1]
			local m1 = `s'[1,3]

			//Use formula 4:11 (Breslow & Day, pag 130) to find Ai using the previously computed M-H estimation of OR
			local stMH = `r'[`nstr'+2,1]
			*Compute the terms of the quadratic equation of Ai (Ai=x, given ax2 + bx + c = 0)
			local a = (1 - `stMH')
			local b = (`n0' + `stMH'*`n1' + `m1'*(`stMH' - 1))
			local c = -`stMH'*`n1'*`m1'
			//To find Ai, solve the quadratic equation: x = (-b +/- SQRT(b^2 - 4ac))/2a.
			local Ap = (-`b' + sqrt((`b'^2)-(4*`a'*`c')))/(2*`a')		//Root using the +
			local Bp = `n1' - `Ap'							//Find the A,B,C,D quantities of 4:10 (Breslow & Day, pag 130) for Ai+
			local Cp = `m1' - `Ap'
			local Dp = `n0' - `m1' + `Ap'
			local Am = (-`b' - sqrt((`b'^2)-(4*`a'*`c')))/(2*`a')		//Root using the -
			local Bm = `n1' - `Am'							//Find the A,B,C,D quantities of 4:10 (Breslow & Day, pag 130) for Ai-
			local Cm = `m1' - `Am'
			local Dm = `n0' - `m1' + `Am'
			//Only one root Ai+, Ai- is correct: A,B,C,D must be all positive
			//To compute the Variance use the formula 4:13 (Breslow & Day, pag 130) with the correct A,B,C,D
			if (`Ap'>0 & `Bp'>0 & `Cp'>0 & `Dp'>0) {
				local Ai = `Ap'
				local var = 1/(1/`Ap' + 1/`Bp' + 1/`Cp' + 1/`Dp')
			}
			if (`Am'>0 & `Bm'>0 & `Cm'>0 & `Dm'>0) {
				local Ai = `Am'
				var = 1/(1/`Am' + 1/`Bm' + 1/`Cm' + 1/`Dm')
			}
			//Use formula 4:30 (Breslow & Day, pag 142) to find the homogeneity statistic with the found Ai,VARi
			local chi2BD = `chi2BD' + (`a1' - `Ai')^2/`var'
		}
	}
	
	return scalar chi2W = `chi2W'
	return scalar p_chi2W = chi2tail(`nstr'-1,`chi2W')

	return scalar chi2BD = `chi2BD'
	return scalar p_chi2BD = chi2tail(`nstr'-1,`chi2BD')

end

program define get_chi2_fisher, rclass
	syntax [anything], data(name) type(integer) st(string) dec(integer)

	tempname chi2
		
	local a1 = `data'[1,2]
	local b1 = `data'[2,2]
	local m1 = `data'[1,3]
	local a0 = `data'[1,1]
	local b0 = `data'[2,1]
	local m0 = `data'[2,3]
	local n0 = `data'[3,1]
	local n1 = `data'[3,2]
	local n = `data'[3,3]

	*Store chi-square results on a matrix:
	*1,1: chi2; 1,2: p_chi2; 2,1: chi2c; 2,2: p_chi2c; 3,1: warning, 3,1: p fisher exact test; ;
	matrix define `chi2' = J(3,2,.)
	
	*Association Chi-square
	matrix `chi2'[1,1] = `n'*((`a1'*`b0'-`a0'*`b1')^2) / (`m1'*`m0'*`n1'*`n0')
	matrix `chi2'[2,1] = `n'*((abs(`a1'*`b0'-`a0'*`b1') - `n'/2)^2) / (`m1'*`m0'*`n1'*`n0')
	if (abs(`a1'*`b0'-`a0'*`b1') < (`n'/2)) matrix `chi2'[2,1] = 0
	if (`type'==2) {
		*Mantel-Haenszel
		matrix `chi2'[1,1] = `chi2'[1,1]*((`n'-1)/`n')
		matrix `chi2'[2,1] = `chi2'[2,1]*((`n'-1)/`n')
	}
	matrix `chi2'[1,2] = chi2tail(1,abs(`chi2'[1,1]))
	matrix `chi2'[2,2] = chi2tail(1,abs(`chi2'[2,1]))
	matrix `chi2'[3,2] = 0
	if (`m1'*(`n1'/`n')<5 | `m0'*(`n1'/`n')<5 | `m1'*(`n0'/`n')<5 | `m0'*(`n0'/`n')<5) matrix `chi2'[3,1] = 1
	
	if (`dec'==0) {	
		*Fisher Exact Test
		preserve
		if ("`st'"=="cc") qui cci `a1' `a0' `b1' `b0', exact
		else quietly csi `a1' `a0' `b1' `b0', or exact
		matrix `chi2'[3,2] = r(p_exact)
	}

	return matrix chi2 = `chi2'
end

program define get_chi2_pt, rclass
	syntax [anything], data(name)

	tempname chi2 chi2c p_chi2 p_chi2c
	
	local a0 = `data'[1,1]
	local a1 = `data'[1,2]
	local m1 = `data'[1,3]
	local t0 = `data'[2,1]
	local t1 = `data'[2,2]	
	local t = `data'[2,3]

	*Store chi-square results on a matrix:
	*1,1: chi2; 1,2: p_chi2; 1,3: warning
	matrix define `chi2' = J(2,3,.)
	
	*Mantel-Haenszel Chi-Square
	matrix `chi2'[1,1] = (`a1'-`m1'*`t1'/`t')^2 / (`m1'*`t1'*`t0'/`t'^2)
	matrix `chi2'[1,2] = chi2tail(1,abs(`chi2'[1,1]))
	matrix `chi2'[1,3]=0
	if (`m1'*`t0'/`t'<5 | `m1'*`t1'/`t'<5) matrix `chi2'[1,3]=1
	*Corrected
	matrix `chi2'[2,1] = (abs(`a1'*`t'-`m1'*`t1')-`t'/2)^2 / (`m1'*`t1'*`t0')
	if (abs(`a1'*`t'-`m1'*`t1')<`t'/2) matrix `chi2'[2,1] = 0
	matrix `chi2'[2,2] = chi2tail(1,abs(`chi2'[2,1]))
	
	return matrix chi2 = `chi2'
end


program define zero_correction, rclass
	syntax anything(name=zero), d(name) st(string) nstr(integer) [str_values(name)]
	
	tempname s st_zero
	
	local offset 0
	if (`nstr'>1) local offset 1
	
	//Apply continuity correction, if necessary
	local a0sum = 0
	local a1sum = 0
	local b0sum = 0
	local b1sum = 0
	matrix define `st_zero' = J(1,`nstr',0)
	foreach i of numlist 1/`nstr' {
		if (`nstr'==1) {
			matrix define `s' = `d'
		}
		else {
			local val = `str_values'[1,`i']
			mata: get_submatrix("`d'", "`s'", `val')
		}
		local a0 = `s'[1,1]
		local a1 = `s'[1,2]
		local m1 = `s'[1,3]
		local b0 = `s'[2,1]
		local b1 = `s'[2,2]
		local m0 = `s'[2,3]
		local n0 = `s'[3,1]
		local n1 = `s'[3,2]
		local n = `s'[3,3]
		local k1 = 0
		local k0 = 0
		if (`a1'==0 | `a0'==0 | `b1'==0 | `b0'==0) {
			*Compute k1, k0 correction terms
		  /*c (Constant, add k=0.5 to each cell)
			p (Proportional, add k1=N1/N and k0=N0/N for EX, CO & CS studies)
							 add k1=M1/N and k0=M0/N for CC studies)
			r (Reciprocal, add k1=1/N0 and k0=1/N1 for EX, CO & CS studies)
						   add k1=1/M0 and k0=1/M1 for CC studies)*/
			matrix `st_zero'[1,`i'] = 1
			if ("`zero'"=="c") {
				local k1 = 0.5
				local k0 = 0.5
			}
			if ("`zero'"=="p") {
				if ("`st'"!="cc") {
					local k1 = `n1'/`n'
					local k0 = `n0'/`n'
				}
				else {
					local k1 = `m1'/`n'
					local k0 = `m0'/`n'
				}
			}
			if ("`zero'"=="r") {
				if ("`st'"!="cc") {
					local k1 = 1/`n0'
					local k0 = 1/`n1'
				}
				else {
					local k1 = 1/`m0'
					local k0 = 1/`m1'
				}
			}
			//Apply the correction
			matrix `d'[`i'+(`i'-1)*2,2+`offset'] = `a1'+`k1'
			matrix `d'[`i'+(`i'-1)*2+1,1+`offset'] = `b0'+`k0'
			if ("`st'"!="cc") {
				matrix `d'[`i'+(`i'-1)*2,1+`offset'] = `a0'+`k0'
				matrix `d'[`i'+(`i'-1)*2+1,2+`offset'] = `b1'+`k1'
			}
			else {
				matrix `d'[`i'+(`i'-1)*2,1+`offset'] = `a0'+`k1'
				matrix `d'[`i'+(`i'-1)*2+1,2+`offset'] = `b1'+`k0'
			}			
		}
		
		if (`nstr'>1) {
			*OVERALL summatories
			local a0sum = `a0sum' + `d'[`i'+(`i'-1)*2,1+`offset']
			local a1sum = `a1sum' + `d'[`i'+(`i'-1)*2,2+`offset']
			local b0sum = `b0sum' + `d'[`i'+(`i'-1)*2+1,1+`offset']
			local b1sum = `b1sum' + `d'[`i'+(`i'-1)*2+1,2+`offset']
		}
	}
	
	//OVERALL
	if (`nstr'>1) {
		matrix `d'[1+3*`nstr',1+`offset'] = `a0sum'
		matrix `d'[1+3*`nstr',2+`offset'] = `a1sum'
		matrix `d'[2+3*`nstr',1+`offset'] = `b0sum'
		matrix `d'[2+3*`nstr',2+`offset'] = `b1sum'
	}
	
	return matrix str_zero = `st_zero'
end

program define get_paired_results, rclass
	syntax [anything], d(name) level(real) [relatsymm]

	******PAIRED SAMPLES RESULTS
	tempname p r chi2
	
	local a0 = `d'[1,1]
	local a1 = `d'[1,2]
	local m1 = `d'[1,3]
	local b0 = `d'[2,1]
	local b1 = `d'[2,2]
	local m0 = `d'[2,3]
	local n0 = `d'[3,1]
	local n1 = `d'[3,2]
	local n  = `d'[3,3]
	local b = `a0'+`b1'

	local alpha = (`level'+100)/200
	local z = invnormal(`alpha')
	
	if ("`relatsymm'"=="") {
		***PROPORTIONS
		get_ci `m1' `n', level(`level') method(wilson)		//Proportion of exposed
		local pe = r(p)
		local lbwe = r(lb)
		local ubwe = r(ub)
		get_ci `n1' `n', level(`level') method(wilson)		//Proportion of unexposed
		local pu = r(p)
		local lbwu = r(lb)
		local ubwu = r(ub)
		get_ci `m0' `n', level(`level') method(wilson)		//Proportion of Y-
		local py = r(p)
		get_ci `n0' `n', level(`level') method(wilson)		//Proportion of X-
		local px = r(p)
		
		
		matrix `p' = J(1,4,.)
		matrix colnames `p' = pe pu pY pX
		matrix `p'[1,1] = `pe'
		matrix `p'[1,2] = `pu'
		matrix `p'[1,3] = `py'
		matrix `p'[1,4] = `px'

		***DIFFERENCE
		local rd =(`a0'-`b1')/`n'
		*Exact bounds
		get_ci `a0' `b', level(`level') method(exact)
		local lbrd_e = (2*r(lb)-1)*(`b')/`n'
		local ubrd_e = (2*r(ub)-1)*(`b')/`n'

		**Newcombe method 10 bounds - 'Statistics with confidence', pg.52.
		*Coefficient #Fi
		local wa = `m1'*`m0'*`n1'*`n0'
		local fi = 0
		if (`wa'>0) {
			local wb = `a1'*`b0' - `a0'*`b1'
			if (`wb' > `n'/2) local wc = `wb' - `n'/2
			if (`wb' >= 0 & `wb' <= `n'/2) local wc = 0
			if (`wb' < 0) local wc = `wb'
			local fi = `wc' / sqrt(`wa')
		}
		*Bounds
		local lbrd_w= `rd' - sqrt((`pe'-`lbwe')^2 - 2*`fi'*(`pe'-`lbwe')*(`ubwu'-`pu') + (`ubwu'-`pu')^2)
		local ubrd_w= `rd' + sqrt((`pu'-`lbwu')^2 - 2*`fi'*(`pu'-`lbwu')*(`ubwe'-`pe') + (`ubwe'-`pe')^2)

		*Asymptotic bounds
		local se = sqrt(`a0'+`b1'-((`a0'-`b1')^2/`n'))/`n'
		local lbrd_a= `rd' - `z'*`se'
		local ubrd_a= `rd' + `z'*`se'
		*Asymptotic bounds (continuity correction)
		local lbrd_ac= `lbrd_a' - 1/`n'
		local ubrd_ac= `ubrd_a' + 1/`n'

		***ODDS RATIO
		local or = `a0'/`b1'
		*Exact bounds
		get_ci `a0' `b', level(`level') method(exact)
		local lbor_e = r(lb)/(1-r(lb))
		local ubor_e = r(ub)/(1-r(ub))
		*Wilson bounds
		get_ci `a0' `b', level(`level') method(wilson)
		local lbor_w = r(lb)/(1-r(lb))
		local ubor_w = r(ub)/(1-r(ub))
		*Asymptotic bounds
		local selnor = sqrt(1/`a0' + 1/`b1')
		local lbor_a = `or'*exp(-`z'*`selnor')
		local ubor_a = `or'*exp(`z'*`selnor')

		matrix `r' = J(7,4,.)
		matrix rownames `r' = rd_exact rd_newcombe rd_asymp rd_asymp_cor or_exact or_wilson or_asymp
		matrix colnames `r' = estim lbCI ubCI se
		matrix `r'[1,1] = `rd'
		matrix `r'[1,2] = `lbrd_e'
		matrix `r'[1,3] = `ubrd_e'
		matrix `r'[2,2] = `lbrd_w'
		matrix `r'[2,3] = `ubrd_w'
		matrix `r'[3,2] = `lbrd_a'
		matrix `r'[3,3] = `ubrd_a'
		matrix `r'[3,4] = `se'
		matrix `r'[4,2] = `lbrd_ac'
		matrix `r'[4,3] = `ubrd_ac'
		matrix `r'[5,1] = `or'
		matrix `r'[5,2] = `lbor_e'
		matrix `r'[5,3] = `ubor_e'
		matrix `r'[6,2] = `lbor_w'
		matrix `r'[6,3] = `ubor_w'	
		matrix `r'[7,2] = `lbor_a'
		matrix `r'[7,3] = `ubor_a'
		matrix `r'[7,4] = `selnor'
	

		***EXACT SIMMETRY
		*McNemar matched-pair (exact) Test
		if (mod(`a0',1)==0 & mod(`b1',1)==0) {
			local s2 = 2*binomial(`a0'+`b1',min(`a0',`b1'),0.5)
		}
		else {
			*Decimal parameters: p value computed by linear interpolation
			if (`a0'<`b1') {
				local a01 = int(`a0')
				local b11 = int(`b1') + (mod(`b1',1)!=0)
				local a00 = int(`a0') + (mod(`a0',1)!=0)
				local b10 = int(`b1')
				
			}
			if (`a0'>`b1') {
				local a01 = int(`a0') + (mod(`a0',1)!=0)
				local b11 = int(`b1')
				local a00 = int(`a0')
				local b10 = int(`b1') + (mod(`b1',1)!=0)
			}
			local s21 = 2*binomial(`a01'+`b11',min(`a01',`b11'),0.5)
			local s20 = 2*binomial(`a00'+`b10',min(`a00',`b10'),0.5)
			if (`a01' == `b11') local s21 = 1
			if (`a00' == `b10') local s20 = 1
			local k12 = abs(`a01'-`a00') + abs(`b11'-`b10')
			local s2 = ((`k12'-mod(`a0',1)-mod(`b1',1))*`s21' + (mod(`a0',1)+mod(`b1',1) )*`s20')/`k12'
		}
		if (`b1'==`a0') local s2 = 1

		*Chi-square, Corrected
		local chi2_sym = ((`a0'-`b1')/sqrt(`a0'+`b1'))^2
		local p_sym = chi2tail(1,`chi2_sym')
		local chi2c_sym = ((abs(`a0'-`b1')-1)/sqrt(`a0'+`b1'))^2
		if (abs(`a0'-`b1')<0.5) local chi2c_sym = 0
		local pc_sym = chi2tail(1,`chi2c_sym')
		local warn_sym 0
		if ((`a0'+`b1')<10) local warn_sym 1

		***TEST OF ASSOCIATION
		local or = (`a1'*`b0')/(`a0'*`b1')
		if (`a1'*`b0'==0) local or = .
		local chi2_assoc = (`n'*(`a1'*`b0' - `a0'*`b1')^2)/(`n0'*`n1'*`m1'*`m0')
		local p_assoc = chi2tail(1,`chi2_assoc')
		local warn_assoc 0
		if (`m1'*(`n1'/`n')<5 | `m0'*(`n1'/`n')<5 | `m1'*(`n0'/`n')<5 | `m0'*(`n0'/`n')<5) local warn_assoc 1
		local chi2c_assoc = (`n'*(abs(`a1'*`b0' - `a0'*`b1')-`n'/2)^2)/(`n0'*`n1'*`m1'*`m0')
		if (abs(`a1'*`b0' - `a0'*`b1')<`n'/2) local chi2c_assoc = 0
		local pc_assoc = chi2tail(1,`chi2c_assoc')
	
		matrix `chi2' = J(6,3,.)
		matrix rownames `chi2' = sym_mcnemar sym_chi2 sym_chi2c assoc_or assoc_chi2 assoc_chi2c
		matrix colnames `chi2' = estim p warn
		matrix `chi2'[1,2] = `s2'
		matrix `chi2'[2,1] = `chi2_sym'
		matrix `chi2'[2,2] = `p_sym'
		matrix `chi2'[2,3] = `warn_sym'
		matrix `chi2'[3,1] = `chi2c_sym'
		matrix `chi2'[3,2] = `pc_sym'
		matrix `chi2'[4,1] = `or'
		matrix `chi2'[5,1] = `chi2_assoc'
		matrix `chi2'[5,2] = `p_assoc'
		matrix `chi2'[5,3] = `warn_assoc'
		matrix `chi2'[6,1] = `chi2c_assoc'
		matrix `chi2'[6,2] = `pc_assoc'
	}
	else {
		***RELATIVE SYMMETRY
		*Not for Case-control studies
		**PROPORTIONS
		matrix `p' = J(1,3,.)
		matrix colnames `p' = pe p1 p0
		matrix `p'[1,1] = `m1'/`n'		//pe
		matrix `p'[1,2] = `a0'/`n0'		//p0
		matrix `p'[1,3] = `a1'/`n1'		//p1
		
		**PROPORTION DIFFERENCE, PROP. RATIO, ODDS RATIO
		matrix `r' = J(4,4,.)
		matrix rownames `r' = PD_wald PD_newcombe PR OR
		matrix colnames `r' = estim lb ub
		get_rd, data(`d') level(`level')
		matrix `r'[1,1] = r(rd)			//prop. difference PD
		matrix `r'[1,2] = r(lbw)		//Wald CI
		matrix `r'[1,3] = r(ubw)
		matrix `r'[2,2] = r(lbn)		//Newcombe CI
		matrix `r'[2,3] = r(ubn)
		get_rr, data(`d') level(`level')
		matrix `r'[3,1] = r(rr)			//prop. ratio PR
		matrix `r'[3,2] = r(lb)			//CI
		matrix `r'[3,3] = r(ub)
		matrix `r'[3,4] = r(se)
		get_or, data(`d') level(`level') st("cc") dec(1)
		matrix `r'[4,1] = r(or)			//odds ratio OR
		matrix `r'[4,2] = r(lbw)		//CI
		matrix `r'[4,3] = r(ubw)
		matrix `r'[4,4] = r(se)
		
		***TEST OF ASSOCIATION
		matrix `chi2' = J(2,3,.)
		matrix rownames `chi2' = chi2 chi2c
		matrix colnames `chi2' = estim p warn
		matrix `chi2'[1,1] = (`n'*(`a1'*`b0' - `a0'*`b1')^2)/(`n0'*`n1'*`m1'*`m0')
		matrix `chi2'[1,2] = chi2tail(1,`chi2'[1,1])
		matrix `chi2'[1,3] = 0
		if (`m1'*(`n1'/`n')<5 | `m0'*(`n1'/`n')<5 | `m1'*(`n0'/`n')<5 | `m0'*(`n0'/`n')<5) matrix `chi2'[1,3] = 1
		matrix `chi2'[2,1] = (`n'*(abs(`a1'*`b0' - `a0'*`b1')-`n'/2)^2)/(`n0'*`n1'*`m1'*`m0')
		if (abs(`a1'*`b0' - `a0'*`b1')<`n'/2) matrix `chi2'[2,1] = 0
		matrix `chi2'[2,2] = chi2tail(1,`chi2'[2,1])
	}


	*Return results matrix
	return matrix p = `p'
	return matrix res = `r'
	return matrix chi2 = `chi2'
end

program define is_dec, rclass
	syntax [anything], data(name)
	local nrows = rowsof(`data')
	local ncols = colsof(`data')
	local dec 0
	foreach i of numlist 1/`nrows' {
		foreach j of numlist 1/`ncols' {
			local nij = `data'[`i',`j']
			if (`nij'<. & mod(`nij',1)!=0) local dec 1
		}
	}
	return scalar dec = `dec'
end

program define is_zero, rclass
	syntax [anything], data(name)
	local nrows = rowsof(`data')
	local ncols = colsof(`data')
	local zero 0
	foreach i of numlist 1/`nrows' {
		foreach j of numlist 1/`ncols' {
			local nij = `data'[`i',`j']
			if (`nij'==0) local zero 1
		}
	}
	return scalar zero = `zero'
end

program define get_note, rclass
	if (c(stata_version)<14) {
		if (c(os)=="Windows") return scalar note = 170
		if (c(os)=="Linux") return scalar note = 170
		if (c(os)=="MacOSX") return scalar note = 187
	}
	else {
		return scalar note = 170
	}
end

program define get_varlabel, rclass
	syntax anything(name=var), len(integer)
	
	local label : variable label `var'
	if ("`label'"==" ") local label = abbrev("`var'",`len')
	else local label = abbrev("`label'",`len')
	
	return local label = "`label'"
end

program define get_var_labels, rclass
	syntax anything(name=var), abb_name(integer) abb_lbl(integer)
	
	return local vname = abbrev("`var'",`abb_name')
	
	qui levelsof `var', local(values)
	foreach v in `values' {
		local label`v' : label (`var') `v'
		return local lbl`v' = abbrev("`label`v''",`abb_lbl')
	}
end


version 12
mata:
void get_submatrix(string scalar data, string scalar sub, real scalar val)
{
	real matrix d, s	
	d = st_matrix(data)
	s = select(d, d[.,1] :== val)[.,(2..4)]
	st_matrix(sub,s)
}
end
