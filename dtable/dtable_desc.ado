*! version 0.0.1  ?jul2018 R. Sesma
/*
dtable: command to add descriptive tables to DOCX or PDF documents
*/

program define dtable_desc
	version 12
	syntax anything(name=type), cont(varlist numeric) [cat(varlist numeric)] by(varname numeric)
	
	tempname V F R t
	
	// type: docx - create Word document with putdocx; pdf - create PDF document with putpdf
	if ("`type'"=="docx") local com "putdocx"
	else if ("`type'"=="pdf") local com "putpdf"
	else print_error "type `type' not defined"

	// by variable
	qui tabulate `by', matcell(`F')
	local n = r(N)
	local ncat = rowsof(`F')
	matrix `F' = `F' \ `n'
	local ntot = `ncat'+1
	local cat`ntot' = "Total"
	
	// get continous variables results with tabstat and store on matrix R
	qui tabstat `cont', by(`by') stats(mean sd q) save		
	foreach i of numlist 1/`ncat' {
		local cat`i' = r(name`i')
		matrix `t' = r(Stat`i')'
		if (`i'==1) matrix `R' = `t'
		else matrix `R' = `R', r(Stat`i')'
		
	}
	matrix `R' = `R', r(StatTotal)'
	
	// create void table
	local nvars : word count `cont'
	local nrows = 3*`nvars' + 2
	local ncols = `ncat' + 2
	`com' table t1 = (`nrows',`ncols'), border(insideV, nil) border(insideH, nil) border(start, nil) border(end, nil)
	`com' table t1(2,.), border(bottom, single)
	
	// column headers
	foreach i of numlist 1/`ntot' {
		local col = 1 + `i'
		`com' table t1(1,`col') = ("`cat`i''"), halign(center)
		local ni = `F'[`i',1]
		local n: di "(N = " `ni' ")"
		`com' table t1(2,`col') = ("`n'"), halign(center)
	}
	
	// row headers
	local count 1
	foreach i of numlist 3(3)`nrows' {
		local v: word `count' of `cont'
		local d: variable label `v'
		`com' table t1(`i',1) = ("`d'"), halign(left) bold
		local row = `i'+1
		`com' table t1(`row',1) = ("      Mean (SD)")
		local row = `i'+2
		`com' table t1(`row',1) = ("      Median (Q1, Q3)")
		local count = `count'+1
	}
	
	// table data
	local count 1
	foreach i of numlist 1/`nvars' {
		foreach j of numlist 2/`ncols' {
			local col = (`j'-2)*5+1
			local m = `R'[`i',`col']
			local sd = `R'[`i',`col'+1]
			local c: di trim(string(`m',"%9.2f")) " (" trim(string(`sd',"%9.2f")) ")"
			local row = (3*`i') + 1
			`com' table t1(`row',`j') = ("`c'"), halign(center)
			
			local p25 = `R'[`i',`col'+2]
			local p50 = `R'[`i',`col'+3]
			local p75 = `R'[`i',`col'+4]
			local c: di trim(string(`p50',"%9.1f")) " (" trim(string(`p25',"%9.1f")) /*
			*/            ", " trim(string(`p75',"%9.1f")) ")"
			local row = (3*`i') + 2
			`com' table t1(`row',`j') = ("`c'"), halign(center)
		}
		local count = `count'+1
	}
	
	// categorical variables
	foreach v of varlist `cat' {
		qui tabulate `v' `by', matcell(`F') matrow(`V')
		local ncat = r(r)
		local ncols = r(c)+1

		// add totals
		mata: st_matrix("`F'", (st_matrix("`F'"), rowsum(st_matrix("`F'"))))
		mata: st_matrix("`F'", (st_matrix("`F'") \ colsum(st_matrix("`F'"))))
		
		// add rows to complete the table
		qui `com' describe t1
		local len = r(nrows)
		`com' table t1(`len',.), addrows(1)
		`com' table t1(`len',.), border(bottom, nil)
		
		// add descrip
		local i = `len'+1
		local d: variable label `v'
		`com' table t1(`i',1) = ("`d'"), halign(left) bold
		
		local ntot = rowsof(F)
		foreach i of numlist 1/`ncat' {
			// add category row
			qui `com' describe t1
			local len = r(nrows)
			`com' table t1(`len',.), addrows(1)
			`com' table t1(`len',.), border(bottom, nil)
			// set descrip for category
			local val = `V'[`i',1]
			local d : label (`v') `val'
			local row = `len' + 1
			`com' table t1(`row',1) = ("      `d'"), halign(left)
			// load values to table
			foreach j of numlist 1/`ncols' {
				local val = `F'[`i', `j']
				local tot = `F'[`ntot', `j']
				local c: di trim(string(`val',"%9.0f")) " (" trim(string(100*`val'/`tot',"%9.1f")) "%)"
				local col = `j'+1
				`com' table t1(`row',`col') = ("`c'"), halign(center)
			}
		}
	}
end


program define print_error
	args message
	display in red "`message'"
	exit 198
end
