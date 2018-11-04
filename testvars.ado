program testvars
	version 12
	syntax varlist(min=1), [p(numlist >0 integer) v(varname) id(varlist)]

  if ("`id'"=="") local id "Id"

	local n : word count `varlist'
	forvalues i = 1/`n' {
		local var: word `i' of `varlist'
		local pi : word `i' of `p'
		if ("`v'"=="") generate _t`var' = (`var' == _`var')
		if ("`v'"!="") generate _t`var' = (`var' == `v')
		quietly summarize _t`var'
		if r(min) == 0 {
			display "{bf:{ul:""Pregunta"" `pi' ""- Hay errores""}}"
			if ("`v'"=="") list `id' `var' _`var' if (_t`var' == 0), noobs sep(0)
			if ("`v'"!="") list `id' `var' `v' if (_t`var' == 0), noobs sep(0)
		}
		else {
			display "{bf:{ul:""Pregunta"" `pi' ""- NO Hay errores""}}"
		}
		drop _t`var'
	}

end
