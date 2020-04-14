*! version 1.2.6  30sep2019 JM. Domenech, JB.Navarro, R. Sesma

program allsets
	version 12
	syntax varlist(fv) [if] [in] [pweight], [LINear LOGistic COX /*
	*/	fixed(varlist numeric) using(string) noreplace /*
	*/	maxvar(numlist integer min=1 max=1 >0) 		   /*
	*/  minvar(numlist integer min=1 max=1 >0)		   /*
	*/	nohierarchical nst(string)]

	tempname nvalid nrows time ncases m r

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

	*Check weight
	if ("`weight'"!="" & "`type'"=="cox") print_error "weight not necessary for cox type; include weight on the stset command"

	*Check filename
	if ("`using'"=="") local using "allsets_results.dta"
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
	if ("`hierarchical'"!="") local hierarch 0
	else local hierarch 1

	marksample touse, novarlist		//ifin marksample

	if ("`maxvar'"=="") local maxvar 0		//maximum number of variables; ALL by default
	if ("`minvar'"=="") local minvar 1		//minimum number of variables; 1 by default
	if (`maxvar'>0 & `minvar'>`maxvar') print_error "minvar option can't be greater than maxvar"

	*Dependent & Independent variables
	if ("`type'"!="cox") gettoken dep vars: varlist
	else local vars `varlist'
	local vars: list uniq vars		//Remove possible duplicate varnames
	local error 0
	if ("`type'"!="cox") local error: list dep in vars	//Dependent var can't be one of the independent
	if (`error') print_error "dependent variable `dep' can't be one of the independent variables"

	*Loop to get the independent and interaction variables
	local indep ""
	local inter ""
	local cat ""
	local cont ""
	foreach var in `vars' {
		if (strpos("`var'","#")==0){		//Non interaction terms
			cleanvarname `var'
			local indep = "`indep'" + " " + "`r(v_name)'"
			if (strpos("`var'",".")==0) local cont = "`cont'" + " " + "`r(v_name)'"
			else local cat = "`cat'" + " " + "`r(v_name)'"
		}
		else {		//Interaction terms
			local inter = "`inter'" + " " + "`var'"
		}
	}
	*Loop to verify the defined interactions
	if (`hierarch') {
		foreach in in `inter' {
			local temp : subinstr local in "#" " "
			if (strpos("`temp'","#")>0) print_error "`in' is not a valid interaction"

			local terms ""
			local nlen : word count `temp'
			forvalues i = 1/`nlen'{
				local t : word `i' of `temp'
				cleanvarname `t'
				local terms = "`terms'" + " `r(v_name)'"
			}

			local ok : list terms in indep
			if (`ok'==0) print_error "`in' is not a valid interaction, terms missing in the model"
		}
	}
	*Loop to verify fixed variables
	if ("`fixed'"!="") {
		local fixed_vars
		foreach var in `fixed' {
			local is_cont: list var in cont
			local is_cat: list var in cat
			if (!`is_cont' & !`is_cat') print_error "fixed variable `var' missing in the model"
			foreach v in `vars' {
				if (strpos("`v'","#")==0){		//Non interaction terms
					cleanvarname `v'
					if ("`var'"=="`r(v_name)'") local fixed_vars `fixed_vars' `v'
				}
			}
		}
	}

	if ("`type'"!="cox") local lvars = "`dep' `indep'"		//Variable list
	else local lvars = "`indep'"

	quietly count if `touse'
	scalar `ncases' = r(N)				//Total number of cases
	if (`ncases'==0) print_error "no observations"

	*Count number of valid values of each var & number of valid cases
	matrix `m' = J(`: list sizeof lvars', 2, .)
	local i 1
	foreach var in `lvars' {
		quietly count if `touse' & `var'<.
		matrix `m'[`i',1] = r(N)
		matrix `m'[`i',2] = `ncases' - r(N)
		local ++i
	}
	markout `touse' `lvars'				//Exclude missing values of list vars
	quietly count if `touse'
	scalar `nvalid' = r(N)				//Number of valid cases

	preserve
	quietly keep if `touse'				//Select cases a priori

	if ("`type'"=="cox") {
		qui count if _t0>0				//Detect time-varying covariates (tvc)
		local tvc = (r(N)>0)
		capture which somersd			//Verify somersd user-command is installed
		local somers = (_rc==0)

		if (`tvc' & !`somers') {
			di ""
			di in red "{bf:WARNING!}"
			di in red "  User-defined command {bf:somersd} is not installed."
			di in red "  This command is necessary to compute Harrell's C with Time Variable Covariates."
			di in red "  Execute {bf:ssc install somersd} to install."
			exit 198
		}
	}

	//Get results in Mata
	mata: getresults("`dep'", "`vars'", "`inter'","`type'",`hierarch',"`fixed_vars'",`minvar',`maxvar',"`weight'","`exp'")

	//Mata code creates a new dataset with the results
	if (`maxvar'==0) scalar `nrows' = _N
	if (`maxvar'>0) {
		qui count if NVar <= `maxvar'
		scalar `nrows' = r(N)
	}
	tempname rmax
	scalar `time' = time[1]
	quietly drop time
	//Var properties and format
	label variable NVar "Number of variables"
	label variable Variables "Variables"
	label variable AIC "Akaike Information Criterion"
	label variable BIC "Schwarz Bayesian Criterion"
	if ("`type'"=="linear") {
		if (`maxvar'==1) {
			order NVar Variables b pValue Cp R2Adj AIC BIC R2
			label variable b "Coefficient"
			format b %8.0g
			sort Cp iCat
			qui replace Cp = . if R2Adj==.
		}
		else {
			order NVar Variables pValue Cp R2Adj AIC BIC R2
			sort Cp
			qui drop b
		}
		label variable Cp "Mallows' Prediction Criterion"
		label variable R2 "R Square"
		label variable R2Adj "Adjusted R Square"
		format Cp %9.2f
		format R2Adj R2 %5.3f
		format AIC BIC %9.1f
		local sumvars Cp R2Adj AIC BIC R2
	}
	if ("`type'"=="logistic") {
		if (`maxvar'==1) {
			order NVar Variables OR pValue AIC BIC AUC Se Sp
			qui replace OR = exp(OR)
			label variable OR "Odds Ratio"
			format OR %8.0g
			sort AIC iCat
			qui replace AIC = . if BIC==.
		}
		else {
			order NVar Variables pValue AIC BIC AUC Se Sp
			sort AIC
			qui drop OR
		}
		label variable AUC "Area Under the Curve"
		label variable Se "Sensibility (%)"
		label variable Sp "Specificity (%)"
		local sumvars AIC BIC AUC Se Sp 
		local lpearson = 0
		if ("`weight'"!="") {
			*p not computed on weighted regressions
			qui drop pfitHL pGof
		} 
		else {
			local sumvars `sumvars' pfitHL pGof
		}
/*		if ("`weight'"=="") {
			*pfitHL not computed on weighted regressions
			quietly{
				*Compute pfit using df, chi2 from mata results
				generate pfitHL = 1 - chi2(df,chi2)
				replace pfitHL = 1 if (pearson==1 & df==0)
				label variable pfitHL "Hosmer-Lemeshow goodness-of-fit"
				format pfitHL %5.3f
				*There's some pearson chi2 results?
				count if (pearson==1)
				if (`r(N)'>0) local lpearson = 1
				
				local sumvars `sumvars' pfitHL
			}
		}
		qui drop df chi2 pearson		//drop auxiliary vars*/
		qui drop pearson
		format AIC BIC %9.1f
		format AUC %5.3f
		format Se Sp %5.1f
	}
	if ("`type'"=="cox") {
		if (`maxvar'==1) {
			order NVar Variables HR pValue AIC BIC HarrellC _2ll
			qui replace HR = exp(HR)
			label variable HR "Hazard Ratio"
			format HR %8.0g
			sort AIC iCat
			qui replace AIC = . if BIC==.
		}
		else {
			order NVar Variables pValue AIC BIC HarrellC _2ll
			sort AIC
			qui drop HR
		}
		label variable HarrellC "Harrell's C"
		label variable _2ll "-2 Log likelihood"
		format AIC BIC %9.1f
		format _2ll %6.1f
		format HarrellC %5.3f
		local sumvars AIC BIC HarrellC _2ll
	}
	label variable pValue "Significance of model test"
	format pValue %5.3f
	if (`minvar'==1 & `maxvar'==0) qui drop pValue			//pValue only for minvar,maxvar calls
	qui drop iCat

	*use tabstat to compute summary results
	if (`maxvar'==0) {
		qui tabstat `sumvars', statistics(min max) save
		matrix `r' = r(StatTotal)
	}
	else {
		qui tabstat `sumvars', statistics(min max) save
		matrix `rmax' = r(StatTotal)
		qui tabstat `sumvars' if NVar<=`maxvar', statistics(min max) save
		matrix `r' = r(StatTotal)
		qui drop if NVar>`maxvar' & NVar<.
	}

	local fmt : format Variables
	local fmt : subinstr local fmt "%" "%-"
	format Variables `fmt'
	quietly save `"`using'"', replace		//Save results
	local path = c(filename)				//Saved results path directory

	if (`maxvar'==1) {
		*Save in nrows the real number of combinations in case maxvar=1
		qui count if !missing(NVar)
		local nrows = r(N)
	}

	restore     //Restore original data

	//Print results
	di as res "{break}{break}"
	if ("`type'"=="linear") di "ALLSETS - Linear regression"
	if ("`type'"=="logistic") di "ALLSETS - Logistic regression"
	if ("`type'"=="cox") di "ALLSETS - Cox regression"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	di
	display as txt "ALL VARIABLES"
	if ("`type'"=="linear" | "`type'"=="logistic") {
		display as text "Dependent: " as result "`dep'"
	}
	display as text "Continuous: " as result "`cont'"
	if ("`cat'"!="") display as text "Categoricals: " as result "`cat'"
	if ("`inter'"!="") display as text "Interactions: " as result "`inter'"
	if ("`fixed'"!="") display as text "Fixed: " as result "`fixed'"

	*Print the number of valid and missing values for each variable
	di
	matrix colnames `m' = "Valid Missing"
	matrix rownames `m' = `lvars'
	print_matrix, m(`m') formats("%8.0f %8.0f") rname("Variable") rsize(12)
	display as text "Valid number of cases (listwise): " as result `nvalid'
	if (`hierarch') di as txt "Total number of hierarchical submodels estimated: " as result `nrows'
	else di as txt "Total number of submodels estimated: " as result `nrows'
	if (`minvar'!=1) di as txt "Minimum number of variables included in the combinations: " as result `minvar'
	if (`maxvar'>0) di as txt "Maximum number of variables included in the combinations: " as result `maxvar'
	display as text "Total time: " as result %4.1f `time' as text " seconds"

	//Check collinearity
	qui _rmcoll `vars' if `touse', expand
	if (strpos("`r(varlist)'","o.")>0) {
		di
		di as txt "{bf:WARNING:} variable(s) omitted because of collinearity in some models"
		_rmcoll `vars' if `touse'
	}

	di
	di as txt "A new dataset has been created with the results. Save your data and execute:"
	di as txt "{cmd:use {c 34}`path'{c 34}, clear} to open the dataset with the results"

	*Print stats table
	tempname m
	local k = cond(`maxvar'!=0,2,1)
	foreach z of numlist 1/`k' {
		if (`z'==1) matrix `m' = `r'
		if (`z'==2) matrix `m' = `rmax'
		local cs = cond(`z'==2,"*","")
		if ("`type'"=="logistic") {
			// local c = cond(`lpearson',"*","")
			if ("`weight'"=="") matrix colnames `m' = "AIC BIC AUC Se Sp pfitHL pGof"
		}
		if ("`type'"=="cox") matrix colnames `m' = "AIC BIC HarrellC _2ll"
		print_matrix, m(`m') rname("stats`cs'") rsize(8)
		if ("`type'"=="logistic" & "`weight'"=="" & `lpearson') di as txt "(*)some p values computed with Pearson's Chi2 instead of Hosmer-Lemeshow test"
		if ("`type'"=="logistic" & "`weight'"!="") di as txt "For weighted data the Hosmer-Lemeshow test is not computed"
		if (`z'==2) di as txt "(*)Results computed including maximum model results"
	}
end

program print_matrix
	syntax [anything], m(name) rsize(integer) [formats(string) rname(string)]

	*print data of matrix m
	local ncols = colsof(`m')
	local nrows = rowsof(`m')
	local cnames : colnames `m'
	local rnames : rownames `m'
	local def_fmt "%9.0g"

	*print row title and column labels
	di
	di as txt "{ralign `rsize':`rname'} {c |} " _c
	local s1 = `rsize'+1
	local s2 0
	foreach i of numlist 1/`ncols' {
		local clbl : word `i' of `cnames'
		if ("`formats'"!="") local fmt : word `i' of `formats'
		else local fmt `def_fmt'
		local size = substr("`fmt'",2,strpos("`fmt'",".")-2)
		di as txt "{ralign `size':`clbl'} " _c
		local s2 = `s2' + `size'+1
	}
	di as txt _n "{hline `s1'}{c +}{hline `s2'}" _c

	*print row labels and matrix data
	foreach i of numlist 1/`nrows' {
		local rlbl : word `i' of `rnames'
		local rlbl = abbrev("`rlbl'",`rsize')
		di as txt _n "{ralign `rsize':`rlbl'} {c |} " _c
		foreach j of numlist 1/`ncols' {
			if ("`formats'"!="") local fmt : word `j' of `formats'
			else local fmt `def_fmt'
			di as res `fmt' `m'[`i',`j'] " " _c
		}
	}
	di as txt _n "{hline `s1'}{c BT}{hline `s2'}"
end

program cleanvarname, rclass
	version 12
	args var
	if (strpos("`var'",".")>0){
		*If there's #. get the name without the #.
		local var : subinstr local var "." " ", all
		local var : word 2 of `var'
	}
	return local v_name = "`var'"
end

program define print_error
	args message
	display in red "`message'"
	exit 198
end


version 12
mata:
struct allsets_res
{
	string scalar		dep
	string rowvector	names
	string rowvector	inter
	string rowvector	fixed
	real   scalar       rmse_max
	real   scalar		hierarchical
	real   scalar		tvc, somersd
	string scalar		type
	string scalar		weight
	string scalar		exp
}

version 12
mata:
void getresults(string scalar dep, string scalar indep, string scalar inter, string scalar type, /*
*/				real scalar hierarchical, string scalar fixed, real scalar minvar, real scalar maxvar, /*
*/				string scalar weight, string scalar exp)
{
	struct allsets_res scalar	r
	string colvector			combs
	string colvector			vnames
	real colvector				results
	real scalar					i
	real scalar					len
	real scalar					nrows
	real scalar					maxncomb

	r.dep = dep
	r.names = tokens(indep)
	r.inter = tokens(inter)
	r.fixed = tokens(fixed)
	r.type = type
	r.hierarchical = hierarchical
	r.tvc = strtoreal(st_local("tvc"))
	r.somersd = strtoreal(st_local("somers"))
	r.weight = ""
	if (weight!="") {
		r.weight = "[" + weight + exp + "]"
		r.exp = exp
	}

	timer_clear()
	timer_on(1)

	if (r.type == "linear") {
		//rmse of the maximum model: needed to compute Cp
		stata("regress " + dep + " " + indep + " " + r.weight,1)
		r.rmse_max = st_numscalar("e(rmse)")
	}
	//Get all the possible combinations
	maxncomb = cols(r.names)
	if (maxvar > 0 & maxvar<=maxncomb) maxncomb = maxvar		//Maximum number of variables; ALL by default
	for (i=minvar; i<=maxncomb; i++) {
		combinations(i,1,cols(r.names),combs,r)
	}
	if (maxvar > 0 & maxvar<=maxncomb) addcomb(indep,combs)
	//Compute the regression for each combination
	executereg(results,vnames,combs,r,maxvar)

	//Build the results dataset
	stata("clear")
	nrows = rows(results)
	st_addobs(nrows)
	len = 1
	for (i=1; i<=rows(vnames); i++) {
		if (strlen(vnames[i])>len) len = strlen(vnames[i])
	}
	//len = strlen(vnames[nrows])
	if (r.type=="linear") {
		x = st_addvar(("str" + strofreal(len),"float","float","float","float","float","float","float","float","float","float"), /*
				*/	("Variables","b","pValue","R2","R2Adj","Cp","AIC","BIC","NVar","time","iCat"))
		st_sstore(.,"Variables",vnames)
		st_store(.,"R2",results[.,1])
		st_store(.,"R2Adj",results[.,2])
		st_store(.,"Cp",results[.,3])
		st_store(.,"AIC",results[.,4])
		st_store(.,"BIC",results[.,5])
		st_store(.,"NVar",results[.,6])
		st_store(.,"pValue",results[.,7])
		st_store(.,"b",results[.,8])
		st_store(.,"iCat",results[.,9])

	}
	if (r.type=="logistic") {
		x = st_addvar(("str" + strofreal(len),"float","float","float","float","float","float","float","float","float","float","float","float","float"), /*
				*/	("Variables","OR","pValue","AIC","BIC","AUC","Se","Sp","pfitHL","pGof","pearson","NVar","time","iCat"))
		st_sstore(.,"Variables",vnames)
		st_store(.,"AIC",results[.,1])
		st_store(.,"BIC",results[.,2])
		st_store(.,"AUC",results[.,3])
		st_store(.,"Se",results[.,4])
		st_store(.,"Sp",results[.,5])
		//st_store(.,"df",results[.,6])
		//st_store(.,"chi2",results[.,7])
		st_store(.,"pfitHL",results[.,6])
		st_store(.,"pGof",results[.,7])
		st_store(.,"pearson",results[.,9])
		st_store(.,"NVar",results[.,8])
		st_store(.,"pValue",results[.,10])
		st_store(.,"OR",results[.,11])
		st_store(.,"iCat",results[.,12])
	}
	if (r.type=="cox") {
		x = st_addvar(("str" + strofreal(len),"float","float","float","float","float","float","float","float","float"), /*
				*/	("Variables","HR","pValue","AIC","BIC","HarrellC","_2ll","NVar","time","iCat"))
		st_sstore(.,"Variables",vnames)
		st_store(.,"AIC",results[.,1])
		st_store(.,"BIC",results[.,2])
		st_store(.,"HarrellC",results[.,3])
		st_store(.,"_2ll",results[.,4])
		st_store(.,"NVar",results[.,5])
		st_store(.,"pValue",results[.,6])
		st_store(.,"HR",results[.,7])
		st_store(.,"iCat",results[.,8])
	}

	//Timer: stored in the dataset as the last column
	timer_off(1)
	st_store(1,"time",timer_value(1)[1,1])
}
end

version 12
mata:
void combinations(real scalar elements, real scalar first, real scalar last, string colvector combs, struct allsets_res scalar r)
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
			terms = terms + " " + r.names[i]
		}
		addcomb(terms,combs)
	}
	else {
        //Get solutions containing first allowed (first).
        if (elements == 1) {
			p_combs = J(1,1,"")
		}
		else {
			combinations((elements - 1), (first + 1), last, p_combs, r)
        }

        //Add first to make the full solutions
		for (i=1; i<=rows(p_combs); i++) {
			if (p_combs[i] == "") {
				terms = r.names[first]
			}
			else {
				terms = r.names[first] + " " + p_combs[i]
			}
			addcomb(terms,combs)
		}

        //Get solutions not containing first allowed (first).
        combinations( elements, (first+1), last, p_combs2, r )

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
void executereg(real colvector results, string colvector vnames, string colvector combs, struct allsets_res scalar r, real scalar maxvar) {
	real scalar 	r2
	real scalar 	r2a
	real scalar 	rss
	real scalar 	df_m
	real scalar 	eN
	real scalar 	cp
	real scalar     nvar
	real scalar 	i
	real scalar 	lexe
	real scalar		ll
	real matrix		rSS
	real scalar		aic
	real scalar		bic
	real matrix		rS
	real scalar 	auc
	real scalar 	se
	real scalar 	sp
	real scalar 	pfit
	real scalar		df
	real scalar 	chi2
	real scalar		ll0
	real scalar		hc
	real scalar		pValue
	string scalar 	comb
	string scalar	term
	string scalar	c
	string scalar	hr, invhr, censind
	real scalar		len
	real colvector	mselect
	real matrix		som
	real matrix 	wauc, freq
	string rowvector	terms
	real scalar 	pearson
	string scalar	ypred, yrecode, fr
	real scalar		df_r, F, nrows
	real scalar		ires, icat
	real matrix		coef
	string matrix	coef_names
	real scalar 	pct
	real scalar     pHL, pPearson

	//Declare matrix
	nrows = rows(combs)
	len = nrows
	if (maxvar==1) {
		for (i=1; i<=(nrows-1); i++) {
			c = combs[i]
			if (strpos(c,".")>0 & strpos(c,"#")==0) {
				c = tokens(c,".")[1,3]
				fr = st_tempname()
				stata("tabulate " + c + ",matrow(" + fr + ")",1)
				len = len + rows(st_matrix(fr)) - 1
			}
		}
	}


	if (r.type == "linear") {
		results = J(len,9,.)
	}
	if (r.type == "logistic") {
		results = J(len,12,.)
	}
	if (r.type == "cox") {
		results = J(len,8,.)
	}
	vnames = J(len,1,"")
	mselect = results[.,1]

	ires = 1
	icat = 0
	printf("allsets running "+ strofreal(len) + " submodels...\n")
	printf("0%%")
	displayflush()
	pct = round(len/10)
	for (i=1; i<=rows(combs); i++) {
		if (mod(i,pct)==0) {
			printf("..." + strofreal(10*trunc(i/pct)) + "%%")
			displayflush()
		}
		
		lexe = 1
		comb = combs[i]

		if (r.hierarchical==1) {
			//Exclude non hierarchical combinations -- all the terms in an interaction must be in the combination
			for (j=1; j<=cols(r.inter); j++) {
				if (strpos(" "+comb+" "," "+r.inter[j]+" ")>0) {
					terms = tokens(subinstr(r.inter[j],"#"," "))
					for (k=1; k<=cols(terms); k++) {
						term = terms[k]
						if (strpos(term,"c.")>0){
							term = subinstr(term,"c.","")
						}
						if (strpos(" " + comb + " "," " + term + " ")==0){
							lexe = 0
							break
						}
					}
				}
				if (lexe==0) break
			}
		}
		//Fixed variables: exclude combinations where the fixed variables do not appear
		if (lexe==1){
			for (j=1; j<=cols(r.fixed); j++) {
				c = ""			//Non interactions terms of comb
				terms = tokens(comb)
				for (k=1; k<=cols(terms); k++) {
					if (strpos(terms[k],"#")==0){
						c = c + " " + terms[k]
					}
				}

				if (strpos(strtrim(c),r.fixed[j])==0) {
					lexe = 0
					break
				}
			}
		}

		mselect[ires]=lexe
		if (lexe==1){
			vnames[ires,1] = strtrim(stritrim(comb))
			nvar = cols(tokens(comb))
			if (r.type == "linear") {
				stata("regress " + r.dep + " " + comb + " " + r.weight,1)		//Execute the regression
				r2 = st_numscalar("e(r2)")						//Get the results
				r2a = st_numscalar("e(r2_a)")
				rss = st_numscalar("e(rss)")
				df_m = st_numscalar("e(df_m)")
				eN = st_numscalar("e(N)")
				ll = st_numscalar("e(ll)")
				df_r = st_numscalar("e(df_r)")
				F = st_numscalar("e(F)")
				aic = -2*ll + 2*(df_m+1)
				bic = -2*ll + (df_m+1)*ln(eN)
				cp = rss/(r.rmse_max^2) + (2*(df_m + 1) - eN)
				pValue = Ftail(df_m, df_r, F)
				results[ires,1] = r2
				results[ires,2] = r2a
				results[ires,3] = cp
				results[ires,4] = aic
				results[ires,5] = bic
				results[ires,6] = nvar
				results[ires,7] = pValue
				if (maxvar==1) {
					coef = st_matrix("e(b)")
					coef_names = st_matrixcolstripe("e(b)")
				}
			}
			if (r.type == "logistic") {
				stata("logit " + r.dep + " " + comb + " " + r.weight,1)	//Execute the regression
				df_m = st_numscalar("e(df_m)")			//AIC,BIC,-2ll
				eN = st_numscalar("e(N)")
				ll = st_numscalar("e(ll)")
				loglik = -2*ll
				aic = loglik + 2*(df_m+1)
				bic = loglik + (df_m+1)*ln(eN)
				pValue = st_numscalar("e(p)")			//pValue (significance of model test)
				if (maxvar==1) {
					coef = st_matrix("e(b)")
					coef_names = st_matrixcolstripe("e(b)")
				}
				if (r.weight=="") {
					stata("lroc, nograph",1)				//AUC
					auc = st_numscalar("r(area)")
					stata("estat classification",1)			//Se,Sp
					se = st_numscalar("r(P_p1)")
					sp = st_numscalar("r(P_n0)")
					pHL = .
					if (_stata("estat gof, group(10)",1) == 0) {
						//By default, Hosmer-Lemeshow test, group(10)
						df = st_numscalar("r(df)")
						chi2 = st_numscalar("r(chi2)")
						if (df > 0) {
							pHL = (1 - chi2(df,chi2))
						}
					}
					pPearson = .
					if (_stata("estat gof",1) == 0) {
						df = st_numscalar("r(df)")
						chi2 = st_numscalar("r(chi2)")
						pPearson = (1 - chi2(df,chi2))
					}
/*					//gof: by default, HL -- if not possible, Pearson chi2
					pearson = 1
					if (_stata("estat gof, group(10)",1) == 0) {
						//By default, Hosmer-Lemeshow test, group(10)
						df = st_numscalar("r(df)")
						chi2 = st_numscalar("r(chi2)")
						pearson = (df==0)		//If df == 0, p not available
					}
					if (pearson==1) {
						//If Hosmer-Lemeshow test gives no p, use Pearson chi2 instead
						if (_stata("estat gof",1) == 0) {
							df = st_numscalar("r(df)")
							chi2 = st_numscalar("r(chi2)")
						}
						else {
							//If Pearson chi2 not available, final p will be 1
							df = .
							chi2 = .
						}
					}*/
				}
				else {
					//Weighted regression; AUC and Se, Sp are computed in a different way to apply pweight
					ypred = st_tempname()
					stata( "predict " + ypred,1)
					//Execute rocreg to obtain AUC, predict variable needed
					stata( "rocreg " + r.dep + " " + ypred + " " + r.weight + ", probit ml",1)
					wauc = st_matrix("e(b)")
					auc = wauc[1,3]
					//Se and Sp: build the weighted table to manually compute the values
					yrecode = st_tempname()
					fr = st_tempname()
					stata("recode " + ypred + " (0/0.5=0)(0.5/1=1), gen(" + yrecode + ")",1)
					stata("tabulate " + r.dep + " " + yrecode + " [iweight" + r.exp + "], matcell(" + fr + ")",1)
					freq = st_matrix(fr)
					sp = 100*freq[1,1]/(freq[1,1]+freq[1,2])		//Sp
					se = 100*freq[2,2]/(freq[2,1]+freq[2,2])		//Se
				}
				results[ires,1] = aic
				results[ires,2] = bic
				results[ires,3] = auc
				results[ires,4] = se
				results[ires,5] = sp
				results[ires,6] = pHL
				results[ires,7] = pPearson
				results[ires,8] = nvar
				results[ires,9] = .
				results[ires,10]= pValue
			}
			if (r.type == "cox") {
				stata("stcox " + comb,1)				//Execute the regression
				df_m = st_numscalar("e(df_m)")
				eN = st_numscalar("e(N)")
				ll = st_numscalar("e(ll)")
				chi2 = st_numscalar("e(chi2)")
				loglik = -2*ll							//AIC,BIC,loglik
				aic = loglik + 2*(df_m)
				bic = loglik + (df_m)*ln(eN)
				pValue = chi2tail(df_m,chi2)
				if (maxvar==1) {
					coef = st_matrix("e(b)")
					coef_names = st_matrixcolstripe("e(b)")
				}
				/*chi2 = st_numscalar("e(chi2)")		//R2: DISABLED
				ll0 = st_numscalar("e(ll_0)")
				r2 = (chi2 - 2*df_m)/(-2*ll0)*/
				hc = .
				if (r.tvc==0) {
					//NO TVC: estat concordance to get Harrell's C
					stata("estat concordance, harrell",1)	//Harrell's C
					hc = st_numscalar("r(C)")
				}
				if (r.tvc==1 & r.somersd==1) {
					//Get Harrell's C with user-defined command somersd (if installed)
					hr = st_tempname()
					invhr = st_tempname()
					censind = st_tempname()
					stata("predict " + hr,1)
					stata("gen " + invhr + "=1/" + hr,1)
					stata("gen " + censind + "=1-_d if _st==1",1)
					stata("somersd _t " + invhr + " if _st==1, cenind(" + censind + ") tdist transf(c)",1)
					som = st_matrix("e(b)")
					hc = som[1,1]
					stata("drop " + hr + " " + invhr + " " + censind,1)
				}
				results[ires,1] = aic
				results[ires,2] = bic
				results[ires,3] = hc
				results[ires,4] = loglik
				results[ires,5] = nvar
				results[ires,6] = pValue
			}

			if (maxvar==1) {
				if ((i==nrows) | cols(coef)==2 | (r.type == "cox" & cols(coef)==1)) {
					if (r.type == "linear") results[ires,8] = coef[1,1]
					if (r.type == "logistic") results[ires,11] = coef[1,1]
					if (r.type == "cox") results[ires,7] = coef[1,1]
				}
				else {
					icat = icat + 1
					if (r.type == "linear") results[ires,9] = icat
					if (r.type == "logistic") results[ires,12] = icat
					if (r.type == "cox") results[ires,8] = icat

					k = cols(coef)-1
					if (r.type == "cox") k = cols(coef)
					for (j=2; j<=k; j++) {
						ires = ires+1
						if (r.type == "linear") {
							results[ires,8] = coef[1,j]
							results[ires,9] = icat + (j-1)/100
							results[ires,3] = cp
						}
						if (r.type == "logistic") {
							results[ires,11] = coef[1,j]
							results[ires,12] = icat + (j-1)/100
							results[ires,1] = aic
						}
						if (r.type == "cox") {
							results[ires,7] = coef[1,j]
							results[ires,8] = icat + (j-1)/100
							results[ires,1] = aic
						}
						vnames[ires,1] = coef_names[j,2]
						mselect[ires] = lexe
					}
				}
			}
		}
		ires = ires+1
	}
	results = select(results, mselect)		//Select the rows with valid results
	vnames = select(vnames, mselect)
}
end
