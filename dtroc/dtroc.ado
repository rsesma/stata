*! version 1.1.3  07may2019 JM. Domenech, R. Sesma
/*
dtroc: ROC analysis
*/

program define dtroc, rclass
	version 12
	syntax varlist [if] [in], /*
	*/	[ic(numlist integer max=1) noINC PREV(numlist max=1 >0 <100) 	/*
	*/	 detail cost(numlist max=1 >0) Level(numlist max=1 >50 <100) 	/*
	*/	 ST(string) GRAPH using(string) noreplace nst(string)]

	tempvar ref refneg fp tn npos nneg n tp se sp ef t d lrn lrp pvn pvp j a optimal cumul
	tempname area se alpha b area_lb area_ub data maxef mind t  efficiency roc ratio hyp
	
	*Variable names
	tokenize `varlist'
	local ref0 `1'
	local clas `2'
	
	if ("`level'"=="") local level 95
	if ("`cost'"=="") local cost 1
	*Study type
	if ("`st'"=="") local st = "cs"
	if ("`st'"!="cs" & "`st'"!="cc") print_error "st() invalid -- invalid value" 

	*Check filename
	if ("`using'"=="") local using "dtroc_cutoff.dta"
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
	
	*if/in: select cases
	marksample touse
	preserve
	quietly {
		drop if `touse'==0			//drop cases not used to compute
		local ncases = _N
		if (`ncases'==0) print_error "no observations" 
		
		*Test illness code exists and that outcome vary
		if ("`ic'"=="") local ic 1
		count if `ref0'==`ic'
		if (r(N)==0) print_error "`ic' is not a valid value of `ref0' variable" 
		count if `ref0'!=`ic' & `ref0'<.
		if (r(N)==0) print_error "outcome does not vary"

		*recode so as the 'health' group has all the values of ref0 != ic
		recode `ref0' (`ic'=1) (else=0), generate(`ref')
		recode `ref0' (`ic'=0) (else=1), generate(`refneg')
		
		*Calculations are made with ranks, ascendending sort is needed
		sort `clas' `ref'
		
		*False Positives and True Negatives count as if each cut-off point was used as threshold
		gen `fp' = sum(`ref')
		gen `tn' = sum(`refneg')
		
		*Number of healthy and ill subjects
		egen `npos' = max(`fp')
		egen `nneg' = max(`tn')

		*To use the classifier variable as breaking variable clears the ties, 
		*making the classifier values cut-off points; create the False Positive, 
		*True Negative, and the number of positives and negatives
		collapse (max) `fp' `tn' `npos' `nneg', by(`clas')

		*Add one case, with se=100%, sp=0% if increasing, or se=0%, sp=100% if decreasing
		local n1 = _N+1
		set obs `n1'
		*Move last case to the first position
		gen `t' = 1 in `n1'
		sort `t' `clas'
		drop `t'
		*Populate the first added case and reassign classifier values to the next
		replace `fp'=0 in 1
		replace `tn'=0 in 1
		replace `npos'=`npos'[_n+1] in 1
		replace `nneg'=`nneg'[_n+1] in 1
		replace `clas' = `clas'[_n+1]
		replace `clas' = `clas'[_n-1] in `n1'
		
		*Sensitibity, Specificity & Efficiency
		gen `tp' = `npos' - `fp'			//True positives
		if ("`inc'"=="") {
			*Illness increases test variable
			gen `se' = 100*`tp'/`npos'
			gen `sp' = 100*`tn'/`nneg'
			gen `ef' = 100*(`tp'+`tn')/(`npos'+`nneg')
		}
		else {
			*Illness decreases test variable
			gen `se' = 100 - 100*`tp'/`npos'
			gen `sp' = 100 - 100*`tn'/`nneg'
			gen `ef' = 100*(`fp'+`nneg'-`tn')/(`npos'+`nneg')
		}
		*d
		gen `d' = sqrt((1-`se'/100)^2 + (1-`sp'/100)^2)

		*Youden J, Likelihood ratios
		gen `lrn' = (100-`se')/`sp'
		gen `lrp' = `se'/(100-`sp')
		gen `j' = `se'+`sp'-100

		*Sample Prevalence
		local sample_prev = `npos'[1]/(`npos'[1]+`nneg'[1])*100
		local sample_print = string(`sample_prev',"%7.0g")
		if("`prev'"!="") local prev_print = string(`prev',"%7.0g")
		if ("`st'"=="cs" | "`prev'"!="") {
			*Predictive Values, with given or sample prevalence
			if ("`prev'"=="") local p = `sample_prev'/100
			else local p = `prev'/100
			gen `pvn' = 100*((1-`p')*`sp')/((`p'*(100-`se'))+((1-`p')*`sp'))
			gen `pvp' = 100*(`p'*`se')/((`p'*`se')+((1-`p')*(100-`sp')))
		}
		
		*ROC area. With the abs() function this compute is also valid for decreasing test variables
		gen `a' = abs((((`se'+`se'[_n-1])/2) * (`sp'-`sp'[_n-1]))/10000)
		sum `a'
		scalar `area' = r(sum)
		scalar `se' = sqrt(`area'*(1-`area')/`ncases')
		scalar `b' = `area'*`ncases'
		scalar `alpha' = (`level'+100)/200
		scalar `area_lb' = `b'/(`b'+(`ncases'-`b'+1)*invF(2*(`ncases'-`b'+1), 2*`b',`alpha'))
		scalar `area_ub' = (`b'+1)/(`b'+1 +(`ncases'-`b')/invF(2*(`b'+1),2*(`ncases'-`b'),`alpha'))
	}
	
	di 
	di as res "ROC ANALYSIS & OPTIMAL CUTOFF POINT"
	if ("`nst'"!="") display as text "{bf:STUDY:} `nst'"

	*ROC area
	di
	di as txt "{hline 69}"
	di as txt " Valid cases (total): " as res %6.0f `ncases'
	di as txt " Area Under Curve: AUC = " as res  %7.5f `area' as txt " (`level'% CI: " /*
	*/			as res %7.5f `area_lb' as txt " to " as res %7.5f `area_ub' as txt ") (Exact)"
	di as txt "{hline 69}"

	*Graph
	if ("`graph'"!="") {
		*set trace on
		qui replace `se' = `se'/100
		qui replace `sp' = `sp'/100
		twoway (line `se' `clas', sort) (line `sp' `clas', sort lpattern(dash)), ///
		ytitle("Probability") ylabel(0(0.1)1, angle(horizontal) glcolor(gs10)) ymtick(##5) ///
		xlabel(, grid glcolor(gs10)) ///
		legend(order( 1 "Sensitivity" 2 "Specificity") rows(2) position(2) symxsize(5)) 
		qui replace `se' = `se'*100
		qui replace `sp' = `sp'*100
	}

	if ("`detail'"!="") {
		*Print detail report
		local note = cond(("`st'"=="cs" & "`prev'"!=""),"*","")
		local c = cond(("`prev'"==""),"for SAMPLE Prevalence","for Hyp. Prev.= `prev_print'%")
		
		di
		di as txt _col(43) "Likelihood" _c
		if ("`st'"=="cs" | "`prev'"!="") di _col(57) "Predictive Values`note'" _c
		di _newline _col(45) "Ratios" _c
		if ("`st'"=="cs" | "`prev'"!="") di _col(55) "`c'" _c
		di _newline _col(34) "Youden" _col(41) "{hline 13}" _c
		if ("`st'"=="cs" | "`prev'"!="") di _col(55) "{hline 21}" _c
		di _newline "{center 10:CUT-OFF}  {ralign 6:Se(%)} {ralign 6:Sp(%)} Eff(%) {center 6:J(%)} " _c
		di "{center 6:LR+} {ralign 6:1/LR-}" _c
		if ("`st'"=="cs" | "`prev'"!="") di "  {center 9:PV+(%)} {center 9:PV-(%)}" _c
		di _newline "{hline 10}  {hline 6} {hline 6} {hline 6} {hline 6} {hline 6} {hline 6}" _c
		if ("`st'"=="cs" | "`prev'"!="") di "  {hline 9} {hline 9}" _c
		
		foreach i of numlist 1/`n1' {
			if (`i'!=`n1') local sign = cond("`inc'"!="",">=","<=")
			else local sign = cond("`inc'"!="","> ","< ")

			local pos 13
			di as txt _newline "`sign'" as res %8.0g `clas'[`i'] _c
			foreach v in `se' `sp' `ef' `j' `lrp' `lrn' {
				local val = `v'[`i']
				if (`v'==`lrn') local val = 1/`val'
				if (`v'!=`lrp' & `v'!=`lrn') print_pct `val', nopercent col(`pos')
				else di as res _col(`pos') %6.0g `val' _c
				local pos = `pos'+7
			}
			if ("`st'"=="cs" | "`prev'"!="") {
				local val = `pvp'[`i']
				print_pct `val', nopercent col(58)
				local val = `pvn'[`i']
				print_pct `val', nopercent col(68)
			}			
		}
		if ("`st'"=="cs" | "`prev'"!="") di _newline "{hline 75}"
		else di _newline "{hline 53}"
		if ("`st'"!="cc") di as txt "SAMPLE prevalence = `sample_print'%"
		if ("`st'"=="cs" & "`prev'"!="") di as txt "*Assumed constant Sensitivity and Specificity"
		
		*Save detail results
		tempfile dirtmp
		qui {
			save `dirtmp'			//Save actual dataset
			if ("`st'"=="cs" | "`prev'"!="") {
				rename (`clas' `se' `sp' `ef' `j' `lrp' `pvp' `pvn') (CutOff Se Sp Eff Youden LRpos PVpos PVneg)
				keep CutOff Se Sp Eff Youden LRpos PVpos PVneg `lrn'
			}
			else {
				rename (`clas' `se' `sp' `ef' `j' `lrp') (CutOff Se Sp Eff Youden LRpos)
				keep CutOff Se Sp Eff Youden LRpos `lrn'
			}
			gen rLRneg = 1/`lrn'
			drop `lrn'
			if ("`st'"=="cs" | "`prev'"!="") order CutOff Se Sp Eff Youden LRpos rLRneg PVpos PVneg
			else order CutOff Se Sp Eff Youden LRpos rLRneg
			label variable CutOff "Cut-Off point"
			label variable Se "Sensitivity (%)"
			label variable Sp "Specificity (%)"
			label variable Eff "Efficiency (%)"
			label variable Youden "Youden J (%)"
			label variable LRpos "Likelihood Ratio + (%)"
			label variable rLRneg "1/Likelihood Ratio - (%)"
			if ("`st'"=="cs" | "`prev'"!="") label variable PVpos "Predictive Values + (%)"
			if ("`st'"=="cs" | "`prev'"!="") label variable PVneg "Predictive Values - (%)"
			save `"`using'"', replace
			use `dirtmp'			//Restore working dataset
		}
		di as txt "A new dataset has been created with table data."
		di as txt "To open the new dataset execute: {cmd:use {c 34}`using'{c 34}}"
	}
	qui drop in `n1'
	
	if ("`st'"=="cs" | "`prev'"!="") local pv = 1
	else local pv = 0
	*OPTIMAL CUTOFF POINTS
	*Maximum efficiency (FNcost=FPcost)
	di
	di as txt "{bf:OPTIMAL CUTOFF POINT for maximum efficiency} (FNcost=FPcost)"
	qui sum `ef'
	scalar `maxef' = r(max)			//Maximum value of the efficiency
	*Get data of the optimal cut-off points
	if ("`st'"=="cs" | "`prev'"!="") mkmat `clas' `se' `npos' `sp' `nneg' `pvp' `pvn' if `ef'==`maxef', matrix(`data')
	else mkmat `clas' `se' `npos' `sp' `nneg' if `ef'==`maxef', matrix(`data')
	get_results `data' `efficiency', level(`level') pv(`pv')
	if (rowsof(`efficiency')>1) di as txt " Multiple cutoff points: " as res r(values) _newline
	print_results `efficiency', pv(`pv') p(`p') level(`level') prev(1)

	*ROC curve: minimize d
	di
	di as txt "{bf:OPTIMAL CUTOFF POINT based on ROC curve} (FNcost=FPcost)"
	qui sum `d'
	scalar `mind' = r(min)			//Minimum value of d
	*Get data of the optimal cut-off points
	if ("`st'"=="cs" | "`prev'"!="") mkmat `clas' `se' `npos' `sp' `nneg' `pvp' `pvn' if `d'==`mind', matrix(`data')
	else mkmat `clas' `se' `npos' `sp' `nneg' if `d'==`mind', matrix(`data')
	get_results `data' `roc', level(`level') pv(`pv')
	if (rowsof(`roc')>1) di as txt " Multiple cutoff points: " as res r(values) _newline
	print_results `roc', pv(`pv') p(`p') level(`level') prev(1)
	
	if (`pv'==1) {
		*Zweig & Campbell
		di
		di as txt "{bf:OPTIMAL CUTOFF POINT} for: RATIO FNcost/FPcost = `cost'"
		if ("`prev'"=="") di as txt _col(29) "SAMPLE prevalence = `sample_print'%" 
		else di as txt _col(36) "Prevalence = `prev_print'%" 
		
		getoptimal `se' `sp', optimal(`optimal') p(`p') cost(`cost')
		*Get data of the optimal cut-off points
		if ("`st'"=="cs" | "`prev'"!="") mkmat `clas' `se' `npos' `sp' `nneg' `pvp' `pvn' if `optimal'==1, matrix(`data')
		else mkmat `clas' `se' `npos' `sp' `nneg' if `optimal'==1, matrix(`data')
		drop `optimal'
		get_results `data' `ratio', level(`level') pv(`pv')
		if (rowsof(`ratio')>1) di as txt " Multiple cutoff points: " as res r(values) _newline
		print_results `ratio', pv(`pv') p(`p') level(`level') prev(0)
	}
	
	*Compute the Hypothetical Prevalence x cost table
	*Header
	di
	di as txt "{bf:OPTIMAL CUTOFF POINT}**"
	di as txt "Hypothetical  {hline 10} False Negative Cost / False Positive Cost {hline 9}"
	di as txt "Prevalence*    1/16    1/8    1/4    1/2     1      2      4      8     16"
	di as txt "{hline 13} {hline 6} {hline 6} {hline 6} {hline 6} {hline 6} {hline 6} {hline 6} {hline 6} {hline 6}" _c
	*Loop through the Hypothetical Prevalences
	foreach pr of numlist 0.05 0.1 0.2 0.3 0.4 0.5 {
		matrix `data' = J(3,9,.)
		local i 1
		*For each prevalence, compute the optimal cutoff point for each cost
		foreach c of numlist 0.0625 0.125 0.25 0.5 1 2 4 8 16 {
			getoptimal `se' `sp', optimal(`optimal') p(`pr') cost(`c')
			mkmat `clas' `se' `sp' if `optimal'==1, matrix(`t')
			matrix `data'[1,`i'] = `t'[1,1]		//Get the FIRST optimal cutoff point (in case there's more than one)
			matrix `data'[2,`i'] = `t'[1,2]
			matrix `data'[3,`i'] = `t'[1,3]
			drop `optimal'
			local i = `i'+1
		}
		if (`pr'==0.05) matrix `hyp' = `data'
		else matrix `hyp' = `hyp' \ `data'
	}
	tempname prev
	matrix define `prev' = (5,10,20,30,40,50)
	local z 1
	foreach i of numlist 1/18 {
		if (inlist(`i',1,4,7,10,13,16)) {
			if (`i'!=1) di _newline _c
			di as txt _newline %2.0f `prev'[1,`z'] "%" _col(8) "Cutoff " _c
			local ++z
		}
		else {
			if (inlist(`i',2,5,8,11,14,17)) di as txt _newline _col(8) "Se (%) " _c
			if (inlist(`i',3,6,9,12,15,18)) di as txt _newline _col(8) "Sp (%) " _c
		}
		foreach j of numlist 1/9 {
			if (inlist(`i',1,4,7,10,13,16)) {
				di as res %6.0g `hyp'[`i',`j'] as txt " " _c
			}
			else {
				local v = `hyp'[`i',`j']
				di as txt " " _c
				print_pct `v', nopercent
				di as txt " " _c
			}
		}
	}
	di as txt _newline "{hline 76}"
	di as txt "*Assumed constant Sensitivity and Specificity"
	di as txt "**Zweig & Campbell. Clin Chem. 1993;39:561-77."
	
	restore
	
	//Stored results
	return scalar N = `ncases'
	return scalar level = `level'
	return scalar auc = `area'
	return scalar lb_auc = `area_lb'
	return scalar ub_auc = `area_ub'
	if (`pv') return scalar prev = 100*`p'
	local names = cond(`pv',"cutoff se lb_se ub_sp sp ub_sp lb_sp pvp pvn","cutoff se lb_se ub_sp lb_sp sp ub_sp")
	matrix colnames `efficiency' = `names'
	return matrix efficiency = `efficiency'
	matrix colnames `roc' = `names'
	return matrix roc = `roc'
	if (`pv') {
		matrix colnames `ratio' = `names'
		return matrix ratio = `ratio'
	}
	matrix colnames `hyp' = 1/16 1/8 1/4 1/2 1 2 4 8 16
	local rownames
	foreach i of numlist 5 10 20 30 40 50 {
		local rownames = "`rownames' `i'_cutoff `i'_se `i'_sp"
	}
	matrix rownames `hyp' = `rownames'
	return matrix hypothetical = `hyp'
end

program define print_pct
	syntax anything, [col(numlist max=1) nopercent]
	local p = `anything'
	local fmt = cond(abs(`p')<10,cond(abs(`p')<1,"%5.0g","%5.2f"),"%5.1f")
	if ("`col'"=="") di as res `fmt' `p' _c
	else di as res _col(`col') `fmt' `p' _c
	if ("`percent'"=="") di as txt "%" _c
end

program define get_results, rclass
	version 12
	syntax anything, pv(integer) level(real)
	
	tokenize `anything'
	local d `1'
	local r `2'

	local len = rowsof(`d')
	local cols = cond(`pv',9,7)
	matrix define `r' = J(`len',`cols',.)
	local values 
	foreach i of numlist 1/`len' {
		local cutoff = `d'[`i',1]
		matrix `r'[`i',1] = `cutoff'
		
		*Se CI
		local se = `d'[`i',2]/100
		local n = `d'[`i',3]
		qui cii `n' `se', wilson level(`level')
		matrix `r'[`i',2] = `d'[`i',2]
		matrix `r'[`i',3] = 100*r(lb)
		matrix `r'[`i',4] = 100*r(ub)

		*Sp CI
		local sp = `d'[`i',4]/100
		local n = `d'[`i',5]
		qui cii `n' `sp', wilson level(`level')
		matrix `r'[`i',5] = `d'[`i',4]
		matrix `r'[`i',6] = 100*r(lb)
		matrix `r'[`i',7] = 100*r(ub)

		*PV+, PV-
		if (`pv') {
			matrix `r'[`i',8] = `d'[`i',6]
			matrix `r'[`i',9] = `d'[`i',7]
		}
		
		local values = "`values' `cutoff'"
	}
	
	return local values = "`values'"
end

program define print_results
	version 12
	syntax anything, pv(integer) prev(integer) Level(numlist max=1) [p(numlist max=1)]

	local d `anything'
	local noptimal = rowsof(`d')
	foreach i of numlist 1/`noptimal' {
		di as txt " Cutoff point: " as res string(`d'[`i',1],"%8.0g")
		
		local se = `d'[`i',2]
		local lo = `d'[`i',3]
		local up = `d'[`i',4]
		di as txt "  Sensitivity: Se=" _c
		print_pct `se'
		di as txt " (`level'% CI: " _c
		print_pct `lo', nopercent
		di as txt " to " _c
		print_pct `up', nopercent
		di as txt ") (Wilson)"
		
		local sp = `d'[`i',5]
		local lo = `d'[`i',6]
		local up = `d'[`i',7]
		di as txt "  Specificity: Sp=" _c
		print_pct `sp'
		di as txt " (`level'% CI: " _c
		print_pct `lo', nopercent
		di as txt " to " _c
		print_pct `up', nopercent
		di as txt ") (Wilson)"
		
		if (`pv'==1) {
			local preval = string(100*`p',"%4.1f")
			local c = cond(`prev'==1,"(Prev = `preval'%)","")
			di as txt "  Positive predictive value `c': PV+ =" _c
			local pvp = `d'[`i',8]
			print_pct `pvp'
			di as txt _newline "  Negative predictive value `c': PV- =" _c
			local pvn = `d'[`i',9]
			print_pct `pvn'
			di ""
		}
		
		if (`i'!=`noptimal') di
	}
	di as txt "{hline 76}"
end

program define getoptimal, rclass
	version 12
	syntax varlist, optimal(string) p(numlist max=1 >0 <100) cost(numlist max=1 >0)

	tempname m maxf
	tempvar f
	
	tokenize `varlist'
	local se `1'
	local sp `2'
	
	*OPTIMAL CUT-OFF POINT 
    /*From Receiver-Operating Characteristic (ROC) Plots: A Fundamental Evaluation Tool in Clinical Medicine
      Zweig & Campbell, Clinical Chemistry, vol 39, no 4, pag 572 (1993)*/
	*Add COST: compute a slope m = (false-positive cost/false-negative cost)*((1-Prevalence)/Prevalence) = (1/cost)*((1-p)/p)
    scalar `m' = (1/`cost')*((1-`p')/`p')
	*The OPTIMAL point is the se,sp pair that maximizes the function [se - m(1-sp)], where m is the slope previously computed
	qui gen `f' = (`se'-`m'*(100-`sp'))
	qui sum `f'
	scalar `maxf' = r(max)			//Maximum value of the function

	*optimal = 1 for the optimal Cut-Off point
	qui gen `optimal' = (`f'==`maxf')
end

program define print_error
	args message
	display in red "`message'" 
	exit 198
end
