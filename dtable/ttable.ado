*! version 0.0.1  ?jul2018 R. Sesma
/*
ttable: command to add tabulate tables to DOCX or PDF documents
*/

program define ttable
	version 12
	syntax varlist(numeric), type(string) by(varname numeric)
	
	// type: docx - create Word document with putdocx; pdf - create PDF document with putpdf
	if ("`type'"=="docx") local com "putdocx"
	else if ("`type'"=="pdf") local com "putpdf"
	else print_error "type `type' not defined"

	qui distinct `by'
	local nby = r(ndistinct)
	
	di `nby'
end


program define print_error
	args message
	display in red "`message'"
	exit 198
end
