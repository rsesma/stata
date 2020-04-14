*! version 1.1.4  14apr2020 JM. Domenech, R. Sesma
/*
Association Measures
*/

program define sta
	version 12
	syntax varlist(min=2 max=3 numeric) [if] [in], /*
	*/	[Data(string) ST(string) Level(numlist max=1 >50 <100) Wilson Exact WAld 		/*
	*/	 Pearson MH R(numlist max=1 >0 <1) PE(numlist max=1 >0 <1) DETail notables		/*
	*/	 NNT(numlist integer max=1 >=0 <=1) MEthod(string) Zero(string) rare            /*
	*/   COrnfield Woolf by(varname numeric) RELatsymm nst(string)]

	local nvars : word count `varlist'
	if (`nvars'==3 & "`data'"!="pt") print_error "wrong number of variables"
	tokenize `varlist'
	local res `1'			//Response (row) variable
	local exp `2'			//Exposure (column) variable
	if ("`data'"=="pt") local time `3'	//Time variable (for person-time data)
	else local time ""
	
	*Check variables
	if ("`res'"=="`exp'") print_error "response and exposure variable must be different"
	if ("`data'"=="pt" & ("`res'"=="`time'" | "`exp'"=="`time'")) print_error "response, exposure and time variable must be different"
	if ("`res'"=="`by'" | "`exp'"=="`by'") print_error "response, exposure and stratum variable must be different"
	if ("`data'"=="pt" & "`time'"=="") print_error "time variable is needed for person-time analysis"
	if ("`data'"!="pt" & "`time'"!="") print_error "time variable is only needed for person-time analysis"
	if ("`data'"=="pt" & "`time'"=="`by'") print_error "time and stratum variable must be different"

	*Mark observations [if/in]
	marksample touse, novarlist
	quietly count if `touse'			//Count number of total cases
	if (r(N)==0) print_error "no observations"
	
	*Check variable values
	qui levelsof `res', local(values)
	if ("`values'"!="0 1") print_error "response variable must binary, with values 0 1"
	qui levelsof `exp', local(values)
	if ("`values'"!="0 1") print_error "exposure variable must binary, with values 0 1"
	
	if ("`paired'"!="" & "`by'"!="")  print_error "by() option is not compatible with paired data"

	*Inmediate call to obtain results
	stai "", data(`data') st(`st') level(`level') `wilson' `exact' `wald' `pearson' `mh' r(`r') pe(`pe')	/*
	*/		`detail' `tables' nnt(`nnt') method(`method') zero(`zero') `rare' nst(`nst') `relatsymm' 		/*
	*/      `cornfield' `woolf' _incall _res(`res') _exp(`exp') _time(`time') _by(`by') _touse(`touse')
	
end


program define print_error
	args message
	display in red "`message'" 
	exit 198
end
