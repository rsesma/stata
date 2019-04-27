*! version 1.4.4 27apr2019 JM. Domenech, R. Sesma

/*
META-ANALYSIS: OR,RR,RD,IR,ID,B,MD,R COMBINED
*/
program define mar, rclass
	version 12
	syntax anything(id="risk measure and type of data") [if] [in], [TABles INFlu METhod(string) CUM(string)    /*
	*/	BEGG EGGer MACask(string) NUS(numlist max=1 >0 <1) INTerval(string) FORest(string) HISTogram RADial    /*
	*/  cumulative abbe FUNnel FUNNELH GALBraith Level(numlist max=1 >50 <100) COHen HEDges GLAss keepmissing  /*
	*/	keep zero(string) exp date(string) nst(string)]

	*Tokenize anything parameter
	tokenize `anything'
	local type `1'
	local stat `2'
	
	*Check parameters
	if ("`stat'"!="or" & "`stat'"!="rr" & "`stat'"!="ir" & "`stat'"!="rd" & /*
	*/	"`stat'"!="id" & "`stat'"!="b" & "`stat'"!="md" & "`stat'"!="r") print_error "statistic `stat' invalid" 	
	if ("`type'"!="raw" & "`type'"!="sst" & "`type'"!="mix") print_error "type `type' invalid"
	if ("`method'"=="") local method "fem"
	if ("`method'"!="fem" & "`method'"!="rem" & "`method'"!="mh" & "`method'"!="peto") print_error "method `method' invalid"
	if ("`type'"!="raw" & ("`method'"=="mh" | "`method'"=="peto")) print_error "method `method' is only available with raw data"
	if ("`method'"=="peto" & "`stat'"!="or") print_error "method `method' is only compatible with or statistic"
	if (("`method'"=="peto" | "`method'"=="mh") & ("`stat'"=="rd" | "`stat'"=="id")) print_error "method `method' is not compatible with `stat' statistic"
	if ("`level'"=="") local level 95
	if ("`zero'"=="") local zero "n"
	if ("`zero'"!="n" & "`zero'"!="c" & "`zero'"!="p" & "`zero'"!="e") print_error "zero invalid"
	if ("`exp'"!="" & "`stat'"!="b") print_error "exp option incompatible with `stat' statistic"
	if ("`date'"=="") local date "YMD"
	if ("`date'"!="YMD" & "`date'"!="YM" & "`date'"!="Y") print_error "date invalid"
	if ("`cumulative'"!="" & "`cum'"=="") print_error "cumulative analisys (cum option) is needed for the cumulative graphic"
	if ("`type'"!="raw" & "`abbe'"!="") print_error "raw data type is needed for l'Abbe plot"
	if ("`type'"=="raw" & "`stat'"=="md" & "`abbe'"!="") print_error "md statistic is not compatible with l'Abbe plot"
	if ("`type'"=="raw" & "`stat'"=="b") print_error "b statistic is not compatible with raw data"
	if ("`type'"=="raw" & "`stat'"=="r") print_error "r statistic is not compatible with raw data"
	if ("`type'"=="mix" & "`stat'"=="r") print_error "r statistic is not compatible with mixed data"
	if ("`cohen'"!="" & ("`hedges'"!="" | "`glass'"!="")) print_error "only one of cohen, hedges, glass options is allowed"
	if ("`hedges'"!="" & "`glass'"!="") print_error "only one of cohen, hedges, glass options is allowed"
	if ("`cohen'"=="" & "`hedges'"=="" & "`glass'"=="") local md_std 0			//No standardization
	if ("`cohen'"!="") local md_std 1			//Mean difference standardization: Cohen's d
	if ("`hedges'"!="") local md_std 2			//Mean difference standardization: Hedges' g
	if ("`glass'"!="") local md_std 3			//Mean difference standardization: Glass's delta
	
	tempname vzeros
	
	*Study is mandatory
	checkvars study, errmsg
	local study_type : type study
	if (substr("`study_type'",1,3)!="str") qui tostring(study), replace force	//Transform numeric study variable to string

	marksample touse			//ifin marksample
	preserve					//Preserve original data
	quietly keep if `touse'		//Select cases

	if (_N == 0) print_error "no data available"		//Check there's data on the dataset

	*Check for auxiliary variables: date var and interval, forest plot vars
	checkvars date, local(ldate)
	local ldate = cond(`ldate'==1,"date","")
	if ("`interval'"!="" & "`interval'"!="se") checkvars `interval', errmsg
	if ("`forest'"!="" & "`forest'"!="se") checkvars `forest', errmsg

	local lzeros 0
	if ("`type'"=="raw") {
		data_raw `stat', zero(`zero') vzeros(`vzeros') md_std(`md_std') level(`level')
		local lzeros = r(zeros)
		local ormh_zero = r(ormh_zero)
		local md_exists = r(md_exists)
	}
	if ("`type'"=="sst") {
		if ("`stat'"=="r") {
			tempname rho
			capture g `rho' = r
		}
		data_sst `stat',level(`level')
	}
	local keep_mix = ""
	if ("`type'"=="mix") {
		restore
		
		quietly {
			*Look for variable names in the dataset
			tempname E
			matrix `E' = J(1,21,.)
			local i 1
			foreach v in `stat' a1 a0 b1 b0 n1 n0 n i1 i0 t1 t0 se lo up cl pexp pexp_nc pres pres_ue _mar_ {
				capture confirm variable `v'
				matrix `E'[1,`i'] = (!_rc)
				local i = `i'+1
			}
			/*E gets existence of variables:
			  1: statistic, 2: a1, 3: a0, 4: b1, 5: b0, 6: n1, 7: n0, 8: n, 9: i1, 10: i0
			  11: t1, 12: t0, 13: se, 14: lo, 15: up, 16: cl, 17: pexp, 18: pexp_nc, 19: pres, 20: pres_ue
			  21: _mar_*/

			*Check for data errors if the dataset is not keeped
			if (!`E'[1,21]) {
				quietly {
					capture drop __err
					g __err = 0
					if (`E'[1,1] & `E'[1,2] & `E'[1,3]) replace __err = 1 if (`stat'<. & (a1<. | a0<.))
					if (`E'[1,2] & `E'[1,3] & `E'[1,13]) replace __err = 2 if (se<. & (a1<. | a0<.))
					if (`E'[1,2] & `E'[1,3] & `E'[1,14] & `E'[1,15]) replace __err = 3 if ((lo<. | up<.) & (a1<. | a0<.))
					if (`E'[1,13] & `E'[1,14] & `E'[1,15]) replace __err = 4 if ((lo<. | up<.) & se<.)
					if (`E'[1,2] & `E'[1,3] & `E'[1,8]) replace __err = 5 if (n<. & (a1<. | a0<.))
					if (`E'[1,4] & `E'[1,5] & `E'[1,6] & `E'[1,7]) replace __err = 6 if ((b1<. | b0<.) & (n1<. | n0<.))
					if (`E'[1,9] & `E'[1,10] & `E'[1,11] & `E'[1,12]) replace __err = 7 if ((i1<. | i0<.) & (t1<. | t0<.))
					if (`E'[1,2] & `E'[1,3] & `E'[1,17]) replace __err = 8 if (pexp<. & (a1<. | a0<.))
					if (`E'[1,2] & `E'[1,3] & `E'[1,18]) replace __err = 8 if (pexp_nc<. & (a1<. | a0<.))
					if (`E'[1,2] & `E'[1,3] & `E'[1,19]) replace __err = 8 if (pres<. & (a1<. | a0<.))
					if (`E'[1,2] & `E'[1,3] & `E'[1,20]) replace __err = 8 if (pres_ue<. & (a1<. | a0<.))
					label variable __err "Data error"
					label define derr 0 "Correct" 1 "Error: a1,a0 incompatible with `stat'" 2 "Error: a1,a0 incompatible with se" ///
									  3 "Error: a1,a0 incompatible with lo,up" 4 "Error: se incompatible with lo,up" ///
									  5 "Error: n incompatible with a1,a0" 6 "Error: b1,b0 incompatible with n1,n0" ///
									  7 "Error: i1,i0 incompatible with t1,t0" 8 "Error: pexp,pexp_nc,pres,pres_ue incompatible with a1,a0", replace
					label values __err derr
					
					summarize __err
					if (r(sum)>0) print_error "some observations have data errors -- see __err variable"
					drop __err
					label drop derr
				}
			}
			  
			preserve
			*Mixed type: stat variable is needed
			if (!`E'[1,1]) print_error "missing `stat' variable for mixed type of data" 
			if (!`E'[1,13]) g se=.		//If se doesn't exists, it's created missing

			if ((`E'[1,2] & !`E'[1,3]) | (!`E'[1,2] & `E'[1,3])) print_error "for raw data observations variables a1 and a0 are needed" 
			if (`E'[1,2] & `E'[1,3]) {
				if ("`stat'"=="b" | "`stat'"=="md") print_error "raw data observations are incompatible with `stat' statistic" 
				*Raw data observations: complete the missing data and compute statistic
				if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") {
					if ((`E'[1,4] & !`E'[1,5]) | (!`E'[1,4] & `E'[1,5])) print_error "missing variable b1 or b0 for raw data observations" 
					if (!`E'[1,4] & !`E'[1,5]) {
						g b1 = .		//Create b1, b0 variables missing
						g b0 = .
					}
					if ((`E'[1,6] & !`E'[1,7]) | (!`E'[1,6] & `E'[1,7])) print_error "missing variable n1 or n0 for raw data observations" 
					if (!`E'[1,6] & !`E'[1,7]) {
						g n1 = .		//Create n1, n0 variables missing
						g n0 = .
					}
					replace n1 = a1 + b1 if (n1==.)
					replace n0 = a0 + b0 if (n0==.)
					replace b1 = n1 - a1 if (b1==.)
					replace b0 = n0 - a0 if (b0==.)
					
					tempname vraw
					g `vraw' = !missing(a1)		//raw observations must have a valid value on a1
					zero_correction `zero', vzeros(`vzeros') mixed vraw(`vraw')
					local lzeros = r(zeros)
					local ormh_zero = r(ormh)
					if (`lzeros') local keep_mix = "a1 a0 b1 b0 n1 n0 n"
					
					if ("`stat'" == "or") {
						replace or = (a1 / b1) / (a0 / b0) if or==.
						replace se = sqrt(1/a1 + 1/b1 + 1/a0 + 1/b0) if (se==. & a1!=.)
					}
					if ("`stat'" == "rr") {
						replace rr = (a1 / n1) / (a0 / n0) if rr==.
						replace se = sqrt(1/a1 - 1/n1 + 1/a0 - 1/n0) if (se==. & a1!=.)
					}
					if ("`stat'" == "rd") {
						replace rd = (a1 / n1) - (a0 / n0) if rd==.
						replace se = sqrt(((a1/n1)*(1-(a1/n1)))/n1 + ((a0/n0)*(1-(a0/n0)))/n0) if (se==. & a1!=.)
					}

					if (`E'[1,8]) replace n = n1 + n0 if (n==.)

					if (`E'[1,17]) replace pexp = n1/(n1+n0) if (pexp==.)
					if (`E'[1,18]) replace pexp_nc = b1/(b0+b1) if (pexp_nc==.)
					if (`E'[1,19]) replace pres = (a0+a1)/(n1+n0) if (pres==.)
					if (`E'[1,20]) replace pres_ue = a0/n0 if (pres_ue==.)
					
					if (`E'[1,17] & `lzeros') local keep_mix = "`keep_mix' pexp"
					if (`E'[1,18] & `lzeros') local keep_mix = "`keep_mix' pexp_nc"
					if (`E'[1,19] & `lzeros') local keep_mix = "`keep_mix' pres"
					if (`E'[1,20] & `lzeros') local keep_mix = "`keep_mix' pres_ue"
				}
				if ("`stat'"=="ir" | "`stat'"=="id") {
					if ((`E'[1,11] & !`E'[1,12]) | (!`E'[1,11] & `E'[1,12])) print_error "missing variable b1 or b0 for raw data observations" 
					if (!`E'[1,11] & !`E'[1,12]) {
						g t1 = .		//Create b1, b0 variables missing
						g t0 = .
					}
					if ((`E'[1,9] & !`E'[1,10]) | (!`E'[1,9] & `E'[1,10])) print_error "missing variable n1 or n0 for raw data observations"
					if (!`E'[1,9] & !`E'[1,10]) {
						g i1 = .		//Create n1, n0 variables missing
						g i0 = .
					}
					replace i1 = a1/t1 if (i1==.)
					replace i0 = a0/t0 if (i0==.)
					replace t1 = a1/i1 if (t1==.)
					replace t0 = a0/i0 if (t0==.)

					if ("`stat'" == "ir") {
						replace ir = (a1/t1) / (a0/t0) if ir==.
						replace se = sqrt(1/a1 + 1/a0) if (se==. & a1!=.)
					}
					if ("`stat'" == "id") {
						replace id = (a1/t1) - (a0/t0) if id==.
						replace se = sqrt(a1/t1^2 + a0/t0^2) if (se==. & a1!=.)
					}

					if (`E'[1,17]) replace pexp = t1/(t1+t0) if (pexp==.)
					if (`E'[1,19]) replace pres = (a0+a1)/(t1+t0) if (pres==.)
					if (`E'[1,20]) replace pres_ue = a0/t0 if (pres_ue==.)
				}
			}
			if ((`E'[1,14] & !`E'[1,15]) | (!`E'[1,14] & `E'[1,15])) print_error "missing variable lo or up for sst data observations"
			if (!`E'[1,14] & !`E'[1,15]) {
				qui gen lo = .		//Create lo, up variables missing
				qui gen up = .
			}
					
			if (!`E'[1,16]) g cl=.
			replace cl=95 if cl==.

			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") {
				replace se = (ln(up)-ln(lo))/(2*invnormal((cl+100)/200)) if se==.
				replace lo = `stat'*exp(-invnormal((cl+100)/200)*se) if lo==.
				replace up = `stat'*exp(invnormal((cl+100)/200)*se) if up==.
			}
			else {
				replace se = (up-lo)/(2*invnormal((cl+100)/200)) if se==.
				replace lo = `stat' - invnormal((`level'+100)/200)*se if lo==.
				replace up = `stat' + invnormal((`level'+100)/200)*se if up==.
			}
		}
		
		*From this point on the command must behave as if type = sst
		local type = "sst"
	}	
	*Cumulative sort variable
	qui gen __cumsort = .
	local ldesc 1			//Descendent (greater -> lower) order by default
	if ("`cum'"!="") {
		local lreverse = (substr("`cum'",1,1)=="-") 		//Reverse order?
		if (`lreverse') local cum = substr("`cum'",2,.)		//Variable name without the reverse sign
		if ("`cum'"=="date" | "`cum'"=="n") local ldesc 0	//date | n variable: sort ascedending (lower -> greater)
		if (`lreverse') local ldesc = !`ldesc'				//Reverse order
		
		qui replace __cumsort = `cum'
	}

	*Check for missing variables
	local ntotal = _N
	if ("`keepmissing'"=="") {
		*By default, studies with missing data are deleted (keepmissing option prevents the default)
		if ("`type'"=="raw") {
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") local lvars = "a1,b1,n1,a0,b0,n0"
			if ("`stat'"=="ir" | "`stat'"=="id") local lvars = "a1,i1,t1,a0,i0,t0"
			if ("`stat'"=="md") local lvars = "m1,sd1,n1,m0,sd0,n0"
		}
		if ("`type'"=="sst") {
			if ("`stat'"!="r") local lvars = "`stat',se,lo,up"
			else local lvars = "r,n"
		}
		qui keep if !missing(`lvars')
	}
	local nmiss = _N
	local ldeleted = `ntotal'!=`nmiss'
	local ndeleted = `ntotal'-`nmiss'
	
	local len = _N
	local len_1 = _N+1

	local raw_md = ("`type'"=="raw" & "`stat'"=="md")		//md studies with raw data
	if (`raw_md') local type = "sst"	//md studies with raw data must behave like sst data
	
	//Results using mata
	mata: init("`type'","`stat'",`len',`level',("`influ'"!=""),"`method'",("`cum'"!=""),`ldesc')

	//Read mata results into stata matrix
	tempname d st stp rw sw peto inv invlo invup mh iv ivr inf cu
	matrix `d' = __mar_data
	matrix `st' = __mar_st
	matrix `stp' = __mar_stp
	matrix `rw' = __mar_rw
	matrix `sw' = __mar_sw
	matrix `peto' = __mar_peto
	matrix `mh' = __mar_mh
	matrix `iv' = __mar_iv
	matrix `ivr' = __mar_ivr
	matrix `inf' = __mar_influ
	matrix `cu' = __mar_cum

	****PRINT results
	qui g str dates = ""
	if ("`ldate'"!="") {
		*if date not daily, it's the numeric year
		local fmt : format date
		if (substr("`fmt'",1,3)=="%td" & "`date'"=="YMD") local fmt = "%tdCCYY-NN-DD"
		if (substr("`fmt'",1,3)=="%td" & "`date'"=="YM") local fmt = "%tdCCYY-NN"
		if (substr("`fmt'",1,3)=="%td" & "`date'"=="Y") local fmt = "%tdCCYY"
		if (substr("`fmt'",1,3)!="%td") local fmt = "%4.0f"
		qui replace dates = string(date,"`fmt'")
	}

	*Print caption
	di as res "META-ANALYSIS: OR,RR,RD,IR,ID,B,MD,R COMBINED"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"
	
	*Get study names & zero notes
	forvalues i = 1/`len_1'{
		local n`i' = cond(`i'<`len_1',abbrev(study[`i'],12),"GLOBAL")
		local z`i' " "
		if ("`type'"=="raw") {
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") {
				if ("`zero'"!="n" & `i'!=`len_1' & `vzeros'[`i']==1) local z`i' "*"
			}
		}
	}
	
	local title = upper("`stat'")
	if ("`type'"=="raw" & "`tables'"!="") {
		//Print 2x2 tables (if available and asked)
		di
		if ("`stat'"=="or") di as txt _col(25)"{c |}" _col(37)"{c |}" _col(49)"{c |}" _col(61)"{c |}{center 11:OR}{c |}{center 11:OR_peto}"
		di as txt "{lalign 24:STUDY}{c |} UnExposed {c |}  Exposed  {c |}{center 11:TOTAL}{c |}" _c
		if ("`stat'"=="or") di as txt "{center 11:(SE_lnOR)}{c |}{center 11:(SE_lnORp)}"
		if ("`stat'"=="rr" | "`stat'"=="ir") di as txt " `title' (SE_ln`title')"
		if ("`stat'"=="rd" | "`stat'"=="id") di as txt " `title' (SE)"
		di as txt "{hline 24}{c +}{hline 11}{c +}{hline 11}{c +}{hline 11}{c +}" _c
		if ("`stat'"=="or") di as txt "{hline 11}{c +}{hline 11}"
		if ("`stat'"=="rr" | "`stat'"=="ir") di as txt "{hline 13}"
		if ("`stat'"=="rd" | "`stat'"=="id") di as txt "{hline 11}"
		forvalues i = 1/`len_1'{
			di as txt "{lalign 14:`n`i''}" _col(19) "Cases {c |} " %9.0g `d'[`i',2] " {c |} " %9.0g `d'[`i',1] " {c |} " /*
			*/	%9.0g `d'[`i',7] " {c |} " as res %9.0g `st'[`i',1] as txt "`z`i''" _c
			if ("`stat'"=="or") di as res "{c |} " %9.0g `stp'[`i',1] as txt "`z`i''"
			else di as txt " "
			di as txt %-10s dates[`i'] _c
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") di _col(16) "NonCases {c |} " _c
			if ("`stat'"=="ir" | "`stat'"=="id") di  _col(13) "Person-time {c |} " _c
			di as txt  %9.0g `d'[`i',4] " {c |} " %9.0g `d'[`i',3] " {c |} " %9.0g `d'[`i',8] as txt " {c |}(" as res %9.0g `st'[`i',2] as txt ")" _c
			if ("`stat'"=="or") di as txt "{c |}(" as res %9.0g `stp'[`i',2] as txt ")"
			else di as txt " "
			di as txt _col(25) "{c LT}{hline 11}{c +}{hline 11}{c +}{hline 11}{c RT}" _c 
			if ("`stat'"=="or") di as txt _col(73) "{c |}"
			else di as txt " "
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") di as txt _col(19) "TOTAL {c |} " _c
			if ("`stat'"=="ir" | "`stat'"=="id") di  _col(10) "Incidence Rate {c |} " _c
			di as txt %9.0g `d'[`i',6] " {c |} " %9.0g `d'[`i',5] " {c |} " %9.0g `d'[`i',9] /*
			*/	as txt " {c |} p= " as res %6.4f `st'[`i',5] _c
			if ("`stat'"=="or") di as txt " {c |} p= " as res %6.4f `stp'[`i',5]
			else di as txt " "
			local sep "+"
			if (`i'==`len_1') local sep "BT"
			di as txt "{hline 24}{c `sep'}{hline 11}{c `sep'}{hline 11}{c `sep'}{hline 11}{c `sep'}{hline 11}" _c
			if ("`stat'"=="or") di as txt "{c `sep'}{hline 11}"
			else di as txt " "
		}
		if (("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") & (`lzeros' & "`zero'"!="n")) {
			if ("`zero'"=="c") di as txt "(*) Computed with a constant continuity correction (k=0.5)"
			if ("`zero'"=="p") di as txt "(*) Computed with a proportional continuity correction"
			if ("`zero'"=="e") di as txt "(*) Computed with an empirical continuity correction (ORmh= " %9.0g `ormh_zero' ")"
			di as txt "    for studies with zero events."
		}
	}

	//Print statistics table
	/*RAW WEIGHTS:
	  -or: 		Peto MH IV_FEM IV_REM
	  -rr, ir: 	MH IV_FEM IV_REM
	  -rd, id: 	IV_FEM IV_REM
	if there are uncorrected zeros: IV_FEM & IV_REM weights not printed for or, rr
	SST WEIGHTS: IV_FEM IV_REM*/
	local zunc = ("`type'"=="raw" & ("`stat'"=="or" | "`stat'"=="rr")) & (`lzeros' & "`zero'"=="n")
	
	di
	if ("`type'"=="raw" & "`stat'"=="or") {
		if ("`method'"=="peto") local title = "OR_peto"
		local pos = cond(!`zunc',66,60)
		
		di as txt "{hline 24}{c TT}{hline 11}{c TT}{hline 21}{c TT}{hline 17}" cond(!`zunc',"{hline 14}"," ")
		di as txt _col(25) "{c |}" _col(37) "{c |}" %4.0g `level' "% Conf. Interval {c |}" _col(`pos') "Relative WEIGHTS"
		di as txt "STUDY" _col(14) upper("`ldate'") _col(25) "{c |}{center 11:`title'}{c |} {ralign 9:Lower} {ralign 9:Upper} {c |}" /*
		*/	cond(!`zunc',"  Peto     MH   IV_FEM  IV_REM","  Peto     MH")
		di as txt "{hline 24}{c +}{hline 11}{c +}{hline 21}{c +}" /*
		*/	cond(!`zunc',"{hline 7}{c TT}{hline 7}{c TT}{hline 7}{c TT}{hline 7}","{hline 7}{c TT}{hline 9}")
		forvalues i = 1/`len_1'{
			if (`i'==`len_1') di as txt "{hline 24}{c +}{hline 11}{c +}{hline 21}{c +}" /*
			*/	cond(!`zunc',"{hline 7}{c +}{hline 7}{c +}{hline 7}{c +}{hline 7}","{hline 7}{c +}{hline 9}")
			di as txt "{lalign 12:`n`i''} " %-10s dates[`i'] _col(25) "{c |} " /*
			*/	as res %9.0g cond("`method'"!="peto",`st'[`i',1],`stp'[`i',1]) "`z`i''{c |} " /*
			*/	%9.0g cond("`method'"!="peto",`st'[`i',3],`stp'[`i',3]) " " /*
			*/	%9.0g cond("`method'"!="peto",`st'[`i',4],`stp'[`i',4]) " {c |}" _c
			
			*Print relative weights
			local lnum 3 2
			if (!`zunc') local lnum `lnum' 1 4
			foreach j of numlist `lnum' {
				if (`i'==`len_1') local p = 100
				else local p = `rw'[`i',`j']
				print_pct `p'
				if (`j'==3 | (`j'==2 & !`zunc') | `j'==1) di as txt " {c |}" _c
			}
			di " "
		}
		di as txt "{hline 24}{c BT}{hline 11}{c BT}{hline 21}{c +}" /*
		*/	cond(!`zunc',"{hline 7}{c +}{hline 7}{c +}{hline 7}{c +}{hline 7}","{hline 7}{c +}{hline 9}")
		di as txt "{ralign 58:TOTAL Weights }{c |}" as res %6.0g `sw'[1,3] " {c |}" %6.0g `sw'[1,2] _c
		if (!`zunc') di as res " {c |}" %6.0g `sw'[1,1] " {c |}" %6.0g `sw'[1,4]
		else di " "
		di as txt "{hline 58}{c BT}" _c
		di as txt cond(!`zunc',"{hline 7}{c BT}{hline 7}{c BT}{hline 7}{c BT}{hline 7}","{hline 7}{c BT}{hline 9}")
	}
	if ("`type'"=="raw" & ("`stat'"=="rr" | "`stat'"=="ir")) {
		di as txt "{hline 24}{c TT}{hline 11}{c TT}{hline 21}{c TT}{hline 12}" cond(!`zunc',"{hline 11}"," ")
		di as txt _col(25) "{c |}" _col(37) "{c |}" %4.0g `level' "% Conf. Interval {c |} " _c
		if (!`zunc') di _col(61) "Relative WEIGHTS"
		else di as txt "MH Relative"
		di as txt "STUDY" _col(14) upper("`ldate'") _col(25) "{c |}{center 11:`title'}{c |} {ralign 9:Lower} {ralign 9:Upper} {c |}" /*
		*/	cond(!`zunc',"   MH   IV_FEM  IV_REM","    Weights")
		di as txt "{hline 24}{c +}{hline 11}{c +}{hline 21}{c +}" cond(!`zunc',"{hline 7}{c TT}{hline 7}{c TT}{hline 7}","{hline 12}")
		forvalues i = 1/`len_1'{
			if (`i'==`len_1') di as txt "{hline 24}{c +}{hline 11}{c +}{hline 21}{c +}" cond(!`zunc',"{hline 7}{c +}{hline 7}{c +}{hline 7}","{hline 12}")
			di as txt "{lalign 12:`n`i''} " %-10s dates[`i'] _col(25) "{c |} " as res %9.0g `st'[`i',1] "`z`i''{c |} " /*
			*/	%9.0g `st'[`i',3] " " %9.0g `st'[`i',4] " {c |}" _c
			
			*Print relative weights
			local lnum 2
			if (!`zunc') local lnum `lnum' 1 4
			foreach j of numlist `lnum' {
				if (`i'==`len_1') local p = 100
				else local p = `rw'[`i',`j']
				if (`zunc') di "   " _c
				print_pct `p'
				if ((`j'==2 & !`zunc') | `j'==1) di as txt " {c |}" _c
			}
			di " "
		}
		di as txt "{hline 24}{c BT}{hline 11}{c BT}{hline 21}{c +}" /*
		*/	cond(!`zunc',"{hline 7}{c +}{hline 7}{c +}{hline 7}","{hline 12}")
		local fmt = cond(!`zunc',"%6.0g","%8.0g")
		di as txt "{ralign 58:TOTAL Weights }{c |}" as res `fmt' `sw'[1,2] _c
		if (!`zunc') di as res " {c |}" `fmt' `sw'[1,1] " {c |}" `fmt' `sw'[1,4]
		else di " "
		di as txt "{hline 58}{c BT}" _c
		di as txt cond(!`zunc',"{hline 7}{c BT}{hline 7}{c BT}{hline 7}","{hline 12}")
	}
	if ("`type'"=="raw" & ("`stat'"=="rd" | "`stat'"=="id")) {
		di as txt "{hline 24}{c TT}{hline 11}{c TT}{hline 21}{c TT}{hline 23}"
		di as txt _col(25) "{c |}" _col(37) "{c |}" %4.0g `level' "% Conf. Interval {c |}  Relative IoV Weights"
		di as txt "STUDY" _col(14) upper("`ldate'") _col(25) "{c |}{center 11:`title'}{c |} {ralign 9:Lower} {ralign 9:Upper} {c |}" /*
		*/	" Fixed Eff  Random Eff"
		di as txt "{hline 24}{c +}{hline 11}{c +}{hline 21}{c +}{hline 11}{c +}{hline 11}"
		forvalues i = 1/`len_1'{
			if (`i'==`len_1') di as txt "{hline 24}{c +}{hline 11}{c +}{hline 21}{c +}{hline 11}{c +}{hline 11}"
			di as txt "{lalign 12:`n`i''} " %-10s dates[`i'] _col(25) "{c |} " as res %9.0g `st'[`i',1] "`z`i''{c |} " /*
			*/	%9.0g `st'[`i',3] " " %9.0g `st'[`i',4] " {c |}" _c
			
			*Print relative weights
			foreach j of numlist 1 4 {
				if (`i'==`len_1') local p = 100
				else local p = `rw'[`i',`j']
				di "    " _c
				print_pct `p'
				if (`j'==1) di as txt " {c |}" _c
			}
			di " "
		}
		di as txt "{hline 24}{c BT}{hline 11}{c BT}{hline 21}{c +}{hline 11}{c +}{hline 11}"
		di as txt "{ralign 58:TOTAL Weights }{c |}" as res %10.0g `sw'[1,1] " {c |}" %10.0g `sw'[1,4]
		di as txt "{hline 58}{c BT}{hline 11}{c BT}{hline 11}"
	}
	if (("`type'"=="raw") & ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") & (`lzeros' & "`zero'"!="n")) {
		if ("`zero'"=="c") di as txt "(*) Computed with a constant continuity correction (k=0.5)"
		if ("`zero'"=="p") di as txt "(*) Computed with a proportional continuity correction"
		if ("`zero'"=="e") di as txt "(*) Computed with an empirical continuity correction (ORmh= " %9.0g `ormh_zero' ")"
		di as txt "    for studies with zero events."
	}
	if ("`type'"=="sst") {
		if ("`stat'"=="b") local title = cond("`exp'"==""," b","Exp(b)")
		if ("`stat'"=="r") local title = " r"
		if ("`stat'"=="md") local title = cond(`md_std'==1,"d",cond(`md_std'==2,"g",cond(`md_std'==3,"Delta","MD")))
		local md_type = ""
		if ("`stat'"=="md") local md_type = cond(`md_std'==1,"Cohen's",cond(`md_std'==2,"Hedges'",cond(`md_std'==3,"Glass's","")))

		di as txt "{hline 24}{c TT}{hline 11}{c TT}{hline 21}{c TT}{hline 5}{c TT}{hline 23}"
		di as txt _col(25) "{c |}{center 11:`md_type'}{c |} Confidence Interval {c |}" _col(65) "{c |}  Relative IoV Weights"
		di as txt "STUDY" _col(14) upper("`ldate'") _col(25) "{c |}{center 11:`title'}{c |} {ralign 9:Lower} {ralign 9:Upper} {c |}" /*
		*/	"  CL {c |} Fixed Eff  Random Eff"
		di as txt "{hline 24}{c +}{hline 11}{c +}{hline 21}{c +}{hline 5}{c +}{hline 11}{c TT}{hline 11}"
		forvalues i = 1/`len'{
			di as txt "{lalign 12:`n`i''} " %-10s dates[`i'] _col(25) "{c |} " /*
			*/ as res %9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`st'[`i',1]),`st'[`i',1]) " {c |} " /*
			*/	%9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`st'[`i',3]),`st'[`i',3]) " "  /*
			*/  %9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`st'[`i',4]),`st'[`i',4]) " "  /*
			*/  "{c |}" %4.0g cl[`i'] " {c |}" _c
			
			*Print relative weights
			foreach j of numlist 1 4 {
				local p = `rw'[`i',`j']
				di "    " _c
				print_pct `p'
				if (`j'==1) di as txt " {c |}" _c
			}
			di " "
		}
		di as txt "{hline 24}{c BT}{hline 11}{c BT}{hline 21}{c BT}{hline 5}{c +}{hline 11}{c +}{hline 11}"
		di as txt "{ralign 64:TOTAL}{c |}" as res %9.0f 100 as txt "% {c |}" as res %9.0f 100 as txt "%"
		di as txt _col(65) "{c LT}{hline 11}{c +}{hline 11}"
		di as txt "{ralign 64:TOTAL Weights }{c |}" as res %10.0g `sw'[1,1] " {c |}" %10.0g `sw'[1,4]
		di as txt "{hline 64}{c BT}{hline 11}{c BT}{hline 11}"
	}
	if (`ldeleted') {
		di as txt "WARNING: `ndeleted' studies were excluded due to missing data"
	}
	

	***Print estimations table
	if !("`type'"=="raw" & "`stat'"=="rr" & `lzeros' & "`zero'"=="n") {
		*For raw data & rr statistic with zero events, there's no results available
		*For any other combination, print estimations results
		di
		di as txt "{hline 24}{c TT}{hline 12}{c TT}{hline 9}{c TT}{hline 22}"
		di as txt _col(25)"{c |}" _col(38)"{c |}" _col(48)"{c |} " %4.0g `level' "% Conf. Interval"
		di as txt _col(25)"{c |} Estimation {c |} Signif. {c |} {ralign 9:Lower}  {ralign 9:Upper}"
		di as txt "{hline 24}{c +}{hline 12}{c +}{hline 9}{c +}{hline 22}"
	}

	if ("`type'"=="raw" & "`stat'"=="or") local title = "OR"
	local z " "
	if ("`type'"=="raw" & `lzeros' & "`zero'"!="n") local z "*"
	if ("`type'"=="raw" & "`stat'"=="or") {
		*raw data + stat=or: print Peto combined results
		di as txt "PETO COMBINED:  OR_peto`z'{c |}  " as res %9.0g `peto'[1,1] " {c |}  " /*
		*/	%6.4f `peto'[1,5] " {c |} " %9.0g `peto'[1,3] "  " %9.0g `peto'[1,4] 
		if (`peto'[1,1] < 1) di as txt "{ralign 23:1/OR} {c |}  " as res %9.0g 1/`peto'[1,1] " {c |} " /*
		*/	 _col(48)"{c |} " %9.0g 1/`peto'[1,4] "  " %9.0g 1/`peto'[1,3] 
		di as txt "{ralign 24:SE(lnOR_peto)}{c |}  " as res %9.0g `peto'[1,2] " {c |} " _col(48) "{c |}"
		di as txt " Homogeneity Chi-Square {c |}  " as res %9.0g `peto'[1,6] " {c |}  " %6.4f `peto'[1,7] " {c |}"
		return scalar stat_peto = `peto'[1,1]		//RETURNED RESULTS
		return scalar se_peto = `peto'[1,2]
		return scalar stat_peto_lo = `peto'[1,3]
		return scalar stat_peto_up = `peto'[1,4]
		return scalar w_peto = `sw'[1,3]
	}
	if ("`type'"=="raw" & ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") & !(`lzeros' & "`zero'"=="n")) {
		if ("`stat'"=="or") di as txt "{hline 24}{c +}{hline 12}{c +}{hline 9}{c +}{hline 22}"
		di as txt "M-H COMBINED:{ralign 10:`title'} {c |}  " as res %9.0g `mh'[1,1] " {c |}  " /*
		*/	%6.4f `mh'[1,5] " {c |} " %9.0g `mh'[1,3] "  " %9.0g `mh'[1,4] 
		if (`mh'[1,1] < 1) di as txt "{ralign 23:1/`title'} {c |}  " as res %9.0g 1/`mh'[1,1] " {c |} " /*
		*/	_col(48) "{c |} " %9.0g 1/`mh'[1,4] "  " %9.0g 1/`mh'[1,3] 
		di as txt "{ralign 24:SE(ln`title')}{c |}  " as res %9.0g `mh'[1,2] " {c |}" _col(48) "{c |}"
		di as txt " Homogeneity Chi-Square {c |}  " as res %9.0g `mh'[1,6] " {c |}  " %6.4f `mh'[1,7] " {c |}"
		di as txt "{hline 24}{c +}{hline 12}{c +}{hline 9}{c +}{hline 22}"
		return scalar stat_mh = `mh'[1,1]			//RETURNED RESULTS
		return scalar se_mh = `mh'[1,2]
		return scalar stat_mh_lo = `mh'[1,3]
		return scalar stat_mh_up = `mh'[1,4]
		return scalar w_mh = `sw'[1,2]
	}
	if (`lzeros' & "`zero'"=="n" & ("`stat'"=="or" | "`stat'"=="rr")) {
		if ("`type'"=="raw" & "`stat'"=="or") di as txt "{hline 24}{c BT}{hline 12}{c BT}{hline 9}{c BT}{hline 22}"
		display ""
		display as txt "{bf:NOTE:} M-H combined, Fixed and Random Effects models can't be computed" _n "with studies with zero events."
	}
	else {
		if (`iv'[1,15]>0) di as txt "{lalign 24:FIXED EFFECTS MODEL:}{c |}" _col(38) "{c |}" _col(48) "{c |}"
		if (`iv'[1,15]==0) di as txt "{lalign 24:FIXED & RANDOM EFFECTS:}{c |}" _col(38) "{c |}" _col(48) "{c |}"		//If Tau2=0, there are no random effects
		
		local c = cond("`stat'"=="b" & "`exp'"!="","Exp(b)","`title'")
		di as txt "{ralign 23:IoV Weighted `c'} {c |}  " as res /*
		*/	%9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`iv'[1,1]),`iv'[1,1]) " {c |}  " %6.4f `iv'[1,5] " {c |} "/*
		*/	%9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`iv'[1,3]),`iv'[1,3]) "  " /*
		*/	%9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`iv'[1,4]),`iv'[1,4])
		
		if (`iv'[1,1] < 1  & ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir")) {
			di as txt "{ralign 23:1/`title'} {c |}  " as res %9.0g 1/`iv'[1,1] " {c |} " /*
			*/	_col(48) "{c |} " %9.0g 1/`iv'[1,4] "  " %9.0g 1/`iv'[1,3]
		}
		
		local c "SE"
		if ("`stat'"=="r") local c "SE(Zr)"
		if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") local c "SE(ln`title')"
		di as txt "{ralign 23: `c'} {c |}  " as res %9.0g `iv'[1,2] " {c |} " _col(48) "{c |}"

		di as txt "Heterogeneity Measures: {c |}" _col(38) "{c |}" _col(48) "{c |}"
		di as txt " Relative excess      H {c |}  " as res %9.0g `iv'[1,8] " {c |}" _col(48) "{c |} " _c
		if !(`len'<3 & `len'>=`iv'[1,6]) di as res %9.0g `iv'[1,10] "  " %9.0g `iv'[1,11] 
		else di " "
		if !(`len'<3 & `len'>=`iv'[1,6]) di as txt "{ralign 24:SE(lnH)}{c |}  " as res %9.0g `iv'[1,9] " {c |}" _col(48) "{c |}"
		di as txt " Pct. of variation  I^2 {c |}  " as res %9.0g `iv'[1,12] " {c |}" _col(48) "{c |} " _c
		if (`iv'[1,12]>0 & !(`len'<3 & `len'>=`iv'[1,6])) di as res %9.0g `iv'[1,13] "  " %9.0g `iv'[1,14]
		else di ""
		di as txt " due to heterogeneity   {c |}" _col(38) "{c |}" _col(48) "{c |}"
		
		di as txt " Homogeneity Chi-Square {c |}  " as res %9.0g `iv'[1,6] " {c |}  " %6.4f `iv'[1,7] " {c |}"
		di as txt "VAR between stud. Tau^2 {c |}" as res %11.0g `iv'[1,15] " {c |}" _col(48) "{c |}"
		return scalar stat_fem = `iv'[1,1]			//RETURNED RESULTS
		return scalar se_fem = `iv'[1,2]
		return scalar stat_fem_lo = `iv'[1,3]
		return scalar stat_fem_up = `iv'[1,4]
		return scalar tau2 = `iv'[1,15]
		return scalar w_fem = `sw'[1,1]
		
		***Print IOV model - Random effects results (only if Tau2>0)
		if (`iv'[1,15]>0) {
			di as txt "{hline 24}{c +}{hline 12}{c +}{hline 9}{c +}{hline 22}"
			di as txt "{lalign 24:RANDOM EFFECTS MODEL:}{c |}" _col(38) "{c |}" _col(48) "{c |}"
			
			local c = cond("`stat'"=="b" & "`exp'"!="","Exp(b)","`title'")
			di as txt "{ralign 23:IoV Weighted `c'} {c |}  " as res /*
			*/	%9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`ivr'[1,1]),`ivr'[1,1]) " {c |}  " %6.4f `ivr'[1,5] " {c |} "/*
			*/	%9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`ivr'[1,3]),`ivr'[1,3]) "  " /*
			*/	%9.0g cond("`stat'"=="b" & "`exp'"!="",exp(`ivr'[1,4]),`ivr'[1,4])
			
			if (`ivr'[1,1] < 1  & ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir")) {
				di as txt "{ralign 23:1/`title'} {c |}  " as res %9.0g 1/`ivr'[1,1] " {c |} " /*
				*/	_col(48) "{c |} " %9.0g 1/`ivr'[1,4] "  " %9.0g 1/`ivr'[1,3]
			}
			
			local c "SE"
			if ("`stat'"=="r") local c "SE(Zr)"
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") local c "SE(ln`title')"
			di as txt "{ralign 23: `c'} {c |}  " as res %9.0g `ivr'[1,2] " {c |} " _col(48) "{c |}"

			di as txt "Heterogeneity Measures: {c |}" _col(38) "{c |}" _col(48) "{c |}"
			di as txt " Relative excess      H {c |}  " as res %9.0g `ivr'[1,8] " {c |}" _col(48) "{c |} " _c
			if !(`len'<3 & `len'>=`ivr'[1,6]) di as res %9.0g `ivr'[1,10] "  " %9.0g `ivr'[1,11] 
			else di " "
			if !(`len'<3 & `len'>=`ivr'[1,6]) di as txt "{ralign 24:SE(lnH)}{c |}  " as res %9.0g `ivr'[1,9] " {c |}" _col(48) "{c |}"
			di as txt " Pct. of variation  I^2 {c |}  " as res %9.0g `ivr'[1,12] " {c |}" _col(48) "{c |} " _c
			if (`ivr'[1,12]>0 & !(`len'<3 & `len'>=`ivr'[1,6])) di as res %9.0g `ivr'[1,13] "  " %9.0g `ivr'[1,14]
			else di ""
			di as txt " due to heterogeneity   {c |}" _col(38) "{c |}" _col(48) "{c |}"
			di as txt " Homogeneity Chi-Square {c |}  " as res %9.0g `ivr'[1,6] " {c |}  " %6.4f `ivr'[1,7] " {c |}"
			return scalar stat_rem = `ivr'[1,1]			//RETURNED RESULTS
			return scalar se_rem = `ivr'[1,2]
			return scalar stat_rem_lo = `ivr'[1,3]
			return scalar stat_rem_up = `ivr'[1,4]
			return scalar w_rem = `sw'[1,4]
		}
		di as txt "{hline 24}{c BT}{hline 12}{c BT}{hline 9}{c BT}{hline 22}"
		if ("`type'"=="raw" & "`stat'"=="or" & `lzeros' & "`zero'"!="n") {
			di as txt "(*) OR of PETO COMBINED does not need continuity correction,"
			di as txt "    but this estimation is computed with corrected data"
		}
	}
	
	
	***INFLUENCE ANALYSIS
	if ("`influ'"!="" & !(`lzeros' & "`zero'"=="n" & ("`stat'"=="or" | "`stat'"=="rr") & ("`method'"=="fem" | "`method'"=="rem"))) {
		tempname m
		if ("`method'"=="peto" | "`method'"=="mh") local i 44
		if ("`method'"=="fem" | "`method'"=="rem") local i 59		
		if ("`method'"=="peto") {
			matrix `m' = `peto'
			local c1 "PETO"
			local c2 "PETO"
		}
		if ("`method'"=="mh") {
			matrix `m' = `mh'
			local c1 "MH"
			local c2 "MH"
		}
		if ("`method'"=="fem") {
			matrix `m' = `iv'
			local c1 "IoV Fixed Effect Model"
			local c2 "IoV FEM"
		}
		if ("`method'"=="rem") {
			matrix `m' = `ivr'
			local c1 "IoV Random Effect Model"
			local c2 "IoV REM"
		}
	
		if ("`type'"=="raw" & "`stat'"=="or") local title = "OR"
		di
		di as txt "INFLUENCE ANALYSIS"
		if !("`stat'"=="b" & "`exp'"!="") {
			di as txt "{hline 12}{c TT}{hline 44}" _c
			if ("`method'"=="fem" | "`method'"=="rem") di as txt "{hline 15}" _c
			di as txt "{c TT}{hline 9}"
			di as txt _col(13)  "{c |}{center `i':`c1' estimation if the study is deleted}{c |} Relative"
			di as txt "{lalign 12:STUDY}{c |}" _col(23) %4.0g `level' "% Confidence Interval" _col(50) "{center 8:`title'w}" _c
			if ("`method'"=="fem" | "`method'"=="rem") di as txt _col(59) "Heterogeneity " _c
			di as txt "{c |} Weights"
			di as txt "{lalign 12:deleted}{c |} {ralign 9:`title'w}  {ralign 9:Lower}    {ralign 9:Upper} {c |}{center 8:change}" _c
			if ("`method'"=="fem" | "`method'"=="rem") di as txt "{c |}{ralign 5:I^2}  {ralign 6:p} " _c
			di as txt "{c |}{center 9:`c2'}"
			di as txt "{hline 12}{c +}{hline 35}{c +}{hline 8}" _c
			if ("`method'"=="fem" | "`method'"=="rem") di as txt "{c +}{hline 14}" _c
			di as txt "{c +}{hline 9}"
			forvalues i = 1/`len'{
				di as txt "{lalign 12:`n`i''}{c |} " as res %9.0g `inf'[`i',1] "  " %9.0g `inf'[`i',2] as txt " to " /*
				*/	as res %9.0g `inf'[`i',3] " {c |}" _c
				
				local p = `inf'[`i',4]
				print_pct `p', a(6)
				di as txt " {c |}" _c
				
				if ("`method'"=="fem" | "`method'"=="rem") {
					local p = `inf'[`i',5]
					print_pct `p'
					di as txt " " _c
					di as res %6.4f `inf'[`i',6] " {c |}" _c
				}
				
				local j = cond("`method'"=="peto",3,cond("`method'"=="mh",2,cond("`method'"=="fem",1,4)))
				local p = `rw'[`i',`j']
				di " " _c
				print_pct `p'
				di " "
			}
			di as txt "{hline 12}{c +}{hline 35}{c +}{hline 8}" _c
			if ("`method'"=="fem" | "`method'"=="rem") di as txt "{c +}{hline 14}" _c
			di as txt "{c +}{hline 9}"
			di as txt "{ralign 11:NONE} {c |} " as res %9.0g `m'[1,1] "  " %9.0g `m'[1,3] as txt " to " /*
			*/	as res %9.0g `m'[1,4] " {c |}" %6.0f 0 as txt "% {c |}" _c
			if ("`method'"=="fem" | "`method'"=="rem") di as res %5.1f `m'[1,12] as txt "% " /*
			*/ as res %6.4f `m'[1,7] " {c |}" _c
			di as res %6.0f 100 as txt "%"			
			di as txt "{hline 12}{c BT}{hline 35}{c BT}{hline 8}" _c
			if ("`method'"=="fem" | "`method'"=="rem") di as txt "{c BT}{hline 14}" _c
			di as txt "{c BT}{hline 9}"
		}
		else {
			di as txt "{hline 12}{c TT}{hline 78}{c TT}{hline 9}"
			di as txt _col(13)  "{c |}{center 78:`c1' Model estimation if the study is deleted}{c |} Relative"
			di as txt "{lalign 12:STUDY}{c |}" _col(34) %4.0g `level' "% Confidence Interval" _col(61) "{ralign 5:bw}" /*
			*/	_col(70) "Exp(bw) Heterogeneity {c |} Weights"
			di as txt "{lalign 12:deleted}{c |} {ralign 9:bw}  {ralign 9:Exp(bw)}  {ralign 9:Lower}    {ralign 9:Upper} {c |}"/*
			*/ 	"{ralign 7:change}{ralign 8:change} {c |}{ralign 5:I^2}  {ralign 6:p} {c |}{center 9:`c2'}"
			di as txt "{hline 12}{c +}{hline 46}{c +}{hline 16}{c +}{hline 14}{c +}{hline 9}"
			forvalues i = 1/`len'{
				di as txt "{lalign 12:`n`i''}{c |} " as res %9.0g `inf'[`i',1] "  " %9.0g exp(`inf'[`i',1]) /*
				*/	"  " %9.0g exp(`inf'[`i',2]) as txt " to " as res %9.0g exp(`inf'[`i',3]) " {c |} " _c
				
				local p = `inf'[`i',4]
				print_pct `p'
				di "  " _c
				
				local p = 100*(exp(`inf'[`i',1]) - exp(`m'[1,1]))/(exp(`m'[1,1]))
				print_pct `p'
				di " {c |}" _c
				
				local p = `inf'[`i',5]
				print_pct `p'
				
				di " " as res %6.4f `inf'[`i',6] " {c |} " _c
				
				local j = cond("`method'"=="fem",1,4)
				local p = `rw'[`i',`j']
				print_pct `p'
				
				di " "
			}
			di as txt "{hline 12}{c +}{hline 46}{c +}{hline 16}{c +}{hline 14}{c +}{hline 9}"
			di as txt "{ralign 11:NONE} {c |} " as res %9.0g `m'[1,1] "  " %9.0g exp(`m'[1,1]) /*
			*/	"  " %9.0g exp(`m'[1,3]) as txt " to " as res %9.0g exp(`m'[1,4]) " {c |}" /*
			*/	%6.0f 0 as txt "% " as res %6.0f 0 as txt "% {c |}" /*
			*/	as res %5.1f `m'[1,12] as txt "% " as res %6.4f `m'[1,7] " {c |}" as res %6.0f 100 as txt "%"
			di as txt "{hline 12}{c BT}{hline 46}{c BT}{hline 16}{c BT}{hline 14}{c BT}{hline 9}"
		}
	}
	
	***CUMULATIVE ANALYSIS
	if ("`cum'"!="" & !(`lzeros' & "`zero'"=="n" & ("`stat'"=="or" | "`stat'"=="rr") & ("`method'"=="fem" | "`method'"=="rem"))) {
		quietly {
			tempvar cs s
			if ("`cum'"=="date") g __cums = dates
			if ("`cum'"!="date") g __cums = string(__cumsort,"%6.0g")
			g `s' = _n
			if (`ldesc') gsort -__cumsort
			else gsort +__cumsort
			
			forvalues i = 1/`len'{
				local nc`i' = abbrev(study[`i'],12)
			}
		}
		if ("`method'"=="fem") local c "IoV estimation: Fixed effects model"
		if ("`method'"=="rem") local c "IoV estimation: Random effects model"
		if ("`method'"=="mh") local c "Mantel-Haenszel estimation"
		if ("`method'"=="peto") local c "Peto estimation"
		
		di
		di as txt "{hline 36}{c TT}{hline 9} CUMULATIVE META-ANALYSIS {hline 9}"
		di as txt _col(37) "{c |}{center 44:`c'}"
		di as txt _col(37) "{c |}Number of{c |}" _col(59) "{c |} " %4.0g `level' "% Conf. Interval"
		di as txt "{lalign 12:STUDY} " cond("`cum'"!="date",upper("`cum'"),"DATE") _col(25) /*
		*/	"{c |}{rcenter 11:`title'}{c |} studies {c |}{rcenter 11:`title'}{c |} {ralign 9:Lower}  {ralign 9:Upper}"
		di as txt "{hline 24}{c +}{hline 11}{c +}{hline 9}{c +}{hline 11}{c +}{hline 22}"

		forvalues i = 1/`len'{
			forvalues j = 1/4 {
				if ("`stat'"=="b" & "`exp'"!="") matrix `cu'[`i',`j'] = exp(`cu'[`i',`j'])
			}
			di as txt "{lalign 12:`nc`i''} " __cums[`i'] _col(25) "{c |} " as res %9.0g `cu'[`i',4] /*
			*/	" {c |} " %7.0f `i' " {c |} " %9.0g `cu'[`i',1] " {c |} " %9.0g `cu'[`i',2] "  " %9.0g `cu'[`i',3]
		}
		di as txt "{hline 24}{c BT}{hline 11}{c BT}{hline 9}{c BT}{hline 11}{c BT}{hline 22}"
		qui sort `s'
	}
	
	*Influence / Cumulative don't shown note
	if (("`influ'"!="" | "`cum'"!="") & (`lzeros' & "`zero'"=="n" & ("`stat'"=="or" | "`stat'"=="rr") & ("`method'"=="fem" | "`method'"=="rem"))) {
		di as txt _col(7) cond("`influ'"!="" & "`cum'"!="","Influence and Cumulative Meta-",cond("`influ'"!="","Influence ","Cumulative Meta-")) _c
		di as txt "Analysis can't be computed with studies with zero events."
		di as txt _col(7) "To obtain these results, you may select only studies without zero events"
		di as txt _col(7) "or apply a continuity correction to include all studies (see zero option)."
	}

	
	*Publication Bias
	if (("`begg'"!="" | "`egger'"!="" | "`macask'"!="" | "`nus'"!="")) {
		local estitle = upper("`stat'")
		quietly {
			tempname esi sei pi
			gen `esi' = .
			gen `sei' = .
			gen `pi' = .
			forvalues i = 1/`len'{
				replace `esi' = __mar_st[`i',1] in `i'
				replace `sei' = __mar_st[`i',2] in `i'
				replace `pi' = __mar_st[`i',5] in `i'
			}
			if ("`stat'"=="r") replace `esi' = ln(sqrt((1+`esi')/(1-`esi')))
		}
		if ("`begg'"!="") {
			tempname rho_vt rho_n n_vt n_n p_vt p_n vi ti es_begg se_begg n_begg
			if ("`method'"=="peto") {
				scalar `es_begg' = `peto'[1,1]
				scalar `se_begg' = `peto'[1,2]
			}
			if ("`method'"=="mh") {
				scalar `es_begg' = `mh'[1,1]
				scalar `se_begg' = `mh'[1,2]
			}
			if ("`method'"=="fem") {
				scalar `es_begg' = `iv'[1,1]
				scalar `se_begg' = `iv'[1,2]
			}
			if ("`method'"=="rem") {
				if (`iv'[1,15]>0) {
					scalar `es_begg' = `ivr'[1,1]
					scalar `se_begg' = `ivr'[1,2]
				}
				else {
					scalar `es_begg' = `iv'[1,1]
					scalar `se_begg' = `iv'[1,2]
				}
			}
			if ("`stat'"=="r") scalar `es_begg' = ln(sqrt((1+`es_begg')/(1-`es_begg')))
			qui gen `vi' = `sei'^2
			if (`raw_md') {
				qui gen `n_begg' = n1+n0
			}
			else {
				qui gen `n_begg' = n
			}
			if ("`stat'"=="rd" | "`stat'"=="id" | "`stat'"=="md" | "`stat'"=="r") {
				qui gen `ti' = (`esi' - `es_begg')/sqrt(`vi' - `se_begg'^2)
			}
			else {
				qui gen `ti' = (ln(`esi') - ln(`es_begg'))/sqrt(`vi' - `se_begg'^2)
			}
			di
			di as res "Begg Publication Bias"
			qui ktau `ti' `vi'
			scalar `rho_vt' = r(tau_b)
			scalar `p_vt' = r(p)
			scalar `n_vt' = r(N)
			qui ktau `ti' `n_begg'
			scalar `rho_n' = r(tau_b)
			scalar `p_n' = r(p)
			scalar `n_n' = r(N)
			di as txt _col(53) "{c |}   Vi    {c |}    N"
			di as txt "{hline 52}{c +}{hline 9}{c +}{hline 9}"
			di as txt "Kendall's tau_b   Ti        Correlation Coefficient {c |} " as res %7.4f `rho_vt' " {c |} " %7.4f `rho_n'
			di as txt _col(23) "Prob > |z| (continuity corr.) {c |} " as res %7.4f `p_vt' " {c |} " %7.4f `p_n'
			di as txt _col(51) "N {c |} " as res %7.0f `n_vt' " {c |} " %7.0f `n_n'
			di as txt "{hline 52}{c BT}{hline 9}{c BT}{hline 9}"
		}
		if ("`egger'"!="") {
			di
			di as res "Egger Publication Bias"
			qui gen Precision = 1 / `sei'
			if ("`stat'"=="rd" | "`stat'"=="id" | "`stat'"=="md" | "`stat'"=="r") {
				if ("`stat'"=="r") {
					qui gen Zr_SE = `esi' / `sei'
					regress Zr_SE Precision, noheader
				}
				else {
					qui gen `estitle'_SE = `esi' / `sei'
					regress `estitle'_SE Precision, noheader
				}
			}
			else {
				qui gen ln`estitle'_SE = ln(`esi') / `sei'
				regress ln`estitle'_SE Precision, noheader
			}
		}
		if ("`macask'"!="" & "`stat'"!="rd" & "`stat'"!="id" & "`stat'"!="md" & "`stat'"!="r") {
			*Macask weight variable is needed
			if ("`type'"!="raw") {
				checkvars `macask', errmsg
				checkvars n, errmsg
			}
			else {
				if ("`macask'"!="pres" & "`macask'"!="pres_ue" & "`macask'"!="pexp" & "`macask'"=="pexp_nc") {
					checkvars `macask', errmsg
				}
			}
						
			qui gen w = n*`macask'*(1-`macask')
			qui gen inv_n = 1 / n
			qui gen ln`estitle' = ln(`esi')
			di
			di as res "Macaskill Publication Bias"
			di as txt "regress ln`estitle' n [aw=w], noheader"
			regress ln`estitle' n [aw=w], noheader
			di
			regress ln`estitle' inv_n [aw=w], noheader
		}
		if ("`nus'"!="") {
			if ("`type'"=="raw") {
				qui gen p_nus = `pi'
				if ("`method'"=="peto") {
					matname __mar_stp es_p se_p lo_p up_p p_peto chi2_p, columns(.) explicit
					svmat __mar_stp, names(col)
					qui gen p_nus = p_peto
				}
				if ("`stat'"=="or" | "`stat'"=="rr") qui gen z_nus = sqrt((n-1)*((a1*n-n1*m1)^2)/(m1*m0*n1*n0))
				if ("`stat'"=="ir") qui gen z_nus = sqrt(((a1*t-t1*m1)^2)/(m1*t1*t0))
			}
			if ("`type'"=="sst") {
				if ("`stat'"=="rd" | "`stat'"=="id" | "`stat'"=="md" | "`stat'"=="r") {
					qui gen p_nus = 2*(1-normal(abs(`esi'/`sei')))
					qui gen z_nus = `esi' / `sei'
				}
				else {
					qui gen p_nus = 2*(1-normal(abs(ln(`esi')/`sei')))
					qui gen z_nus = ln(`esi') / `sei'
				}
			}
			
			quietly {
				gen __sort_nus = _n
				sort p_nus
				gen _rp = _n
				gen _flt = p_nus < `nus' if p_nus < .
				egen _mnus = mean(_flt)
				egen _pmax = max(p_nus)
				egen _pmin = min(p_nus)
				egen _sumz = total(z_nus)
				replace _mnus = _mnus*_N
				gen _f = ceil((_sumz^2)/2.706 - _N)
				gen _pcut0 = .
				replace _pcut0 = p_nus if (_rp == _mnus)
				egen _pcut = max(_pcut0)
			}
			di
			di as res "Publication Bias"
			*Print Rosenthal method
			di
			di as txt "RESISTANCE FOR FUTURE NULL RESULTS (ROSENTHAL model)"
			di as txt "Number of additional non-significant studies that is necessary"
			di as txt "to add a significant meta-analysis for becoming non-significant ......." as res %7.0f _f[1]
			local num = _f[1]
			local criteria = _N*5+10
			if (_f[1]<=`criteria') {
				di as txt "WARNING! The number of unpublished studies `num' is <= `criteria' (k*5+10)"
			}
			else {
				di as txt "The number of unpublished studies `num' is > `criteria' (k*5+10)"
			}
			
			di
			di as txt "GLESER-OLKIN Models"
			di as txt "{hline 12}{c TT}{hline 4}{c TT}{hline 8}"
			di as txt "Study       {c |} RP {c |}    p"
			di as txt "{hline 12}{c +}{hline 4}{c +}{hline 8}"
			forvalues i = 1/`len'{
				di as txt %-11s study[`i'] " {c |} " as res %2.0f _rp[`i'] " {c |} " %5.4f p_nus[`i']
			}
			di as txt "{hline 12}{c BT}{hline 4}{c BT}{hline 8}"
			di as txt "Number of reported studies..............: " as res %2.0f _N
			di as txt "Largest reported p-value................: " as res %5.4f _pmax[1]
			di as txt "Smallest reported p-value...............: " as res %5.4f _pmin[1]
			di as txt "P cut for select smallest p-values......: " as res %3.2f `nus'
			di as txt "Number of studies with smallest p-values: " as res %2.0f _mnus[1]
			di as txt "Maximum of the smallest p-values........: " as res %5.4f _pcut[1]
			
			tempname knus pmax mnus pcut ngo ngog q qg f idf nl nlg
			scalar `knus' = _N
			scalar `pmax' = _pmax[1]
			scalar `mnus' = _mnus[1]
			scalar `pcut' = _pcut[1]
			if (`mnus' > 0) {
				*Gleser-Olkin model
				scalar `ngo' = trunc((`knus'-1)/`pmax' - `knus')
				scalar `ngog' = trunc((`mnus'-1)/`pcut' - `knus')
				*Gleser-Olkin model: lower bound of the CI
				scalar `q' = -999
				scalar `qg' = -999
				forvalues i = 0/999 {
					*Simple model
					scalar `f' = (`i'+1)*`pmax'/(`knus'*(1-`pmax'))
					scalar `idf' = invF(2*`knus',2*(`i'+1),(100-`level')/100)
					if (`q'<0 & `idf'<`f') scalar `q' = `i'
					*Generalized simple model
					scalar `f' = (`i'+1)*`pcut'/(`mnus'*(1-`pcut'))
					scalar `idf' = invF(2*`mnus',2*(`i'+1),(100-`level')/100)
					if (`qg'<0 & `idf'<`f') scalar `qg' = `i'
					if (`qg'>0 & `q'>0) continue, break
				}
				scalar `nl' = `q'
				scalar `nlg' = `qg' - `knus' + `mnus'
				di as txt "{hline 21}{c TT}{hline 29}"
				di as txt _col(22) "{c |}NUMBER OF UNPUBLISHED STUDIES"
				di as txt _col(22) "{c |}              {c |} Generalized"
				di as txt _col(22) "{c |} Simple model {c |} Simple model"
				di as txt "{hline 21}{c +}{hline 14}{c +}{hline 14}"
				di as txt " Unbiased Estimation {c |}" as res %9.0f `ngo' _col(37) "{c |}" %9.0f `ngog'
				if (`ngog'>=0) di as txt "  `level'% CI Lower bound {c |}" as res %9.0f `nl' _col(37) "{c |}" %9.0f `nlg'
				else di as txt "  `level'% CI Lower bound {c |}" as res %9.0f `nl' _col(37) "{c |}  unestimable"
				di as txt "{hline 21}{c BT}{hline 14}{c BT}{hline 14}"
			}
			else {
				di as txt "NUMBER OF UNPUBLISHED STUDIES = Not estimable"
			}
		}
	}
	
	tempfile dirsave
	if ("`keep'"!="") qui save `dirsave', replace
	
	***GRAPHICS
	if ("`interval'"!="" | "`forest'"!="" | "`histogram'"!="" | "`radial'"!="" | "`cumulative'"!="" | /* 
		*/	"`abbe'"!="" | "`funnel'"!="" | "`funnelh'"!="" | "`galbraith'"!="") {
		local int_var ""
		if ("`interval'"!="" & "`interval'"!="se") local int_var "`interval'"
		local for_var ""
		if ("`forest'"!="" & "`forest'"!="se") local for_var "`forest'"
		local cum_var ""
		if ("`cumulative'"!="") local cum_var "__cums __cumsort"
		local abbe_vars ""
		if ("`abbe'"!="") local abbe_vars "a0 n0 a1 n1"
		keep study `cum_var' `abbe_vars' `int_var' `for_var'
		quietly {
			*Build the dataset for the graphs
			gen `stat' = .
			gen se = .
			gen lo = .
			gen up = .
			gen rw = .
			gen _comb = 0
			forvalues i = 1/`len'{
				replace `stat' = __mar_st[`i',1] in `i'
				replace se = __mar_st[`i',2] in `i'
				replace lo = __mar_st[`i',3] in `i'
				replace up = __mar_st[`i',4] in `i'
				if ("`method'"=="fem") replace rw = __mar_rw[`i',1] in `i'
				if ("`method'"=="mh") replace rw = __mar_rw[`i',2] in `i'
				if ("`method'"=="peto") replace rw = __mar_rw[`i',3] in `i'
				if ("`method'"=="rem") replace rw = __mar_rw[`i',4] in `i'
			}						
			if ("`method'"=="fem") gen sw = __mar_sw[1,1]
			if ("`method'"=="mh") gen sw = __mar_sw[1,2]
			if ("`method'"=="peto") gen sw = __mar_sw[1,3]
			if ("`method'"=="rem") gen sw = __mar_sw[1,4]
			gen wght = round(rw*sw/100)
			
			*Add the COMBINE results (estimated estatistic)
			if ("`method'"=="fem") matrix __mar_temp = __mar_iv
			if ("`method'"=="mh") matrix __mar_temp = __mar_mh
			if ("`method'"=="peto") matrix __mar_temp = __mar_peto
			if ("`method'"=="rem") matrix __mar_temp = __mar_ivr
			set obs `len_1'
			replace study = "Overall" in `len_1'
			replace `stat' = __mar_temp[1,1] in `len_1'
			replace se = __mar_temp[1,2] in `len_1'
			replace lo = __mar_temp[1,3] in `len_1'
			replace up = __mar_temp[1,4] in `len_1'
			replace _comb = 1 in `len_1'
			matrix drop __mar_temp
			
			if ("`method'"=="fem") local ref_es = __mar_iv[1,1]
			if ("`method'"=="mh") local ref_es = __mar_mh[1,1]
			if ("`method'"=="peto") local ref_es = __mar_peto[1,1]
			if ("`method'"=="rem") local ref_es = __mar_ivr[1,1]

			*Correlation graphics: use Fisher's Z wiht SE
			if ("`stat'"=="r") {
				replace `stat' = ln(sqrt((1+`stat')/(1-`stat')))
				replace lo = ln(sqrt((1+lo)/(1-lo)))
				replace up = ln(sqrt((1+up)/(1-up)))
				local ref_es = ln(sqrt((1+`ref_es')/(1-`ref_es')))
			}
		}

		if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir" | ("`stat'"=="b" & "`exp'"!="")) {
			if ("`stat'"=="b" & "`exp'"!="") local xtitle = "Exp(b)"
			else local xtitle = upper("`stat'") 
			local xtitle =  "`xtitle' (logarithmic scale)"
			local ref_line = 1
			local xscale = "xscale(log)"
		}
		else {
			if ("`stat'"=="md") {
				if (`md_std'==0) local xtitle "Mean difference"
				if (`md_std'==1) local xtitle "Cohen's d"
				if (`md_std'==2) local xtitle "Hedges' g"
				if (`md_std'==3) local xtitle "Glass's Delta"
			}
			else if ("`stat'"=="r") {
				local xtitle "Zr"
			}
			else {
				local xtitle = upper("`stat'")
			}
			local ref_line = 0
			local xscale = ""
		}
		
		*Create graphics
		if ("`interval'"!="") {
			quietly {
				gen __sort_g = _n
				gsort -_comb +`interval'
				gen id_int = _n
				forvalues i=1/`len_1' {
					local val = study[`i']
					label define d_int `i' "`val'", add
				}
				label values id_int d_int
				if ("`stat'"=="b" & "`exp'"!="") {
					replace `stat' = exp(`stat')
					replace lo = exp(lo)
					replace up = exp(up)
					local ref_es = exp(`ref_es')
				}
				/*gen xpos_st_i = minlo - 0.1
				(scatter id xpos_st_i, msymbol(none) mlabel(study) mlabcolor(black) mlabpos(3) mlabsize(small)),  */
				noisily twoway (rcap lo up id_int, horizontal lwidth(medthick) lcolor(black)) ///
				    (scatter id_int `stat', mfcolor(gs10) msize(medlarge) mcolor(black)),     ///
					xline(`ref_line', lcolor(black)) xline(`ref_es', lcolor(black) lpattern(dash))     ///
					xtitle(`xtitle', size(medlarge)) ylabel(#`len_1', nogrid valuelabels angle(horizontal) labsize(medsmall)) ///
					legend(off) ytitle("") `xscale' name(interval,replace) title(Interval Plot)
				if ("`stat'"=="b" & "`exp'"!="") {
					replace `stat' = ln(`stat')
					replace lo = ln(lo)
					replace up = ln(up)
					local ref_es = ln(`ref_es')
				}
				sort __sort_g
				drop __sort_g
			}
		}
		if ("`forest'"!="") {
			quietly {
				gen __sort_g = _n
				gsort -_comb +`forest'
				gen id_for = _n
				gen ytop = id_for + 0.4 if _comb==1
				gen ydown = id_for - 0.4 if _comb==1
				forvalues i=1/`len_1' {
					local val = study[`i']
					label define d_for `i' "`val'", add
				}
				label values id_for d_for
				if ("`stat'"=="b" & "`exp'"!="") {
					replace `stat' = exp(`stat')
					replace lo = exp(lo)
					replace up = exp(up)
					local ref_es = exp(`ref_es')
				}
				/*gen xpos_st = minlo - 0.1
				(scatter id xpos_st, msymbol(none) mlabel(study) mlabcolor(black) mlabpos(3) mlabsize(small))*/
				twoway (scatter id_for `stat' if _comb==0 [aweight=rw], msymbol(square) mfcolor("180 180 180") mlcolor(black)) ///
				   (pcspike id_for lo id_for up if _comb==0, lcolor(black) lwidth(medthick))  ///
				   (pcspike id_for lo ytop `stat' if _comb==1, lcolor(black) lwidth(medthick)) ///
				   (pcspike ytop `stat' id_for up if _comb==1, lcolor(black) lwidth(medthick)) ///
				   (pcspike id_for up ydown `stat' if _comb==1, lcolor(black) lwidth(medthick)) ///
				   (pcspike ydown `stat' id_for lo if _comb==1, lcolor(black) lwidth(medthick)) ///
				   (scatter id_for `stat' if _comb==0, msymbol(diamond) msize(vsmall) mcolor(black)),  ///
				   `xscale' legend(off) ylabel(#`len_1', nogrid valuelabels angle(horizontal) labsize(medsmall))  ///
				   xtitle(`xtitle') xline(`ref_line', lcolor(black)) xline(`ref_es', lcolor(black) lpattern(dash)) ///
				   ytitle("") title(Forest Plot) name(forest,replace)
				if ("`stat'"=="b" & "`exp'"!="") {
					replace `stat' = ln(`stat')
					replace lo = ln(lo)
					replace up = ln(up)
					local ref_es = ln(`ref_es')
				}
				sort __sort_g
				drop __sort_g
			}
		}
		if ("`radial'"!="") {
			if ("`stat'"=="rd" | "`stat'"=="id" | "`stat'"=="md" | "`stat'"=="r") {
				local xtitler = "`xtitle' / SE"
				qui gen x_rad = `stat'/se
			}
			else {
				local xtitler = "ln" + upper("`stat'") + " / SE"
				qui gen x_rad = ln(`stat')/se
			}
			qui gen y_rad = 1/se
			twoway (scatter y_rad x_rad), xtitle(`xtitler', size(medlarge))  ///
				ytitle(1 / SE, size(medlarge)) title(Radial Plot) name(radial,replace)
		}
		if ("`histogram'"!="") {
			qui drop if _comb==1
			/*local xtitleh = upper("`stat'")
			if ("`stat'"=="md") {
				if (`md_std'==1) local xtitleh "Cohen's d"
				if (`md_std'==2) local xtitleh "Hedges' g"
				if (`md_std'==3) local xtitleh "Glass's Delta"
			}*/
			qui histogram `stat' [w=wght], frequency xtitle(`xtitle', size(medlarge)) ///
				ytitle("Study weight sum", size(medlarge)) ylabel(,angle(horizontal)) ///
				title("Histogram (weighted)") name(histogram,replace)
		}
		if ("`cumulative'"!="") {
			quietly {
				gen __sort_g = _n
				drop if _comb==1
				if (`ldesc') gsort -__cumsort
				else gsort +__cumsort
				gen id_cum = _n
				gen es_cum = .
				gen lo_cum = .
				gen up_cum = .
				forvalues i = 1/`len'{
					replace es_cum = __mar_cum[`i',1] in `i'
					replace lo_cum = __mar_cum[`i',2] in `i'
					replace up_cum = __mar_cum[`i',3] in `i'
				}
				gen cum_title = study + " (" + __cums + ")"
				forvalues i=1/`len' {
					local val = cum_title[`i']
					label define d_cum `i' "`val'", add
				}
				label values id_cum d_cum
			}
			if ("`stat'"=="b" & "`exp'"!="") {
				qui replace es_cum = exp(es_cum)
				qui replace lo_cum = exp(lo_cum)
				qui replace up_cum = exp(up_cum)
			}
			/*(scatter id xpos_title, msymbol(none) mlabel(cum_title) mlabcolor(black) mlabpos(3) mlabsize(small))*/
			twoway (scatter id_cum es_cum, msymbol(circle) msize(small) mcolor(black))  ///
				(pcspike id_cum lo_cum id_cum up_cum, lcolor(navy)), ///
				`xscale' legend(off) yscale(reverse) ylabel(#`len', nogrid valuelabels angle(horizontal) labsize(small)) ytitle("") ///
				 xtitle(`xtitle') xline(`ref_line', lcolor(black)) name(cumulative,replace) legend(off) title(Cumulative Plot)
			sort __sort_g
			drop __sort_g
		}
		if ("`abbe'"!="") {
			quietly {
				drop if _comb==1
				gen Px = (a0/n0)*100
				gen Py = (a1/n1)*100
				set obs `len_1'
				replace Px = 0 in `len_1'
			}
			qui twoway (line Px Px) (scatter Py Px [aweight=rw], msymbol(square) mlcolor(black) mfcolor(none)) ,  ///
				legend(off) xtitle(Px) ytitle(Py) name(abbe,replace) title(Abbe Plot)
		}
		if ("`galbraith'"!="") {
			quietly {
				drop if _comb==1
				if ("`stat'"=="rd" | "`stat'"=="id" | "`stat'"=="md" | "`stat'"=="r") {
					gen y_galb = `stat'/se
					local ln_se = `ref_es'
					local ytitle = "`xtitle' / SE"
				}
				else {
					gen y_galb = ln(`stat')/se
					local ln_se = ln(`ref_es')
					local ytitle = "ln" + upper("`stat'") + " / SE"
				}
				gen x_galb = 1/se
				egen x_galb_max = max(x_galb)
			}
			local max_galb = x_galb_max[1]
			twoway (scatter y_galb x_galb, msize(medium) mlabel(study) mlabposition(9))		///
				(function y=`ln_se'*x, range(0 `max_galb') lcolor(black) lpattern(solid))   ///
				(function y=`ln_se'*x+2, range(0 `max_galb') lcolor(black) lpattern(dash))  ///
				(function y=`ln_se'*x-2, range(0 `max_galb') lcolor(black) lpattern(dash)), ///
				legend(off) xtitle(1 / SE) ytitle(`ytitle') name(galbraith,replace) title(Galbraith (radial) Plot)
		}
		if (("`funnel'"!="" | "`funnelh'"!="") & ("`stat'"!="rd" & "`stat'"!="id" & "`stat'"!="md")) {
			quietly {
				drop if _comb==1				
				if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") {
					gen fun_es = ln(`stat')
					local fun_ref = ln(`ref_es')
					local xtitle = "ln" + upper("`stat'")
					local ytitle = "SE(ln" + upper("`stat')")
				}
				else if ("`stat'"=="rd" | "`stat'"=="id" | "`stat'"=="md" | "`stat'"=="b" | "`stat'"=="r") {
					gen fun_es = `stat'
					local fun_ref = `ref_es'
					local xtitle = upper("`stat'")
					local ytitle = upper("SE(`stat')")
					if ("`stat'"=="r") {
						local xtitle "Zr"
						local ytitle "SE(Zr)"
					}
				}
				gen fun_se = se

				forval i = 1/6 { 
					local obs`i' = _N + `i'
				}
				set obs `obs6'
				egen maxse = max(se)
								
				if ("`funnel'"!="") {
					*Estimated statistic line
					gen y_es = 0 if _n==`obs1'
					replace y_es = maxse if _n==`obs2'
					gen x_fun = `fun_ref' if _n==`obs1' | _n==`obs2'
					*Pseudo 95% confidence limits - lo
					gen y_lo = 0 if _n==`obs3'
					replace y_lo = maxse if _n==`obs4'
					replace x_fun = `fun_ref' if _n==`obs3'
					replace x_fun = `fun_ref' - invnorm(0.975) * maxse if _n==`obs4'
					*Pseudo 95% confidence limits - up
					gen y_up = 0 if _n==`obs5'
					replace y_up = maxse if _n==`obs6'
					replace x_fun = `fun_ref' if _n==`obs5'
					replace x_fun = `fun_ref' + invnorm(0.975) * maxse if _n==`obs6'
				}
				if ("`funnelh'"!="") {
					*Estimated statistic line
					gen y_esh = `fun_ref' if _n==`obs1' | _n==`obs2'
					gen x_funh = 0 if _n==`obs1'
					replace x_funh = maxse if _n==`obs2'
					*Pseudo 95% confidence limits - lo
					gen y_loh = `fun_ref' if _n==`obs3'
					replace y_loh = `fun_ref' - invnorm(0.975) * maxse if _n==`obs4'
					replace x_funh = 0 if _n==`obs3'
					replace x_funh = maxse if _n==`obs4'
					*Pseudo 95% confidence limits - up
					gen y_uph = `fun_ref' if _n==`obs5'
					replace y_uph = `fun_ref' + invnorm(0.975) * maxse if _n==`obs6'
					replace x_funh = 0 if _n==`obs5'
					replace x_funh = maxse if _n==`obs6'
				}
			}
			
			if ("`funnel'"!="") {
				twoway (scatter fun_se fun_es, yscale(reverse)) ///
					(line y_lo y_up y_es x_fun, msymbol(none none none) ///
					clcolor(black black black) clpat(dash dash solid) ///
					clwidth(medium medium medium)), ///
					legend(off) xtitle(`xtitle') ytitle(`ytitle') ///
					title(Funnel plot with pseudo 95% confidence limits) name(funnel,replace)
			}
			if ("`funnelh'"!="") {
				twoway (scatter fun_es fun_se) ///
					(line y_loh y_uph y_esh x_funh, msymbol(none none none) ///
					clcolor(black black black) clpat(dash dash solid) ///
					clwidth(medium medium medium)), ///
					legend(off) ytitle(`xtitle') xtitle(`ytitle') ///
					title(Funnel plot with pseudo 95% confidence limits) name(funnelh,replace)
			}
			
		}
	}

	*Save variables to keep
	if ("`keep'"!="") {
		qui use `dirsave', clear
		local keep_vars study
		if ("`ldate'"!="") local keep_vars = "`keep_vars' date"
		if (`raw_md') {
			local keep_vars = "`keep_vars' m1 sd1 n1 m0 sd0 n0"
			if (`md_exists') local keep_vars = "`keep_vars' _md0_orig _se0_orig _lo0_orig _up0_orig"
		}
		if ("`type'"=="raw") {
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") local keep_vars = "`keep_vars' a1 a0 b1 b0 m1 m0 n1 n0 n pres pres_ue pres_ex pexp pexp_nc pexp_ca"
			if ("`stat'"=="ir" | "`stat'"=="id") local keep_vars = "`keep_vars' a1 a0 t1 t0 i1 i0 m1 t pres pres_ue pres_ex pexp pexp_ca"
			erasevars `stat' se lo up
			quietly {
				*Add matrix variables
				gen `stat' = .
				gen se = .
				gen lo = .
				gen up = .
				forvalues i = 1/`len'{
					replace `stat' = __mar_st[`i',1] in `i'
					replace se = __mar_st[`i',2] in `i'
					replace lo = __mar_st[`i',3] in `i'
					replace up = __mar_st[`i',4] in `i'
				}
				if ("`stat'"=="or") {
					erasevars or_peto lnor_peto se_or_peto lo_or_peto up_or_peto wp
					gen or_peto = .
					gen lnor_peto = .
					gen se_or_peto = .
					gen lo_or_peto = .
					gen up_or_peto = .
					gen wp = .
					forvalues i = 1/`len'{
						replace or_peto = __mar_stp[`i',1] in `i'
						replace se_or_peto = __mar_stp[`i',2] in `i'
						replace lo_or_peto = __mar_stp[`i',3] in `i'
						replace up_or_peto = __mar_stp[`i',4] in `i'
						replace wp = __mar_rw[`i',3] * __mar_sw[1,3]/100 in `i'
					}
					replace lnor_peto = ln(or_peto)
					local keep_vars = "`keep_vars' or_peto lnor_peto se_or_peto lo_or_peto up_or_peto wp"
				}
				if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") {
					erasevars wmh
					gen wmh = .
					forvalues i = 1/`len'{
						replace wmh = __mar_rw[`i',2] * __mar_sw[1,2]/100 in `i'
					}
					local keep_vars = "`keep_vars' wmh"
				}
			}
		}
		if ("`type'"=="sst") local keep_vars = "`keep_vars' cl"
		if ("`stat'"=="r") {
			qui {
				erasevars z
				rename r z
				rename `rho' r
				order r, before(z)
				replace lo = (exp(2*lo)-1)/(exp(2*lo)+1)
				replace up = (exp(2*up)-1)/(exp(2*up)+1)
			}
		}
		quietly {
			erasevars wivf wivr
			gen wivf = .
			gen wivr = .
			forvalues i = 1/`len'{
				replace wivf = __mar_rw[`i',1] * __mar_sw[1,1]/100 in `i'
				replace wivr = __mar_rw[`i',4] * __mar_sw[1,4]/100 in `i'
			}
		}
		local keep_vars = "`keep_vars' `stat' se lo up wivf wivr"
		if ("`stat'"=="r") local keep_vars = "`keep_vars' z"
		local keep_vars = "`keep_vars' `keep_mix'"
		keep `keep_vars'
		if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") {
			*Add ln(stat) for or, rr, ir
			quietly generate ln`stat' = ln(`stat')
			order ln`stat', after(`stat')
		}
		qui save `dirsave', replace
	}

	restore			//Restore original dataset

	*Add variables to the original dataset
	if ("`keep'"!="") {
		tempname sort_orig
		qui gen `sort_orig' = _n
		qui merge 1:1 study using `dirsave', update replace nogenerate
		sort `sort_orig'
		capture confirm variable _mar_
		if (_rc!=0) qui gen _mar_ = 1		//Variable to identify the dataset as 'keeped'
		
		if (`raw_md') {
			if (`md_std'>0) {
				if (`md_std'==1) local vars_md "d se_d lo_d up_d"
				if (`md_std'==2) local vars_md "g se_g lo_g up_g"
				if (`md_std'==3) local vars_md "Delta se_Delta lo_Delta up_Delta"
				foreach v in `vars_md' {
					capture confirm variable `v', exact
					if (_rc==0) drop `v'
				}
				rename (`stat' se lo up) (`vars_md')
				if (`md_exists') rename (_md0_orig _se0_orig _lo0_orig _up0_orig) (md se lo up)
			}
			else {
				if (`md_exists') drop _md0_orig _se0_orig _lo0_orig _up0_orig
			}
		}
		
		*Label variables
		quietly{
			label variable study "Study"
			if ("`ldate'"!="") label variable date "Date of Study"
			if ("`type'"=="raw") {
				label variable a1 "Cases Exposed"
				label variable a0 "Cases Unexposed"
				label variable pres "Proportion of response in Total sample"
				label variable pres_ue "Proportion of response in Unexposed"
				label variable pres_ex "Proportion of response in Exposed"
				label variable pexp "Proportion of exposure in Total sample"
				label variable pexp_ca "Proportion of exposure in Cases"
				if ("`stat'"=="ir" | "`stat'"=="id") {
					label variable t1 "Person-time Exposed"
					label variable t0 "Person-time Unexposed"
					label variable i1 "Incidence Exposed"
					label variable i0 "Incidence Unexposed"
					label variable m1 "Total Cases"
					label variable t "Total Person-time"
				}
				else {
					label variable pexp_nc "Proportion of exposure in Non Cases"
					label variable b1 "Non Cases Exposed"
					label variable b0 "Non Cases Unexposed"
					label variable n1 "Total Exposed"
					label variable n0 "Total Unexposed"
					label variable m1 "Total Cases"
					label variable m0 "Total Non Cases"
					label variable n "Total"
				}
				if ("`stat'"=="or" | "`stat'"=="rr") {
					*v1.3.9: for raw data & or | rr stat: always keep or, or_peto, rr
					if ("`stat'"=="or") {
						erasevars se_or lo_or up_or rr lnrr se_rr lo_rr up_rr
						rename (se lo up) (se_or lo_or up_or)
						qui g rr = (a1 / n1) / (a0 / n0)
						qui g lnrr = ln(rr)
						qui g se_rr = sqrt(1/a1 - 1/n1 + 1/a0 - 1/n0)
						qui g lo_rr = rr * exp(-invnormal((`level'+100)/200) * se_rr)
						qui g up_rr = rr * exp(invnormal((`level'+100)/200) * se_rr)
						
						order or lnor se_or lo_or up_or or_peto lnor_peto se_or_peto lo_or_peto up_or_peto rr lnrr se_rr lo_rr up_rr, after(pres_ex)
					}
					if ("`stat'"=="rr") {
						erasevars se_rr lo_rr up_rr or lnor se_or lo_or up_or
						rename (se lo up) (se_rr lo_rr up_rr)
						qui g or = (a1 / b1) / (a0 / b0)
						qui g lnor = ln(or)
						qui g se_or = sqrt(1/a1 + 1/b1 + 1/a0 + 1/b0)
						qui g lo_or = or * exp(-invnormal((`level'+100)/200) * se_or)
						qui g up_or = or * exp(invnormal((`level'+100)/200) * se_or)
						
						erasevars or_peto lnor_peto se_or_peto lo_or_peto up_or_peto
						qui g se_or_peto = (m1 * (n1/n)) * ((n0 * m0) / (n * (n-1)))
						qui g or_peto = exp((a1 - (m1 * (n1/n))) / se_or_peto)
						qui g lnor_peto = ln(or_peto)
						qui replace se_or_peto = sqrt(1/se_or_peto)
						qui g lo_or_peto = or_peto * exp(-invnormal((`level'+100)/200) * se_or_peto)
						qui g up_or_peto = or_peto * exp(invnormal((`level'+100)/200) * se_or_peto)
						
						order rr lnrr se_rr lo_rr up_rr or lnor se_or lo_or up_or or_peto lnor_peto se_or_peto lo_or_peto up_or_peto, after(pres_ex)
					}
				
					label variable or "Odds Ratio"
					label variable lnor "ln(Odds Ratio)"
					label variable se_or "Standard Error of ln(OR)"
					label variable lo_or "OR Lower Bound (`level'% CI)"
					label variable up_or "OR Upper Bound (`level'% CI)"
					label variable or_peto "Odds Ratio (Peto)"
					label variable lnor_peto "ln(Odds Ratio) (Peto)"
					label variable se_or_peto "Standard Error of ln(OR) (Peto)"
					label variable lo_or_peto "OR (Peto) Lower Bound (`level'% CI)"
					label variable up_or_peto "OR (Peto) Upper Bound (`level'% CI)"
					label variable rr "Risk Ratio"
					label variable lnrr "ln(Risk Ratio)"
					label variable se_rr "Standard Error of ln(RR)"
					label variable lo_rr "RR Lower Bound (`level'% CI)"
					label variable up_rr "RR Upper Bound (`level'% CI)"
				}
			}
			if ("`type'"!="raw" & "`stat'"=="or") {
				label variable or "Odds Ratio"
				label variable lnor "ln(Odds Ratio)"
				label variable se "Standard Error of ln(OR)"
				label variable lo "OR Lower Bound (`level'% CI)"
				label variable up "OR Upper Bound (`level'% CI)"
			}
			if ("`type'"!="raw" & "`stat'"=="rr") {
				label variable rr "Risk Ratio"
				label variable lnrr "ln(Risk Ratio)"
				label variable se "Standard Error of ln(RR)"
				label variable lo "RR Lower Bound (`level'% CI)"
				label variable up "RR Upper Bound (`level'% CI)"
			}
			if ("`stat'"=="ir") {
				label variable ir "Rate Ratio"
				label variable lnir "ln(Rate Ratio)"
				label variable se "Standard Error of ln(IR)"
				label variable lo "IR Lower Bound (`level'% CI)"
				label variable up "IR Upper Bound (`level'% CI)"
			}
			if ("`stat'"=="rd") {
				label variable rd "Risk Difference"
				label variable se "Standard Error of RD"
				label variable lo "RD Lower Bound (`level'% CI)"
				label variable up "RD Upper Bound (`level'% CI)"
			}
			if ("`stat'"=="id") {
				label variable id "Rate Difference"
				label variable se "Standard Error of ID"
				label variable lo "ID Lower Bound (`level'% CI)"
				label variable up "ID Upper Bound (`level'% CI)"
			}
			if ("`stat'"=="b") {
				label variable b "Slope"
				label variable se "Standard Error of B"
				label variable lo "B Lower Bound (`level'% CI)"
				label variable up "B Upper Bound (`level'% CI)"
			}
			if ("`stat'"=="md") {
				if (`raw_md') {
					if (`md_std'==0) {
						label variable md "Mean Difference"
						label variable se "Standard Error of MD"
						label variable lo "MD Lower Bound (`level'% CI)"
						label variable up "MD Upper Bound (`level'% CI)"
					}
					if (`md_std'==1) {
						label variable d "Cohen's d standardised mean difference"
						label variable se_d "Standard Error of d"
						label variable lo_d "d Lower Bound (`level'% CI)"
						label variable up_d "d Upper Bound (`level'% CI)"
					}
					if (`md_std'==2) {
						label variable g "Hedges' adjusted g standardised mean difference"
						label variable se_g "Standard Error of g"
						label variable lo_g "g Lower Bound (`level'% CI)"
						label variable up_g "g Upper Bound (`level'% CI)"
					}
					if (`md_std'==3) {
						label variable Delta "Glass's Delta standardised mean difference"
						label variable se_Delta "Standard Error of Delta"
						label variable lo_Delta "Delta Lower Bound (`level'% CI)"
						label variable up_Delta "Delta Upper Bound (`level'% CI)"
					}
				}
				else {
					if (`md_std'==0) label variable md "Mean Difference"
					if (`md_std'==1) label variable md "Mean Difference (Cohen's d)"
					if (`md_std'==2) label variable md "Mean Difference (Hedges' adjusted g)"
					if (`md_std'==3) label variable md "Mean Difference (Glass's Delta)"
					label variable se "Standard Error of MD"
					label variable lo "MD Lower Bound (`level'% CI)"
					label variable up "MD Upper Bound (`level'% CI)"
				}
			}
			if ("`stat'"=="r") {
				label variable r "Correlation coefficient"
				label variable n "Sample Size"
				label variable z "Fisher's z Transformed Correlation coefficient (Zr)"
				label variable se "Standard Error of Zr"
				label variable lo "Correlation Coefficient Lower Bound (`level'% CI)"
				label variable up "Correlation Coefficient Upper Bound (`level'% CI)"
			}
			if ("`type'"=="sst") label variable cl "Confidence Level"
			if ("`type'"=="raw" & "`stat'"=="or") label variable wp "Peto Weight"
			if ("`type'"=="raw" & ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir")) label variable wmh "Mantel-Haenszel Weight"
			label variable wivf "Inverse of Variance Fixed Effects Model Weight"
			label variable wivr "Inverse of Variance Random Effects Model Weight"
		}
	}
	
	*Drop temporary matrix
	matrix drop __mar_data __mar_st __mar_stp __mar_rw __mar_sw __mar_peto __mar_mh __mar_iv __mar_ivr __mar_influ __mar_cum

end


program data_raw, rclass
	syntax anything(name=stat), zero(string) vzeros(name) md_std(integer) level(real)
	
	*Prepare raw data for analysis
	
	local lzeros 0			//default values for zero correction flags
	local ormh_zero 0
	local md_exists 0
	
	quietly {
		if ("`stat'"!="md") checkvars a1 a0, errmsg
		if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="rd") {
			checkvars b1 b0, local(found_b) 
			checkvars n1 n0, local(found_n) 
			if (!`found_b' & !`found_n') print_error "missing b1,b0 or n1,n0 variable(s)"
			if (`found_b') {
				erasevars n1 n0
				g n1 = a1 + b1
				g n0 = a0 + b0
			}
			if (`found_n') {
				erasevars b1 b0
				g b1 = n1 - a1
				g b0 = n0 - a0
			}
			erasevars m1 m0 n
			g m1 = a0 + a1
			g m0 = b0 + b1
			g n = n1 + n0
			
			zero_correction `zero', vzeros(`vzeros')
			local lzeros = r(zeros)
			local ormh_zero = r(ormh)
			
			erasevars pexp pexp_nc pexp_ca pres pres_ue pres_ex
			g pexp = n1/n
			g pexp_nc = b1/m0
			g pexp_ca = a1/m1					//v1.3.9: add pexp_ca, pres_ex variables
			g pres = m1/n
			g pres_ue = a0/n0
			g pres_ex = a1/n1					//v1.3.9: add pexp_ca, pres_ex variables
		}
		if ("`stat'"=="ir" | "`stat'"=="id") {
			checkvars t1 t0, local(found_t)
			checkvars i1 i0, local(found_i) 
			if (!`found_t' & !`found_i') print_error "missing t1,t0 or i1,i0 variable(s)"
			if (`found_t') {
				erasevars i1 i0
				g i1 = a1 / t1
				g i0 = a0 / t0
			}
			if (`found_i') {
				erasevars t1 t0
				g t1 = a1 / i1
				g t0 = a0 / i0
			}
			erasevars m1 t i pexp pexp_ca pres pres_ue pres_ex
			g m1 = a0 + a1
			g t = t1 + t0
			g i = m1 / t

			g pexp = t1/t
			g pexp_ca = a1/m1					//v1.3.9: add pexp_ca, pres_ex variables
			g pres = m1/t
			g pres_ue = a0/t0
			g pres_ex = a1/t1					//v1.3.9: add pexp_ca, pres_ex variables
		}
		if ("`stat'"=="md") {
			//check for variable names and erase existent variables
			checkvars m1 sd1 n1 m0 sd0 n0, errmsg
			
			checkvars md se lo up, local(md_exists)
			if (`md_exists') {
				g _md0_orig = md
				g _se0_orig = se
				g _lo0_orig = lo
				g _up0_orig = up
			}
			
			erasevars md se lo up cl
			tempname N s
			g `N' = n1+n0											//Total number of participants
			g `s' = sqrt(((n1-1)*sd1^2+(n0-1)*sd0^2)/(`N'-2))		//Pooled standard deviation of the two groups
			if (`md_std'==0) {
				g md = m1 - m0										//No standardization
				g se = sqrt(sd1^2/n1 + sd0^2/n0)
			}
			else if (`md_std'==1) {
				g md = (m1 - m0)/`s'								//Cohen's d
				g se = sqrt(`N'/(n1*n0) + md^2/(2*(`N'-2)))
			}
			else if (`md_std'==2) {
				g md = ((m1 - m0)/`s')*(1-3/(4*`N'-9))				//Hedge's adjusted g
				g se = sqrt(`N'/(n1*n0) + md^2/(2*(`N'-3.94)))
			}
			else if (`md_std'==3) {
				g md = (m1 - m0)/sd0								//Glass's delta
				g se = sqrt(`N'/(n1*n0) + md^2/(2*(n0-1)))
			}
			g cl = `level'
			g lo = md - invnormal((cl+100)/200)*se
			g up = md + invnormal((cl+100)/200)*se
		}
	}
	
	return scalar zeros = `lzeros'
	return scalar ormh_zero = `ormh_zero'
	return scalar md_exists = `md_exists'
end

program data_sst
	syntax anything(name=stat), level(real)
	
	checkvars `stat', errmsg
	quietly{
		if ("`stat'"!="r") {
			checkvars lo up, local(found_ci) 
			if (!`found_ci') checkvars se, local(found_se) 
			else local found_se 0
			if (!`found_ci' & !`found_se') print_error "missing lo,up or se variable(s)"
		}
		else {
			*Correlation coefficient: r, n variables
			checkvars n, errmsg
			capture drop se
			
			replace r = ln(sqrt((1+r)/(1-r)))	//Fisher's Z
			g se = 1/sqrt(n-3)					//Fisher's Z Standard Error
			local found_ci 0
			local found_se 1
		}
		*Compute Confidece Interval
		if (`found_ci') {
			capture drop se
			checkvars cl
			if (!r(ok)) g cl = `level'
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") g se = (ln(up)-ln(lo))/(2*invnormal((cl+100)/200))
			else g se = (up-lo)/(2*invnormal((cl+100)/200))
		}
		if (`found_se') {
			erasevars lo up
			if ("`stat'"=="or" | "`stat'"=="rr" | "`stat'"=="ir") {
				g lo = `stat'*exp(-invnormal((`level'+100)/200)*se)
				g up = `stat'*exp(invnormal((`level'+100)/200)*se)
			}
			else {
				g lo = `stat' - invnormal((`level'+100)/200)*se
				g up = `stat' + invnormal((`level'+100)/200)*se
			}
			capture drop cl
			g cl = `level'
		}
	}
end


program checkvars, rclass
	syntax anything(name=vars), [errmsg local(str)]
	foreach v in `vars' {
		capture confirm variable `v'
		local ok = (_rc==0)
		if (!`ok') {
			if ("`error_msg'"!="") print_error "missing `v' variable"
			break
		}
	}
	if "`local'" != "" {
		c_local `local' `"`ok'"'
	}
	return scalar ok = `ok'
end

program erasevars
	syntax anything(name=vars)
	foreach v in `vars' {
		capture confirm variable `v', exact
		if !_rc {
			qui drop `v'
		}
	}
end

program zero_correction, rclass
	syntax anything(name=type), vzeros(string) [mixed vraw(string)]
	
	tempname k1 k0 nmhi dmhi nmh dmh ormh
	
	local lzeros 0
	if ("`mixed'"=="") {
		//raw data
		qui gen `vzeros' = (a1==0) | (a0==0) | (b1==0) | (b0==0)
	}
	else {
		//mixed data
		qui gen `vzeros' = (`vraw'==1) & ((a1==0) | (a0==0) | (b1==0) | (b0==0))
	}
	qui sum `vzeros'
	local lzeros = r(max)

	scalar `ormh' = 0
	if ("`type'"!="n" & `lzeros'==1) {
		quietly {
			if ("`type'"=="c") {
				gen `k1' = 0.5 if (`vzeros'==1)
				gen `k0' = 0.5 if (`vzeros'==1)
			}
			if ("`type'"=="p") {
				gen `k1' = n1/(n1+n0) if (`vzeros'==1)
				gen `k0' = n0/(n1+n0) if (`vzeros'==1)
			}
			if ("`type'"=="e") {
				//Compute the ORmh with the studies without zero events
				gen `nmhi' = a1*b0/(n1+n0) if (`vzeros'==0)
				gen `dmhi' = a0*b1/(n1+n0) if (`vzeros'==0)
				sum `nmhi'
				scalar `nmh' = r(sum)
				sum `dmhi'
				scalar `dmh' = r(sum)
				scalar `ormh' = `nmh'/`dmh'
				gen `k1' = (`ormh' * n1)/(n0 + `ormh'*n1) if (`vzeros'==1)
				gen `k0' = n0/(n0 + `ormh'*n1) if (`vzeros'==1)
			}
			replace a1 = a1 + `k1' if (`vzeros'==1)
			replace a0 = a0 + `k0' if (`vzeros'==1)
			replace b1 = b1 + `k1' if (`vzeros'==1)
			replace b0 = b0 + `k0' if (`vzeros'==1)
			replace n1 = a1 + b1 if (`vzeros'==1)
			replace n0 = a0 + b0 if (`vzeros'==1)
			if ("`mixed'"=="") {
				replace m1 = a0 + a1 if (`vzeros'==1)
				replace m0 = b0 + b1 if (`vzeros'==1)
			}
			replace n = n1 + n0 if (`vzeros'==1)
		}
	}
	return scalar zeros = `lzeros'
	return scalar ormh = `ormh'
end

program define print_pct
	syntax anything, [col(numlist max=1) a(real 5) nopercent]
	local p = `anything'
	local v = abs(`p')
	if (`v'<0.01 & `v'>0) local fmt = "%`a'.3f"
	else local fmt = cond(abs(`p')<10,cond(abs(`p')<1,"%`a'.0g","%`a'.2f"),"%`a'.1f")
	if ("`col'"=="") di as res `fmt' `p' _c
	else di as res _col(`col') `fmt' `p' _c
	if ("`percent'"=="") di as txt "%" _c
end

program define print_error
	args message
	noisily display in red "`message'" 
	exit 198
end


version 12
mata:
struct mar_results
{
	real   matrix   data		//2x2 data: 1 a1; 2 a0; 3 b1; 4 b0; 5 n1; 6 n0; 7 m1; 8 m0; 9 n
	real   matrix   st			//stat: 1 stat; 2 se; 3 loCI; 4 upCI; 5 p; 6 chi2
	real   matrix   st_peto		//PETO stat: 1 or_peto; 2 se_peto; 3 loCI_peto; 4 upCI_peto; 5 p_peto
	real   matrix   w			//weights: 1 iv; 2 mh; 3 peto; 4 ivr
	real   rowvector sw			//Sum of total weights
	real   matrix   rw			//relative weights: 1 iv; 2 mh; 3 peto; 4 ivr
	real   matrix   influ		//influence analysis: 1 es; 2 lo; 3 up; 4 change; 5 I2; 6 p
	real   matrix   cum			//cumulative analysis: 1 es_cum; 2 lo; 3 up; 4; es
	real   rowvector  est_peto	//Peto combined estimations
	real   rowvector  est_mh	//MH combined estimations
	real   rowvector  est_iv	//IoV - Fixed effects estimations
	real   rowvector  est_ivr	//IoV - Random effects estimations
	real   rowvector   a1		//2x2 tables: rowvector with terms
	real   rowvector   a0
	real   rowvector   b1
	real   rowvector   b0
	real   rowvector   n1
	real   rowvector   n0
	real   rowvector   m1
	real   rowvector   m0
	real   rowvector   n
	real   rowvector   t1
	real   rowvector   t0
	real   rowvector   i1
	real   rowvector   i0
	real   rowvector   t
	real   rowvector   i
	string scalar	type
	string scalar	stat
	real   scalar   len
	real   scalar   level
	real   scalar   z
	real   scalar   get_peto
	real   scalar   get_mh
	real   scalar   get_influ
	string scalar   method
	real   scalar   get_cum
	real   scalar	cum_descent
}

version 12
mata:
void init(string scalar type, string scalar stat, real scalar nstudy, real scalar level,real scalar influ,string scalar method,real scalar cum,real scalar cumdescent)
{
	struct mar_results scalar	r
	real matrix 	temp

	r.type = type
	r.stat = stat
	r.level = level
	r.z = invnormal((r.level+100)/200)
	r.len = nstudy
	if (r.type == "raw") r.st = J(r.len+1,6,.)
	if (r.type == "sst") r.st = J(r.len,6,.)
	r.st_peto = J(r.len+1,5,.)
	r.w = J(r.len,4,.)
	r.get_peto = 0
	r.get_mh = 0
	r.get_influ = influ
	r.method = method
	r.influ = J(r.len,6,.)
	r.get_cum = cum
	r.cum = J(r.len,4,.)
	r.cum_descent = cumdescent

	if (r.type == "raw") {
		if (r.stat=="or" | r.stat=="rr" | r.stat=="rd") r.data = st_data(.,("a1","a0","b1","b0","n1","n0","m1","m0","n","__cumsort"))
		if (r.stat=="ir" | r.stat=="id") r.data = st_data(.,("a1","a0","t1","t0","i1","i0","m1","t","i","__cumsort"))
		r.data = r.data \ colsum(r.data)		//Add TOTAL row
		if (r.stat=="ir" | r.stat=="id") {
			r.data[r.len+1,5] = r.data[r.len+1,1]:/r.data[r.len+1,3]
			r.data[r.len+1,6] = r.data[r.len+1,2]:/r.data[r.len+1,4]
			r.data[r.len+1,9] = r.data[r.len+1,7]:/r.data[r.len+1,8]
		}
		if (r.stat=="or" | r.stat=="rr" | r.stat=="ir") r.get_mh = 1
		if (r.stat=="or") r.get_peto = 1
		getterms(r)								//Get individual terms
		getstdata(r)							//Build st matrix with statistic data
		st_matrix("__mar_data",r.data)
		r.data = r.data[1::r.len,.]				//Delete TOTAL row
		getterms(r)								//Get individual terms - without the TOTAL row
	}
	else {
		r.data = st_data(.,(r.stat,"se","lo","up","cl","__cumsort"))
		getstdata(r)							//Build st matrix with statistic data
		st_matrix("__mar_data",r.data)
	}
	getweights(r)			//Compute weights
	if (r.type == "raw" & (r.stat == "or" | r.stat == "rr" | r.stat == "ir")) {
		if (r.stat == "or") {
			r.est_peto = peto(r,r.w[.,3],r.st_peto[1::r.len,1],r.a1,r.m1,r.n1,r.n)		//Peto estimations
		}
		st_matrix("__mar_peto",r.est_peto)
		r.est_mh = mh(r,r.st[1::r.len,1],r.st[1::r.len,2],r.a1,r.a0,r.b1,r.b0,r.t1,r.t0,r.n,r.t,0)		//MH estimations
		st_matrix("__mar_mh",r.est_mh)
	}
	else {
		st_matrix("__mar_peto",J(1,1,.))
		st_matrix("__mar_mh",J(1,1,.))
	}
	r.est_iv = iov(r,r.w[.,1],r.st[1::r.len,1])		//IoV - fixed effects estimations
	if (r.stat == "r") {
		r.est_iv[1,1] = ZtoRho(r.est_iv[1,1])
		r.est_iv[1,3] = ZtoRho(r.est_iv[1,3])
		r.est_iv[1,4] = ZtoRho(r.est_iv[1,4])
	}
	st_matrix("__mar_iv",r.est_iv)
	getwivr(r)											//Get IoV - random effects weights
	r.est_ivr = iov(r,r.w[.,4],r.st[1::r.len,1])		//IoV - random effects estimations
	if (r.stat == "r") {
		r.est_ivr[1,1] = ZtoRho(r.est_ivr[1,1])
		r.est_ivr[1,3] = ZtoRho(r.est_ivr[1,3])
		r.est_ivr[1,4] = ZtoRho(r.est_ivr[1,4])
	}
	st_matrix("__mar_ivr",r.est_ivr)
	
	if (r.get_influ) influ(r)		//Influence analysis
	
	if (r.get_cum) cum(r)		//Cumulative analysis
	
	if (r.stat == "r") {
		r.st[.,1] = ZtoRhoM(r.st[.,1])
		r.st[.,3] = ZtoRhoM(r.st[.,3])
		r.st[.,4] = ZtoRhoM(r.st[.,4])
	}
	st_matrix("__mar_st",r.st)
	st_matrix("__mar_stp",r.st_peto)
	st_matrix("__mar_rw",r.rw)
	st_matrix("__mar_sw",r.sw)
	st_matrix("__mar_influ",r.influ)
	st_matrix("__mar_cum",r.cum)
}
end

version 12
mata:
real scalar ZtoRho(real scalar z)
{
	//Fisher's Z to rho correlation coefficient
	return( (exp(2*z)-1)/(exp(2*z)+1) )
}
end

version 12
mata:
real matrix ZtoRhoM(real matrix Z)
{
	//Fisher's Z to rho correlation coefficient
	return((exp(2:*Z) :- 1) :/ (exp(2:*Z) :+ 1))
}
end

version 12
mata:
void cum(struct mar_results scalar r)
{
	real matrix D, T, R, temp, S
	real scalar order

	temp = J(r.len,1,.)
	//Build the data matrix to compute the cumulative analysis and sort
	if (r.method=="fem") D = (r.data[.,cols(r.data)],r.w[.,1],r.st[1::r.len,1])
	if (r.method=="rem") D = (r.data[.,cols(r.data)],r.w[.,1],r.st[1::r.len,1],r.st[1::r.len,2])
	if (r.method=="mh") {
		if (r.stat=="or" | r.stat=="rr" | r.stat=="rd") {
			D = (r.data[.,cols(r.data)],r.st[1::r.len,1],r.st[1::r.len,2],r.a1,r.a0,r.b1,r.b0,temp,temp,r.n,temp)
		}
		if (r.stat=="ir" | r.stat=="id") {
			D = (r.data[.,cols(r.data)],r.st[1::r.len,1],r.st[1::r.len,2],r.a1,r.a0,temp,temp,r.t1,r.t0,temp,r.t)
		}
	}
	if (r.method=="peto") D = (r.data[.,cols(r.data)],r.w[.,3],r.st[1::r.len,3],r.a1,r.m1,r.n1,r.n)
	
	S = (r.data[.,cols(r.data)],r.st[1::r.len,1],r.st[1::r.len,3],r.st[1::r.len,4])
	if (r.method=="peto") S = (r.data[.,cols(r.data)],r.st_peto[1::r.len,1],r.st_peto[1::r.len,3],r.st_peto[1::r.len,4])
	
	//Sort matrix
	order = -1
	if (r.cum_descent==0) order = 1
	D = sort(D,order)
	S = sort(S,order)
		
	r.cum[1,1] = S[1,2]		//The first study needs no calculations
	r.cum[1,2] = S[1,3]
	r.cum[1,3] = S[1,4]
	r.cum[1,4] = S[1,2]
	
	for (i=2; i<=r.len; i++) {
		T = D[|1,1 \ i, cols(D)|]		//Get the accumulated matrix
		//Get the results for each method
		if (r.method=="fem") R = iov(r, T[.,2], T[.,3])
		if (r.method=="mh") R = mh(r, T[.,2], T[.,3], T[.,4], T[.,5], T[.,6], T[.,7], T[.,8], T[.,9], T[.,10], T[.,11], 0)
		if (r.method=="peto") R = peto(r, T[.,2], T[.,3], T[.,4], T[.,5], T[.,6], T[.,7])
		if (r.method=="rem") {
			R = iov(r, T[.,2], T[.,3])
			temp = 1 :/ ((T[.,4]):^2 :+ R[1,15])		//IoV weight - Random effects
			R = iov(r, temp, T[.,3])
		}
		
		r.cum[i,1] = R[1,1]
		r.cum[i,2] = R[1,3]
		r.cum[i,3] = R[1,4]
		r.cum[i,4] = S[i,2]
	}
	if (r.stat=="r") {
		r.cum[.,1] = ZtoRhoM(r.cum[.,1])
		r.cum[.,2] = ZtoRhoM(r.cum[.,2])
		r.cum[.,3] = ZtoRhoM(r.cum[.,3])
		r.cum[.,4] = ZtoRhoM(r.cum[.,4])
	}
}
end

version 12
mata:
real matrix delrow(real matrix M, real scalar i, real scalar n)
{
	//Return matrix M without the i row. The matrix is nxn
	real matrix R
	if (i==1) {
		R = M[|2,1 \ n, cols(M)|]		//Delete the first row
	}
	else if (i==n) {
		R = M[|1,1 \ n-1, cols(M)|]		//Delete the last row
	}
	else {
		R = M[|1,1 \ i-1, cols(M)|] \ M[|i+1,1 \ n, cols(M)|]		//Delete the ith row
	}
	return(R)
}
end

version 12
mata:
void influ(struct mar_results scalar r)
{
	real rowvector R
	real matrix w, st, a1, a0, b1, b0, n, t1, t0, t
	
	//INFLUENCE ANALYSIS
	for (i=1; i<=r.len; i++) {
		if (r.method=="fem") {
			w = delrow(r.w,i,r.len)
			st = delrow(r.st,i,r.len)
			R = iov(r, w[.,1], st[.,1])
			if (r.stat == "r") {
				R[1,1] = ZtoRho(R[1,1])
				R[1,3] = ZtoRho(R[1,3])
				R[1,4] = ZtoRho(R[1,4])
			}
			r.influ[i,1] = R[1,1]
			r.influ[i,2] = R[1,3]
			r.influ[i,3] = R[1,4]
			r.influ[i,4] = 100*(R[1,1]-r.est_iv[1,1])/r.est_iv[1,1]   //Percentage of change of the statistic
			r.influ[i,5] = R[1,12]
			r.influ[i,6] = R[1,7]
		}
		if (r.method=="rem") {
			w = delrow(r.w,i,r.len)
			st = delrow(r.st,i,r.len)
			R = iov(r, w[.,1], st[.,1])
			w = 1 :/ (st[.,2]:^2 :+ R[1,15])
			R = iov(r, w, st[.,1])
			if (r.stat == "r") {
				R[1,1] = ZtoRho(R[1,1])
				R[1,3] = ZtoRho(R[1,3])
				R[1,4] = ZtoRho(R[1,4])
			}
			r.influ[i,1] = R[1,1]
			r.influ[i,2] = R[1,3]
			r.influ[i,3] = R[1,4]
			r.influ[i,4] = 100*(R[1,1]-r.est_ivr[1,1])/r.est_ivr[1,1]   //Percentage of change of the statistic
			r.influ[i,5] = R[1,12]
			r.influ[i,6] = R[1,7]
		}
		if (r.method=="mh") {
			st = delrow(r.st,i,r.len)
			a1 = delrow(r.a1,i,r.len)
			a0 = delrow(r.a0,i,r.len)
			if (r.stat!="ir") {
				b1 = delrow(r.b1,i,r.len)
				b0 = delrow(r.b0,i,r.len)
				n = delrow(r.n,i,r.len)
				t1 = J(r.len-1,1,.)
				t0 = J(r.len-1,1,.)
				t = J(r.len-1,1,.)
			}
			else {
				t1 = delrow(r.t1,i,r.len)
				t0 = delrow(r.t0,i,r.len)
				t = delrow(r.t,i,r.len)
				b1 = J(r.len-1,1,.)
				b0 = J(r.len-1,1,.)
				n = J(r.len-1,1,.)
			}
			R = mh(r, st[.,1], st[.,2], a1, a0, b1, b0, t1, t0, n, t, 0)
			r.influ[i,1] = R[1,1]
			r.influ[i,2] = R[1,3]
			r.influ[i,3] = R[1,4]
			r.influ[i,4] = 100*(R[1,1]-r.est_mh[1,1])/r.est_mh[1,1]   //Percentage of change of the statistic
		}
		if (r.method=="peto") {
			w = delrow(r.w,i,r.len)
			st = delrow(r.st,i,r.len)
			a1 = delrow(r.a1,i,r.len)
			m1 = delrow(r.m1,i,r.len)
			n1 = delrow(r.n1,i,r.len)
			n = delrow(r.n,i,r.len)
			R = peto(r, w[.,3], st[.,3], a1, m1, n1, n)
			r.influ[i,1] = R[1,1]
			r.influ[i,2] = R[1,3]
			r.influ[i,3] = R[1,4]
			r.influ[i,4] = 100*(R[1,1]-r.est_peto[1,1])/r.est_peto[1,1]   //Percentage of change of the statistic
		}
	}
}
end

version 12
mata:
void getterms(struct mar_results scalar r)
{
	if (r.stat=="or" | r.stat=="rr" | r.stat=="rd") {
		r.a1 = r.data[.,1]
		r.a0 = r.data[.,2]
		r.b1 = r.data[.,3]
		r.b0 = r.data[.,4]
		r.n1 = r.data[.,5]
		r.n0 = r.data[.,6]
		r.m1 = r.data[.,7]
		r.m0 = r.data[.,8]
		r.n = r.data[.,9]
	}
	if (r.stat=="ir" | r.stat=="id") {
		r.a1 = r.data[.,1]
		r.a0 = r.data[.,2]
		r.t1 = r.data[.,3]
		r.t0 = r.data[.,4]
		r.i1 = r.data[.,5]
		r.i0 = r.data[.,6]
		r.m1 = r.data[.,7]
		r.t = r.data[.,8]
		r.i = r.data[.,9]
	}
}
end

version 12
mata:
real rowvector mh(struct mar_results scalar r, real matrix st, real matrix s_e, real matrix a1, /*
*/	real matrix a0, real matrix b1, real matrix b0, real matrix t1, real matrix t0, real matrix n, real matrix t, real scalar zerocor)
{
	real matrix R, num, den, rmh, s, pr, psqr, qs, numse, n1, n0, m1
	real scalar se, es, lo, up, p, Q, pQ
	
	if (r.stat == "or" | zerocor) {
		num = a1:*b0:/n
		den = a0:*b1:/n
		rmh = (a1:*b0):/n
		s = (a0:*b1):/n
		pr = ((a1:+b0):/n):*rmh
		psqr = ((a1:+b0):/n):*s :+ (1:-((a1:+b0):/n)):*rmh
		qs = (1:-((a1:+b0):/n)):*s
		//Standard error (or)
		se = sqrt(colsum(pr)/(2*colsum(rmh)^2) + colsum(psqr)/(2*colsum(rmh)*colsum(s)) + /*
			*/	colsum(qs)/(2*colsum(s)^2))
	}
	else {
		if (r.stat == "rr") {
			n1 = a1 :+ b1
			n0 = a0 :+ b0
			m1 = a0 :+ a1
			num = a1:*n0:/n
			den = a0:*n1:/n
			numse = (m1:*n1:*n0:/n:^2) :- a1:*a0:/n
		}
		if (r.stat == "ir") {
			m1 = a0 :+ a1
			num = a1:*t0:/t
			den = a0:*t1:/t
			numse = (m1:*t1:*t0:/t:^2) :- a1:*a0:/t
		}
		if (r.stat == "rr" | r.stat == "ir") {
			se = sqrt(colsum(numse)/(colsum(num)*colsum(den)))		//Standard Error (rr, ir)
		}
	}
	es = colsum(num)/colsum(den)       	//Estimation of the statistic
	lo = es*exp(-r.z*se)				//CI
	up = es*exp(r.z*se)
	p = 2*(1-normal(abs(ln(es)/se)))		//Significance
	if (missing(st)==0) {
		Q = colsum((ln(st):-ln(es)):^2:/(s_e:^2))
		pQ = 1-chi2(r.len-1, abs(Q))
	}
	R = (es,se,lo,up,p,Q,pQ)
	return(R)
}
end

version 12
mata:
real rowvector peto(struct mar_results scalar r, real matrix w, real matrix st, real matrix a1, real matrix m1, real matrix n1, real matrix n)
{
	real rowvector R, ae, Q
	real scalar sw, es, se, lo, up, p, Qpeto, pQpeto
	
	ae = (a1 :- (m1:*n1:/n))			//Peto combined: terms for the summatory
	sw = colsum(w)
	es = exp(colsum(ae)/sw)				//Estimation of the OR Peto
	se = sqrt(1/sw)						//SE
	lo = es*exp(-r.z*se)				//CI
	up = es*exp(r.z*se)
	p  = 2*(1-normal(abs(ln(es)/se)))	//Significance
	Q = ((ln(st) :- ln(es)):^2) :* w	//Homogeneity Q Test (Peto)
	Qpeto = colsum(Q)
	pQpeto = (1-chi2(r.len-1,abs(Qpeto)))
	
	R = (es,se,lo,up,p,Qpeto,pQpeto)
	return(R)
}
end

version 12
mata:
real rowvector iov(struct mar_results scalar r, real matrix w, real matrix st)
{
	real rowvector R, num, Q
	real scalar se, sw, es, lo, up, p, Qiv, pQiv
	real scalar k, H, swH, loH, upH, I2, upI2, loI2, Tau2
		
	//IoV - fixed & random effects
	k = rows(w)
	sw = colsum(w)
	se = sqrt(1/sw)							//SE
	if (r.stat=="or" | r.stat=="rr" | r.stat=="ir") {
		num = w :* ln(st)
		es = exp(colsum(num)/sw)			//Weigthed statistic
		lo = es * exp(-r.z*se)				//CI
		up = es * exp(r.z*se)
		p = 2*(1-normal(abs(ln(es)/se)))	//Significance
		Q = w :* (ln(st) :- ln(es)):^2     	//Homogeneity Q Test
	}
	else {
		num = w :* st
		es = colsum(num)/sw					//Weigthed statistic
		lo = es - r.z*se					//CI
		up = es + r.z*se
		p = 2*(1-normal(abs(es/se)))		//Significance
		Q = w :* (st :- es):^2     			//Homogeneity Q Test
	}
	Qiv = colsum(Q)
	pQiv = (1- chi2(k-1,abs(Qiv)))
	
	//Heterogeneity Measures
	//Relative excess
	
	H = sqrt(Qiv/(k-1))
	seH = 0
	if (Qiv>k) {
		seH = (ln(Qiv)-ln(k-1))/(2*(sqrt(2*Qiv) - sqrt(2*k-3)))
	}
	else {
		if (k>2) seH = sqrt((1/(2*(k-2))) * (1-1/(3*(k-2)^2)))
	}
	loH = H*exp(-r.z*seH)
	upH = H*exp(r.z*seH)
	//% of Variance that is due heterogeneity between studies: I2 Statistic
	I2 = 100*(H^2-1)/H^2
	if (I2<0) I2 = 0
	loI2 = 100*(loH^2-1)/loH^2
	if (loI2<1) loI2 = 0
	upI2 = 100*(upH^2-1)/upH^2
	if (upI2<1) upI2 = 0

	//Variance between studies (Tau2) for IOV model
	Tau2 = (Qiv-k+1)/(sw-colsum(w:^2)/sw)
	if (Tau2<0) Tau2 = 0
	
	R = (es,se,lo,up,p,Qiv,pQiv,H,seH,loH,upH,I2,loI2,upI2,Tau2)
	return(R)
}
end

version 12
mata:
void getstdata(struct mar_results scalar r)
{
	real   rowvector   t
	
	if (r.type == "raw") {
		if (r.stat == "or") {
			r.st[.,1] = (r.a1 :/ r.b1) :/ (r.a0 :/ r.b0)		//stat=or,Odds Ratio   
			r.st[.,2] = sqrt(1:/r.a1 + 1:/r.b1 + 1:/r.a0 + 1:/r.b0)

			t = (r.m1 :* (r.n1:/r.n)) :* ((r.n0 :* r.m0) :/ (r.n :* (r.n:-1)))	  //Peto Weight - temporary
			r.st_peto[.,1] = exp((r.a1 - (r.m1 :* (r.n1:/r.n))) :/ t)     //Peto OR
			r.st_peto[.,2] = sqrt(1:/t)       					  //Peto Standard Error
		}
		if (r.stat == "rr") {
			r.st[.,1] = (r.a1 :/ r.n1) :/ (r.a0 :/ r.n0)		//stat=rr,Relative Risk
			r.st[.,2] = sqrt(1:/r.a1 - 1:/r.n1 + 1:/r.a0 - 1:/r.n0)
		}
		if (r.stat == "ir") {
			r.st[.,1] = (r.a1 :/ r.t1) :/ (r.a0 :/ r.t0)		//stat=ir,Rate Ratio
			r.st[.,2] = sqrt(1:/r.a1 :+ 1:/r.a0)
		}
		if (r.stat == "rd") {
			r.st[.,1] = (r.a1 :/ r.n1) - (r.a0 :/ r.n0)			//stat=rd,Risk Difference
			r.st[.,2] = sqrt(((r.a1:/r.n1):*(1:-(r.a1:/r.n1))):/r.n1 + ((r.a0:/r.n0):*(1:-(r.a0:/r.n0))):/r.n0)
		}
		if (r.stat == "id") {
			r.st[.,1] = (r.a1 :/ r.t1) :- (r.a0 :/ r.t0)			//stat=id,Rate Difference
			r.st[.,2] = sqrt(r.a1:/r.t1:^2 :+ r.a0:/r.t0:^2)
		}
		
		//Compute bounds for the statistic
		if (r.stat=="or" | r.stat=="rr" | r.stat=="ir") {
			r.st[.,3] = r.st[.,1] :* exp(-r.z * r.st[.,2])
			r.st[.,4] = r.st[.,1] :* exp(r.z * r.st[.,2])
			if (r.get_peto) {
				r.st_peto[.,3] = r.st_peto[.,1] :* exp(-r.z * r.st_peto[.,2])
				r.st_peto[.,4] = r.st_peto[.,1] :* exp(r.z * r.st_peto[.,2])
			}
		}
		else {
			r.st[.,3] = r.st[.,1] - (r.z * r.st[.,2])
			r.st[.,4] = r.st[.,1] + (r.z * r.st[.,2])
		}

		//MH Chi-Square and signification (p)
		if (r.stat=="or" | r.stat=="rr" | r.stat=="rd") {
			r.st[.,6] = (r.n:-1) :* ((r.a1:*r.n :- r.n1:*r.m1):^2) :/ (r.m1:*r.m0:*r.n1:*r.n0)
		}
		else {
			r.st[.,6] = ((r.a1:*r.t - r.t1:*r.m1):^2) :/ (r.m1:*r.t1:*r.t0)
		}
		r.st[.,5] = 1 :- chi2(1,abs(r.st[.,6]))
		if (r.get_peto) r.st_peto[.,5] = 2 :* (1 :- normal(abs(ln(r.st_peto[.,1]):/r.st_peto[.,2])))
	}
	if (r.type == "sst") {
		r.st[.,1] = r.data[.,1]
		r.st[.,2] = r.data[.,2]
		r.st[.,3] = r.data[.,3]
		r.st[.,4] = r.data[.,4]
	}
}
end

version 12
mata:
void getweights(struct mar_results scalar r)
{
	real  rowvector  sw

	r.w[.,1] = 1 :/ (r.st[1::r.len,2]):^2					//IoV weight - fixed effects
	if (r.get_mh) {											//MH weight
		if (r.stat=="or") r.w[.,2] = r.a0 :* r.b1 :/ r.n
		if (r.stat=="rr") r.w[.,2] = r.a0 :* r.n1 :/ r.n
		if (r.stat=="ir") r.w[.,2] = r.a0 :* r.t1 :/ r.t
	}
	if (r.get_peto) r.w[.,3] = (r.m1 :* (r.n1:/r.n)) :* ((r.n0 :* r.m0) :/ (r.n :* (r.n:-1)))	//Peto Weight

	//Relative weights
	r.sw = colsum(r.w)
	r.rw = J(r.len,4,.)
	r.rw[.,1] = (r.w[.,1] :/ r.sw[1])*100
	r.rw[.,2] = (r.w[.,2] :/ r.sw[2])*100
	r.rw[.,3] = (r.w[.,3] :/ r.sw[3])*100
	
	//IoV weights - Random effects must be computed after IoV - Fixed: see getwivr
}
end

version 12
mata:
void getwivr(struct mar_results scalar r)
{
	real  scalar     Tau2

	Tau2 = r.est_iv[15]
	r.w[.,4] = 1 :/ ((r.st[1::r.len,2]):^2 :+ Tau2)					//IoV weight - Random effects

	//Relative weights
	r.sw[4] = colsum(r.w[.,4])
	r.rw[.,4] = (r.w[.,4] :/ r.sw[4])*100
}
end
