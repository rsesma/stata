*! version 1.1.1  04may2018 JM. Domenech, R. Sesma

program define cohenkap, byable(recall)
	version 12
	syntax varlist(min=2 max=2 numeric) [if] [in], /*
	*/	[Wilson Exact WAld Level(numlist max=1 >50 <100) ordered nst(string)]
	
	tokenize `varlist'
	local y `1'
	local x `2'
	
	if ("`y'"=="`x'") print_error "X and Y variables can't be the same"

	marksample touse					//ifin marksample
	qui count if `touse'
	if (r(N)==0) print_error "no observations"

	*Get Y & X variable values and join (should be the same list of values in general)
	qui levelsof `y' if `touse', local(vy)
	qui levelsof `x' if `touse', local(vx)
	local values : list vy | vx
	local values : list sort values

	local d
	foreach i in `values' {
		foreach j in `values' {
			qui count if `touse' & `y'==`i' & `x'==`j'
			local v = r(N)
			local d `d' `v'
		}
		local d = "`d' \"
	}
	local d = substr("`d'",1,length("`d'")-1)

	cohenkapi `d', `wilson' `wald' `exact' level(`level') `ordered' nst("`nst'") _vy(`y') _vx(`x') _values(`values')
end


program define print_error
	args message
	display in red "`message'" 
	exit 198
end
