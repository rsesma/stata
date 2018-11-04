*! version 1.0.9  19oct2017 JM. Domenech, R. Sesma
/*
Data Checking
*/

program define dc
	version 12
	syntax [varlist], /*
	*/	[isid vl(string) nd(integer 0) table(string) vk(name) di(string) df(string)   		/*
	*/ 	 dd(string) ddl(numlist min=1 max=1 >0) ddu(numlist min=1 max=1 >0) ddunit(string) 	/*
	*/	 nomissing nodups varl(varlist) id(varlist)		/*
	*/	 code1(numlist integer max=1 >=10) expr1(string) code2(numlist integer max=1 >=10) expr2(string)	/*
	*/	 code3(numlist integer max=1 >=10) expr3(string) code4(numlist integer max=1 >=10) expr4(string)	/*
	*/	 code5(numlist integer max=1 >=10) expr5(string)]
	
	tempfile fdic
	
	local obsnum "_ObsNum"		//variable name with the original sequence number
	confirm variable `obsnum'	//_ObsNum variable is needed
	
	*Default values
	if ("`ddunit'"=="") local ddunit "days"
	confirm variable `obsnum'
	if ("`table'"!="") confirm file "`table'"

	*Test options
	if ("`ddunit'"!="days" & "`ddunit'"!="years") print_error "ddunit option with wrong value"
	if ("`vl'"!="" & ("`table'"!="" | "`di'"!="" | "`df'"!="" | "`dd'"!="" | "`ddl'"!="" |     /*
	*/	"`ddu'"!="")) print_error "too much options"
	if ("`table'"!="" & ("`vl'"!="" | "`di'"!="" | "`df'"!="" | "`dd'"!="" | "`ddl'"!="" |     /*
	*/	"`ddu'"!="")) print_error "too much options"
	if (("`di'"!="" & "`df'"=="") | ("`di'"=="" & "`df'"!="")) print_error "missing option di or df"
	if (("`di'"!="" & "`df'"!="") & ("`vl'"!="" | "`dd'"!="" | "`ddl'"!="" |     /*
	*/	"`ddu'"!="")) print_error "too much options"
	if (("`dd'"!="" & ("`ddl'"=="" | "`ddu'"=="")) | ("`ddl'"!="" & ("`dd'"=="" | "`ddu'"=="")) | /*
	*/	("`ddu'"!="" & ("`ddl'"=="" | "`dd'"==""))) print_error "missing option dd, ddl or ddu"
	if (("`dd'"!="" & "`ddl'"!="" & "`ddu'"!="") & ("`vl'"!="" | "`di'"!="" | "`df'"!="")) print_error "too much options"

	foreach i of numlist 1/5 {
		if ("`code`i''"!="" & "`expr`i''"=="") print_error "missing option expr`i'"
		if ("`code`i''"=="" & "`expr`i''"!="") print_error "missing option code`i'"
	}
	
	*Error variable value labels
	qui label define _Err__dic 0 "No errors" 1 "Missing" 2 "Out of range" 3 "Precision error" 4 "Duplicate", replace

	display "DATA CHECK"
	if ("`isid'"!="") {
		*Id: check for duplicates and missings
		quietly {
			capture confirm variable _Er__id
			if (!_rc) drop _Er__id

			duplicates tag `varlist', generate(_Er__id)
			recode _Er__id (0=0) (else=4)
			foreach var in `varlist'{
				replace _Er__id = 1 if `var'==.
			}
		}
		label values _Er__id _Err__dic
		*There's errors
		qui count if _Er__id>0
		display ""
		if (r(N)>0) {
			qui count if _Er__id==4
			if (r(N)>0) {
				di as res "Duplicates in terms of `varlist'"
				list `obsnum' `varlist' if _Er__id==4, noobs abb(12) sep(0)
			}
			qui count if _Er__id==1
			if (r(N)>0) {
				di as res "Missing values in terms of `varlist'"
				list `obsnum' `varlist' if _Er__id==1, noobs abb(12) sep(0)
			}
		}
		else {
			di as res "NO Errors found in terms of `varlist'"
		}
	}
	else {
		if ("`id'"=="") print_error "missing id option"
		confirm variable `id'
		
		local extravars ""
		local i 1
		foreach var in `varlist'{
			tempvar vl_err`i' nd_err`i' dic_err`i' dd`i' dup_err`i'

			quietly {
				*If the err_ var exists, clean with 0; if not, create as 0
				local err_v = "_Er_`var'"
				capture confirm variable `err_v'
				if (!_rc) replace `err_v' = 0
				else generate `err_v' = 0

				//Logical checks
				foreach j of numlist 1/5 {
					if ("`code`j''"!="") {
						replace `err_v' = `code`j'' if (`expr`j'')
					}
				}
				
				*Get var type ("str" if var is string)
				local vtype : type `var'
				local vtype = substr("`vtype'",1,3)

				if ("`vtype'"=="str") {
					*Check string variables
					if ("`vl'"!="") {
						*Check with a list of valid string values
						generate `vl_err`i'' = 2 if !missing(`var')
						foreach el in `vl'{
							replace `vl_err`i'' = 0 if `var' == `"`el'"'
						}
						replace `err_v' = `vl_err`i'' if `vl_err`i'' != 0 & !missing(`vl_err`i'')
					}
				}
				else {
					*Check numeric variables
					if ("`vl'"!="") {
						*Check with a list of valid values
						recode `var' (`vl'=0)(else=2) if !missing(`var'), generate(`vl_err`i'')
						replace `err_v' = `vl_err`i'' if `vl_err`i''!=0 & !missing(`vl_err`i'')
					}

					*Check number of decimals
					generate `nd_err`i'' = 3 if mod(`var'*10^`nd',1)>0 & !missing(`var')
					replace `err_v' = `nd_err`i'' if `nd_err`i'' != 0 & !missing(`nd_err`i'')
					
					*Date check
					if ("`di'"!="" & "`df'"!="") {
						*Date range
						replace `err_v' = 2 if (`var'<date("`di'","DMY") | `var'>date("`df'","DMY")) & !missing(`var')
					}
					if ("`dd'"!="" & "`ddl'"!="" & "`ddu'"!="") {
						*Date difference
						generate `dd`i'' = `dd'
						if ("`ddunit'"=="years") replace `dd`i'' = `dd`i''/365.25
						replace `err_v' = 2 if (`dd`i''<`ddl' | `dd`i''>`ddu') & !missing(`dd`i'')
						local dref = trim(subinstr(subinstr("`dd'","`var'","",.),"-","",.))
						local extravars = "`extravars' `dref'"
					}
				}
				
				if ("`table'"!="") {
					*Check with a dictionary file
					*Open the dic file and save as temporary file
					preserve
					use "`table'", clear
					if ("`vk'"!="") rename `vk' `var'
					noisily confirm variable `var'
					keep `var'
					replace `var' = trim(`var')
					save `fdic'
					restore
					*Merge m:1 with the var as key
					replace `var' = trim(`var')
					merge m:1 `var' using `fdic', generate(`dic_err`i'')
					keep if !missing(`obsnum')
					sort `obsnum'
					replace `err_v' = 2 if `dic_err`i''==1
				}
				
				*Missing values
				if ("`missing'"!="") replace `err_v' = 1 if missing(`var')
				
				*Duplicates
				if ("`dups'"!="") {
					duplicates tag `var', generate(`dup_err`i'')
					recode `dup_err`i'' (0=0) (else=4)
					replace `err_v' = `dup_err`i'' if `dup_err`i''!=0 & !missing(`var')
				}
				
				*Error var properties
				label variable `err_v' "Error(s) detected on variable `var'"
				label values `err_v' _Err__dic
				
				*There's errors
				count if `err_v'>0
				local nerr = r(N)
			}
			
			display ""
			if (`nerr'>0) {
				di as res "Found `nerr' error(s) in variable `var'"
				list `obsnum' `id' `err_v' `var' `varl' if `err_v', noobs abb(15) sep(0)
			}
			else {
				di as res "NO Errors found in variable `var'"
			}
			
			local i = `i'+1
		}
	}
	label drop _Err__dic			//Delete error dictionary

end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end
