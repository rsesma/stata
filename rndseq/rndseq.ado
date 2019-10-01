*! version 1.0.5  30sep2019 JM. Domenech, R. Sesma
/*
rndseq: Generation of Random Sequences
*/

program define rndseq
	version 12
	syntax anything(id="randomization type"), /*
	*/	 n(numlist integer max=1 >0) Treat(string) Drug(string) Prot(string) /*
	*/	[Center(string) PCenter(numlist min=1 >0 <1) Strata(string) PStrata(numlist min=1 >0 <1) /*
	*/	 Ratio(numlist integer min=1 >0) PREfix(string) seed(numlist max=1 >0) /*
	*/ 	 lp(numlist max=1 >0 <0.5) hp(numlist max=1 >0.5 <1) bs(numlist integer max=1 >0) /*
	*/	 noprint using(string) noreplace nst(string)]

	tempname mratios mfreqs mcenter mstrata

	local parser ","
	
	*Type of randomization
	local type = "`anything'"
	if ("`type'"!="simple" & "`type'"!="block" & "`type'"!="efron") print_error "type `type' invalid"

	*Check parameter logic
	if ("`type'"=="efron" & "`ratio'"!="") print_error "ratio() option is incompatible with efron randomization"
	if ("`type'"!="block" & "`bs'"!="") print_error "bs() option only makes sense with block randomization"
	if ("`type'"!="efron" & ("`lp'"!="" | "`hp'"!="")) print_error "lp, hp options only make sense with efron randomization"
	if ("`type'"=="block" & "`bs'"=="") print_error "missing option bs() for block randomization"
	if ("`type'"=="efron" & ("`lp'"=="" | "`hp'"=="")) print_error "missing option lp or hp for efron randomization"

	*Get number of Treatments
	numtoken "`treat'", parse("`parser'")
	local ntreat = r(n)
	if (`ntreat'!=2 & "`type'"=="efron") print_error "efron randomization allows only 2 treatments"
	if (mod(`n',`ntreat')!=0) print_error "the number of subjects must be a multiple of the number of treatments"
	
	*Get Ratios
	if ("`type'"=="simple" | "`type'"=="block") {
		if ("`ratio'"!="") {
			local i 0
			local sumr 0
			foreach r in `ratio' {
				local ++i
				if (`i'==1) matrix `mratios'=(`r')
				else matrix `mratios'=(`mratios',`r')
				local sumr = `sumr' + `r'
			}
		}
		else {
			matrix `mratios' = J(1,`ntreat',1)
			local sumr = `ntreat'
		}
	}
	
	*Check
	if ("`type'"=="simple" | "`type'"=="block") {
		if (mod(`n',`sumr')!=0) print_error "the number of subjects must be a multiple of the sum of ratios"
		if (colsof(`mratios')!=`ntreat') print_error "the number of ratios and treatments must be the same"
	}
	if ("`type'"=="block") {
		if (mod(`n',`bs')!=0) print_error "the number of subjects must be a multiple of the block size"
		if (mod(`bs',`sumr')!=0) print_error "the sum of ratios must be a multiple of the block size"
	}

	*Get number of Centers
	numtoken "`center'", parse("`parser'")
	local ncenter = r(n)
	if ("`pcenter'"!="" & "`center'"=="") print_error "missing center() option"
	*Get center probability
	matrix `mcenter' = J(1,`ncenter',.)
	parsedata `ncenter', m("`mcenter'") prob(`pcenter')
	if (r(error)==1) print_error "the number of expected proportions for each center and the number of centers must be the same"
	if (r(sum)!=1) print_error "the number of expected center proportions must sum up to 1"
	
	*Get number of Strata
	numtoken "`strata'", parse("`parser'")
	local nstrata = r(n)
	if ("`pstrata'"!="" & "`strata'"=="") print_error "missing strata() option"
	*Get strata probability
	matrix `mstrata' = J(1,`nstrata',.)
	parsedata `nstrata', m("`mstrata'") prob(`pstrata')
	if (r(error)==1) print_error "the number of expected proportions for each stratum and the number of strata must be the same"
	if (r(sum)!=1) print_error "the number of expected stratum proportions must sum up to 1"
	
	*Get prefixes
	if ("`prefix'"!="") {
		numtoken "`prefix'", parse(" ")
		local npre = r(n)
		if (`npre'!=`ncenter'*`nstrata') print_error "wrong number of prefixes --see the help"
	}
	
	*Check filename
	if ("`using'"=="") local using "rndseq_results.dta"
	capture confirm new file `"`using'"'
	if ("`replace'"!="" & _rc==602) {
		print_error "using() invalid -- the file exists and the noreplace option is specified"
	}
	else {
		if (_rc==603) {
			print_error "using() invalid -- the filename is invalid, the specified directory does not exist, or the directory permissions do not allow to create a new file"
		}
	}

	preserve
	*Create the new dataset with the results
	clear
	quietly {
		set obs `n'
		
		if ("`type'"=="block") {
			*Block randomization
			egen _block = seq(), block(`bs')
			bysort _block: gen assignment = _n

			*recode(s) to build the final variable
			local ratio = `bs'/`sumr'
			local ini 1
			foreach i of numlist 1/`ntreat' {
				local fin = `ini' + `mratios'[1,`i']*`ratio' - 1
				recode assignment (`ini'/`fin' = `i')
				local ini = `fin'+1
			}

			if ("`seed'"!="") set seed `seed'
			gen _r = uniform()
			sort _block _r
		}

		
		*Center id
		gen _id1 = _n
		*Create center variable according to user/default proportions
		gen center = .
		local p 0
		local n0 0
		foreach i of numlist 1/`ncenter' {
			local n1 = `n0' + round(`mcenter'[1,`i']*`n')
			replace center = `i' if (_id1>`n0' & _id1<=`n1')
			local n0 = `n1'
		}
		
		*Stratum id
		bysort center: gen _id2 = _n
		*Create strata variable according to user/default proportions
		gen stratum = .
		foreach i of numlist 1/`ncenter' {
			*Count number of cases for each strata
			count if center == `i'
			local nstr = r(N)
			
			local p 0
			local n0 0
			foreach j of numlist 1/`nstrata' {
				local n1 = `n0' + round(`mstrata'[1,`j']*`nstr')
				replace stratum = `j' if (center==`i' & _id2>`n0' & _id2<=`n1')
				local n0 = `n1'
			}
		}

		*Stratum identifier variable
		gen _id3 = .
		local n0 0
		foreach i of numlist 1/`ncenter' {
			foreach j of numlist 1/`nstrata' {
				local ++n0
				replace _id3 = `n0' if (center==`i' & stratum==`j')
			}
		}
		*By-Stratum id
		bysort center stratum: gen _id4 = _n
		
		if ("`type'"=="simple") {
			*Simple randomization: Stata's algorithm to generate random integers over [a,b]
			if ("`seed'"!="") set seed `seed'
			bysort center stratum: gen assignment = 1+int((`sumr')*runiform())
			if ("`ratio'"!="") {
				*recode(s) to build the final variable
				local ini 1
				foreach i of numlist 1/`ntreat' {
					local fin = `ini' + `mratios'[1,`i'] - 1
					recode assignment (`ini'/`fin' = `i')
					local ini = `fin'+1
				}
			}
		}
		if ("`type'"=="efron") {
			*Efron randomization
			if ("`seed'"!="") set seed `seed'
			bysort center stratum: gen _r = runiform()		//Random variable
			
			gen assignment = .
			local npos = 1
			foreach i of numlist 1/`ncenter' {
				foreach j of numlist 1/`nstrata' {
					local p = 0.5
					local nA = 0
					local nB = 0
					count if center == `i' & stratum==`j'
					local nstr = r(N)
					foreach k of numlist 1/`nstr' {
						if (_r[`npos']<`p') {
							replace assignment = 1 in `npos'
							local nA = `nA' + 1
						}
						else {
							replace assignment = 2 in `npos'
							local nB = `nB' + 1
						}
						
						if (`nA'==`nB') local p 0.5
						else if (`nA'>`nB') local p `lp'
						else if (`nA'<`nB') local p `hp'
						local npos = `npos'+1
					}
				}
			}
		}
		
		*Generate id variable
		local zeros = "000000"
		gen str _pre = string(_id3)
		if ("`prefix'"!="") {
			local zeros = "000"
			foreach i of numlist 1/`npre' {
				local p : word `i' of `prefix'
				replace _pre = "`p'" if _id3==`i'
			}
		}
		gen str _suf = string(_id4)
		gen str _zeros = substr("`zeros'",1,(length("`zeros'")-length(_suf)+1))
		gen str subject_id = _pre + _zeros + _suf
		drop _*
		
		order subject_id center stratum assignment
		
		*Define treatment dictionary
		creadic "`treat'", name(dTreat) parse("`parser'")
		label values assignment dTreat

		*Define center dictionary
		local lcenter = ("`center'"!="")
		if (`lcenter') {
			creadic "`center'", name(dCenter) parse("`parser'")
			label values center dCenter
		}
		else {
			drop center
		}
		
		*Define strata dictionary
		local lstrata = ("`strata'"!="")
		if (`lstrata') {
			creadic "`strata'", name(dStrata) parse("`parser'")
			label values stratum dStrata
		}
		else {
			drop stratum
		}
	}
	
	*Print results
	if ("`type'"=="simple") di as res "COMPLETE RANDOMIZATION"
	if ("`type'"=="efron") di as res "TREATMENT ADAPTIVE RANDOMIZATION (Efron)"
	if ("`type'"=="block") di as res "PERMUTATED-BLOCK RANDOMIZATION"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	
	*Print seed, drug and protocol
	di
	if ("`seed'"=="") di as txt "Random number seed= {bf:RANDOM}"
	else di as txt "Random number seed= {bf:`seed'}"
	di
	di as txt "Random codes for Drug: {bf:`drug'}"
	di as txt "Protocol: {bf:`prot'}"

	if ("`print'"=="") {
		*Print list of cases
		foreach i of numlist 1/`ncenter' {
			di
			local lab : label dCenter `i'
			if (`lcenter') {
				di as txt "Study Center: " as res "`lab'"
				if (`lstrata') list subject_id stratum assignment if center==`i', separator(0) abbreviate(10) noobs
				else list subject_id assignment if center==`i', separator(0) abbreviate(10) noobs
			}
			else {
				list subject_id assignment, separator(0) abbreviate(10) noobs
			}
		}
		
		//Summary table: sample size by treatment
		if ("`type'"=="simple" | "`type'"=="efron") {
			qui tab assignment, matcell(`mfreqs')
			di
			di as txt "Summary of Sample Size by Treatment"
			di as txt "{hline 35}"
			foreach i of numlist 1/`ntreat' {
				local lab : label dTreat `i'
				di as txt _col(3) abbrev("`lab'",20) as res _col(23) %4.0f `mfreqs'[`i',1] /*
				*/	as txt " (" as res %4.1f 100*`mfreqs'[`i',1]/`n' as txt "%)"
			}
			di as txt "{hline 35}"
			di as txt _col(3) "TOTAL" as res _col(23) %4.0f `n' as txt " (" as res 100 as txt "%)"
		}
	}

	quietly save `"`using'"', replace		//Save results
	local path = c(filename)
		
	di
	di as txt "A new dataset has been created with the results"
	di as txt "Execute {cmd:use {c 34}`path'{c 34}} to open the dataset with the results"
	
	restore
end


program define numtoken, rclass
	syntax anything, parse(string)
	
	*Get number of tokens
	local s = `anything'
	if ("`s'"!="") {
		local n 0
		gettoken t s : s, parse("`parse'")
		while "`t'" != "" {
			if ("`t'"!=",") local ++n
			gettoken t s : s, parse("`parse'")
		}
		return scalar n = `n'
	}
	else {
		return scalar n = 1
	}
end

program define creadic
	syntax anything, name(string) parse(string)
	
	*Create a dictionary
	local dic = `anything'
	local i 0
	gettoken lab dic : dic, parse("`parse'")
	while "`lab'" != "" {
		if ("`lab'"!=",") {
			local ++i
			if (`i'==1) label define `name' `i' "`lab'"
			else label define `name' `i' "`lab'", add
		}
		gettoken lab dic : dic, parse("`parse'")
	}
end

program define parsedata, rclass
	syntax anything, m(string) [prob(numlist)]

	local n = `anything'
	
	local error 0
	if ("`prob'"!="") {
		//prob contains the probabilities
		local i 0
		local sum 0
		foreach p in `prob' {
			local ++i
			if (`i'>`n') {
				local error 1
				continue, break			//Error
			}
			
			matrix `m'[1,`i'] = `p'
			local sum = `sum' + `p'
		}
	}
	else {
		//Default: each item has the same probability
		foreach i of numlist 1/`n' {
			matrix `m'[1,`i'] = 1/`n'
		}
		local sum 1
	}
	
	return scalar error = `error'
	return scalar sum = `sum'
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end
