*! version 0.0.2  ?nov2018

program define getaccess
	version 15
	syntax [anything], db(string) table(string) [clock(varlist) clear]

	if (!c(changed) | (c(changed) & ("`clear'"!=""))) {
		qui clear

		javacall com.leam.stata.getaccess.GetDataFromAccess getData, jars(getaccess.jar) args(`"`db'"' `"`table'"')

		qui compress

		foreach v of varlist * {
			if (substr("`v'",1,6)=="_Date_") {
				capture confirm string variable `v'
				if (!_rc) {
					local name = substr("`v'",7,.)
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

		local nobs = _N
		di as txt "Process finished."
		di as txt "`c(k)' variables and `nobs' observations imported."
	}
	else {
		display in red "no; data in memory would be lost"
		exit 198
	}
end
