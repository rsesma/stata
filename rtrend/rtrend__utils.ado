*! version 1.2.6  30sep2019
program rtrend__utils
	version 12.0
	gettoken subcmd 0 : 0
	`subcmd' `0'
end


program genCommand
	syntax , clsname(string)
	local dlg .`clsname'
	local cmdstring cmd
	
	local command ""
	
	local metric ""	
	forvalues i = 1/9 {
		local v = "``dlg'.data.ed_m`i'.value'"
		if (trim("`v'")!="") local metric "`metric' `v'"
	}

	local str = "``dlg'.data.cb_str.value'"
	
	local a ""
	local l = cond(`str',"1 3 5","1")
	foreach j of numlist `l' {
		local a`j' ""
		foreach i of numlist 1/9 {
			local v = "``dlg'.data.ed_r`i'c`j'.value'"
			if (trim("`v'")!="") local a`j' "`a`j'' `v'"
		}
		local a`j' = trim("`a`j''")
		if ("`a`j''"!="") {
			if (`j'==1) local a "`a`j''"
			else local a "`a' \ `a`j''"
		}
	}
	
	local n ""
	local l = cond(`str',"2 4 6","2")
	foreach j of numlist `l' {
		local n`j' ""
		foreach i of numlist 1/9 {
			local v = "``dlg'.data.ed_r`i'c`j'.value'"
			if (trim("`v'")!="") local n`j' "`n`j'' `v'"
		}
		local n`j' = trim("`n`j''")
		if ("`n`j''"!="") {
			if (`j'==2) local n "`n`j''"
			else local n "`n' \ `n`j''"
		}
	}
	
	local command "`metric' \ `a' \ `n'"
	
	`dlg'.`cmdstring'.value = "`command'"
end


