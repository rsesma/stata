*! version 1.0.7  05oct2016 JM. Domenech, R. Sesma
/*
Data Check - Incidence Report
*/

program define dcreport
	version 12
	syntax [varlist], id(varlist) [idnum]

	*Default names for identifier variables
	if ("`id'"=="") print_error "missing id option"
	confirm variable `id'
	
	local obsnum "_ObsNum"
	confirm variable `obsnum'

	*Find the _Er_ vars of varlist: necessary if there's no varlist
	local vars ""
	foreach var of varlist `varlist' {
		local name `var'
		if (substr("`var'",1,4)=="_Er_") & ("`var'"!="_Er_TOTAL") & ("`var'"!="_Er__id") {
			local oname = substr("`var'",5,.)
			local lid : list oname in id
			
			if (!`lid') local vars = "`vars' `var'"
		}
	}

	*Generate the TOTAL errors variable: number of errors for each case
	capture confirm variable _Er_TOTAL
	if (!_rc) drop _Er_TOTAL
	qui	egen _Er_TOTAL = anycount(`vars'), values(1/99)

	*Error summary
	local ntotvars : list sizeof vars		//Number of variables
	local totvals = `ntotvars' * _N			//Total number of values: # of vars * # of cases
	qui summarize _Er_TOTAL
	local toterrors = r(sum)				//Total number of error values (as stored in _Err_TOTAL)
	local totcorrect = `totvals' - `toterrors'
	local perrors = (`toterrors'/`totvals')*100
	local pcorrect = 100 - `perrors'
		
	*Print header and incidence summary
	display "DATA CHECK - INCIDENCE REPORT"
	display ""
	display "INCIDENCE SUMMARY {hline 31}"
	display as txt "Total ERRORS .............. = " as res %7.0f `toterrors' " (" %5.2f `perrors' " %)"
	display as txt "Total correct values ...... = " as res %7.0f `totcorrect' " (" %5.2f `pcorrect' " %)"
	display "{hline 49}"
	
	*If there are errors, print a list and the error correction commands
	if (`toterrors'>0) {
		preserve
		qui keep if _Er_TOTAL > 0		//Only the error cases are of interest
		local itot = _N
		*Loop through the error cases and print the values
		forvalues i = 1/`itot'{
			*Get the id value for the list
			local idval
			foreach vid of varlist `id' {
				*The id can be multiple (+1 variable): loop
				local tv : type `vid'
				local fv : format `vid'
				*Get the formatted value
				if (substr("`tv'",1,3)=="str") local val = `vid'[`i']
				else local val = string(`vid'[`i'],"`fv'")			//For numeric/date values, get the formatted value
				if ("`idval'"=="") local idval = "`vid' = `val'"
				else local idval = "`idval' & `vid' = `val'"
			}
			*Print the errors for each case
			display ""
			display as txt "Identifier:  "  as res "`idval'"
			display as txt "_ObsNum: " as res %7.0f `obsnum'[`i'] as txt " ; Number of errors = " as res _Er_TOTAL[`i']
			display "{hline 49}"
			foreach var of varlist `vars' {
				if (`var'[`i']>0) {
					local v = subinstr("`var'","_Er_","",.)
					local fv : format `v'
					display abbrev("`v'",12) _col(12) " = " `fv' `v'[`i']
				}
			}
			display "{hline 49}"
		}

		*Loop through the error cases and print the error correction command
		display ""
		display as res "ERROR CORRECTION COMMANDS"
		display "{hline 49}"
		forvalues i = 1/`itot'{
			*Create the select identifier string
			local idval
			if ("`idnum'"=="") {
				*Use the id variables to select
				foreach vid of varlist `id' {
					local tv : type `vid'
					local fv : format `vid'
					if (substr("`tv'",1,3)=="str") {
						*String variable: quote value ({c 34} = ")
						local val = `vid'[`i']
						local val = "{c 34}`val'{c 34}"
					}
					else {
						*Numeric / date value
						if (substr("`fv'",1,2)=="%t") {
							*Date value (only %td dates are allowed): get day, month and year
							local d = day(`vid'[`i'])
							local m = month(`vid'[`i'])
							local y = year(`vid'[`i'])
							*To select, use the date function
							local val = "mdy(`m',`d',`y')"
						}
						else {
							*Numeric value: get the string representation with the right format
							local val = string(`vid'[`i'],"`fv'")
						}
					}
					if ("`idval'"=="") local idval = "`vid'==`val'"
					else local idval = "`idval' & `vid'==`val'"
				}
			}
			else {
				local val = `obsnum'[`i']
				local idval = "`obsnum' == `val'"
			}
			
			*Error correction commands
			foreach var of varlist `vars' {
				if (`var'[`i']>0) {
					local v = subinstr("`var'","_Er_","",.)		//Original variable
					local tv : type `v'
					local fv : format `v'
					if (substr("`tv'",1,3)=="str") {
						*String value: default value is null string ""
						display "replace `v' = {c 34}{c 34} if `idval'"
					}
					else {
						if (substr("`fv'",1,2)=="%t") {
							*Date value: default value is missing: use date function for inserting the correct value (if available)
							display "replace `v' = mdy(.,0,0) if `idval'"
						}
						else {
							*Numeric value: default value is .
							display "replace `v' = . if `idval'"
						}
					}
					
				}
			}
		}
		restore
	}
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end
