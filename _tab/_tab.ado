*! version 0.0.1  ?apr2018 JM. Domenech, R. Sesma
/*

_tab: utility command to create tabulate tables with row descending order

*/

program define _tab, byable(recall) sortpreserve
	version 12
	syntax varlist(max=2) [if] [in] [fweight aweight iweight] [ , * ]
    
	tempname rvar d

	tokenize `varlist'
	
	*row and (optionally) column variables
	local row `1'
	local col `2'
	
	*generate reverse temporal variable
	qui su `row'
	local max = r(max)
	local min = r(min)
	qui g `rvar' = `max' + `min' - `row'
	
	*variable label
	local l : variable label `row'
	if ("`l'"!="") label variable `rvar' "`l'"
	else label variable `rvar' "`row'"
	
	*reverse value labels: define new temporary dictionary
	qui levelsof `row', local(values)
	foreach v of numlist `values' {
		local l : label (`row') `v'
		local r = `max' + `min' - `v'
		label define `d' `r' "`l'", add
	}
	label values `rvar' `d'
	
	*call for tabulate table using reverse variable
	marksample touse
	tabulate `rvar' `col' [`weight' `exp'] if `touse', `options'

end