program define test_st, rclass
	syntax anything(name=st)
	
	local error = ("`st'"!="co" & "`st'"!="co rr" & "`st'"!="co or" & 	/*
				*/	"`st'"!="cs" & "`st'"!="cs pr" & "`st'"!="cs or" & 	/*
				*/	"`st'"!="cc")

	/*type = 1 Cohort, 2 Cross-Sectional, 3 Case-Control
	  stat = 1 Risk/Prevalence ratio, 2 Odds ratio*/
	local c1 : word 1 of `st'
	local c2 : word 2 of `st'
	local type = cond("`c1'"=="co",1,cond("`c1'"=="cs",2,3))
	if ("`c1'"!="cc" & "`c2'"=="") local c2 = cond("`c1'"=="co","rr","pr")
	local stat = cond("`c2'"=="rr" | "`c2'"=="pr",1,2)
	
	return scalar error = `error'
	return scalar type = `type'
	return scalar stat = `stat'
end

program define get_tokens, rclass
	syntax anything, type(integer) data(string)
	tempname r d t
	
	mata: get_array("`anything'", "\", "`r'")
	if (rowsof(`r')<3) print_error "data invalid -- metric, a or n|b|t missing"
	if (rowsof(`r')>3 & mod(rowsof(`r')-1,2)!=0) print_error "data invalid -- a or n|b|t missing"
	
	local cols = colsof(`r')
	local nstr = (rowsof(`r')-1)/2
	foreach i of numlist 1/`nstr' {
		matrix `t' = (`r'[1,1..`cols']', `r'[`i'+1,1..`cols']', `r'[(`i'+1)+`nstr',1..`cols']', J(`cols',1,`i'))
		if ("`data'"=="freq" & `type'<3) {
			foreach j of numlist 1/`cols' {
				matrix `t'[`j',3] = `t'[`j',3] - `t'[`j',2]			//for co, cs types the third column is n; it has to be b
			}
		}
		if (`i'==1) matrix `d' = `t'
		else matrix `d' = `d' \ `t'
	}
	//Add OVERALL for strata studies
	if (`nstr'>1) {
		mata: get_overall("`d'",`nstr',"`r'")
		matrix `d' = `d' \ (`r', J(`cols',1,`nstr'+1))
	}
	return matrix data = `d'
	return scalar nstr = `nstr'
end

program define print_results, rclass
	syntax anything, r(name) level(real) method(integer) rc(string) chi2P(real) nstr(integer) zero(string) k2(integer) str(integer)

	tokenize `anything'
	local data = "`1'"
	local type = `2'
	local stat = `3'
	local len = rowsof(`r')
	get_method_rc `method' `rc'
	
	if ("`data'"=="freq") {
		local lzero 0
		if (`type'<=2) {
			//Cohort or Cross-Sectional, Risk or Odds
			if (!`k2') {
				local c1 = cond(`type'==1,"","Preva-")
				local c2 = cond(`type'==1,"Risk","lences")
				if (`stat'==1) {
					local c3 = cond(`type'==1,"RR","PR")
					local c4 = cond(`method'==0,"","{col 33}[`level'% Conf. Int.]")
					di as txt " Expo {c |}" _col(25) "`c1'" _col(33) "`r(method)'  Ref. category: `r(rc)'"
					di as txt "Metric{c |} Cases {ralign 7:Total} {ralign 8:`c2'}`c4' {ralign 9:`c3'}{ralign 20:`level'% Conf. Inter.}"
					local n1 = cond(`method'==0,53,72)
					local n2 = cond(`method'==0,23,42)
				}
				if (`stat'==2) {
					di as txt " Expo {c |}" _col(35) "`c1'" _col(52) "Ref. category: `r(rc)'"
					di as txt "Metric{c |} Cases {ralign 8:NoCases} {ralign 8:Total} {ralign 8:`c2'} {ralign 8:Odds}  {ralign 9:OR}{ralign 19:`level'% Conf. Inter.}"
					local n1 72
					local n2 42
				}
				di as txt "{hline 6}{c +}{hline `n1'}"
				local zero_pos = colsof(`r')-1
				foreach i of numlist 1/`len' {
					local cols= colsof(`r')-2
					if (`i'==`len') local cols 6
					if (`i'==`len') di as txt "{hline 6}{c +}{hline `n1'}"
					if (`i'==`len') di as txt "TOTAL {c |} " _c
					if (`i'<`len') di as res %5.0g `r'[`i',1] " {c |} " _c

					foreach j of numlist 2/`cols' {
						local v = `r'[`i',`j']
						if (!missing(`v')) {
							if (`stat'==1) local fmt = cond(`j'==2,"%5.0g",cond(`j'==3,"%7.0g",cond(`j'<7,"%8.0g","%9.0g")))
							if (`stat'==2) local fmt = cond(`j'==2,"%5.0g",cond(`j'<7,"%8.0g","%9.0g"))
							di as res `fmt' `v' _c
							if ((`stat'==1 & inlist(`j',4,7)) | (`stat'==2 & inlist(`j',5,6,7))) di cond(`r'[`i',`zero_pos']==0," ","*") _c
							else di as txt " " _c
						}
						if (`j'==`cols') di ""
					}
					if (`r'[`i',`zero_pos']) local lzero 1
				}
				di as txt "{hline 6}{c BT}{hline `n2'}"
			}
			else {
				//Response k>2 categories, Exposure binary
				local c1 = cond(`type'==1,"Risk","Preval.")
				if (`stat'==1) {
					di as txt " Resp {c |}" _col(17) "No" _col(27) "Exposed" _col(35) "NoExposed" _col(47) "Ref. category: No exposed"
					di as txt "Metric{c |} Exposed Exposed" _col(27) "{ralign 7:`c1'}" _col(35) "{ralign 9:`c1'}" 	/*
					*/		_col(52) cond(`type'==1,"RR","PR") " " %4.0g `level' "% Conf. Inter."
					di as txt "{hline 6}{c +}{hline 66}"
				}
				if (`stat'==2) {
					di as txt " Resp {c |}" _col(17) "No" _col(27) "Exposed" _col(37) "Exposed"  _col(45) "NoExposed" /*
					*/		_col(57) "Ref. category: No exposed"
					di as txt "Metric{c |} Exposed Exposed" _col(27) "{ralign 7:`c1'}" _col(40) "Odds" 	/*
					*/		_col(50) "Odds" _col(62) "OR " %4.0g `level' "% Conf. Inter."
					di as txt "{hline 6}{c +}{hline 76}"
				}
				foreach i of numlist 1/`len' {
					if (`i'==`len' & `stat'==1) di as txt "{hline 6}{c +}{hline 66}"
					if (`i'==`len' & `stat'==2) di as txt "{hline 6}{c +}{hline 76}"
					if (`i'==`len') di as txt "TOTAL {c |} " _c
					if (`i'<`len') di as res %5.0g `r'[`i',1] " {c |} " _c

					local cols= colsof(`r')-2
					if (`i'==`len' & `stat'==1) local cols 5
					if (`i'==`len' & `stat'==2) local cols 4
					foreach j of numlist 2/`cols' {
						local fmt = cond(`j'<=3,"%7.0g","%9.0g")
						di as res `fmt' `r'[`i',`j'] " "_c
						if (`j'==`cols') di ""
					}
				}
				if (`stat'==1) di as txt "{hline 6}{c BT}{hline 36}"
				if (`stat'==2) di as txt "{hline 6}{c BT}{hline 26}"
			}
		}
		if (`type'==3) {
			//Case-Control
			di as txt " Expo {c |}" _col(24) "Ref. category: `r(rc)'"
			di as txt "Metric{c |}  Cases {ralign 8:Controls} {ralign 9:OR}{ralign 20:`level'% Conf. Inter.}"
			di as txt "{hline 6}{c +}{hline 46}" _c
			local zero_pos = colsof(`r')-1
			foreach i of numlist 1/`len' {
				local cols= colsof(`r')-2
				if (`i'==`len') local cols 3
				if (`i'==`len') di as txt _newline "{hline 6}{c +}{hline 46}"
				if (`i'==`len') di as txt "TOTAL {c |} " _c
				if (`i'<`len') di as res _newline %5.0g `r'[`i',1] " {c |} " _c

				foreach j of numlist 2/`cols' {
					local v = `r'[`i',`j']
					if (!missing(`v')) {
						local fmt = cond(`j'==2,"%6.0g",cond(`j'==3,"%8.0g","%9.0g"))
						di as res `fmt' `v' _c
						if (inlist(`j',4)) di cond(`r'[`i',`zero_pos']==0," ","*") _c
						else di " " _c
					}
				}
				if (`r'[`i',`zero_pos']) local lzero 1
			}
			di as txt _newline "{hline 6}{c BT}{hline 16}"
		}
		if (`lzero' & `nstr'==1) {
			if ("`zero'"=="c") di as txt "(*)Computed with a constant continuity correction (k=0.5)"
			if ("`zero'"=="p") di as txt "(*)Computed with a proportional continuity correction"
			if ("`zero'"=="r") di as txt "(*)Computed with a reciprocal continuity correction"
		}
	}
	if ("`data'"=="pt") {
		local c1 = cond(`method'==0,"","{hline 4} Exact {hline 5} ")
		local c2 = cond(`method'==0,"","{col 36}[`level'% Conf. Int.]")
		local n1 = cond(`method'==0,56,74)
		local n2 = cond(`method'==0,26,44)
		di as txt _col(7) "{c |}" _col(18) "Person-" _col(36) "`c1' Ref. category: `r(rc)'"
		di as txt "Metric{c |} Cases {ralign 10:Time} {ralign 8:Rate}`c2' {ralign 9:IR}{ralign 20:`level'% Conf. Inter.}"
		di as txt "{hline 6}{c +}{hline `n1'}"
		foreach i of numlist 1/`len' {
			local cols= colsof(`r')-2
			if (`i'==`len') local cols 6
			if (`i'==`len') di as txt "{hline 6}{c +}{hline `n1'}"
			if (`i'==`len') di as txt "TOTAL {c |} " _c
			if (`i'<`len') di as res %5.0g `r'[`i',1] " {c |} " _c

			foreach j of numlist 2/`cols' {
				local v = `r'[`i',`j']
				if (!missing(`v')) {
					local fmt = cond(`j'==2,"%5.0g",cond(`j'==3,"%10.0g",cond(`j'<7,"%8.0g","%9.0g")))
					di as res `fmt' `v' " " _c
				}
				if (`j'==`cols') di ""
			}
		}
		di as txt "{hline 6}{c BT}{hline `n2'}"
	}
	
	*Print Linear Trend and Deviation of Linearity
	if (`nstr'==1) di
	local chi2 = `r'[1,colsof(`r')]
	di as txt "MH Test for linear Trend: Chi2(1) = " as res %8.0g `chi2' as txt "  (p= " as res %6.4f as res (1 - chi2(1,`chi2')) as txt ")"
	if (`chi2P'<.) {
		local chi2 = `chi2P' - `chi2'
		local df = rowsof(`r') - 3
		di as txt "Deviation from linearity: Chi2(`df') = " as res %8.0g `chi2' as txt "  (p= " as res %6.4f as res (1 - chi2(`df',`chi2')) as txt ")"
	}	
end

program define print_res_adj
	syntax anything, r(name) level(real) rc(string) nstr(integer) zero(string)

	tokenize `anything'
	local data = "`1'"
	local type = `2'
	local stat = `3'
	local len = rowsof(`r')
	get_method_rc 1 `rc'

	local note = cond(c(stata_version)<14 & c(os)=="MacOSX",187,170)
	
	di ""
	local c = cond(`stat'==2,"OR",cond(`type'==1,"RR","PR"))
	if ("`data'"=="pt") local c = "IR"
	local wald = "{hline 4} Wald {hline 3}"

	di as txt "{bf:ADJUSTED M-H}{col 17}Ref. category: `r(rc)'{col 53}Homogeneity"
	di as txt " Expo {c |}{ralign 8:Crude} {hline 6} Adjusted M-H {hline 6}{col 53}" _c
	di as txt cond(`stat'==1,"`wald'","Breslow-Day{c `note'}") _c
	if (`stat'==2) di as txt _col(68) "`wald'" _c
	di as txt _newline "Metric{c |}{ralign 8:`c'} {ralign 8:`c'}" %4.0g `level' /*
	*/			"% Conf. Inter. {ralign 7:Change} {ralign 7:Chi2}{ralign 7:p}" _c
	if (`stat'==2) di as txt " {ralign 7:Chi2}{ralign 7:p}" _c
	di as txt _newline "{hline 6}{c +}{hline 58}" _c
	if (`stat'==2) di as txt "{hline 15}" _c
	
	local lzero 0
	foreach i of numlist 1/`len' {
		di as res _newline %5.0g `r'[`i',1] " {c |}" _c

		local cols= colsof(`r')-3
		foreach j of numlist 2/`cols' {
			if (`j'!=6) {
				local fmt = cond(`j'<=5,"%8.0g",cond(inlist(`j',7,9),"%7.3f","%6.3f"))
				di as res `col' `fmt' `r'[`i',`j'] _c
				if (inlist(`j',3,7,9)) di as txt cond(!missing(`r'[`i',`j']) & `r'[`i',colsof(`r')]==1,"*"," ") _c
				else di " " _c
			}
			else {
				local v = `r'[`i',`j']
				print_pct `v', nopercent col(45)
				if (!missing(`v')) di as txt "% " _c
				else di as txt "  " _c
			}
		}
		if (`r'[`i',colsof(`r')]==1) local lzero 1
	}
	di as txt _newline "{hline 6}{c BT}{hline 58}" _c
	if (`stat'==2) di as txt "{hline 15}" _c

	local df = `nstr'-2			//nstr is the number of strata + 1
	di as txt _newline "MH Test for linear Trend: Chi2(1) = " as res %8.0g `r'[1,`cols'+1] /*
	*/		as txt "  (p= " as res %6.4f as res (1 - chi2(1,`r'[1,`cols'+1])) as txt ")"
	if ("`data'"=="freq") di as txt "Homogeneity of Linear trends: Chi2(`df') = " as res %8.0g `r'[1,`cols'+2] /*
	*/		as txt "  (p= " as res %6.4f as res (1 - chi2(`df',`r'[1,`cols'+2])) as txt ")"
	if (`stat'==2) di as txt "{c `note'}Recommended method"
	
	if (`lzero') {
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

program define store_results, rclass
	syntax anything, r(name) str(integer) nstr(integer) chi2P(real) k2(integer)

	tokenize `anything'
	local data = "`1'"
	local type = `2'
	local stat = `3'
	
	tempname results M
	local cols= colsof(`r')-2
	local rows=rowsof(`r')-1
	matrix `results' = `r'[.,2..`cols']
	matrix `M' = `r'[1..`rows',1]'
	mata: st_local("rnames",invtokens(strofreal((st_matrix("`M'")))))
	local rnames = "`rnames' TOTAL"
	
	if ("`data'"=="freq") {
		local t1 = cond(`type'==1,"Risk","Preval")
		local t2 = cond(`type'==1,"RR","PR")
		if (!`k2') {
			if (`type'<3 & `stat'==1) local cnames "Cases Total `t1' lb_`t1' ub_`t1' `t2' lb_`t2' ub_`t2'"
			if (`type'<3 & `stat'==2) local cnames "Cases NoCases Total `t1' Odds OR lb_OR ub_OR"
			if (`type'==3) local cnames "Cases Controls OR lb_OR ub_OR"
		}
		else {
			if (`stat'==1) local cnames "Exposed NoExposed Exp`t1' NoExp`t1' `t2' lb_`t2' ub_`t2'"
			if (`stat'==2) local cnames "Exposed NoExposed Exp`t1' ExpOdds NoExpOdds OR lb_OR ub_OR"
		}
	}
	if ("`data'"=="pt") {
		local cnames "Cases PersonTime Rate lb_Rate ub_Rate IR lb_IR ub_IR"
	}

	matrix rownames `results' = `rnames'
	matrix colnames `results' = `cnames'
	
	local name = "Results"
	local c
	if (`nstr'>1) {
		local name = cond(`str'<`nstr', "Str`str'", "OVERALL")
	}
	return matrix `name' = `results'
	
	*chi2
	local n
	if (`nstr'>1) local n = cond(`str'<`nstr', "_`str'", "_OVER")
	
	local chi2 = `r'[1,colsof(`r')]
	return scalar trend_chi2`n' = `chi2'
	return scalar trend_p`n' = (1 - chi2(1,`chi2'))
	if (`chi2P'<.) {
		local chi2 = `chi2P' - `chi2'
		local df = rowsof(`r') - 3
		return scalar lin_chi2`n' = `chi2'
		return scalar lin_p`n' = (1 - chi2(`df',`chi2'))
	}	
end

program define store_results_adj, rclass
	syntax anything, r(name) nstr(integer)

	tokenize `anything'
	local data = "`1'"
	local type = `2'
	local stat = `3'
	
	tempname results M
	local cols= colsof(`r')-3
	local rows=rowsof(`r')
	matrix `results' = `r'[.,2..`cols']
	matrix `M' = `r'[1..`rows',1]'
	mata: st_local("rnames",invtokens(strofreal((st_matrix("`M'")))))
	
	if ("`data'"=="freq") {
		local c = cond(`stat'==2,"OR",cond(`type'==1,"RR","PR"))
		local bd = cond(`stat'==2,"BD_chi2 BD_p","")
		local cnames "Crude`c' `c' lb_`c' ub_`c' Change `bd' Wald_chi2 Wald_p"
	}
	if ("`data'"=="pt") {
		local cnames "CrudeIR IR lb_IR ub_IR Change Wald_chi2 Wald_p"
	}

	matrix rownames `results' = `rnames'
	matrix colnames `results' = `cnames'	
	return matrix AdjustedMH = `results'
	
	*chi2
	return scalar adj_trend_chi2 = `r'[1,`cols'+1]
	return scalar adj_trend_p = (1 - chi2(1,`r'[1,`cols'+1]))
	if ("`data'"=="freq") {
		local df = `nstr'-2			//nstr is the number of strata + 1
		return scalar adj_hom_chi2 = `r'[1,`cols'+2]
		return scalar adj_hom_p = (1 - chi2(`df',`r'[1,`cols'+2]))
	}
end

program define get_method_rc, rclass
	syntax anything
	
	tokenize `anything'
	local method `1'
	local rc `2'

	local c1 ""
	if (`method'==1) local c1 "{hline 4} Wilson {hline 4}"
	if (`method'==2) local c1 "{hline 1}Binomial Exact{hline 1}"
	if (`method'==3) local c1 "{hline 1}Binomial Wald{hline 2}"
	if ("`rc'"=="f") local c2 "First"
	if ("`rc'"=="l") local c2 "Last"
	if ("`rc'"=="p") local c2 "Previous"
	if ("`rc'"=="s") local c2 "Subsequent"
	
	return local method "`c1'"
	return local rc "`c2'" 
end

program define get_results_freq, rclass
	syntax anything, d(name) level(real) method(integer) rc(string) zero(string) k2(integer)
	tempname r
	tokenize `anything'
	mata: results_freq(`1',`2',"`d'","`r'",`method',`level',"`rc'","`zero'",`k2')
	return matrix results = `r'
end

program define get_results_pt, rclass
	syntax [anything], d(name) level(real) rc(string) printci(real)
	tempname r
	mata: results_pt("`d'","`r'",`level',"`rc'",`printci')
	return matrix results = `r'
end

program define compute_adj, rclass
	syntax anything, f(name) type(integer) nstr(integer) level(real) rc(string) zero(string)
	tempname r
	tokenize `anything'
	mata: compute_adj("`1'",`2',"`f'","`r'",`type',`nstr',`level',"`rc'","`zero'")
	return matrix results = `r'
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end


version 12
mata:
struct table2x2 {
	real scalar a1, b1, a0, b0, n0, n
	real scalar risk, lb_risk, ub_risk, odds
	real scalar t1, t0
	real scalar rate, lb_rate, ub_rate
	real scalar ratio, lb, ub, se
	real scalar zero, overall
	real scalar nrr, drr, nse
	real scalar nor, dor, pr, ps, qr, qs
	real scalar nir, dir
	real scalar r1, r0, o1, o0
}
end

version 12
mata:
struct stratum {
	struct table2x2 vector d
}
end

version 12
mata:
struct table2x2 vector build_data_freq(real matrix data, real scalar type, real scalar stat, string scalar rc, /*
	*/ string scalar zero, real scalar adj, real scalar k2)
{
	struct table2x2 vector d
	struct table2x2 scalar t
	struct table2x2 scalar over
	real colvector a, b, a0, b0
	real scalar i, len, tmp, pmh
	real scalar lzero
	real scalar m1, m0
	
	a = data[.,2]
	b = data[.,3]
	a0 = get_refvector(a,rc)	//get reference category vectors
	b0 = get_refvector(b,rc)
	m1 = sum(a)
	m0 = sum(b)
	
	if (!adj) {
		over.a1 = 0		//Initialize overall data
		over.b1 = 0
		over.a0 = 0
		over.b0 = 0
	}
	lzero = 0
	
	len = rows(data)
	if (!adj) d = table2x2(len+1)
	else d = table2x2(len)
	for (i=1; i<=len; i++) {
		if (!k2) {
			t.a1 = a[i]
			t.b1 = b[i]
			t.a0 = a0[i]
			t.b0 = b0[i]
		}
		else {
			//SPECIAL CASE: Response k categories & Exposure binary
			//Build a special 2x2 table, using a1 = ai, b1 = m1 - ai, a0 = bi, b0 = m0 - bi
			t.a1 = a[i]
			t.b1 = m1 - a[i]
			t.a0 = b[i]
			t.b0 = m0 - b[i]
		}
		t.overall = 0
		
		zero_correction(t,type,zero)
		if (t.zero==1) lzero=1
				
		t.n0 = t.a0 + t.b0		//Get marginal totals
		t.n = t.a1 + t.b1
		if (adj) {
			//Compute summatory terms for Adjusted MH results
			tmp = t.n + t.n0
			if (stat==1) {
				//Sumatory terms for RR Adj
				t.nrr = (t.a1 * t.n0) / (tmp)
				t.drr = (t.a0 * t.n) / (tmp)
				//Sumatory terms for RR Bounds
				t.nse = ((t.a1 + t.a0) * t.n * t.n0 - t.a1 * t.a0 * tmp) / tmp^2
			}
			if (stat==2) {
				//Sumatory terms for OR Adj
				t.nor = (t.a1 * t.b0) / tmp
				t.dor = (t.a0 * t.b1) / tmp
				//Sumatory terms for OR Bounds
				pmh = (t.a1 + t.b0) / tmp
				t.pr = t.nor * pmh
				t.ps = t.dor * pmh
				t.qr = (1 - pmh) * t.nor
				t.qs = (1 - pmh) * t.dor
			}
		}
		d[i] = t
		
		if (!adj) {
			//build overall table
			over.a1 = over.a1 + t.a1
			over.b1 = over.b1 + t.b1
			over.a0 = over.a0 + t.a0
			over.b0 = over.b0 + t.b0
		}
	}
	
	if (!adj) {
		//build overall table
		over.n = over.a1 + over.b1
		over.n0 = over.a0 + over.b0
		over.zero = lzero
		over.overall = 1
		d[len+1] = over
	}
	
	return(d)
}
end

version 12
mata:
struct table2x2 vector build_data_pt(real matrix data, string scalar rc, real scalar level, real scalar adj)
{
	struct table2x2 vector d
	struct table2x2 scalar t
	struct table2x2 scalar over
	real colvector a1, t1, a0, t0
	real scalar i, len, alpha, tmp
	
	a1 = data[.,2]
	t1 = data[.,3]
	a0 = get_refvector(a1,rc)	//get reference category vectors
	t0 = get_refvector(t1,rc)
	
	if (!adj) {
		over.a1 = 0		//Initialize overall data
		over.t1 = 0
		over.a0 = 0
		over.t0 = 0
	}

	alpha = (level+100)/200
	len = rows(data)
	if (!adj) d = table2x2(len+1)
	else d = table2x2(len)
	for (i=1; i<=len; i++) {
		t.a1 = a1[i]
		t.t1 = t1[i]
		t.a0 = a0[i]
		t.t0 = t0[i]
		t.overall = 0
		
		if (!adj) {
			//Rate Exact CI
			t.rate = t.a1 / t.t1
			t.lb_rate = 0
			t.ub_rate = 1
			if (t.a1>0) t.lb_rate = invchi2(2*t.a1,1-alpha)/(2*t.t1)
			if (t.t1>t.a1) t.ub_rate = invchi2(2*(t.a1+1),alpha)/(2*t.t1)

			//build overall table
			over.a1 = over.a1 + t.a1
			over.t1 = over.t1 + t.t1
			over.a0 = over.a0 + t.a0
			over.t0 = over.t0 + t.t0
		}
		if (adj) {
			tmp = t.t1 + t.t0
			//Sumatory terms for IR results
			t.nir = (t.a1 * t.t0) / tmp
			t.dir = (t.a0 * t.t1) / tmp
		}
		
		d[i] = t
	}
	
	if (!adj) {
		//build overall table
		over.rate = over.a1 / over.t1
		over.lb_rate = 0
		over.ub_rate = 1
		if (over.a1>0) over.lb_rate = invchi2(2*over.a1,1-alpha)/(2*over.t1)
		if (over.t1>t.a1) over.ub_rate = invchi2(2*(over.a1+1),alpha)/(2*over.t1)
		over.overall = 1
		d[len+1] = over
	}
	
	return(d)
}
end

version 12
mata:
void results_freq(real scalar type, real scalar stat, string scalar data, string scalar results, /*
	*/				real scalar method, real scalar level, string scalar rc, string scalar zero, real scalar k2)
{
	struct table2x2 vector t
	real matrix d, r
	real colvector m, a, n, b
	real scalar m1, m0, ntotal, sa, sm, sn, chi
	real scalar i, len, cols
	
	d = st_matrix(data)						//d: 1 metric, 2 a, 3 b
	len = rows(d)
	
	//Trend test
	m = d[.,1]
	a = d[.,2]
	b = d[.,3]
	n = a :+ b
	m1 = sum(a)
	m0 = sum(b)
	ntotal = sum(n)
	sa = sum(m :* a)
	sm = sum(m :* n)/ntotal
	sn = sum(n :* (m :- sm):^2)
	chi = (sa - m1*sm) / sqrt((m1*m0)/(ntotal^2 - ntotal)*sn)
	a = a \ sum(a)		//ADD TOTALs
	b = b \ sum(b)
	n = n \ sum(n)

	//Build data and compute results
	t = build_data_freq(d,type,stat,rc,zero,0,k2)
	for (i=1; i<=len+1; i++) {
		compute_risk_and_ci(t[i],method,level,k2)	//Risk
		t[i].odds = t[i].a1 / t[i].b1				//Odds
		compute_ratio(t[i],stat,level)				//Ratio
	}
	
	//Corrections
	if (!k2) {
		if (rc=="f" | rc=="p") t[1].ub = .
		if (rc=="f" | rc=="p") t[1].lb = .
		if (rc=="l" | rc=="s") t[rows(d)].ub = .
		if (rc=="l" | rc=="s") t[rows(d)].lb = .
	}
	
	if (type<=2) r = J(rows(d)+1,10,.)
	if (k2 & stat==1)  r = J(rows(d)+1,9,.)
	if (type==3) r = J(rows(d)+1,7,.)
	for (i=1; i<=len+1; i++) {
		if (!t[i].overall) r[i,1] = m[i]

		if (!k2) {
			if (type<=2 & stat==1) {
				r[i,2] = a[i]
				r[i,3] = n[i]
				r[i,4] = t[i].risk
				r[i,5] = t[i].lb_risk
				r[i,6] = t[i].ub_risk
				r[i,7] = t[i].ratio
				r[i,8] = t[i].lb
				r[i,9] = t[i].ub
				r[i,10]= t[i].zero
			}
			if (type<=2 & stat==2) {
				r[i,2] = a[i]
				r[i,3] = b[i]
				r[i,4] = n[i]
				r[i,5] = t[i].risk
				r[i,6] = t[i].odds
				r[i,7] = t[i].ratio
				r[i,8] = t[i].lb
				r[i,9] = t[i].ub
				r[i,10]= t[i].zero
			}
			if (type==3) {
				r[i,2] = a[i]
				r[i,3] = b[i]
				r[i,4] = t[i].ratio
				r[i,5] = t[i].lb
				r[i,6] = t[i].ub
				r[i,7] = t[i].zero
			}
		}
		else {
			//SPECIAL CASE: Response k categories & Exposure binary
			if (stat==1) {
				r[i,2] = t[i].a1
				r[i,3] = t[i].a0
				r[i,4] = t[i].r1
				r[i,5] = t[i].r0
				r[i,6] = t[i].ratio
				r[i,7] = t[i].lb
				r[i,8] = t[i].ub
				r[i,9] = t[i].zero
			}
			if (stat==2) {
				r[i,2] = t[i].a1
				r[i,3] = t[i].a0
				r[i,4] = t[i].r1
				r[i,5] = t[i].o1
				r[i,6] = t[i].o0
				r[i,7] = t[i].ratio
				r[i,8] = t[i].lb
				r[i,9] = t[i].ub
				r[i,10] = t[i].zero
			}
		}
	}
	
	r = (r, J(rows(r),1,chi^2))
	st_matrix(results,r)
}
end

version 12
mata:
void results_pt(string scalar data, string scalar results, real scalar level, string scalar rc, real scalar printci)
{
	struct table2x2 vector s
	real matrix d
	real colvector m, a, t
	real scalar i, len, m1, sa, st, sm, sls2, chi
	
	d = st_matrix(data)						//d: 1 metric, 2 a, 3 t
	len = rows(d)

	//Trend test
	m = d[.,1]
	a = d[.,2]
	t = d[.,3]
	m1 = sum(a)
	sa = sum(m :* a)
	st = sum(t)
	sm = sum(m :* t) / st
	sls2 = sum(t :* (m :- sm):^2)
	chi = (sa-(m1*sm)) / sqrt(m1/st*sls2)
	a = a \ sum(a)		//ADD TOTALs
	t = t \ sum(t)
	
	//Build data and compute results
	s = build_data_pt(d,rc,level,0)
	for (i=1; i<=len+1; i++) {	
		compute_ratio(s[i],3,level)		//Ratio
	}
	
	//Corrections
	if (rc=="f" | rc=="p") s[1].ub = .
	if (rc=="f" | rc=="p") s[1].lb = .
	if (rc=="l" | rc=="s") s[len].ub = .
	if (rc=="l" | rc=="s") s[len].lb = .

	r = J(len+1,10,.)
	for (i=1; i<=len+1; i++) {
		if (!s[i].overall) r[i,1] = m[i]
		r[i,2] = a[i]
		r[i,3] = t[i]
		r[i,4] = s[i].rate
		if (printci==1) {
			r[i,5] = s[i].lb_rate
			r[i,6] = s[i].ub_rate
		}
		else {
			r[i,5] = .
			r[i,6] = .
		}
		r[i,7] = s[i].ratio
		r[i,8] = s[i].lb
		r[i,9] = s[i].ub
	}
	
	r = (r , J(rows(r),1,chi^2))
	st_matrix(results,r)
}
end

version 12
mata:
void compute_adj(string scalar data_type, real scalar stat, string scalar data, string scalar results, real scalar type, /*
		*/		real scalar nstr, real scalar level, string scalar rc, string scalar zero)
{
	struct stratum vector s
	struct stratum vector s0
	real matrix dta, res
	real rowvector m, a, b, aover, crude, t, I, M, Z
	real scalar i, nexp
	real rowvector nrr, drr, nse
	real rowvector nor, dor, pr, ps, qr, qs
	real rowvector dir, nir
	real rowvector r, rse, rub, rlb, change
	real rowvector chi2, p, chi2BD, pBD, num, den
	real rowvector nseir, dseir
	real scalar a1, a0, t1, t0
	real scalar m1, n1, n0, ai, bi, ci, aplus, aminus, A, B, C, D, var, or
	real scalar q, eq, vq, sa, sb, sn, smn, sm2n, sma, st, chi2LT, x2, sls2, chi2H
	real scalar d1, t2, d2, ejk

	dta = st_matrix(data + strofreal(nstr))		//get overall results
	nstr = nstr-1						//number of stratum (all minus the overall -last-)
	nexp = rows(dta)-1					//number of exposure categories
	m = dta[1..nexp,1]					//get metric (m)
	aover = dta[1..nexp,2]				//get overall cases (a)
	//get crude (overall) ratios
	if (data_type=="freq" & type==3) crude = dta[1..nexp,4]		//Case-control data
	else crude = dta[1..nexp,7]
	
	//build stratum data
	s = stratum(nstr)
	s0 = stratum(nstr)
	for (i=1; i<=(nstr); i++) {
		dta = st_matrix(data + strofreal(i))		//get i stratum results
		a = dta[1..nexp,2]
		if (data_type=="freq") {
			if (stat==1) b = dta[1..nexp,3] :- a
			else b = dta[1..nexp,3]
			s[i].d = build_data_freq((m, a, b),type,stat,rc,zero,1,0)
			s0[i].d = build_data_freq((m, a, b),type,stat,rc,"n",1,0)		//get non-zero corrected data for Trend compute
		}
		if (data_type=="pt") {
			t = dta[1..nexp,3]
			s[i].d = build_data_pt((m, a, t),rc,level,1)
		}
	}
	
	//Mantel-Haenszel combined results
	//Initialize summatory terms to 0
	if (data_type=="freq" & stat==1) {
		nrr = J(nexp,1,0)
		drr = J(nexp,1,0)
		nse = J(nexp,1,0)
	}
	if (data_type=="freq" & stat==2) {
		nor = J(nexp,1,0)
		dor = J(nexp,1,0)
		pr = J(nexp,1,0)
		ps = J(nexp,1,0)
		qr = J(nexp,1,0)
		qs = J(nexp,1,0)
	}
	if (data_type=="pt") {
		nir = J(nexp,1,0)
		dir = J(nexp,1,0)
	}
	//Summatories
	for (i=1; i<=(nstr); i++) {
		for (j=1; j<=(nexp); j++) {
			if (data_type=="freq" & stat==1) {
				nrr[j] = nrr[j] + s[i].d[j].nrr		//Sumatories for RR & Bounds
				drr[j] = drr[j] + s[i].d[j].drr
				nse[j] = nse[j] + s[i].d[j].nse
			}
			if (data_type=="freq" & stat==2) {
				nor[j] = nor[j] + s[i].d[j].nor		//Sumatories for OR & Bounds
				dor[j] = dor[j] + s[i].d[j].dor
				pr[j] = pr[j] + s[i].d[j].pr
				ps[j] = ps[j] + s[i].d[j].ps
				qr[j] = qr[j] + s[i].d[j].qr
				qs[j] = qs[j] + s[i].d[j].qs
			}
			if (data_type=="pt") {
				nir[j] = nir[j] + s[i].d[j].nir		//Sumatories for IR & Bounds
				dir[j] = dir[j] + s[i].d[j].dir
			}
		}
	}
	//Compute ratios
	if (data_type=="freq" & stat==1) {
		r = nrr :/ drr						//RR
		rse = sqrt(nse :/ (nrr :* drr))		//Standard Error
	}
	if (data_type=="freq" & stat==2) {
		r = nor :/ dor						//OR
		rse = sqrt(pr :/ (2:*(nor:^2)) :+ (ps :+ qr) :/ (2:*nor:*dor) :+ qs :/ (2:*(dor:^2)))	//Standard Error
	}
	if (data_type=="pt") {
		r = nir :/ dir						//IR
		//Summatory terms for IR Bounds: IR M-H Adj estimation needed to compute IR SE
		nseir = J(nexp,1,0)
		dseir = J(nexp,1,0)
		for (i=1; i<=nstr; i++) {
			for (j=1; j<=(nexp); j++) {
				a1 = s[i].d[j].a1
				a0 = s[i].d[j].a0
				t1 = s[i].d[j].t1
				t0 = s[i].d[j].t0
				nseir[j] = nseir[j] + (t0 * t1 * (a0 + a1)) / (t0 + t1)^2
				dseir[j] = dseir[j] + (t0 * t1 * (a0 + a1)) / ((t0 + t1) * (t0 + r[j] * t1))
			}			
		}
		//Standard Error
		rse = sqrt(nseir :/ (r :* (dseir :^2)))
	}
	rub = r :* exp( invnormal((level+100)/200) :* rse)					//CI
	rlb = r :* exp(-invnormal((level+100)/200) :* rse)
	change = 100 :* abs(crude :- r) :/ r		//Change

	//Compute Homogeneity for Adjusted M-H results: Wald & Breslow-Day (for OR)
	chi2 = J(nexp,1,0)
	chi2BD = J(nexp,1,0)
	num = J(nexp,1,0)
	den = J(nexp,1,0)
	for (i=1; i<=nstr; i++) {
		for (j=1; j<=(nexp); j++) {
			compute_ratio(s[i].d[j], stat, level)
			if (data_type=="freq") {
				//Wald
				chi2[j] = chi2[j] + ((ln(s[i].d[j].ratio) - ln(r[j]))^2 ) / (s[i].d[j].se^2)
				
				//Breslow & Day
				if (stat==2) {
					b1 = s[i].d[j].b1
					b0 = s[i].d[j].b0
					m1 = s[i].d[j].a0 :+ s[i].d[j].a1
					n1 = s[i].d[j].n
					n0 = s[i].d[j].n0
					
					//Use formula 4:11 (Breslow & Day, p.130) to find Ai (using the previously computed M-H estimation of OR)
					or = r[j]
					ai = 1 - or		//Compute the terms of the quadratic equation of Ai (Ai=x, given ax2 + bx + c = 0)
					bi = n0 + (or * n1) + (m1 * (or - 1))
					ci = -or * n1 * m1
					//To find Ai, solve the quadratic equation: x = (-b +/- SQR(b^2 - 4ac))/2a
					aplus = (-bi + sqrt((bi^2) - (4 * ai * ci))) / (2*ai)		//Root using the +
					aminus =(-bi - sqrt((bi^2) - (4 * ai * ci))) / (2*ai)		//Root using the -
					//A,B,C,D quantities of 4:10 (Breslow & Day, p.130) for Ai+, Ai-
					//Only one root Ai+, Ai- is correct: A,B,C,D must be all positive
					if (aplus>0 & (n1-aplus)>0 & (m1-aplus)>0 & (n0-m1+aplus)>0) A = aplus
					if (aminus>0 & (n1-aminus)>0 & (m1-aminus)>0 & (n0-m1+aminus)>0) A = aminus
					B = n1 - A
					C = m1 - A
					D = n0 - m1 + A
					//To compute the Variance use the formula 4:13 (Breslow & Day, p.130) with the correct A,B,C,D
					var = 1/(1/A + 1/B + 1/C + 1/D)
					//Use formula 4:30 (Breslow & Day, p.142) to find the homogeneity statistic with the found Ai,VARi
					chi2BD[j] = chi2BD[j] + (s[i].d[j].a1 - A)^2/var
				}
			}
			if (data_type=="pt") {
				//Person-Time Chi2 Summatories
				num[j] = num[j] + (s[i].d[j].t1 * (s[i].d[j].a0 + s[i].d[j].a1) / (s[i].d[j].t0 + s[i].d[j].t1))
				den[j] = den[j] + ((s[i].d[j].a0 + s[i].d[j].a1) * s[i].d[j].t0 * s[i].d[j].t1 / ((s[i].d[j].t0 + s[i].d[j].t1)^2))
			}
		}
	}
	if (data_type=="pt") chi2 = ((abs(aover :- num) :- 1/2) :/ sqrt(den)):^2
	p = 1 :- chi2(nstr-1,chi2)
	pBD = 1 :- chi2(nstr-1,chi2BD)
	
	//First and Last correction
	if (rc == "f" | rc=="p") {
		if (rc=="p") r[1] = .
		change[1] = .
		rub[1] = .
		rlb[1] = .
		chi2[1] = .
		p[1] = .
		chi2BD[1] = .
		pBD[1] = .
	}
	if (rc == "l" | rc=="s") {
		if (rc=="s") r[nexp] = .
		change[nexp] = .
		rub[nexp] = .
		rlb[nexp] = .
		chi2[nexp] = .
		p[nexp] = .
		chi2BD[nexp] = .
		pBD[nexp] = .
	}
	
	//MH Test for linear Trend & Homogeneity of Linear trends for frequency data
	q = 0
	eq = 0
	vq = 0
	x2 = 0
	M = J(nstr,1,.)
	I = J(nstr,1,.)
	for (i=1; i<=nstr; i++) {
		sa = 0
		sma = 0
		sb = 0
		sn = 0
		smn = 0
		sm2n = 0
		st = 0
		for (j=1; j<=(nexp); j++) {
			if (data_type=="freq") {
				//Computing Q, EQ and VQ
				sa = sa + s0[i].d[j].a1
				sma = sma + m[j] * s0[i].d[j].a1
				sb = sb + s0[i].d[j].b1
				sn = sn + s0[i].d[j].n
				smn = smn + m[j] * s0[i].d[j].n
				sm2n = sm2n + m[j]^2 * s0[i].d[j].n
			}
			if (data_type=="pt") {
				sa = sa + s[i].d[j].a1
				st = st + s[i].d[j].t1
			}
		}
		if (data_type=="freq") {
			//Computing Q, EQ and VQ
			q = q + sma
			eq = eq + (sa/sn) * smn
			vq = vq + (sa*sb)/((sn^2)*(sn-1)) * (sn*sm2n-smn^2)
			
			//Strata trend test
			sls2 = 0
			for (j=1; j<=(nexp); j++) {
				sls2 = sls2 + s0[i].d[j].n * (m[j] - (smn/sn))^2
			}
			x2 = x2 + ((sma- (sa*(smn/sn)))/sqrt(sa*sb*sls2/(sn^2-sn)))^2
		}
		if (data_type=="pt") {
			M[i] = sa
			I[i] = sa/st
		}
	}
	if (data_type=="freq") {
		chi2LT = ((q-eq)/sqrt(vq))^2		//MH Test for linear Trend
		chi2H = x2 - chi2LT					//Homogeneity of Linear trends
	}
	if (data_type=="pt") {
		//MH Test for linear Trend: formula 3.25, p.114 Breslow & Day
		E = J(nexp,1,0)
		for (k=1; k<=nexp; k++) {
			for (j=1; j<=nstr; j++) {
				E[k] = E[k] + s[j].d[k].t1 * I[j]
			}
		}
		t1 = 0
		d1 = 0
		for (k=1; k<=nexp; k++) {
			t1=t1 + m[k]*(aover[k]-E[k])
			d1=d1 + m[k]^2*E[k]
		}
		d2 = 0
		for (j=1; j<=nstr; j++) {
			t2=0
			for (k=1; k<=nexp; k++) {
				ejk = s[j].d[k].t1*I[j]
				t2 = t2 + m[k]*ejk
			}
			d2=d2 + t2/M[j]
		}
		chi2LT = t1^2/(d1-d2)
		chi2H = .		//NO Homogeneity for person-time data
	}

	//check for zero correction
	Z = J(nexp,1,0)
	if (data_type=="freq") {
		for (i=1; i<=nstr; i++) {
			for (j=1; j<=(nexp); j++) {
				if (s[i].d[j].zero) Z[j] = 1
			}
		}
	}
	
	//Return data
	if (data_type=="freq" & stat==2) res = (crude, r, rlb, rub, change, chi2BD, pBD, chi2, p)
	if ((data_type=="freq" & stat==1) | data_type=="pt") res = (crude, r, rlb, rub, change, chi2, p)
	res = (m, res, J(nexp,1,chi2LT), J(nexp,1,chi2H), Z)
	st_matrix(results,res)
}
end

version 12
mata:
void compute_risk_and_ci(struct table2x2 scalar t, real scalar method, real scalar level, real scalar k2)
{
	real scalar a, n, r, lb, ub, wa, wb, wc, z, alpha
	
	if (!k2) {
		a = t.a1
		n = t.n
		z = invnormal((level+100)/200)
		
		r = a / n		//risk = a/n
		lb = .
		ub = .
		if (method == 1) {
			wa = 2*a + z^2					//Wilson
			wb = z*sqrt(z^2 + 4*a*(n-a)/n)
			wc = 2*(n + z^2)
			lb = (wa - wb)/wc
			ub = (wa + wb)/wc
		}
		if (method == 2) {
			alpha = (level+100)/200			//Exact
			lb = 0
			ub = 1
			if (a>0) lb = a/(a+(n-a+1)*invF(2*(n-a+1),2*a,alpha))
			if (n>a) ub = (a+1)/((a+1)+((n-a)/invF(2*(a+1),2*(n-a),alpha)))
		}
		if (method == 3) {
			lb = r - z*sqrt(r*(1-r)/ n)		//Wald
			ub = r + z*sqrt(r*(1-r)/ n)
		}

		t.risk = r
		t.lb_risk = lb
		t.ub_risk = ub
	}
	else {
		//SPECIAL CASE: Response k categories & Exposure binary
		if (!t.overall) {
			t.r1 = t.a1 / t.n
			t.r0 = t.a0 / t.n0
			t.o1 = t.a1 / t.b1
			t.o0 = t.a0 / t.b0
		}
		else {
			t.r1 = 1
			t.r0 = 1
			t.o1 = 1
			t.o0 = 1
		}
	}
}
end

version 12
mata:
void compute_ratio(struct table2x2 t, real scalar stat, real scalar level)
{
	if (!t.overall) {
		if (stat==1) {
			//Risk Ratio
			t.ratio = (t.a1 / t.n) / (t.a0 / t.n0)
			t.se = sqrt(1/t.a0 - 1/t.n0 + 1/t.a1 - 1/t.n)
		}
		if (stat==2) {
			//Odds Ratio
			t.ratio = (t.a1 / t.b1) / (t.a0 / t.b0)
			t.se = sqrt(1/t.a0 + 1/t.b0 + 1/t.a1 + 1/t.b1)
		}
		if (stat==3) {
			//Rate Ratio
			t.ratio = (t.a1 / t.t1) / (t.a0 / t.t0)
			t.se = sqrt(1/t.a0 + 1/t.a1)
		}
		t.ub = t.ratio * exp( invnormal((level+100)/200)*t.se)
		t.lb = t.ratio * exp(-invnormal((level+100)/200)*t.se)
	}	
}
end

version 12
mata:
void zero_correction(struct table2x2 scalar t, real scalar type, string scalar zero)
{
/*
	n  NONE
	c (Constant, add k=0.5 to each cell)
	p (Proportional, add k1=n1/n and k0=n0/n for co & cs studies)
					 add k1=m1/n and k0=m0/n for cc studies)
	r (Reciprocal, add k1=1/n0 and k0=1/n1 for co & cs studies)
				   add k1=1/m0 and k0=1/m1 for cc studies)
*/
	real scalar k1, k0
	real scalar n1, n0, m1, m0, n
		
	t.zero = 0
	if (zero!="n") {
		if ((t.a1==0 | t.b1==0) & (t.a0==. & t.b0==.)) {
			/*There are 0 cell events and there's no reference category
			  For example, the ref cat is previous and there's a 0 in the first category
			  DON'T ZERO CORRECT*/
		}
		else {
			n1 = t.a1 + t.b1
			n0 = t.a0 + t.b0
			m1 = t.a1 + t.a0
			m0 = t.b1 + t.b0
			n = n1 + n0

			if (t.a1==0 | t.b1==0 | t.a0==0 | t.b0==0) {
				//There's some cell with zero values: continuity correction
				if (zero=="c") {
					k1 = 0.5
					k0 = 0.5
				}
				else {
					if (type<=2) {
						//co & cs studies
						if (zero=="p") k1 = n1/n
						if (zero=="p") k0 = n0/n
						if (zero=="r") k1 = 1/n0
						if (zero=="r") k0 = 1/n1
					}
					if (type==3) {
						//cc studies
						if (zero=="p") k1 = m1/n
						if (zero=="p") k0 = m0/n
						if (zero=="r") k1 = 1/m0
						if (zero=="r") k0 = 1/m1
					}
				}
				
				//Apply the correction
				if (type<=2) {
					//co & cs studies
					t.a1 = t.a1 + k1
					t.b1 = t.b1 + k1
					t.a0 = t.a0 + k0
					t.b0 = t.b0 + k0
				}
				if (type==3) {
					//cc studies
					t.a1 = t.a1 + k1
					t.b1 = t.b1 + k0
					t.a0 = t.a0 + k1
					t.b0 = t.b0 + k0
				}
				t.zero = 1
			}
		}
	}
}

version 12
mata:
real colvector get_refvector(real colvector d, string scalar rc)
{
	real colvector ref
	real scalar len, i
	
	len = rows(d)
	if (rc == "f") ref = J(len,1,d[1])
	if (rc == "l") ref = J(len,1,d[len])
	if (rc == "p") {
		ref = J(len,1,.)
		for (i=2; i<=len; i++) {
			ref[i] = d[i-1]
		}
	}
	if (rc == "s") {
		ref = J(len,1,.)
		for (i=1; i<len; i++) {
			ref[i] = d[i+1]
		}
	}

	return(ref)
}
end

version 12
mata:
void get_array(string scalar s, string scalar token, string scalar res)
{
	string matrix d
	real matrix r
	real scalar i	
	d = tokens(s,token)
	r = strtoreal(tokens(d[1]))
	for (i=2; i<=cols(d); i++) {
		if (d[i]!="\") r = r \ strtoreal(tokens(d[i]))
	}
	st_matrix(res,r)
}
end

version 12
mata:
void get_overall (string scalar data, real scalar nstr, string scalar over)
{
	real matrix d, o, a, b, m
	real scalar i
	d = st_matrix(data)
	m = select(d, d[.,4] :== 1)[.,1]
	a = select(d, d[.,4] :== 1)[.,2]
	b = select(d, d[.,4] :== 1)[.,3]	
	for (i=2; i<=nstr; i++) {
		a = a :+ select(d, d[.,4] :== i)[.,2]
		b = b :+ select(d, d[.,4] :== i)[.,3]
	}
	o = (m, a, b)
	st_matrix(over,o)
}
end
