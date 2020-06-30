*! version 0.0.1 30jun2020 R. Sesma

program define commands
	version 16
	syntax [anything(name=command)], [cd(string) comment(string) adodir(string) extractdir(string)]

    * set working dir
    if ("`cd'"!="") qui cd "`cd'"

    * open commands data
    use commands.dta, clear
    * get list with last version and date for each command
    frame copy default list
    frame change list
    sort name version
    collapse (last) version date, by(name)
    foreach i of numlist 1/`c(N)'{
        local n = name[`i']
        if ("`command'"=="" | "`command'"=="`n'") {
            local v = version[`i']
            local d = date[`i']

            * execute java code to update version and export data: use commands data to add version
            frame change default
            javacall com.leam.stata.commands.StataCommands updateCommand, jars(commands.jar) args(`"`n'"' `"`comment'"' `"`v'"' `"`d'"' `"`adodir'"' `"`extractdir'"')
            sort name version
            qui save, replace

            * restore list
            frame change list
        }
    }

    frame change default
    frame drop list

    if ("`command'"!="") {
        list if name=="`command'", sep(0) noobs
    }
end
