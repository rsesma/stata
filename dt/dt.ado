*! version 1.1.8  19jun2020 JM. Domenech, R. Sesma
/*
dt: Diagnostics Tests
Uses the dti inmediate command to compute and print results
*/

program define dt, byable(recall)
	version 12
	syntax varlist [if] [in] [fw], /*
	*/	[ST(string) Wilson Exact WAld P(numlist min=1 >0 <100)   /*
	*/	valtest(numlist integer min=2 max=2) valref(numlist integer min=2 max=2) /*
	*/	m1(numlist integer max=1 >0) n(numlist integer max=1 >0) /*
	*/  Level(numlist max=1 >50 <100) nst(string)]

	if ("`st'"=="bt") print_error "st() invalid -- bayes theorem only available on immediate command"

	tokenize `varlist'
	local test `1'			//Diagnostic Test variable
	local ref  `2'			//Reference criterion variable

	*Mark observations [if/in]
	marksample touse, novarlist
	qui sum `touse' if `touse' [`weight'`exp']			//Count number of total cases
	local total = r(N)
	if (`total'==0) print_error "no observations"

	*Default values for positive, negative values for diagnostic test & reference criterion
	if ("`valtest'"=="") local valtest "0 1"
	if ("`valref'"=="") local valref "0 1"
	*Check values exist on variables
	qui levelsof `test', local(vtest)
	local lexist : list valtest in vtest
	if (`lexist'==0) print_error "`valtest' are not valid values of `test' variable"
	qui levelsof `ref', local(vref)
	local lexist : list valref in vref
	if (`lexist'==0) print_error "`valref' are not valid values of `ref' variable"

	*Recode to ensure negative code is 0 and positive is 1
	tempvar test_r ref_r
	tokenize `valtest'
	qui recode `test' (`1'=0) (`2'=1) (else=.), generate(`test_r')
	tokenize `valref'
	qui recode `ref' (`1'=0) (`2'=1) (else=.), generate(`ref_r')

	*Get data
	tempname d
	qui tabulate `test_r' `ref_r' if `touse' [`weight'`exp'], matcell(`d')
	local valid = r(N)

	local a1 = `d'[2,2]
	local a0 = `d'[1,2]
	local b1 = `d'[2,1]
	local b0 = `d'[1,1]
	dti `a1' `a0' `b1' `b0', st(`st') `wilson' `exact' `wald' p(`p') m1(`m1') n(`n') level(`level') nst(`nst')  /*
	*/			_total(`total') _valid(`valid') _ref("`ref'") _vref("`valref'") _test("`test'") _vtest("`valtest'")
end

program define print_error
	args message
	display in red "`message'"
	exit 198
end
