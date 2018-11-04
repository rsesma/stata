*! version 0.0.1  ?sep2018
program pecs
	version 15
	gettoken subcmd 0 : 0
	`subcmd' `0'
end

program define import
	version 15
	syntax [anything], zip(string) sol(string) [clear]

	if (!c(changed) | (c(changed) & ("`clear'"!=""))) {
		qui clear
		
		javacall com.leam.stata.pecs.CorregirPECs extractZIP, args(`"`zip'"')       ///
				jars(pecs.jar;itextpdf-5.5.10.jar)
		
		javacall com.leam.stata.pecs.CorregirPECs getPECData, args(`"`zip'"' `"`sol'"')       ///
				jars(pecs.jar;itextpdf-5.5.10.jar)
	}
	else {
		display in red "no; data in memory would be lost" 
		exit 198
	}
end

program define analyze
	version 15
	syntax [anything], sol(string) [clear]

	if (!c(changed) | (c(changed) & ("`clear'"!=""))) {
		qui clear
		
		javacall com.leam.stata.pecs.CorregirPECs Analyze, args(`"`sol'"')       ///
				jars(pecs.jar)		
	}
	else {
		display in red "no; data in memory would be lost" 
		exit 198
	}
end

program define getPercent
	version 15
	syntax anything

	local n `anything'
quietly{
	preserve
	keep *`n'
	drop c`n'
	rename (`n' p`n') (value percent)
	drop if missing(percent)
	gsort -percent
	mata: v`n' = st_sdata(.,"value")
	mata: p`n' = st_data(.,"percent")
	restore
}
end

program define freq
	version 15
	syntax [anything]

quietly{
	rename Respostes R
	reshape wide R, i(DNI) j(Pregunta) string
	rename (RP*) (P*)
	drop DNI

	local nvars = c(k)
	
	foreach v of varlist * {
		gen str u`v' = ""
		gen c`v' = .
		
		local i 1
		levelsof `v', local(d)
		foreach val in `d' {
			replace u`v' = "`val'" in `i'
			count if (`v'=="`val'")
			replace c`v' = r(N) in `i'
			local i = `i'+1
		}
		gen p`v' = 100 * (c`v' / _N)
		format p`v' %5.1f
	}
	
	drop P*
	rename (uP*) (P*)
	egen float NMiss = rowmiss(pP*)
	
	drop if (NMiss == `nvars')
	drop NMiss
}
end
