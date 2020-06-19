*! version 0.0.1 19jun2020 R. Sesma

program define test_ado
	version 16
	syntax anything, using(string) cd(string)

    xado `anything'
    cd `"`cd'"'

    foreach i of numlist 0 1 {
        local j = cond(`i'==0,"0"," ")
        log using test`j', replace text
        do `using'.do `"`j'"'
        log close
    }
end
