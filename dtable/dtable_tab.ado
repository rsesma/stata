*! version 0.0.1  ?jul2018 R. Sesma
/*
ttable: command to add tabulate tables to DOCX or PDF documents
*/

program define dtable_tab
	version 12
	syntax varlist(numeric), type(string) by(varname numeric)
	
	tempname F V b
	
	// type: docx - create Word document with putdocx; pdf - create PDF document with putpdf
	if ("`type'"=="docx") local com "putdocx"
	else if ("`type'"=="pdf") local com "putpdf"
	else print_error "type `type' not defined"

	// number of categories of the by variable
	qui levelsof `by', local(values)
	local nby : word count `values'

	// insert table and define headers
	local ncols = (`nby'+1)*2 + 1
	local layout = cond("`type'"=="docx","layout(autofitcontents)","")
	`com' table t1 = (3,`ncols'), border(insideV, nil) border(insideH, nil) border(start, nil) border(end, nil) `layout' memtable
/*					note("n: número total período 2005-2016")*/
	// insert `by' variable label as super header
	local t = `ncols'-1
	local d : variable label `by'
	`com' table t1(1,.), border(bottom, single)			// draw line under the `by' variable
	`com' table t1(1,1) = (" "), border(bottom, nil)		// no not draw line under the first cell
	`com' table t1(1,2) = ("`d'"), colspan(`t') halign(center) bold
	// insert value labels of by variable as column headers
	foreach i of numlist 1/`nby' {
		local v : word `i' of `values'
		local d : label (`by') `v'
		local col = `i' + 1
		`com' table t1(2,`col') = ("`d'"), colspan(2) halign(center) bold
	}
	// total column
	local col = `nby'+2
	`com' table t1(2,`col') = ("Total"), colspan(2) halign(center) bold
	// subcolumn headers
	foreach i of numlist 2/`ncols' {
		local t = cond(mod(`i',2)==0,"n","%")
		`com' table t1(3,`i') = ("`t'"), halign(right)
	}
	matrix `b' = (3)
	
	foreach v of varlist `varlist' {
		// add row for each var and set descrip
		add_rows t1, command(`com')
		local i = r(len)+1
		local d: variable label `v'
		`com' table t1(`i',1) = ("`d'"), halign(left) bold
		
		qui tab `v' `by', matcell(`F') matrow(`V')
		// add totals
		mata: st_matrix("`F'", (st_matrix("`F'"), rowsum(st_matrix("`F'"))))
		mata: st_matrix("`F'", (st_matrix("`F'") \ colsum(st_matrix("`F'"))))

		// print data
		local ncat = rowsof(`V')+1
		local ncols = colsof(`F')
		add_rows t1, command(`com') nrows(`ncat')
		local pos = r(len)
		foreach i of numlist 1/`ncat' {
			local row = `pos' + `i'
			if (`i'<`ncat') {
				// category value label
				local val = `V'[`i',1]
				local d : label (`v') `val'
				`com' table t1(`row',1) = ("`d'"), halign(left)
			}
			else {
				// total row
				`com' table t1(`row',1) = ("Total"), halign(left) bold
				matrix `b' = (`b',`row')
			}
			
			foreach j of numlist 1/`ncols' {
				local n = `F'[`i',`j']
				local N = `F'[`ncat',`j']
				local p = (100 * `n'/`N')
				local col = 2*`j'
				`com' table t1(`row',`col') = (`n'), halign(right) nformat(%9.0fc)
				local col = `col'+1
				`com' table t1(`row',`col') = (`p'), halign(right) nformat(%5.1fc)
			}
		}
	}
	// sample size
	add_rows t1, command(`com')
	local row = r(len) + 1
	`com' table t1(`row',1) = ("Tamaño de muestra"), halign(left) bold
	foreach i of numlist 1/`ncols' {
		if (`i'<`ncols') {
			local value : word `i' of `values'
			qui count if `by'==`value'
		}
		else {
			qui count if `by'<.
		}
		local n = r(N)
		local col = 2*`i'
		`com' table t1(`row',`col') = (`n'), halign(right) nformat(%9.0fc)
	}

	// draw separator lines between variables
	local len = colsof(`b')
	foreach i of numlist 1/`len' {
		local pos = `b'[1,`i']
		`com' table t1(`pos',.), border(bottom, single)
	}
	
	putdocx table tbl = (1,1), border(all, nil)  `layout' note("n: número total período 2005-2016\n%: porcentaje respecto al total por columna")
	putdocx table tbl(1,1) = table(t1) 

end

program define add_rows, rclass
	version 12
	syntax anything(name=tname), command(string) [nrows(integer 1)]
	qui `command' describe `tname'
	local len = r(nrows)
	`command' table `tname'(`len',.), addrows(`nrows') border(bottom, nil)
	
	return scalar len = `len'
end

program define print_error
	args message
	display in red "`message'"
	exit 198
end
