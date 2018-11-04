program xum
	version 12
	syntax varlist(min=1), values(numlist)

	*change values into user missings on varlist variables	
	local umlist "abcdefghijklmnopqrstuvwxyz"		//list of possible user missing values

	foreach var of varlist `varlist' {
		local i 1
		foreach val of numlist `values' {
			*user missing value to use
			local um = "." + substr("`umlist'",`i',1)
			
			*update value label (if needed)
			local dic : value label `var'
			if ("`dic'"!="") {
				local lbl : label `dic' `val', strict
				if ("`lbl'"!="") {
					label define `dic' `val' "", modify		//erase old label
					label define `dic' `um' "`lbl'", add	//add new label
				}
			}
			
			*change numeric value to user missing
			mvdecode `var', mv(`val' = `um')
			
			local i = `i'+1
		}
	}
end
