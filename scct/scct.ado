*! version 1.0.6  30sep2019 JM. Domenech, R. Sesma
/*
scct: Stochastic curtailment (immediate command)
*/

program define scct
	version 12
	syntax anything(id="argument numlist"), /*
	*/	Alpha(numlist max=1 >0 <50) Beta(numlist max=1 >0 <50) [CP1(numlist max=1 >=50 <100) nst(string)]

	local n : word count `anything'
	if (`n'!=3) print_error "t, cp0 and cp1 are needed"
	tokenize `anything'
	local t `1'			//Percentage of information accrued
	local cp0  `2'		//Conditional power under null hypothesis
	local cp1  `3'		//Conditional power under alternative hypothesis
	
	confirm number `t'
	confirm number `cp0'
	confirm number `cp1'
	
	if (`t'<=0 | `t'>100) print_error "invalid t -- 0 < t <= 100"
	if (`cp0'<50 | `cp0'>=100) print_error "invalid cp0 -- 50 <= cp0 < 100"
	if (`cp1'<50 | `cp1'>=100) print_error "invalid cp1 -- 50 <= cp1 < 100"
	
	*Compute results
	local t = `t'/100
	local z0= invnormal(1-`cp0'/100)
	local z1= invnormal(`cp1'/100)
	
	foreach i of numlist 1/2 {
		local za`i' = invnormal(1-`alpha'/(`i'*100))
		local zb`i' = `za`i'' + invnormal(1-`beta'/100)
		
		local ztr`i' = (`za`i'' - `z0'*sqrt(1-`t'))/sqrt(`t')
		if (`i'==2) local ztr2n = -1*`ztr2'
		local ptr`i' = (1-normal(`ztr`i''))*`i'
		
		local zta`i' = (`za`i'' - `z1'*sqrt(1-`t') - `zb`i''*(1-`t'))/sqrt(`t')
		if (`i'==2) local zta2n = -1*`zta2'
		local pta`i' = (1-normal(`zta`i''))*`i'
	}

	*Print results
	di as res "STOCHASTIC CURTAILMENT: Clinical trials"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	di
	di as txt "Risk: Alpha= {bf:`alpha'}%    Beta= {bf:`beta'}%"
	di as txt "Conditional power: under H0= {bf:`cp0'}%  under H1= {bf:`cp1'}%"
	local t = `t'*100
	di as txt "Accrued information= {bf:`t'}%"
	di
	di as txt "{hline 6}{c TT}{hline 23}{c TT}{hline 22}{c TT}{hline 25}"
	di as txt " TEST {c |}" _col(16) "Z value" _col(31) "{c |}" _col(41) "P value" _col(54) "{c |} DECISION"
	di as txt "{hline 6}{c +}{hline 23}{c +}{hline 22}{c +}{hline 25}"
	di as txt " TWO  {c |}{bf:+infinity} to" _col(21) as res %9.5f `ztr2' " {c |} 0" /*
		*/	as txt _col(41) " to " as res %7.6f `ptr2' as txt " {c |} STOP: Beneficial effect"
	if (`zta2'>0) {
		di as txt "SIDED {c |}" as res %9.5f `ztr2' as txt " to " as res %9.5f `zta2' " {c |} " /*
			*/ %7.6f `ptr2' as txt " to " as res %7.6f `pta2' as txt " {c |} CONTINUE"
		di as res _col(7) "{c |}" as res %9.5f `zta2' as txt " to " as res %9.5f `zta2n' " {c |} " /*
			*/ %7.6f `pta2' as txt " to " as res "1" as txt _col(54) "{c |} STOP: Lack of power (H0)"
		di as res _col(7) "{c |}" as res %9.5f `zta2n' as txt " to " as res %9.5f `ztr2n' " {c |} " /*
			*/ %7.6f `pta2' as txt " to " as res %7.6f `ptr2' as txt " {c |} CONTINUE"
	}
	else {
		di as txt "SIDED {c |}" as res %9.5f `ztr2' as txt " to " as res %9.5f `ztr2n' " {c |} " /*
			*/ %7.6f `ptr2' as txt " to " as res "1" as txt _col(54) "{c |} CONTINUE"
	}
	di as res _col(7) "{c |}" as res %9.5f `ztr2n' as txt " to {bf:-infinity}" _col(31) "{c |} " /*
			*/ as res %7.6f `ptr2' as txt " to " as res "0" _col(54) as txt "{c |} STOP: Harmful effect"

	di as txt "{hline 6}{c +}{hline 23}{c +}{hline 22}{c +}{hline 25}"
	di as txt " ONE  {c |}{bf:+infinity} to" _col(21) as res %9.5f `ztr1' " {c |} 0" /*
		*/	as txt _col(41) " to " as res %7.6f `ptr1' as txt " {c |} STOP: Beneficial effect"
	di as txt "SIDED {c |}" as res %9.5f `ztr1' as txt " to " as res %9.5f `zta1' " {c |} " /*
		*/ %7.6f `ptr1' as txt " to " as res %7.6f `pta1' as txt _col(54) "{c |} CONTINUE"
	di as res _col(7) "{c |}" as res %9.5f `zta1' as txt " to {bf:-infinity}" _col(31) "{c |} " /*
			*/ as res %7.6f `pta1' as txt " to " as res "1" _col(54) as txt "{c |} STOP: Lack of power (H0)"
	di as txt "{hline 6}{c BT}{hline 23}{c BT}{hline 22}{c BT}{hline 25}"
	
end


program define print_error
	args message
	display in red "`message'" 
	exit 198
end
