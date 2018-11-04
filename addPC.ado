*! version 1.0.0  07apr2015 R. Sesma

/*
add PC location to alumni data
*/

program define addPC
	version 12
	syntax anything, dir(string)

	tokenize `anything'
	local p `1'
	local g `2'
	
	cd "`dir'"
	quietly{
		import excel "`g'.xlsx", sheet("PC") firstrow clear
		save "`g'_PC.dta", replace

		import excel "`g'.xlsx", sheet("datos") firstrow clear
		drop puntuacion 
		rename (curso dni) (Grupo DNI)
		generate Curso = substr(Grupo,1,3)
		generate Periodo = "`p'"
		generate CLASE = .
		merge 1:1 Grupo DNI using "`g'_PC.dta", nogenerate noreport

		order Periodo Curso DNI Grupo PC nombre apellido CLASE provincia población trabajo
		keep if PC<.
		sort PC
		export excel using "`g'.xlsx", sheet("datos_pc") firstrow(variables)

		erase "`g'_PC.dta"
	}
	
	di "Proceso finalizado"
end
