*! version 1.3.2  03feb2020
program nsize__utils
	version 12.0
	gettoken subcmd 0 : 0
	`subcmd' `0'
end


program define showHide
	syntax , [clsname(string)]
	local dlg .`clsname'
	local type = "``dlg'.main.co_type.value'"
	
	`dlg'.main.tx_type.setlabel "`type'"
	
	`dlg'.onOff.setfalse				// set false to block events when seton sample size by default
	
	local l co1p co2p c1pe c2pe copp co1m co2m c2me cokm ci1p ci2p ci1m ci2m co1c co2c co2r co2i ncr
	local l: list l - type
	
	* show controls for selected type
	s_h , clsname(`dlg') type(`type') show
	
	* hide controls for non-selected types
	foreach j in `l' {
		s_h , clsname(`dlg') type(`j') hide
	}
	
	* sample size is the default
	if ("`type'"=="cokm") {
		`dlg'.main.`type'_mean.seton
		onOff, clsname(`clsname') mean
	}
	else {
		if ("`type'"=="co2r") {
			`dlg'.main.`type'_co.seton
			co2r, clsname(`clsname') co
		}
		else {
			if ("`type'"!="ncr") {
				`dlg'.main.`type'_size.seton
				onOff, clsname(`clsname') size
			}
		}
	}
	
	`dlg'.onOff.settrue
end

program define s_h
	syntax , clsname(string) type(string) [show hide]
	local dlg .`clsname'
	
	if ("`type'"=="co1p" | "`type'"=="co2p" | "`type'"=="copp" | /*
	*/ "`type'"=="co1c" | "`type'"=="co2c" | "`type'"=="co2i") local l gb1 size power
	if ("`type'"=="c1pe" | "`type'"=="c2pe") local l gb1 size power gb2 equ non sup
	if ("`type'"=="co1m" | "`type'"=="co2m" | "`type'"=="c2me") local l gb1 size power effect
	if ("`type'"=="cokm") local l gb1 mean pair power1 power2
	if ("`type'"=="ci1p" | "`type'"=="ci2p" | "`type'"=="ci1m" | "`type'"=="ci2m") local l gb1 size preci
	if ("`type'"=="co2r") local l gb1 co cc gb2 size1 power1 gb3 size2 power2
	if ("`type'"=="ncr") local l gb1 gb2
	foreach j in `l' {
		`dlg'.main.`type'_`j'.`show'`hide'
	}
	
	if ("`type'"=="co1p") local l p p1 ef a b n
	if ("`type'"=="co2p") local l p0 p1 ef a b n
	if ("`type'"=="c1pe") local l p0 p1 d a b n
	if ("`type'"=="c2pe") local l p0 p1 d r a b n0 n1
	if ("`type'"=="copp") local l or pd p0 ora r a b n
	if ("`type'"=="co1m" | "`type'"=="c2me") local l sd a e1 e2 b1 b2 n1 n2
	if ("`type'"=="co2m") local l sd r a e1 b1 e2 n11 n01 b2 n12 n02
	if ("`type'"=="cokm") local l sd m e c nk1 nk2
	if ("`type'"=="ci1p") local l p0 cl n a ns
	if ("`type'"=="ci2p") local l p0 p1 cl r a n1 n0
	if ("`type'"=="ci1m") local l sd cl n a ns
	if ("`type'"=="ci2m") local l sd cl r a n1 n0
	if ("`type'"=="co1c") local l cr cr1 e a b n1
	if ("`type'"=="co2c") local l cr0 cr1 e a b n1 n0
	if ("`type'"=="co2r") local l r0 r1 rr rd or1 rt1 pe a1 b1 n1 n0 pe0 pe1 or2 rt2 a2 b2 m1 m0
	if ("`type'"=="co2i") local l i0 i1 ir id d r a b n1 n0
	if ("`type'"=="ncr") local l vb vw e a b
	foreach j in `l' {
		`dlg'.main.`type'_`j'_de.`show'`hide'
		`dlg'.main.`type'_`j'_ed.`show'`hide'
		`dlg'.main.`type'_`j'_tx.`show'`hide'
	}
end

program define onOff
	syntax , clsname(string) [power size effect mean pair preci]
	local dlg .`clsname'
	local type = "``dlg'.main.co_type.value'"

	* enable / disable controls by sample size / power

	if ("`size'"!="") {
		if ("`type'"=="co1p") | ("`type'"=="co2p") | ("`type'"=="c1pe")  | ("`type'"=="copp"){
			`dlg'.main.`type'_power.setoff
			`dlg'.main.`type'_n_ed.disable
			`dlg'.main.`type'_b_ed.enable
		}
		if ("`type'"=="c2pe") | ("`type'"=="co2i") {
			`dlg'.main.`type'_power.setoff
			`dlg'.main.`type'_n0_ed.disable
			`dlg'.main.`type'_n1_ed.disable
			`dlg'.main.`type'_b_ed.enable
		}
		if ("`type'"=="co1m" ) | ("`type'"=="c2me") | ("`type'"=="co2m") {
			`dlg'.main.`type'_e1_ed.enable
			`dlg'.main.`type'_b1_ed.enable
			`dlg'.main.`type'_power.setoff
			`dlg'.main.`type'_e2_ed.disable
			`dlg'.main.`type'_effect.setoff
			`dlg'.main.`type'_b2_ed.disable
			
			if ("`type'"=="co1m" ) | ("`type'"=="c2me") `dlg'.main.`type'_n1_ed.disable
			if ("`type'"=="co1m" ) | ("`type'"=="c2me") `dlg'.main.`type'_n2_ed.disable

			if ("`type'"=="co2m" ) `dlg'.main.`type'_n11_ed.disable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n01_ed.disable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n12_ed.disable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n02_ed.disable
		}
		if ("`type'"=="ci1p") | ("`type'"=="ci1m") {
			`dlg'.main.`type'_a_ed.enable
			`dlg'.main.`type'_preci.setoff
			`dlg'.main.`type'_ns_ed.disable
			if ("`type'"=="ci1p") {
				`dlg'.main.`type'_p0_tx.setlabel "Supposed Population Proportion(%):"
				`dlg'.main.`type'_cl_ed.setdefault "90 95 99"
				`dlg'.main.`type'_cl_ed.setvalue "90 95 99"
			}
		}
		if ("`type'"=="ci2p") | ("`type'"=="ci2m") {
			`dlg'.main.`type'_a_ed.enable
			`dlg'.main.`type'_preci.setoff
			`dlg'.main.`type'_n1_ed.disable
			`dlg'.main.`type'_n0_ed.disable
		}
		if ("`type'"=="co1c") | ("`type'"=="co2c") {
			`dlg'.main.`type'_b_ed.enable
			`dlg'.main.`type'_power.setoff
			`dlg'.main.`type'_n1_ed.disable
			if ("`type'"=="co2c") `dlg'.main.`type'_n0_ed.disable
		}
		if ("`type'"=="co2r") {
			if (``dlg'.main.`type'_co.value') {
				`dlg'.main.`type'_b1_ed.enable
				`dlg'.main.`type'_power1.setoff
				`dlg'.main.`type'_n1_ed.disable
				`dlg'.main.`type'_n0_ed.disable				
			}
			if (``dlg'.main.`type'_cc.value') {
				`dlg'.main.`type'_b2_ed.enable
				`dlg'.main.`type'_power2.setoff
				`dlg'.main.`type'_m1_ed.disable
				`dlg'.main.`type'_m0_ed.disable				
			}
		}
	}
	
	if ("`power'"!="") {
		if ("`type'"=="co1p") | ("`type'"=="co2p") | ("`type'"=="c1pe")  | ("`type'"=="copp") {	
			`dlg'.main.`type'_size.setoff
			`dlg'.main.`type'_n_ed.enable
			`dlg'.main.`type'_b_ed.disable
		}
		if ("`type'"=="c2pe") | ("`type'"=="co2i") {
			`dlg'.main.`type'_size.setoff
			`dlg'.main.`type'_n0_ed.enable
			`dlg'.main.`type'_n1_ed.enable
			`dlg'.main.`type'_b_ed.disable
		}
		if ("`type'"=="co1m") | ("`type'"=="co2m") | ("`type'"=="c2me") {
			`dlg'.main.`type'_e2_ed.enable
			`dlg'.main.`type'_size.setoff
			`dlg'.main.`type'_e1_ed.disable
			`dlg'.main.`type'_b1_ed.disable
			`dlg'.main.`type'_effect.setoff
			`dlg'.main.`type'_b2_ed.disable

			if ("`type'"=="co1m" ) | ("`type'"=="c2me") `dlg'.main.`type'_n1_ed.enable
			if ("`type'"=="co1m" ) | ("`type'"=="c2me") `dlg'.main.`type'_n2_ed.disable
			
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n11_ed.enable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n01_ed.enable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n12_ed.disable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n02_ed.disable
		}
		if ("`type'"=="co1c") | ("`type'"=="co2c") {	
			`dlg'.main.`type'_n1_ed.enable
			if ("`type'"=="co2c") `dlg'.main.`type'_n0_ed.enable
			`dlg'.main.`type'_size.setoff
			`dlg'.main.`type'_b_ed.disable
		}
		if ("`type'"=="co2r") {
			if (``dlg'.main.`type'_co.value') {
				`dlg'.main.`type'_n1_ed.enable
				`dlg'.main.`type'_n0_ed.enable
				`dlg'.main.`type'_size1.setoff
				`dlg'.main.`type'_b1_ed.disable
			}
			if (``dlg'.main.`type'_cc.value') {
				`dlg'.main.`type'_m1_ed.enable
				`dlg'.main.`type'_m0_ed.enable				
				`dlg'.main.`type'_size2.setoff
				`dlg'.main.`type'_b2_ed.disable
			}
		}
	}
	
	if ("`effect'"!="") {
		if ("`type'"=="co1m") | ("`type'"=="co2m") | ("`type'"=="c2me") {
			`dlg'.main.`type'_b2_ed.enable
			`dlg'.main.`type'_size.setoff
			`dlg'.main.`type'_e1_ed.disable
			`dlg'.main.`type'_b1_ed.disable
			`dlg'.main.`type'_power.setoff
			`dlg'.main.`type'_e2_ed.disable
			
			if ("`type'"=="co1m" ) | ("`type'"=="c2me") `dlg'.main.`type'_n2_ed.enable
			if ("`type'"=="co1m" ) | ("`type'"=="c2me") `dlg'.main.`type'_n1_ed.disable
			
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n11_ed.disable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n01_ed.disable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n12_ed.enable
			if ("`type'"=="co2m" ) `dlg'.main.`type'_n02_ed.enable			
		}
	}

	if ("`mean'"!="") {
		if ("`type'"=="cokm") {
			`dlg'.main.`type'_m_ed.enable
			`dlg'.main.`type'_power1.setoff
			`dlg'.main.`type'_power1.enable
			`dlg'.main.`type'_pair.setoff
			`dlg'.main.`type'_e_ed.disable
			`dlg'.main.`type'_c_ed.disable
			`dlg'.main.`type'_power2.setoff
			`dlg'.main.`type'_power2.disable
			`dlg'.main.`type'_nk2_ed.disable
		}
	}

	if ("`pair'"!="") {
		if ("`type'"=="cokm") {
			`dlg'.main.`type'_e_ed.enable
			`dlg'.main.`type'_c_ed.enable
			`dlg'.main.`type'_power2.setoff
			`dlg'.main.`type'_power2.enable
			`dlg'.main.`type'_mean.setoff
			`dlg'.main.`type'_m_ed.disable
			`dlg'.main.`type'_power1.setoff
			`dlg'.main.`type'_power1.disable
			`dlg'.main.`type'_nk1_ed.disable
		}
	}
	
	if ("`preci'"!="") {
		if ("`type'"=="ci1p") | ("`type'"=="ci1m") {
			`dlg'.main.`type'_ns_ed.enable
			`dlg'.main.`type'_size.setoff
			`dlg'.main.`type'_a_ed.disable
			if ("`type'"=="ci1p") {
				`dlg'.main.`type'_p0_tx.setlabel "List of Supposed Population Proportion(%):"
				`dlg'.main.`type'_cl_ed.setdefault "95"
				`dlg'.main.`type'_cl_ed.setvalue "95"
			}
		}
		if ("`type'"=="ci2p") | ("`type'"=="ci2m") {
			`dlg'.main.`type'_n1_ed.enable
			`dlg'.main.`type'_n0_ed.enable
			`dlg'.main.`type'_size.setoff
			`dlg'.main.`type'_a_ed.disable
		}
	}
	
end

program define test
	syntax , clsname(string)
	local dlg .`clsname'
	local type = "``dlg'.main.co_type.value'"

	* set delta text for c1p2, c2pe types
	if (``dlg'.main.`type'_equ.value') local c "Equivalence limit"
	if (``dlg'.main.`type'_non.value') local c "Non-Inferiority limit"
	if (``dlg'.main.`type'_sup.value') local c "Superiority limit"
	
	`dlg'.main.`type'_d_tx.setlabel "`c'"
end

program define co2r
	syntax , clsname(string) [co cc]
	local dlg .`clsname'
	local type co2r
	
	`dlg'.co2rOnOff.setfalse
	
	if ("`co'"!="") {
		local ls1 gb2 size1 power1 
		local lh1 gb3 size2 power2
		local ls2 r0 r1 rr rd or1 rt1 pe a1 b1 n1 n0
		local lh2 pe0 pe1 or2 rt2 a2 b2 m1 m0
	}
	if ("`cc'"!="") {
		local ls1 gb3 size2 power2
		local lh1 gb2 size1 power1 
		local ls2 pe0 pe1 or2 rt2 a2 b2 m1 m0
		local lh2 r0 r1 rr rd or1 rt1 pe a1 b1 n1 n0
	}
	foreach j in `ls1' {
		`dlg'.main.`type'_`j'.show
	}
	foreach j in `lh1' {
		`dlg'.main.`type'_`j'.hide
	}
	
	foreach j in `ls2' {
		`dlg'.main.`type'_`j'_de.show
		`dlg'.main.`type'_`j'_ed.show
		`dlg'.main.`type'_`j'_tx.show
	}
	foreach j in `lh2' {
		`dlg'.main.`type'_`j'_de.hide
		`dlg'.main.`type'_`j'_ed.hide
		`dlg'.main.`type'_`j'_tx.hide
	}

	if ("`co'"!="") {
		`dlg'.main.`type'_size1.seton
	}
	if ("`co'"!="") {
		`dlg'.main.`type'_size2.seton
	}
	onOff, clsname(`clsname') size

	`dlg'.co2rOnOff.settrue
	
end


program define get_nsize, rclass
	syntax anything, type(string) [alpha(numlist) beta(numlist) r(numlist) lim(numlist) PD(numlist) means(numlist) n(numlist)]

	if ("`type'"!="cokm" & "`type'"!="ci1p" & "`type'"!="ci2p" & 	/*
	*/	"`type'"!="ci1m" & "`type'"!="ci2m") {
		local za = invnormal((100-`alpha')/100)
		local zb = invnormal((100-`beta')/100)
	}
	tokenize `anything'
	if ("`type'"=="co1p" | "`type'" == "co2p") {
		if ("`type'"=="co1p") local p `1'
		if ("`type'"=="co2p") local p0 `1'
		local p1 `2'
		local effect `3'
		if ("`type'"=="co1p") {
			local na = ceil((`za'+`zb')^2/(4*(asin(sqrt(`p1'))-asin(sqrt(`p')))^2))
			local nn = ceil((`za'*sqrt(`p'*(1-`p'))+`zb'*sqrt(`p1'*(1-`p1')))^2/((`effect')^2))
			local nc = ceil(`nn'+ 2/abs(`effect'))
			return scalar warn = ((`nn'*`p1')<10 | (`nn'*(1-`p1'))<10 | (`nn'*`p')<10 | (`nn'*(1-`p'))<10)
		}
		if ("`type'" == "co2p") {
			local n1 = `za'*sqrt(2*((`p1'+`p0')/2)*(1-((`p1'+`p0')/2)))
			local n2 = `zb'*sqrt((`p0'*(1-`p0')) + (`p1'*(1-`p1')))
			local na = ceil(2*(`za'+`zb')^2/(4*(asin(sqrt(`p1'))-asin(sqrt(`p0')))^2))
			local nn = ceil((`n1'+`n2')^2/(`effect')^2)
			local nc = ceil(`nn' + 2/(abs(`effect')))
			return scalar warn = ((`nn'*`p1')<10 | (`nn'*(1-`p1'))<10 | (`nn'*`p0')<10 | (`nn'*(1-`p0'))<10)
		}
		return scalar nn = `nn'
		return scalar nc = `nc'
		return scalar na = `na'
	}
	if ("`type'" == "c1pe" | "`type'" == "c2pe") {
		local p0 `1'
		local p1 `2'
		local delta `3'
		if (`lim'==3) local zb = invnormal((100-`beta'/2)/100)				//Equivalence
		if ("`type'" == "c1pe") {
			*One Single proportion vs reference; p.156-163 (32-34) Ene3.0 manual
			*(?) Chow, Shao y Wang, 2008, 4.1.3 (p.86) & 4.1.4 (p.87): these equations are a particular case, use
			*the Ene3.0 more general ones
			if (`lim'==3 & `p0'>=`p1') local delta = abs(`delta')
			if (`lim'==3 & `p0'<`p1') local delta = -abs(`delta')
			local num1 = sqrt((`p0'+`delta')*(1-(`p0'+`delta')))
			local num2 = sqrt(`p1'*(1-`p1'))
			local n = ((`za'*`num1'+`zb'*`num2')/(abs(`p1'-(`p0'+`delta'))))
			return scalar n  = ceil(`n'^2)
		}
		if ("`type'" == "c2pe") {
			*Two proportions; p.163-171 (examples 35-37) Ene3.0 manual
			*Chow, Shao y Wang, 2008, 4.2.3 (p.90) & 4.2.4 (p.91) same equations as Ene3.0
			if (`lim'==1 | `lim'==2) {
				*Non-Inferiority/Superiority: p.165 & 168 Ene3.0 manual
				local n = ((`za'+`zb')^2*(`p0'*(1-`p0')/`r'+`p1'*(1-`p1')))/(abs(`p1'-`p0')-`delta')^2
			}
			if (`lim'==3) {
				*Equivalence: p.171 Ene3.0 manual
				local n = ((`za'+`zb')^2*(`p0'*(1-`p0')/`r'+`p1'*(1-`p1')))/(abs(`delta')-abs(`p1'-`p0'))^2
			}
			local n1 = ceil(`n')
			if (mod(`r',1)==0) local n0 = `r'*`n1'
			else local n0 = ceil(`r'*`n')
			return scalar n1 = `n1'
			return scalar n0 = `n0'
			return scalar n = `n1' + `n0'

		}
	}
	if ("`type'" == "copp") {
		local or `1'
		tempname res
		*Discordant pairs (Nd)
		local nd = ((`za'*(`or'+1)+2*`zb'*sqrt(`or'))/(`or'-1))^2		//Normal (Schlesselman)
		local nc= `nd' + 2*(`or'+1)/(`or'-1)							//Continuity correction
		matrix `res' = (`nd' \ `nc')
		if (`r'>1) {
			*Matched results
			local nd_cases = `nd'*(`r'+1)/(2*`r')		//Normal (Schlesselman)
			local nd_contr = `r'*`nd_cases'
			local nc_cases = `nc'*(`r'+1)/(2*`r')		//Continuity correction
			local nc_contr= `r'*`nc_cases'
			matrix `res' = (`nd_cases' \ `nd_contr' \ `nc_cases' \ `nc_contr')
		}
		if ("`pd'"!="") {
			*Discordant pairs: Connett
			local nd_con = (`za'*sqrt(`or'+1)+`zb'*sqrt(`or'+1 -((`or'-1)^2)*`pd'/(`or'+1)))^2/((`or'-1)^2/(`or'+1))
			local l = "`l' nd_con"
			*Total pairs (N)
			if (`r'==1) {
				local n = `nd'/`pd'
				local ndc = `nc'/`pd'
				local ncon = `nd_con'/`pd'
				matrix `res' = (`nd' \ `n' \ `nc' \ `ndc' \ `nd_con' \ `ncon')
			}
			else {
				local n_cases = ceil(`nd_cases'/`pd')		//Normal (Schlesselman)
				local n_contr = `r'*`n_cases'
				local ndc_cases = ceil(`nc_cases'/`pd')		//Continuity correction
				local ndc_contr = `r'*`ndc_cases'
				local ndcon_cases = `nd_con'*(`r'+1)/(2*`r')		//Connett
				local ndcon_contr = `r'*`ndcon_cases'
				local ncon_cases = ceil(`ndcon_cases'/`pd')
				local ncon_contr = `r'*`ncon_cases'
				matrix `res' = (`nd_cases' \ `nd_contr' \ `n_cases' \ `n_contr' \ 			///
								`nc_cases' \ `nc_contr' \ `ndc_cases' \ `ndc_contr' \ 		///
								`ndcon_cases' \ `ndcon_contr' \ `ncon_cases' \ `ncon_contr')
			}
		}
		local len = rowsof(`res')
		foreach i of numlist 1/`len' {
			matrix `res'[`i',1] = ceil(`res'[`i',1])
		}
		return matrix result = `res'
	}
	if ("`type'" == "co1m" | "`type'" == "co2m" | "`type'" == "c2me") {
		local sd `1'
		local effect `2'		//effect is eqlim for type=c2me
		if ("`type'" == "c2me") local eqlim `2'
		if ("`type'" == "co1m" | "`type'" == "c2me") {
			local i = cond("`type'"=="co1m",1,2)
			local n = ceil(`i'*(`sd'^2)*(`za'+`zb')^2/(`effect')^2)
			
			* (v1.3.0) obtain results using Student's T, using invnormal n as df
			local ta = invttail((`i'*`n')-`i',(100-`alpha')/100)
			local tb = invttail((`i'*`n')-`i',(100-`beta')/100)
			local n = ceil(`i'*(`sd'^2)*(`ta'+`tb')^2/(`effect')^2)
			
			return scalar n = `n'
			return scalar warn = (`n'<30)
		}
		if ("`type'" == "co2m") {
			local n1 = (`r'+1)*(`sd'^2)*(`za'+`zb')^2/(`r'*(`effect')^2)
			if (mod(`r',1)==0) local n0 = ceil(`n1')*`r'
			else local n0 = ceil(`n1'*`r')
			local n1 = ceil(`n1')
			local n = `n1'+`n0'
			
			* (v1.3.0) obtain results using Student's T, using invnormal n as df
			local ta = invttail(`n'-2,(100-`alpha')/100)
			local tb = invttail(`n'-2,(100-`beta')/100)
			local n1 = (`r'+1)*(`sd'^2)*(`ta'+`tb')^2/(`r'*(`effect')^2)
			if (mod(`r',1)==0) local n0 = ceil(`n1')*`r'
			else local n0 = ceil(`n1'*`r')
			local n1 = ceil(`n1')
			
			* stored results
			return scalar n1 = `n1'
			return scalar n0 = `n0'
			return scalar n = `n1'+`n0'
			return scalar warn = (`n1'<30 | `n0'<30)
		}
	}
	if ("`type'" == "cokm") {
		tempname coef r result
		local warning 0
		local sd `1'
		if ("`means'"!="") {
			*SIMULTANEOUS COMPARISONS
			local i : list sizeof means
			local s 0
			foreach mi of numlist `means' {
				local s = `s' + `mi'
			}
			local m = `s' / `i'
			local d 0
			foreach mi of numlist `means' {
				local d = `d' + (`mi'-`m')^2/(`sd'^2)
			}
			*The coef values come from numeric results
			matrix define `coef' = ((7.849, 8.976, 10.507, 11.679, 13.048, 14.879) \		///
									(9.635, 10.923, 12.654, 13.881, 15.403, 17.427) \		///
									(10.903, 12.301, 14.171, 15.458, 17.087, 19.247) \		///
									(11.935, 13.422, 15.405, 16.749, 18.466, 20.737) \		///
									(12.828, 14.391, 16.469, 17.869, 19.661, 22.028) \		///
									(13.624, 15.255, 17.419, 18.872, 20.731, 23.182) \		///
									(14.351, 16.042, 18.284, 19.787, 21.707, 24.235) \		///
									(15.022, 16.770, 19.083, 20.635, 22.611, 25.211) \		///
									(15.650, 17.460, 19.829, 21.429, 23.457, 26.123) \		///
									(16.241, 18.090, 20.532, 22.177, 24.254, 26.982) \		///
									(16.802, 18.697, 21.198, 22.886, 25.011, 27.798))
			matrix `r' = `coef'[`i'-1,1..6]		//Get the coefs for the number of means
			foreach i of numlist 1/6 {
				local v = `r'[1,`i']
				local n = int(1+`v'/`d')
				if (`i'==1) matrix `result' = (`n')
				else matrix `result' = (`result', `n')
			}
		}
		else {
			*PAIRWISE COMPARISONS: ALPHA and BETA by default
			local c `2'
			local effect `3'
			local lfirst 1
			foreach a of numlist 5 1 {
				foreach b of numlist 20 15 10 {
					local za = invnormal((100-`a'/(2*`c'))/100)
					local zb = invnormal((100-`b')/100)
					local n = ceil(2*(`sd'^2)*(`za'+`zb')^2/(`effect')^2)
					if (`lfirst') matrix `result' = (`n')
					else matrix `result' = (`result', `n')
					local lfirst 0
					if (`n'<30) local warning 1
				}
			}
			return scalar warning  = `warning'
		}
		return matrix result = `result'
	}
	if ("`type'"=="ci1p" | "`type'"=="ci1m") {
		if ("`type'"=="ci1p") {
			local p0 `1'
			local a `2'
			local c `3'
		}
		if ("`type'"=="ci1m") {
			local sd `1'
			local a `2'
			local c `3'
		}
		local z = invnormal((`c'+100)/200)
		if ("`type'"=="ci1p") local nsize = ((`z'^2)*(`p0'/100)*(1-(`p0'/100)))/((`a'/100)^2)
		if ("`type'"=="ci1m") local nsize = ((`z'*`sd')/`a')^2
		if ("`n'"!="") local nsize = `nsize'/(1+`nsize'/`n')
		return scalar n = ceil(`nsize')
	}
	if ("`type'"=="ci2p" | "`type'"=="ci2m") {
		if ("`type'"=="ci2p") {
			local p0 `1'
			local p1 `2'
			local a `3'
			local c `4'
		}
		if ("`type'"=="ci2m") {
			local sd `1'
			local a `2'
			local c `3'
		}
		local z = invnormal((`c'+100)/200)
		if ("`type'"=="ci2p") local n1 = (`z'/`a')^2*((`r'*`p0'*(100-`p0')+`p1'*(100-`p1'))/`r')
		if ("`type'"=="ci2m") local n1 = (((`z'*`sd')/`a')^2)*((`r'+1)/`r')
		if (mod(`r',1)==0) local n0 = ceil(`n1')*`r'
		else local n0 = `r'*`n1'
		return scalar n1 = ceil(`n1')
		return scalar n0 = ceil(`n0')
		return scalar n = ceil(`n0')+ceil(`n1')
	}
	if ("`type'"=="co1c" | "`type'"=="co2c") {
		local r `1'
		local r1 `2'
		*Sinusual inverse exact probability of Fisher (Arcosinus method)
		local onetwo = cond("`type'" == "co2c",2,1)
		return scalar n= ceil(`onetwo'*((`za'+`zb')/(0.5*ln((1+`r')/(1-`r'))-0.5*ln((1+`r1')/(1-`r1'))))^2 + 3)
	}
	if ("`type'"=="ncr") {
		local v `1'
		local effect `2'
		local n = 2*`v'*(`za'+`zb')^2/`effect'^2
		local nc = `n'*(trunc(`n')+3)/(trunc(`n')+1)
		return scalar n = ceil(`n')
		return scalar nc = ceil(`nc')
	}
	if ("`type'"=="co2r") {
		local p0 `1'
		local p1 `2'
		local r `3'
		local rd `4'
		*Sinusual inverse exact probability of Fisher (Arcosinus method)
		local n1a = ceil((`r'+1)*(`za'+`zb')^2/((4*`r')*(asin(sqrt((`p0'+`rd')/100))-asin(sqrt(`p0'/100)))^2))
		local n0a = ceil(`r'*`n1a')
		return scalar n1a = `n1a'
		return scalar n0a = `n0a'
		return scalar na = `n1a' + `n0a'
		*Normal method
		local ppond = (`p1'/100+`r'*`p0'/100)/(`r'+1)
		local t1 = `za'*sqrt((`r'+1)*`ppond'*(1-`ppond'))
		local t2 = `zb'*sqrt((`p0'/100*(100-`p0')/100)+`r'*(`p1'/100*(100-`p1')/100))
		local n1n = ceil((`t1'+`t2')^2 / (`r'*(`rd'/100)^2))
		local n0n = ceil(`n1n'*`r')
		return scalar n1n = `n1n'
		return scalar n0n = `n0n'
		return scalar nn = `n1n' + `n0n'
		return scalar warning = ((`n1n'*`p1'/100)<10 | (`n1n'*(1-`p1'/100))<10 | (`n0n'*`p0'/100)<10 | (`n0n'*(1-`p0'/100))<10)
		*Normal method with Fleiss correction
		local n1f = ceil(`n1n' + (`r'+1)/(`r'*abs(`rd'/100)))
		local n0f = ceil(`n1f'*`r')
		return scalar n1f = `n1f'
		return scalar n0f = `n0f'
		return scalar nf = `n1f' + `n0f'
	}
	if ("`type'"=="co2i") {
		local i0 `1'
		local i1 `2'
		local d `3'
		local id `4'
		*Sinusual inverse exact probability of Fisher (Arcosinus method)
		local darcs = 4*`r'*`d'*(asin(sqrt(`i1'))-asin(sqrt(`i0')))^2
		local n1a = (`r'+1)*(`za'+`zb')^2/`darcs'
		if (mod(`r',1)==0) local n0a =`r'*ceil(`n1a')
		else local n0a = `r'*`n1a'
		*Normal method
		local i = (`i1'+`r'*`i0')/(`r'+1)
		local dnorm = `r'*`d'*(`id')^2
		local t1 = `za'*sqrt((`r'+1)*`i')
		local t2 = `zb'*sqrt(`i0'+`r'*`i1')
		local n1n = (`t1'+`t2')^2 / `dnorm'
		if (mod(`r',1)==0) local n0n = `r'*ceil(`n1n')
		else local n0n = `r'*`n1n'
		return scalar warning = ((`n1n'*`i1'*`d')<10 | (`n1n'*(1-`i1'*`d'))<10 | (`n0n'*`i0'*`d')<10 | (`n0n'*(1-`i0'*`d'))<10)
		*Normal method with Fleiss correction
		local n1f = `n1n' + (`r'+1)/(`r'*`d'*abs(`id'))
		if (mod(`r',1)==0) local n0f = `r'*ceil(`n1f')
		else local n0f = `r'*`n1f'
		foreach v in n0a n1a n0n n1n n0f n1f {
			local `v' = ceil(``v'')
			return scalar `v'  = ``v''
		}
		return scalar na  = `n0a' + `n1a'
		return scalar nn  = `n0n' + `n1n'
		return scalar nf  = `n0f' + `n1f'
	}
end

program define get_power, rclass
	syntax anything, type(string) [alpha(numlist) lim(numlist) means(numlist) nk(numlist)]

	if ("`type'"!="cokm" & "`type'"!="ci1p" & "`type'"!="ci2p" & /*
	*/	"`type'"!="ci1m" & "`type'"!="ci2m") {
		local za = invnormal((100-`alpha')/100)
	}
	tokenize `anything'
	if ("`type'"=="co1p" | "`type'"=="co2p") {
		if ("`type'"=="co1p") local p `1'
		if ("`type'"=="co2p") local p0 `1'
		local p1 `2'
		local effect `3'
		local n `4'
		if ("`type'"=="co1p") {
			local n0 = sqrt(`p'*(1-`p'))
			local n1 = sqrt(`p1'*(1-`p1'))
			return scalar warn = ((`n'*`p1')<10 | (`n'*(1-`p1'))<10 | (`n'*`p')<10 | (`n'*(1-`p'))<10)
		}
		else {
			local n0 = sqrt(2*((`p1' + `p0')/2)*(1-((`p1' + `p0')/2)))
			local n1 = sqrt((`p0')*(1-`p0') + (`p1')*(1-`p1'))
			return scalar warn = ((`n'*`p0')<10 | (`n'*(1-`p0'))<10 | (`n'*`p1')<10 | (`n'*(1-`p1'))<10)
		}
		return scalar pn = 100-((1-normal((sqrt(`n'*((`effect')^2)) - `za'*`n0')/`n1'))*100)
		return scalar pc= 100-((1-normal((sqrt((`n'-2/abs(`effect'))*((`effect')^2)) - `za'*`n0')/`n1'))*100)
		if ("`type'"=="co1p") return scalar pa = 100-((1-normal(sqrt((`n'*4*(asin(sqrt(`p1'))-asin(sqrt(`p')))^2)) - `za'))*100)
		if ("`type'"=="co2p") return scalar pa = 100-((1-normal(sqrt((`n'*4*(asin(sqrt(`p1'))-asin(sqrt(`p0')))^2)/2) - `za'))*100)
	}
	if ("`type'"=="c1pe" | "`type'"=="c2pe") {
		local p0 `1'
		local p1 `2'
		local delta `3'
		if ("`type'"=="c1pe") {
			local n `4'
			local p = normal((sqrt(`n')*abs(`p1'-(`p0'+`delta'))-`za'*sqrt((`p0'+`delta')*(1-(`p0'+`delta'))))/sqrt(`p1'*(1-`p1')))
			if (`lim'==3) local p = 2*`p' - 1
		}
		if ("`type'"=="c2pe") {
			local n0 `4'
			local n1 `5'
			if (`lim'==1 | `lim'==2) {
				local p = normal((abs(`p1'-`p0')-`delta')/sqrt(`p0'*(1-`p0')/`n0'+`p1'*(1-`p1')/`n1') - `za')
			}
			if (`lim'==3) {
				local p = 2*normal((abs(`delta')-abs(`p1'-`p0'))/sqrt(`p0'*(1-`p0')/`n0'+`p1'*(1-`p1')/`n1') - `za') - 1
			}
		}
		return scalar p = `p'*100
	}
	if ("`type'"=="copp") {
		local or `1'
		local n `2'
		local r `3'
		local pd `4'
		local np = `n'*2*`r'/(`r'+1)
		local zb = ((`or'-1)*sqrt(`np'*`pd'/(`or'+1))-`za'*sqrt(`or'+1))/sqrt(`or'+1-`pd'*(`or'-1)^2/(`or'+1))
		return scalar p = normal(`zb')*100
	}
	if ("`type'"=="co1m" | "`type'"=="co2m" | "`type'"=="c2me") {
		local sd `1'
		local effect `2'		//effect is eqlim for type=c2me
		local n `3'				//n is n1 for type=co2m
		local r `4'				//only for type=co2m
		local i = cond("`type'"=="co1m",1,cond("`type'"=="c2me",2,0))
		if ("`type'"=="co1m" | "`type'"=="c2me") local zb = sqrt((`n'*((`effect')^2))/(`i'*(`sd'^2))) - `za'
		if ("`type'"=="co2m") local zb = sqrt((`n'*`r'*((`effect')^2))/((`r'+1)*(`sd'^2))) - `za'
		return scalar beta = (1- normal(`zb'))*100
	}
	if ("`type'"=="cokm") {
		local sd `1'
		if ("`means'"!="") {
			*SIMULTANEOUS COMPARISONS
			tempname m n
			mata: st_matrix("`m'",strtoreal(tokens(st_local("means"))))
			mata: st_matrix("`n'",strtoreal(tokens(st_local("nk"))))
			mata: st_local("ns",strofreal(rowsum(st_matrix("`n'"))))
			mata: st_local("ms",strofreal(rowsum(st_matrix("`m'") :* st_matrix("`n'"))))
			local t = `ms' / `ns'
			local d 0
			local len = colsof(`m')
			foreach i of numlist 1/`len' {
				local mi = `m'[1,`i']
				local ni = `n'[1,`i']
				local d = `d' + `ni'*(`mi'-`t')^2/(`sd'^2)
			}
			return scalar p1 = nFtail(`len'-1,`ns'-`len',`d',invF(`len'-1,`ns'-`len',1-0.01))*100
			return scalar p5 = nFtail(`len'-1,`ns'-`len',`d',invF(`len'-1,`ns'-`len',1-0.05))*100
		}
		else {
			*PAIRWISE COMPARISONS
			local c `2'
			local effect `3'
			local d = sqrt(`nk'*`effect'^2/(2*(`sd'^2)))
			foreach i of numlist 1 5 {
				local zb = `d' - invnormal(1-(`i'/100)/(2*`c'))
				return scalar p`i'= 100 - ((1 - normal(`zb'))*100)
			}
		}
	}
	if ("`type'"=="ci1p" | "`type'"=="ci1m") {
		if ("`type'"=="ci1p") local p `1'
		if ("`type'"=="ci1m") local sd `1'
		local n `2'
		local cl `3'
		local z = invnormal((`cl'+100)/200)
		if ("`nk'"!="") local n = `n'/(1-(`n'/`nk'))		//Population not INFINITE
		if ("`type'"=="ci1p") return scalar p = `z'*sqrt((`p'/100)*(1-(`p'/100))/`n')*100
		if ("`type'"=="ci1m") return scalar p = (`z'*`sd')/sqrt(`n')
	}
	if ("`type'"=="ci2p") {
		local p0 `1'
		local p1 `2'
		local n1 `3'
		local r `4'
		local cl `5'
		local z = invnormal((`cl'+100)/200)
		return scalar p = `z'*sqrt((`r'*`p0'*(100-`p0')+`p1'*(100-`p1'))/(`r'*`n1'))
	}
	if ("`type'"=="ci2m") {
		local sd `1'
		local n1 `2'
		local r `3'
		local cl `4'
		local z = invnormal((`cl'+100)/200)
		return scalar p = (`z'*`sd')*sqrt((`r'+1)/(`r'*`n1'))
	}
	if ("`type'"=="co1c" | "`type'"=="co2c") {
		local r `1'
		local r1 `2'
		local n1 `3'
		local n0 `4'
		local fzr0 = 0.5*ln((1+`r')/(1-`r'))
		local fzr1 = 0.5*ln((1+`r1')/(1-`r1'))
		if ("`type'"=="co1c") local t = (`fzr1'-`fzr0')/sqrt(1/(`n1'-3))
		if ("`type'"=="co2c") local t = (`fzr1'-`fzr0')/sqrt(1/(`n0'-3)+ 1/(`n1'-3))
		local zb = abs(`t')-`za'
		return scalar p = normal(`zb')*100
	}
	if ("`type'"=="co2r") {
		local p0 `1'
		local p1 `2'
		local r `3'
		local rd `4'
		local n1 `5'
		*Sinusual inverse exact probability of Fisher (Arcosinus method)
		local darcs = (4*`r')*(asin(sqrt((`p0'+`rd')/100))-asin(sqrt(`p0'/100)))^2
		return scalar pa = 100-((1-normal(sqrt((`n1'*`darcs')/(`r' + 1)) - `za'))*100)
		*Normal method
		local ppond = (`p1'/100+`r'*`p0'/100)/(`r'+1)
		local dnorm = `r'*(`rd'/100)^2
		local t1 = sqrt((`r'+1)*`ppond'*(1-`ppond'))
		local t2 = sqrt((`p0'/100*(100-`p0')/100)+`r'*(`p1'/100*(100-`p1')/100))
		return scalar pn = 100-((1-normal((sqrt(`n1'*`dnorm') - `za'*`t1')/`t2'))*100)
		*Normal method with Fleiss correction
		local fleiss= (`r'+1)/(`r'*abs(`rd'/100))
		return scalar pf = 100-((1-normal((sqrt((`n1'-`fleiss')*`dnorm') - `za'*`t1')/`t2'))*100)
	}
	if ("`type'"=="co2i") {
		local i0 `1'
		local i1 `2'
		local r `3'
		local d `4'
		local id `5'
		local n1 `6'
		*Sinusual inverse exact probability of Fisher (Arcosinus method)
		local darcs = 4*`r'*`d'*(asin(sqrt(`i1'))-asin(sqrt(`i0')))^2
		return scalar pa = 100-((1-normal(sqrt((`n1'*`darcs')/(`r' + 1)) - `za'))*100)
		*Normal method
		local i = (`i1'+`r'*`i0')/(`r'+1)
		local dnorm = `r'*`d'*(`id')^2
		local t1 = sqrt((`r'+1)*`i')
		local t2 = sqrt(`i0'+`r'*`i1')
		return scalar pn = 100-((1-normal((sqrt(`n1'*`dnorm') - `za'*`t1')/`t2'))*100)
		*Normal method with Fleiss correction
		local fleiss= (`r'+1)/(`r'*`d'*abs(`id'))
		return scalar pf=100-((1-normal((sqrt((`n1'-`fleiss')*`dnorm') - `za'*`t1')/`t2'))*100)
	}
end

program define get_effect, rclass
	syntax anything, type(string) alpha(real) beta(real)

	local za = invnormal((100-`alpha')/100)
	local zb = invnormal((100-`beta')/100)
	tokenize `anything'
	if ("`type'"=="co1m" | "`type'"=="c2me") {
		local sd `1'
		local n `2'
		if ("`type'" == "co1m") return scalar effect = (`za'+`zb')*sqrt(`sd'^2/`n')
		if ("`type'" == "c2me") return scalar effect = `sd'*(`za'+`zb')*sqrt(2/`n')
	}
	if ("`type'"=="co2m") {
		local sd `1'
		local n1 `2'
		local r `3'
		return scalar effect = `sd'*(`za'+`zb')*sqrt((`r'+1)/(`r'*`n1'))
	}
end
