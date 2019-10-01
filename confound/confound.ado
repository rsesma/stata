*! version 1.1.5  30sep2019 JM. Domenech, JB.Navarro, R. Sesma

program confound
	version 12
	syntax varlist(fv) [if] [in] [pweight], [LINear LOGistic COX CHange(real 10) 		/*
	*/	MINimum FIXed(varlist numeric) using(string) noreplace VALues(string)	/*
	*/	Level(numlist max=1 >50 <100) nst(string)]

	if ("`level'"=="") local level 95

	*Check type
	if ("`linear'"=="" & "`logistic'"=="" & "`cox'"=="") {
		print_error "missing regression type -- specify one of linear, logistic, cox"
	}
	if ("`linear'"!="" & "`logistic'"!="" | "`linear'"!="" & "`cox'"!="" | "`logistic'"!="" & "`cox'"!="") {
		print_error "only one of linear, logistic, cox is needed"
	}
	if ("`linear'"!="") local type "linear"
	if ("`logistic'"!="") local type "logistic"
	if ("`cox'"!="") local type "cox"

	*Weight
	local w ""
	if ("`weight'"!="") {
		if ("`type'"=="cox") print_error "weight not necessary for cox type; include weight on the stset command"
		local w "[`weight'`exp']"
	}

	*Check filename
	if ("`using'"=="") local using "confound_results.dta"
	capture confirm new file `"`using'"'
	if ("`replace'"!="" & _rc==602) {
		display in red "using() invalid -- the file exists and the noreplace option is specified"
		exit 198
	}
	else {
		if (_rc==603) {
			display in red "using() invalid -- the filename is invalid, the specified directory does not exist,"
			display in red "or the directory permissions do not allow to create a new file"
			exit 198
		}
	}

	marksample touse, novarlist		//ifin marksample

	*Dependent, Exposition & Independent variables
	if ("`type'"!="cox") {
		gettoken dep vars: varlist
		gettoken exp vars: vars
	}
	else {
		gettoken exp vars: varlist
	}
	local vars: list uniq vars		//Remove possible duplicate varnames
	local error 0
	if ("`type'"!="cox") local error: list dep in vars	//Dependent var can't be one of the independent
	if (`error') print_error "dependent variable `dep' can't be one of the independent variables"
	local error: list exp in vars	//Exposition var can't be one of the independent
	if (`error') print_error "exposition variable `exp' can't be one of the independent variables"

	*Values (for continuous interaction variables)
	if ("`values'"=="") local values = "p5 p50 p95"
	foreach v in `values' {
		if (substr("`v'",1,1) == "p") {
			local v = substr("`v'",2,.)
			if !(inlist(real("`v'"),1,5,10,25,50,75,90,95,99)) print_error "values() invalid -- allowed percentiles are 1 5 10 25 50 75 90 95 99"
		}
		else {
			capture confirm number "`v'"
			if (!_rc) print_error "values not valid"
		}
	}

	*Loop to get the independent and interaction variables
	local indep ""
	local inter ""
	local cont ""
	local varlist ""
	local indep_print ""
	local fixed_vars ""
	foreach var in `vars' {
		if (strpos("`var'","#")==0){		//Non interaction terms
			local v = substr("`var'",strpos("`var'",".")+1,.)
			local indep = "`indep'" + " " + "`v'"
			local indep_print = "`indep_print'" + " " + "`var'"
			if (strpos("`var'",".")==0) local cont = "`cont'" + " " + "`var'"
			local varlist = "`varlist' `var'"
			local is_fixed: list v in fixed		//Fixed terms
			if (`is_fixed') local fixed_vars = "`fixed_vars'" + " " + "`var'"
		}
		else {		//Interaction terms
			local inter = "`inter'" + " " + "`var'"
		}
	}
	local clean_exp = substr("`exp'",strpos("`exp'",".")+1,.)

	tempname nvalid nrows time ncases
	if ("`type'"!="cox") local lvars = "`dep' `clean_exp' `indep'"		//Variable list
	else local lvars = "`clean_exp' `indep'"
	quietly count if `touse'
	scalar `ncases' = r(N)				//Total number of cases
	if (`ncases'==0) print_error "no observations"
	*Count number of valid values of each var
	foreach var in `lvars' {
		quietly count if `touse' & `var'<.
		tempname nval_`var'
		scalar `nval_`var'' = r(N)
	}
	markout `touse' `lvars'				//Exclude missing values of list vars
	quietly count if `touse'
	scalar `nvalid' = r(N)				//Number of valid cases

	preserve
	quietly keep if `touse'			//Select cases a priori

/*	//Check collinearity
	quietly _rmcoll `exp' `vars', expand
	local lcol 0
	local temp `r(varlist)'
	local n_names : word count `temp'
	local vcol
	forvalues i = 1/`n_names' {
		local name : word `i' of `temp'
		local found = strpos("`name'","o.") > 0
		if (`found') {
			local lcol 1
			local vcol `vcol' `name'
		}
	}
	local vcol: list uniq vcol*/

	*Exposition categorical?
	local exp_vars ""
	if (strpos("`exp'",".")>0) {
		tempname exp_cat			//Values of the exposition var
		qui tabulate `clean_exp', matrow(`exp_cat')
		local ncat = rowsof(`exp_cat')

		local ib = substr("`exp'",1,strpos("`exp'",".")-1)
		if ("`ib'"=="i") {
			local refcat = `exp_cat'[1,1]
		}
		else if (substr("`exp'",1,2)=="ib") {
			local refcat = substr("`ib'",3,.)
			local lfound = 0
			forvalues i=1/`ncat' {
				if (`exp_cat'[`i',1]==`refcat') local lfound = 1
			}
			if (!`lfound') print_error "exposition variable invalid"
		}
		else {
			print_error "exposition variable invalid"
		}

		*Exposition dummy variables
		local exp_dummy ""
		forvalues i=1/`ncat' {
			local v_cat = `exp_cat'[`i',1]
			if (`v_cat'!=`refcat') {
				qui gen _cnf87`clean_exp'_`v_cat'`refcat' = `clean_exp' == `v_cat'
				local exp_vars = "`exp_vars' `clean_exp'_`v_cat'`refcat'"
				local exp_dummy = "`exp_dummy' _cnf87`clean_exp'_`v_cat'`refcat'"
			}
		}
		local n_cat = rowsof(`exp_cat')-1
	}
	else {
		qui gen _cnf87`exp' = `exp'
		local n_cat = 1
		local exp_vars = "`exp'"
		local exp_dummy = "_cnf87`exp'"
	}

	*Check interactions
	local int_vars ""
	foreach in in `inter' {
		local int_var ""
		local ok 1
		local temp : subinstr local in "#" " "
		local nlen : word count `temp'
		if (`nlen'>2) local ok 0
		local t10 : word 1 of `temp'
		local t20 : word 2 of `temp'

		local t1 = substr("`t10'",strpos("`t10'",".")+1,.)
		local t2 = substr("`t20'",strpos("`t20'",".")+1,.)

		if ("`t1'"=="`clean_exp'") {
			local ok : list t2 in indep
			local int_var "`t2'"
		}
		else if ("`t2'"=="`clean_exp'") {
			local ok : list t1 in indep
			local int_var "`t1'"
		}
		else {
			local ok 0
		}
		if (`ok'==0) print_error "`in' is not a valid interaction"
		else local int_vars = "`int_vars' `int_var'"

		*Exclude interaction vars from the list
		local t_vars ""
		foreach var in `varlist' {
			if (substr("`var'",strpos("`var'",".")+1,.) != "`int_var'") local t_vars = "`t_vars' `var'"
		}
		local varlist = "`t_vars'"
	}

	*Loop to verify fixed variables
	if ("`fixed'"!="") {
		foreach var in `fixed' {
			local is_indep: list var in indep
			local is_inter: list var in int_vars
			if (!`is_indep' | `is_inter') print_error "fixed variable `var' is not an independent variable"
		}
	}

	if ("`minimum'"!="" & (`n_cat'>1 | "`int_vars'"!="")) print_error "minimum option is incompatible with interactions or catregorical exposition"

	local nref = `n_cat'
	if ("`int_vars'"!="") {
		*Interactions: dummy variables
		tempname a_values
		local int_terms ""
		foreach var in `int_vars' {
			local i_values ""
			local co : list var in cont
			if (`co') {
				*Continuous interaction var
				local ndummy 0
				qui summarize `var', detail
				foreach v in `values' {
					local ndummy = `ndummy'+1

					if (substr("`v'",1,1) == "p") {
						local v = r(`v')
					}
					else {
						if !(`v'>=r(min) & `v'<=r(max)) print_error "values not valid"
					}
					if (`ndummy'==1) matrix `a_values' = J(1,1,real("`v'"))
					else matrix `a_values' = `a_values' \ (real("`v'"))
				}
				*Sort values
				mata : st_matrix("`a_values'", sort(st_matrix("`a_values'"), 1))
				local len = rowsof(`a_values')
				forvalues i=1/`len' {
					local v = `a_values'[`i',1]
					qui generate _cnf87`var'`i' = `var' - `v'
					local i_values = "`i_values'_`v'"
				}
				local i_values = substr("`i_values'",2,.)
				local int_terms = "`int_terms' `var';`i_values'"
			}
			else {
				*Categorical interaction var
				tempname cat_values
				qui tabulate `var', generate(_cnf87`var') matrow(`cat_values')
				local ndummy = rowsof(`cat_values')
				forvalues i=1/`ndummy' {
					local v = `cat_values'[`i',1]
					local i_values = "`i_values'_`v'"
				}
				local i_values = substr("`i_values'",2,.)
				local int_terms = "`int_terms' i.`var';`i_values'"
			}
			*Dummy interaction variables
			forvalues j = 1/`ndummy' {
				local temp = "`exp_dummy'"
				forvalues k = 1/`n_cat' {
					gettoken d temp: temp
					qui generate `d'_`var'`j' = `d' * _cnf87`var'`j'
				}
			}
			local nref = `nref' * `ndummy'
		}
	}

	//Get results in Mata
	mata: getresults("`dep'", "`clean_exp'", "`exp_vars'", "`varlist'", "`type'", "`int_terms'","`fixed_vars'","`w'")

	quietly {
		tempname time
		scalar `time' = time[1]

		*Model sequence
		generate _ref = mod(_n, `nref')
		replace _ref = `nref' if _ref == 0
		generate Model = int(_n / `nref') + 1
		replace Model = int(_n / `nref') if _ref == `nref'
		local refcases = _N - `nref'
		if ("`minimum'"!="") local refcases = 1
		if ("`minimum'"=="") replace Model = 0 if _n > (`refcases')
		sort Model _ref

		*Compute CI and Range difference
		if ("`type'"=="linear") {
			gen double lbCI = B - abs(invttail(N-df,(`level'+100)/200)*SE)
			gen double ubCI = B + abs(invttail(N-df,(`level'+100)/200)*SE)
		}
		if ("`type'"=="logistic" | "`type'"=="cox") {
			generate ExpB = exp(B)
			gen double lbCI = exp(B)*exp(-invnormal((`level'+100)/200)*SE)
			gen double ubCI = exp(B)*exp(invnormal((`level'+100)/200)*SE)
			if ("`type'"=="logistic") qui generate pfitHL = 1 - chi2(df_chi2,chi2)
		}
		gen Range = ubCI - lbCI

		*Compute Change, RangeDiff and Select
		generate Change = .
		generate RangeDiff = .
		forvalues ref = 1/`nref' {
			if ("`type'"=="linear") replace Change = 100 * abs((B - B[`ref'])/B[`ref']) if _ref == `ref'
			if ("`type'"=="logistic" | "`type'"=="cox") replace Change = 100 * abs((ExpB - ExpB[`ref'])/ExpB[`ref']) if _ref == `ref'
			replace RangeDiff = Range - Range[`ref'] if _ref == `ref'
		}
		if ("`minimum'"=="") generate Select = Change < `change'
		if ("`minimum'"!="") generate Select = Change > `change'
		by Model: egen _minSelect = min(Select)
		replace Select = 0 if (Select!=_minSelect)
		replace Select = . if _n <= `nref'
		if ("`int_vars'"=="" & `n_cat'==1) {
			gsort -Select +Range +Change, mfirst 			//Sort
		}
		else {
			gsort -Select +Model +_ref +Range +Change, mfirst 			//Sort
		}

		*Dataset properties
		local pfit ""
		if ("`type'"=="logistic") local pfit "pfitHL"
		local coef "B"
		if ("`type'"=="logistic" | "`type'"=="cox") local coef "ExpB"
		order Model NVar Variables Labels `coef' Change lbCI ubCI Range RangeDiff `pfit' Select
		keep Model NVar Variables Labels `coef' Change lbCI ubCI Range RangeDiff `pfit' Select
		format `coef' lbCI ubCI Range RangeDiff `pfit' Change %9.0g
		local len = length(Variables[1])
		format Variables %-`len's

		if ("`int_vars'"=="" & `n_cat'==1) drop Model Labels
		if ("`type'"=="logistic" & "`weight'"!="") drop pfitHL		//there's no pfitHL on weighted data

		save `"`using'"', replace		//Save results
	}

	//Print results
	di
	if ("`type'"=="linear") di as res "CONFOUND - Linear regression"
	if ("`type'"=="logistic") di as res "CONFOUND - Logistic regression"
	if ("`type'"=="cox") di as res "CONFOUND - Cox regression"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	di
	display as txt "ALL VARIABLES"
	if ("`type'"=="linear" | "`type'"=="logistic") {
		display as text "Response: " as result "`dep'"
	}
	if (`n_cat'==1) {
		di as txt "Exposition: " as res "`clean_exp'"
	}
	else {
		local n_cat = `n_cat'+1
		di as txt "Exposition: " as res "`clean_exp'" as txt " (`n_cat' categories, RefCat value= `refcat')"
	}
	if ("`int_vars'"!="") {
		local int_text ""
		local conf_vars ""
		foreach var in `int_vars' {
			local co : list var in cont
			if (`co') local int_text = "`int_text' {bf:`var'} (continuous)"
			else local int_text = "`int_text' {bf:`var'} (categorical)"
		}
		local lenvars : word count of `indep'
		foreach i of numlist 1/`lenvars' {
			local v1 : word `i' of `indep'
			local v1_print : word `i' of `indep_print'
			local lfound : list v1 in int_vars
			if (!`lfound') local conf_vars = "`conf_vars' `v1_print'"
		}
	}
	else {
		local conf_vars = "`indep_print'"
	}
	if ("`fixed_vars'"!="") {
		foreach v in `fixed_vars' {
			local conf_vars = subinstr("`conf_vars'","`v'","",.)
		}
	}
	if ("`fixed'"!="") display as text "Fixed: " as result "`fixed_vars'"
	display as text "Potential confounders: " as result "`conf_vars'"
	if ("`int_vars'"!="") display as text "Interactions: `int_text'"
	if ("`minimum'"=="") display as text "Important change: >= " as res "`change'%"
	else display as text "Unimportant change: <= " as res "`change'%"
	*if (`lcol') di as txt "{bf:WARNING: } collinearity present in some variable(s)"

	*Print the number of valid and missing values for each variable
	display		//Print header
	display as text "    Variable {c |}    Valid    Missing"
	display as text "{hline 13}{c +}{hline 20}"
	foreach var in `lvars' {
		display as text %12s abbrev("`var'",12) " {c |} " /*
				*/ as result /*
				*/ %8.0g `nval_`var'' "   " /*
				*/ %8.0g (`ncases'-`nval_`var'')
	}
	display as text "{hline 13}{c BT}{hline 20}"
	display as text "Valid number of cases (listwise): " as result `nvalid'
	*display as text "Total time: " as result %4.1f `time' as text " seconds"
	local path = c(filename)
	di
	di as txt "A new dataset has been created with the results. Save your data and execute:"
	di as txt "{cmd:use {c 34}`path'{c 34}, clear} to open the dataset with the results"
	if ("`type'"=="logistic" & "`weight'"!="") di as txt "For weighted data the Hosmer-Lemeshow test is not computed"

	restore
end

program define print_error
	args message
	display in red "`message'"
	exit 198
end


version 12
mata:
struct confound_res
{
	string scalar		dep
	string scalar		exp
	string rowvector	names
	string rowvector	inter
	string colvector	fixed
	string colvector	fixed_names
	string colvector	labels
	string scalar		type
	string scalar		weight
}

version 12
mata:
void getresults(string scalar dep, string scalar exp, string scalar exp_vars, string scalar indep, 	/*
*/				string scalar type, string scalar int_terms, string scalar fixed, string scalar weight)
{
	struct confound_res scalar	r
	string colvector combs, vnames, terms, terms_names, terms_labels, rlabels
	real colvector results
	real scalar i, len_v, nrows, j, k, len_l
	string scalar first, fvar
	string rowvector inter, v_int, ev, evd, fixed_vars
	string scalar nameint, term, name, vint
	real scalar nint, lcat


	r.dep = dep
	r.exp = exp
	r.names = tokens(indep)
	r.type = type

	//Tokenize & add the exposition variable
	ev = tokens(exp_vars)
	len = cols(ev)
	terms = J(len,1,"")
	terms_names = J(len,1,"")
	terms_labels = J(len,1,"")
	for (i=1; i<=len; i++) {
		term = ev[1,i]
		if (len>1) {
			term = "_cnf87" + term
			for (j=1; j<=len; j++) {
				if (j!=i) term = term + " _cnf87" + ev[1,j]
			}
		}
		terms[i,1] = term
		terms_names[i,1] = exp
		terms_labels[i,1] = ev[1,i]
	}
	r.fixed = terms
	r.fixed_names = terms_names
	r.labels = terms_labels
	if (len==1) r.labels[1,1]=""

	//Fixed variables
	fixed_vars = tokens(fixed)
	for (i=1; i<=cols(fixed_vars); i++) {
		fvar = fixed_vars[1,i]
		r.names = tokens(subinword(invtokens(r.names),fvar,""))
	}

	//Weight
	r.weight = weight

	//Tokenize interactions
	inter = tokens(int_terms)
	for (i=1; i<=cols(inter); i++) {
		temp = inter[i]
		nameint = substr(temp,1,strpos(temp,";")-1)
		vint = subinstr(substr(temp,strpos(temp,";")+1,.),"_"," ")
		v_int = tokens(vint)
		nint = cols(v_int)
		if (substr(temp,1,2)=="i.") {
			lcat = 1
			nameint = substr(nameint,strpos(nameint,".")+1,.)
		}
		else {
			lcat = 0
		}
		//Build the interaction terms for each var
		terms = J(nint,1,"")
		terms_names = J(nint,1,"")
		terms_labels = J(nint,1,"")
		for (j=1; j<=nint; j++) {
			term = ""
			if (lcat == 0) {
				//For cont. interactions, the element is the dummy value + the inter term
				term = "_cnf87" + nameint + strofreal(j)
				for (k=1; k<=len; k++) {
					term = term + " " + "_cnf87" + ev[1,k] + "_" + nameint + strofreal(j)
				}
			}
			else {
				//For cat. interactions, the element is all the dummies except the one of the value
				term = ""
				for (k=1; k<=nint; k++) {
					if (k!=j) term = term + "_cnf87" + nameint + strofreal(k) + " "
				}
				for (k=1; k<=nint; k++) {
					if (k!=j) {
						for (z=1; z<=len; z++) {
							term = term + "_cnf87" + ev[1,z] + "_" + nameint + strofreal(k) + " "
						}
					}
				}
			}
			terms[j,1] = term
			terms_names[j,1] = nameint + " " + exp + "#" + nameint
			terms_labels[j,1] = nameint + " = " + v_int[1,j]
		}
		r.fixed = addterm(r.fixed,terms," ")
		r.fixed_names = addterm(r.fixed_names,terms_names," ")
		r.labels = addterm(r.labels,terms_labels," & ")
	}
	for (i=1; i<=rows(r.labels); i++) {
		r.labels[i,1] = strtrim(r.labels[i,1])
	}

	timer_clear()
	timer_on(1)

	//Get all the possible combinations
	for (i=1; i<=cols(r.names); i++) {
		combinations(i,1,cols(r.names),combs,r.names)
	}
	//Compute the regression for each combination
	executereg(results,vnames,rlabels,combs,r,fixed_vars)

	//Build the results dataset
	stata("clear")
	st_addobs(rows(results))
	len_v = strlen(vnames[rows(vnames)])
	len_l = 1
	for (i=1; i<=rows(rlabels); i++) {
		if (strlen(rlabels[i,1]) > len_l) len_l = strlen(rlabels[i,1])
	}
	if (r.type=="linear" | r.type=="cox") {
		x = st_addvar(("str" + strofreal(len_v),"str" + strofreal(len_l),"double","double","double","double","float","float"), /*
				*/	("Variables","Labels","B","SE","N","df","NVar","time"))
	}
	if (r.type=="logistic") {
		x = st_addvar(("str" + strofreal(len_v),"str" + strofreal(len_l),"double","double","double","double","double","double","float","float"), /*
				*/	("Variables","Labels","B","SE","N","df","df_chi2","chi2","NVar","time"))
	}
	st_sstore(.,"Variables",vnames)
	if (cols(inter)!=0 | cols(ev)>1) st_sstore(.,"Labels",rlabels)
	st_store(.,"B",results[.,1])
	st_store(.,"SE",results[.,2])
	st_store(.,"N",results[.,3])
	st_store(.,"df",results[.,4])
	st_store(.,"NVar",results[.,5])
	if (r.type=="logistic") {
		st_store(.,"df_chi2",results[.,6])
		st_store(.,"chi2",results[.,7])
	}

	//Timer: stored in the dataset as the last column
	timer_off(1)
	st_store(1,"time",timer_value(1)[1,1])
}
end

version 12
mata:
string colvector addterm(string colvector fixed, string colvector terms, string scalar sep)
{
	real scalar i, j, lenf, lent
	string colvector ret
	string scalar t

	lenf = rows(fixed)
	lent = rows(terms)
	ret = J(lenf*lent,1,"")
	for (i=1; i<=lenf; i++) {
		for (j=1; j<=lent; j++) {
			if (strlen(fixed[i,1])>0) {
				t = fixed[i,1] + sep + terms[j,1]
			}
			else {
				t = terms[j,1]
			}
			ret[(i-1)*lent + j,1] = t
		}
	}
	return( ret )
}
end

version 12
mata:
void combinations(real scalar elements, real scalar first, real scalar last, string colvector combs, string rowvector names)
{
	real scalar			i
	real scalar			laddcomb
	string scalar		terms
	string colvector	p_combs
	string colvector	p_combs2

	if (elements < 1) {
		//We don't need to pick any more. Do nothing
	}
	else if (elements > last - first + 1) {
		//There are not enough items. Do nothing
	}
	else if (elements == (last - first + 1)) {
		//All the items must be in the solution.
		terms = ""
		for (i=first; i<=last; i++) {
			terms = terms + " " + names[i]
		}
		addcomb(terms,combs)
	}
	else {
        //Get solutions containing first allowed (first).
        if (elements == 1) {
			p_combs = J(1,1,"")
		}
		else {
			combinations((elements - 1), (first + 1), last, p_combs, names)
        }

        //Add first to make the full solutions
		for (i=1; i<=rows(p_combs); i++) {
			if (p_combs[i] == "") {
				terms = names[first]
			}
			else {
				terms = names[first] + " " + p_combs[i]
			}
			addcomb(terms,combs)
		}

        //Get solutions not containing first allowed (first).
        combinations(elements, (first+1), last, p_combs2, names)

        //Add these to the solutions
		for (i=1; i<=rows(p_combs2); i++) {
			addcomb(p_combs2[i],combs)
		}
	}
}
end

version 12
mata:
void addcomb(string scalar comb, string colvector combs) {
	if (rows(combs) == 0) {
		combs = J(1,1,comb)
	}
	else {
		combs = combs \ (comb)
	}
}
end

version 12
mata:
void executereg(real colvector results, string colvector vnames, string colvector labels, string colvector combs, struct confound_res scalar r, string rowvector fixed_vars) {
	real matrix eb, eV, F
	real scalar i, nvar, nfixed, j, index, m, ok
	string scalar model, names

	//Declare matrix
	nfixed = rows(r.fixed)
	if (r.type=="linear" | r.type=="cox") results = J((rows(combs)+1)*nfixed,5,.)
	if (r.type=="logistic") results = J((rows(combs)+1)*nfixed,7,.)
	vnames = J((rows(combs)+1)*nfixed,1,"")
	labels = J((rows(combs)+1)*nfixed,1,"")			//labels is created always - disabled: if (nfixed>1)

	index = 1
	for (i=0; i<=rows(combs); i++) {
		if (i==0){
			comb = ""			//The first loop is for minimum model, fixed terms
		}
		else {
			comb = combs[i]
		}

		for (j=1; j<=nfixed; j++) {
			//For each combination, add the fixed terms
			model = r.fixed[j,1]
			names = r.fixed_names[j,1]
			if (rows(fixed_vars)>0) {
				//Fixed variables
				model = model + " " + invtokens(fixed_vars)
				names = names + " " + invtokens(fixed_vars)
			}
			model = model + " " + comb
			names = names + " " + comb

			vnames[index,1] = strtrim(stritrim(names))
			labels[index,1] = r.labels[j,1]			//labels is created always - disabled: if (nfixed>1)
			nvar = cols(tokens(names))

			//Execute the regression
			if (r.type == "linear") stata("regress " + r.dep + " " + model + " " + r.weight,1)
			if (r.type == "logistic") stata("logit " + r.dep + " " + model + " " + r.weight,1)
			if (r.type == "cox") stata("stcox " + " " + model + " " + r.weight,1)
			eb = st_matrix("e(b)")
			eV = st_matrix("e(V)")
			results[index,1] = eb[1,1]
			results[index,2] = sqrt(eV[1,1])
			results[index,3] = st_numscalar("e(N)")
			results[index,4] = st_numscalar("e(df_m)")
			results[index,5] = nvar
			if (r.type == "logistic") {
				if (r.weight == "") {
					//gof can only be computed if there's no active weight
					ok = 1
					if (comb=="" & nfixed==1 & cols(tokens(model))==1) {
						stata("tab " + model + ", matrow(__Freq)",1)
						F = st_matrix("__Freq")
						if (rows(F)==2) {
							ok = 0
							//Special case: binary variable has perfect adjustment
							results[index,6] = 1
							results[index,7] = -1
						}
					}
					if (ok==1) {
						stata("estat gof, group(10)",1)
						m = st_numscalar("r(m)")
						if (comb=="" & m==2) {
							//Special case: the minimum model has m=2, pFit must be 1 -> df=1,chi2=-1
							results[index,6] = 1
							results[index,7] = -1
						}
						else {
							results[index,6] = st_numscalar("r(df)")
							results[index,7] = st_numscalar("r(chi2)")
						}
					}
				}
			}
			index = index+1
		}
	}
}
end
