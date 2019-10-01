*! version 1.0.8 30sep2019 JM. Domenech, R. Sesma

/*
Kruskal-Wallis equality-of-populations rank test and non-parametric pairwise comparisons across the levels of factor variables
*/

program define pwkwallis, rclass
	version 12
	syntax varname(numeric) [if] [in], by(varname numeric) [BONferroni]

	tempname sumR2 N H S2 SE0 P
	tempvar R R2
	
	if "`varlist'" == "`by'" {
		display in red "outcome variable can't be the group defining variable" 
		exit 198		
	}
	local adj = ("`bonferroni'"!="")	

	marksample touse					//ifin marksample
	
	*Kruskal-Wallis
	kwallis `varlist' if `touse', by(`by')
	scalar `H' = r(chi2_adj)

	quietly {
		egen `R' = rank(`varlist') if `touse'	//Sort answers
		generate `R2' = `R'^2  if `touse'
		summarize `R2'				//R2 sum, N (number of cases)
		scalar `sumR2' = r(sum)
		scalar `N' = r(N)
	}

	preserve
	quietly collapse (sum) Ri = `R' (count) ni = `R' if `touse', by(`by')		//Ri, ni with collapse
	quietly generate Rm = Ri/ni		//Rm: mean Ri
	local k = _N					//k: number of groups
	
	scalar `S2' = (1/(`N'-1))*(`sumR2' - (`N'*(`N'+1)^2)/4)
	scalar `SE0' = `S2'*(`N'-1-`H')/(`N'-`k')

	*Compute contrast, std err, t, p no adj pairwise
	quietly levelsof `by', local(levels)
	local ncomb = (`k'*(`k'-1))/2		//number of combinations of n elements chosing r: n!/(r!(n-r)!); if r=2, ncomb = (n*(n-1))/2
	matrix `P' = J(`ncomb',4,.)
	local c 1
	local rowlbls ""
	forvalues i = 1/`k' {
		local t = `i'+1
		forvalues j = `t'/`k' {	
			matrix `P'[`c',1] = Rm[`i'] - Rm[`j']
			matrix `P'[`c',2] = sqrt(`SE0'*(1/ni[`i'] + 1/ni[`j']))
			matrix `P'[`c',3] = abs(`P'[`c',1])/`P'[`c',2]
			matrix `P'[`c',4] = 2*ttail(`N'-`k',`P'[`c',3])
			
			tempname lbl`c'
			local vali : word `i' of `levels'
			local valj : word `j' of `levels'
			scalar `lbl`c'' = "`vali' vs `valj'"
			local rowlbls = "`rowlbls' `vali'vs`valj'"

			local c = `c'+1
		}
	}
	restore
	
	if (`adj') {
		matrix `P' = `P' , J(`ncomb',1,.)		//add column for manual bonferroni correction, NOT using _mtest command
		forvalues i = 1/`ncomb' {
			matrix `P'[`i',5] = 1 - (1-`P'[`i',4])^(`k'*(`k'-1)/2)
		}
		*for Holm and Sidak correction, use _mtest command
		_mtest adjust `P', mtest(holm) pindex(4) append
		_mtest adjust r(result), mtest(sidak) pindex(4) append
		matrix `P' = r(result)
	}

	*Print results
	di
	di as res "Pairwise comparisons"
	di as txt "{hline 13}{c TT}" cond(`adj',"{hline 62}","{hline 38}")
	di as txt  _col(14) "{c |}" _col(40) "{ralign 13:Non corrected}" _c
	if (`adj') di as txt "{ralign 8:Bonferr}{ralign 8:Holm}{ralign 8:Sidak}" _c
	di as txt _n _col(14) "{c |}  {ralign 9:Contrast}  {ralign 9:Std. Err.}  {ralign 6:t}{ralign 8:P>|t|}" _c
	if (`adj') di as txt "{ralign 8:P>|t|}{ralign 8:P>|t|}{ralign 8:P>|t|}" _c
	di as txt _n "{hline 13}{c +}" cond(`adj',"{hline 62}","{hline 38}")
	local c = abbrev("`by'",12)
	di as txt "{ralign 12:`c'} {c |}" _c
	local nrows = rowsof(`P')
	local ncols = colsof(`P') 
	forvalues i=1/`nrows' {
		local c = `lbl`i''
		di as txt _newline "{ralign 12:`c'} {c |}" _c
		forvalues j=1/`ncols' {
			local fmt = cond(`j'<=2,"%9.0g",cond(`j'==3,"%6.0g","%6.4f"))
			di as res "  " `fmt' `P'[`i',`j'] _c
		}
	}
	di as txt _newline "{hline 13}{c BT}" cond(`adj',"{hline 62}","{hline 38}")
	
	*Stored results
	matrix rownames `P' = `rowlbls'
	if (!`adj') matrix colnames `P' = Contrast StdErr t NonCorr
	else matrix colnames `P' = Contrast StdErr t NonCorr Bonferr Holm Sidak
	return matrix results = `P'
end
