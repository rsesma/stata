*! version 1.0.1  20jan2021 JM. Domenech, JB.Navarro, R. Sesma
/*
intcon: internal consistency
*/

program define intcon, rclass
	version 12
	syntax varlist(min=2 numeric) [if] [in] [aw fw pw], [Cont Ord nst(string)]

	if ("`cont'"=="" & "`ord'"=="") {
		display in red "cont and/or ord option needed"
		exit 198
	}
	local lweight = ("`weight'"!="")		// weighted call

	capture which polychoric				// verify polychoric user-command is installed for ordinal calls
	local polyok = ("`ord'"=="" | _rc==0)
	capture which alphawgt					// verify alphawgt user-command is installed for continous weighted calls
	local alphawgtok = (!`lweight' | "`cont'"=="" | _rc==0)
	if (!`polyok' | !`alphawgtok') {
		di ""
		di in red "{bf:WARNING!}"
		if (!`polyok') {
			di in red "  User-defined command {bf:polychoric} is not installed."
			di in red "  This command is necessary to compute ordinal indexes."
			di in red "  Execute {search polychoric:search polychoric} to install."
		}
		if (!`alphawgtok') {
			if (!`polyok') di ""
			di in red "  User-defined command {bf:alphawgt} is not installed."
			di in red "  This command is necessary to compute weighted continuous indexes."
			di in red "  Execute {search alphawgt:search alphawgt} to install."
		}
		exit 198
	}

	marksample touse, novarlist		//if/in: select cases

	* print title
	di as res _n "Internal Consistency"
	if ("`nst'"!="") di as txt "{bf:STUDY:} `nst'"

	* weights
	local w
	local wgt
	local pw 0
	if (`lweight') {
		local w = "[`weight' `exp']"
		local wgt = "wgt"
		if (substr("`weight'",1,1)=="p") local pw 1		// pweight?
		* aweight not allowed in sem, use iweight instead
		local ws = "`w'"
		if (`lweight' & substr("`weight'",1,1)=="a" & "`cont'"!="") local ws = "[iweight `exp']"
	}

	tempname vp sGamma sPsi se f f2 u2 p scf nm R
	if ("`cont'"!="") {
		* continuous measures
		if (`lweight' & `pw') {
			di as txt _n "{bf:WARNING!} continuous indexes can't be computed with sampling weights {cmd:[pweight]} "
		}
		else {
			* use alpha / alphawgt to compute Cronbach's alpha
			qui alpha`wgt' `varlist' if `touse' `w', asis
			local alpha = r(alpha)
			local k = r(k)			// number of items in the scale

			* Armor’s theta
			qui factor `varlist' if `touse' `w', pcf factors(1)
			matrix `vp' = e(Ev)
			local theta = (`k'/(`k'-1))*(1-1/`vp'[1,1])

			* McDonald’s omega(t)
/*			v1.0.1: change calculations to use sem 
			mata: st_numscalar("`sl'", colsum(st_matrix("e(L)")))		// sl: sum of lambdas
			mata: st_numscalar("`se'", rowsum(st_matrix("e(Psi)")))		// se: sum of errors
			local omega = `sl'^2 / (`sl'^2 + `se')*/
			qui sem (F1 -> `varlist')  if `touse' `ws', latent(F1) nocapslatent var(F1@1)
			qui estat framework, fitted
			mata: st_numscalar("`sGamma'", colsum(st_matrix("r(Gamma)")))
			mata: st_numscalar("`sPsi'", colsum(diagonal(st_matrix("r(Psi)"))))
			local omega = `sGamma'^2 / (`sGamma'^2 + `sPsi')

			* print results
			di as txt _n "Cronbach's alpha: " _col(24) as res %6.4f `alpha'
			di as txt "Armor’s theta: " _col(24) as res %6.4f `theta'
			di as txt "McDonald's omega(t): " _col(24) as res %6.4f `omega'

			* stored results
			return scalar alpha = `alpha'
			return scalar theta = `theta'
			return scalar omega = `omega'
		}
	}

	if ("`ord'"!="") {
		* ordinal measures
		qui polychoric `varlist' if `touse' `w'
		matrix `R' = r(R)
		mata: st_numscalar("`nm'", missing(st_matrix("r(R)")))
		if (`nm' > 0) {
			di as txt _n "Polychoric correlation matrix"
			matrix list r(R), noheader
			di as txt _n "{bf:WARNING!} Polychoric correlation matrix contains missing values."
			di as txt "Try to delete items that generate missing coefficients."
		}
		else {
			local n = r(N)
			qui factormat `R', n(`n') factors(1) forcepsd
			scalar `p' = rowsof(e(L))
			matrix `vp'= e(Ev)

			* alpha ordinal
			mata: st_numscalar("`f'", colsum(st_matrix("e(L)")) / st_numscalar("`p'"))
			mata: st_numscalar("`f2'", colsum(st_matrix("e(L)") :^2) / st_numscalar("`p'"))
			mata: st_numscalar("`u2'", rowsum(st_matrix("e(Psi)")) / st_numscalar("`p'"))
			local pf2 = `p' * `f'^2
			local alpha_ord = `p' / (`p' - 1) * (`pf2' - `f2') / (`pf2' + `u2')

			* omega ordinal
			mata: st_numscalar("`scf'", colsum(st_matrix("e(L)")))		// scf: sum of factorial charges
			mata: st_numscalar("`se'", rowsum(st_matrix("e(Psi)")))		// se: sum of errors
			local omega_ord = `scf'^2 / (`scf'^2 + `se')

			* theta ordinal: add pcf option to factorformat (v1.0.1)
			qui factormat `R', n(`n') pcf factors(1) forcepsd
			scalar `p' = rowsof(e(L))
			matrix `vp'= e(Ev)
			local theta_ord = (`p' / (`p' - 1))*(1-1/`vp'[1,1])

			* print results
			di as txt _n "Ordinal alpha: " _col(17) as res %6.4f `alpha_ord'
			di as txt "Ordinal theta: " _col(17) as res %6.4f `theta_ord'
			di as txt "Ordinal omega: " _col(17) as res %6.4f `omega_ord'

			* stored results
			return scalar alpha_ord = `alpha_ord'
			return scalar theta_ord = `theta_ord'
			return scalar omega_ord = `omega_ord'
		}
	}
end
