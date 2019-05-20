*! version 0.0.3  ?may2019

program define getaccess
	version 15
	syntax using/, [table(string) describe clock(varlist) clear]

	confirm file `"`using'"'									// check using is a file
	mata: st_local("ext",pathsuffix(st_local("using")))			// file extension
	if (upper("`ext'")!=".MDB" & upper("`ext'")!=".ACCDB") {
		display in red "file is not an MS-Access database"
		exit 198
	}

	if ("`describe'"!="") {
		javacall com.leam.stata.getaccess.GetDataFromAccess getTables, jars(getaccess.jar) args(`"`using'"')
		
		di as txt ""
		di as txt "Describe data from {bf:`using'}"
		di as txt "{ralign 7:tables}: " as res %8.0f `ntables'
		di "{hline}"
		gettoken tbl tables : tables, parse(";")
		while ("`tbl'"!="") {
			if ("`tbl'"!=";" & ("`table'"=="" | upper("`table'")==upper("`tbl'"))) {
				javacall com.leam.stata.getaccess.GetDataFromAccess getTblData, jars(getaccess.jar) args(`"`using'"' `"`tbl'"')
			
				di as txt "{ralign 7:table}: {bf:`tbl'}"
				di as txt "{ralign 7:obs}: " as res %8.0f `obs'
				di as txt "{ralign 7:vars}: " as res %8.0f `nvars'
				
				local pos 10
				di as txt _col(`pos') _c
				local smax = `c(linesize)'
				local size `pos'
				gettoken var vars : vars, parse(";")
				while ("`var'"!="") {
					if ("`var'"!=";") {
						local svar = length("`var'")
						if ((`size'+`svar'+1)>`smax') {
							di as txt ""
							di as txt _col(`pos') _c
							local size `pos'
						}
						di as res "`var' " _c
						local size = `size'+`svar'+1
					}
					gettoken var vars : vars, parse(";")
				}
				di ""
				di "{hline}"
			}
			gettoken tbl tables : tables, parse(";")
		}
	}
	else {
		if (!c(changed) | (c(changed) & ("`clear'"!=""))) {
			qui clear

			javacall com.leam.stata.getaccess.GetDataFromAccess getData, jars(getaccess.jar) args(`"`using'"' `"`table'"')

			qui compress

			foreach v of varlist * {
				if (substr("`v'",1,7)=="_Date__") {
					capture confirm string variable `v'
					if (!_rc) {
						local name = substr("`v'",8,.)
						qui generate double `name' = clock(`v',"YMDhms#"), after(`v')
						if (`: list name in clock') {
							format `name' %tc
						}
						else {
							qui replace `name' = dofc(`name')
							format `name' %td
						}
						qui drop `v'
					}
				}
			}

			di as txt ""
			di as txt "Process finished."
			di as txt "{bf:`c(k)'} variables and {bf:`c(N)'} observations imported."
		}
		else {
			display in red "no; data in memory would be lost"
			exit 198
		}
	}
end
