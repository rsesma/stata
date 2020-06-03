*! version 0.0.6  06may2020

program define getaccess, rclass
	version 14
	syntax using/, [Table(string) Describe noVARnames ///
	       tc(namelist) labels(namelist) clear  ///
		   loadTables loadVars clsname(string)]

	if ("`loadTables'"!="" | "`loadVars'"!="") {
		local dlg .`clsname'

		mata: st_local("ext",pathsuffix(st_local("using")))			// file extension
		capture confirm file `"`using'"'							// check using is a file
		if (_rc == 0 & (upper("`ext'")==".MDB" | upper("`ext'")==".ACCDB")) {
			if ("`loadTables'"!="") {
				javacall com.leam.stata.getaccess.GetDataFromAccess getTables, jars(getaccess.jar) args(`"`using'"')

				`dlg'.tbls.Arrdropall
				gettoken tbl tables : tables, parse(";")
				while ("`tbl'"!="") {
					if ("`tbl'"!=";") {
						`dlg'.tbls.Arrpush "`tbl'"
					}
					gettoken tbl tables : tables, parse(";")
				}
				`dlg'.main.lb_tables.repopulate
				`dlg'.main.co_vl.repopulate
			}
			if ("`loadVars'"!="") {
				* local table = subinstr(subinstr("`table'","[","",.),"]","",.)
				javacall com.leam.stata.getaccess.GetDataFromAccess getTblData, jars(getaccess.jar) args(`"`using'"' `"`table'"')

				`dlg'.vars.Arrdropall
				gettoken var vars : vars, parse(";")
				while ("`var'"!="") {
					if ("`var'"!=";") {
						local var = subinstr(subinstr("`var'","'","",.),"*","",.)
						`dlg'.vars.Arrpush "`var'"
					}
					gettoken var vars : vars, parse(";")
				}
				`dlg'.main.co_tc.repopulate
			}
		}
		else {
			`dlg'.tbls.Arrdropall
			`dlg'.vars.Arrdropall
			`dlg'.main.lb_tables.repopulate
			`dlg'.main.co_tc.repopulate
			`dlg'.main.co_vl.repopulate
		}

	}
	else {
		confirm file `"`using'"'									// check using is a file
		mata: st_local("ext",pathsuffix(st_local("using")))			// file extension
		if (upper("`ext'")!=".MDB" & upper("`ext'")!=".ACCDB") {
			display in red "file is not an MS-Access database"
			exit 198
		}
		if ("`table'"=="" & "`describe'"=="") {
			display in red "table or describe options missing"
			exit 198
		}

		if ("`describe'"!="") {
			javacall com.leam.stata.getaccess.GetDataFromAccess getTables, jars(getaccess.jar) args(`"`using'"')

			di as txt ""
			di as txt "Describe data from {bf:`using'}"
			di as txt "{ralign 7:tables}: " as res `ntables'
			di "{hline}"
			gettoken tbl tables : tables, parse(";")
			while ("`tbl'"!="") {
				if ("`tbl'"!=";") {
					javacall com.leam.stata.getaccess.GetDataFromAccess getTblData, jars(getaccess.jar) args(`"`using'"' `"`tbl'"')

					// header
					di as txt "{ralign 7:table}: {bf:`tbl'}"
					di as txt "{ralign 7:obs}: " as res `obs'
					di as txt "{ralign 7:vars}: " as res `nvars'
					// show varlist
					if ("`varnames'"=="") {
						local colsize = `maxlen' + 2			// column size: max name length + 2
						local pos 10
						gettoken var vars : vars, parse(";")
						while ("`var'"!="") {
							if ("`var'"!=";") {
								if ((`pos'+`colsize')>`c(linesize)') {
									di as res
									local pos 10
								}
								di as res _col(`pos') "`var'" _c
								local pos = `pos'+`colsize'
							}
							gettoken var vars : vars, parse(";")
						}
						di as res
					}
					di "{hline}"
				}
				gettoken tbl tables : tables, parse(";")
			}
			if ("`varnames'"=="") di as txt "(')string variable; (*)date variable"
		}
		else {
			if (!c(changed) | (c(changed) & ("`clear'"!=""))) {
				qui clear
				javacall com.leam.stata.getaccess.GetDataFromAccess getData, jars(getaccess.jar) args(`"`using'"' `"`table'"' `"`tc'"')
				qui compress

				if ("`labels'"!="") {
					javacall com.leam.stata.getaccess.GetDataFromAccess createLabels, jars(getaccess.jar) args(`"`using'"' `"`labels'"')
				}

				di as txt ""
				di as txt "Process finished."
				di as txt "{bf:`c(k)'} variables and {bf:`c(N)'} observations imported."
				if ("`labels'"!="") {
					if ("`ok'"!="") {
						local ok = trim("`ok'")
						di as txt ""
						di as txt "{bf:`ok'} label values added."
						di as txt "Use {cmd:label values} to assign label values to variables,"
						di as txt "{cmd:label list} to list label values and"
						di as txt "{cmd:label save} to save label values syntax definition to a do-file."
					}
					if ("`err'"!="") {
						local err = trim("`err'")
						di as txt ""
						di as txt "{bf:WARNING!}: create label values using {bf:`err'} is not possible."
					}
				}

			}
			else {
				display in red "no; data in memory would be lost"
				exit 198
			}
		}
	}
end
