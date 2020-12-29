*! version 0.0.3  29dec2020
program pecs
	version 15

	if ("`c(os)'" == "Windows") {
		global dir = "C:\CorregirPECs"
		global PEC1 = "C:\CorregirPECs\ST1\PEC1"
		global mv = "move"
		global reader = "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"
	}
	global originales = "originales"
	global corregidas = "corregidas"
	global sintaxis = "sintaxis"

	gettoken subcmd 0 : 0
	`subcmd' `0'
end

program define open
	version 15
	syntax [anything], [dni(string)]

	* abrir el archivo de datos
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) {
			use "$dir/`f'", clear
		}
	}
	* obtener el periodo, el curso y la PEC
	local p = periodo[1]
	local curso = curso[1]
	if ("`curso'"=="ST1") local pec = "PEC2"
	if ("`curso'"=="ST2") local pec = "PEC1"
	* recorrer la matriz y encontrar el primer no corregido
	local ldni 0
	local found = 0
	local Ntotal = _N
	foreach i of numlist 1/`Ntotal' {
		local obs = 0
		if ("`dni'"=="") {
			if (correg[`i']==0 & entrega[`i']==1) {
				local obs = `i'
			}
		}
		else {
			local ldni 1
			if (DNI[`i']=="`dni'") {
				local obs = `i'
			}
		}
		if (`obs'>0) {
			local dni = DNI[`obs']
			local nom = nomcomp[`obs']
			local found = 1
			* marcar como corregida
			qui replace correg = 1 in `i'
			qui save, replace

			continue, break
		}
	}
	if (`found') {
		* nombre del archivo
		local name "`pec'_`curso'_`dni'.pdf"
		* ruta del archivo original
		mata: st_local("orig", pathjoin(st_global("dir"),st_local("curso")))
		mata: st_local("orig", pathjoin(st_local("orig"),st_local("pec")))
		mata: st_local("orig", pathjoin(st_local("orig"),st_global("originales")))
		mata: st_local("orig", pathjoin(st_local("orig"),st_local("name")))
		* ruta del archivo corregido
		mata: st_local("corr", pathjoin(st_global("dir"),st_local("curso")))
		mata: st_local("corr", pathjoin(st_local("corr"),st_local("pec")))
		mata: st_local("corr", pathjoin(st_local("corr"),st_global("corregidas")))
		mata: st_local("corr", pathjoin(st_local("corr"),st_local("name")))
		* mover el pdf con el SO
		shell $mv `orig' `corr'
		* abrir el pdf con winexec
		winexec "$reader" "`corr'"
		* ruta del archivo sintaxis
		local name "`dni'.do"
		mata: st_local("sint", pathjoin(st_global("dir"),st_local("curso")))
		mata: st_local("sint", pathjoin(st_local("sint"),st_local("pec")))
		mata: st_local("sint", pathjoin(st_local("sint"),st_global("sintaxis")))
		mata: st_local("sint", pathjoin(st_local("sint"),st_local("name")))
		* abrir el archivo de sintaxis
		doedit "`sint'"
		* output de progreso
		qui count if (entrega==1)
		local ntot = r(N)
		qui count if (correg==1)
		local corr = r(N)
		if (!`ldni') di as res "Corrigiendo PEC `corr' de `ntot' (`dni' `nom')"
		if (`ldni') di as res "Corrigiendo PEC `dni' (`nom')"
	}
	else {
		di as res "No hay más PECs"
	}
end

program define nota
	version 15
	syntax [anything], [dni(string)]

	* obtener los nombres de los archivos de datos y solución
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) local dta = "`f'"
		if (strpos("`f'","sol")>0) local sol = "`f'"
	}
	* abrir el archivo de datos
	use "$dir/`dta'", clear
	
	* si la variable NOTA no existe, la creamos
	capture confirm variable NOTA, exact
	if (_rc > 0) gen NOTA = ., after(PEC)

	* obtener el periodo, el curso y la PEC
	local p = periodo[1]
	local curso = curso[1]
	if ("`curso'"=="ST1") local pec = "PEC2"
	if ("`curso'"=="ST2") local pec = "PEC1"
	* recorrer la matriz y encontrar el último corregido o el dni proporcionado
	local found = 0
	local Ntotal = _N
	foreach i of numlist 1/`Ntotal' {
		local obs = 0
		if ("`dni'"=="") {
			if (correg[`i']==1 & PEC[`i']>=.) {
				local obs = `i'
			}
		}
		else {
			if (DNI[`i']=="`dni'") {
				local obs = `i'
			}
		}
		if (`obs'>0) {
			local dni = DNI[`obs']
			local nom = nombre[`obs'] + " " + ape1[`obs'] + " " + ape2[`obs']
			local found = 1

			continue, break
		}
	}
	if (`found') {
		* datos solución
		frame create sol
		frame sol: use "$dir/`sol'", clear

		* ruta del archivo corregido
		local name "`pec'_`curso'_`dni'.pdf"
		mata: st_local("file", pathjoin(st_global("dir"),st_local("curso")))
		mata: st_local("file", pathjoin(st_local("file"),st_local("pec")))
		mata: st_local("file", pathjoin(st_local("file"),st_global("corregidas")))
		mata: st_local("file", pathjoin(st_local("file"),st_local("name")))

		javacall com.leam.stata.pecs.StataPECs getNota, args(`"`file'"' `"`obs'"')       ///
				jars(statapecs.jar)

		frame drop sol				// eliminar el frame solución

		* calcular nota
		quietly{
			capture drop sum
			qui egen sum = rowtotal(w*_*), missing
			qui replace PEC = round(10 * (sum/wtot),0.1) in `obs'
			qui replace correg = 1 in `obs'
			qui count if (correg == 1)
		
			if ("`curso'"=="ST1") {
				* curso ST1: PEC1 15% + PEC2 85%
				replace NOTA = 0.15*PEC1 + 0.85*PEC in `obs'
				* sumar la nota de la PEC0, hasta un máximo de 9.5
				if (NOTA[`obs']<9.5 & PEC0[`obs']<.) replace NOTA = min(9.5, NOTA + PEC0 * 0.125) in `obs'
			}
			if ("`curso'"=="ST2") {
				* curso ST2: la nota final es la de la PEC1
				replace NOTA = PEC in `obs'
			}
			replace NOTA = round(NOTA,0.1) in `obs'
			* sumar las notas de clase para las notas al filo
			replace NOTA = 7 if (inrange(NOTA,6.6,7) & clase >=3) in `obs'
			replace NOTA = 9 if (inrange(NOTA,8.6,9) & clase >=4) in `obs'
			* EN LOS CURSOS ONLINE ESTO NO APLICA
			* las copias, los no presentados y los suspensos se convierten en 5
			*replace NOTA = 5 if (copia==1 | PEC==. | NOTA<5) in `obs'
		}
		
		di "Corregida PEC `r(N)' de " _N
		if ("`curso'"=="ST1") list DNI nomcomp clase PEC0 PEC1 PEC NOTA in `obs', noobs
		if ("`curso'"=="ST2") list DNI nomcomp clase PEC NOTA in `obs', noobs
		qui drop sum
		qui save, replace
	}
	else {
		di as res "Todo corregido"
	}
end

program define entrega
	version 15
	syntax [anything]

	* abrir el archivo de datos
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) {
			use "$dir/`f'", clear
		}
	}
	* obtener el curso de la primera fila
	local curso = curso[1]
	if ("`curso'"=="ST1") local pec = "PEC2"
	if ("`curso'"=="ST2") local pec = "PEC1"

	* ruta de la carpeta corregidas
	mata: st_local("orig", pathjoin(st_global("dir"),st_local("curso")))
	mata: st_local("orig", pathjoin(st_local("orig"),st_local("pec")))
	mata: st_local("orig", pathjoin(st_local("orig"),st_global("originales")))
	* obtener todos los pdf de la carpeta
	local files : dir "`orig'" files "*.pdf", respectcase
	foreach f in `files' {
		local dni = upper(subinstr(subinstr("`f'","`pec'_`curso'_","",.),".pdf","",.))
		qui replace entrega = 1 if (DNI=="`dni'" & curso=="`curso'")

		mata: st_local("file", pathjoin(st_local("orig"),st_local("f")))
		javacall com.leam.stata.pecs.StataPECs getHonor, args(`"`file'"' `"`dni'"')       ///
				jars(statapecs.jar)
	}
	qui replace entrega = 0 if entrega==.
	qui save, replace

	qui count if (entrega==1)
	di as res "PECs entregadas: `r(N)'"
	qui count if (entrega==1 & honor==0)
	if (`r(N)'>0) {
		di as res "PECs sin HONOR: `r(N)'"
		list grupo DNI nom ape1 ape2 email if entrega==1 & honor==0
	}
	qui count if (problema==1)
	if (`r(N)'>0) {
		di as res "PECs con problemas: `r(N)'"
		list grupo DNI nom ape1 ape2 email if problema==1
	}
end

program define getdta
	version 15
	syntax [anything], p(string) curso(string) folder(string) [online]

	cd "`folder'"

	* obtener todos los xlsx de folder
	local files : dir "`folder'" files "*.xlsx", respectcase
	local dta
	foreach f in `files' {
		* importar excel
		import excel "`f'", sheet("Exported") firstrow clear
		* renombrar, crear variables fijo+corr y diccionarios
		generate periodo = "`p'"
		if ("`online'"=="") {
			rename (Grup DNINIE Nom Cognom1 Cognom2 Nota Comentari Provincia Població Feina eMail) ///
				   (grupo DNI nombre ape1 ape2 clase coment prov pobl trabajo email)
			generate curso = substr(grupo,1,3)
			generate fijo = (Fixe=="Si")
			drop Fixe
		} 
		else {
			gen grupo = Curs + B + C
			drop B C Mòbil País
			rename (Curs DNINIE Nom Cognom1 Cognom2 Provincia Poblaciò eMail) ///
				   (curso DNI nombre ape1 ape2 prov pobl email)
			gen PC = 0
			gen fijo = 0
			gen clase = 1
			gen coment = ""
			gen trabajo = ""
		}
		gen nomcomp = ustrtrim(nombre + " " + ape1 + " " + ape2)
		generate correg = 0
		generate entrega = .
		generate honor = .
		generate problema = 0
		generate copia = 0
		generate IDcopia = .
		generate ePEC1 = .
		generate hPEC1 = .
		generate PEC = .
		label define dSiNo 0 "No" 1 "Sí"
		label values fijo correg entrega honor problema copia ePEC1 hPEC1 dSiNo
		label define dNotaClase 0 "No asiste" 1 "Aprobado" 2 "Bien" 3 "Notable" 4 "Excelente"
		label values clase dNotaClase
		* asegurar que existe una variable coment string
		local t : type coment
		if (substr("`t'",1,3)!="str") {
			drop coment
			generate coment = "", after(clase)
		}
		* ordenar las variables
		order periodo curso DNI grupo nombre ape1 ape2 nomcomp PC fijo clase  ///
		   ePEC1 hPEC1 entrega problema honor correg PEC copia IDcopia coment prov pobl trabajo email
		* mantener solo los que asistieron a clase
		keep if PC<.
		* eliminar variable labels
		foreach v of varlist * {
			label variable `v' ""
		}
		* alinear a la izquierda las vars string
		ds, has(type string)
		foreach v in `r(varlist)' {
			local type : type `v'
			local type = subinstr("`type'","str","",.)
			format `v' %-`type's
		}
		* ordenar datos y grabar dta
		sort periodo curso grupo PC DNI
		local name = grupo[1]
		save `name'.dta, replace
		local dta "`dta' `name'"
	}
	* unir en un único dta por periodo y grabar
	clear
	append using `dta'
	local file = "$dir/`p'_`curso'.dta"
	save `file', replace
end

program define addPvars
	version 15
	syntax [anything]
	* añadir las variables P

	* datos solución
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")>0) local sol = "`f'"
	}
	frame create sol
	frame sol: use "$dir/`sol'", clear

	* obtener los nombres de las preguntas
	frame sol: qui levelsof p, local(names)

	* añadir las varibles a la matriz
	foreach n in `names' {
		qui g `n' = ""
		local w = subinstr("`n'","P","w",1)
		qui g `w' = .
	}
	frame sol: qui sum w					// obtener la suma de w
	qui g wtot = `r(sum)'
	format PEC %4.1f
	frame drop sol

	save, replace
end

program define getsol
	version 15
	syntax [anything], p(string) curso(string) using(string)

	import delimited "`using'", delimiter(comma) varnames(1) clear
	drop id numopc
	rename (eti tipres rescor val) (p tipo rescor w)
	replace p = subinstr(p, "'", "", .)
	replace rescor = subinstr(rescor,"'","",.)
	generate accion = .
	label define dAccion 1 "Leer" 2 "Test" 3 "Datos" 4 "Ignorar" 5 "Grabar"
	label values accion dAccion
	generate p1 = ""
	generate p2 = ""
	generate periodo = "`p'", before(p)
	generate curso = "`curso'", after(periodo)
	save "$dir/`p'_`curso'_sol.dta", replace
end

program define sintaxis
	version 15
	syntax [anything]

	* obtener los nombres de los archivos de datos y solución
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) local dta = "`f'"
		if (strpos("`f'","sol")>0) local sol = "`f'"
	}
	* abrir el archivo de datos
	use "$dir/`dta'", clear
	local curso = curso[1]
	if ("`curso'"=="ST1") local pec = "PEC2"
	if ("`curso'"=="ST2") local pec = "PEC1"
	* abrir el archivo solución
	use "$dir/`sol'", clear

	* ruta de la carpeta originales
	mata: st_local("orig", pathjoin(st_global("dir"),st_local("curso")))
	mata: st_local("orig", pathjoin(st_local("orig"),st_local("pec")))
	mata: st_local("orig", pathjoin(st_local("orig"),st_global("originales")))
	* ruta de la carpeta sintaxis
	mata: st_local("sint", pathjoin(st_global("dir"),st_local("curso")))
	mata: st_local("sint", pathjoin(st_local("sint"),st_local("pec")))
	mata: st_local("sint", pathjoin(st_local("sint"),st_global("sintaxis")))
	* ruta de la carpeta cd
	mata: st_local("cd", pathjoin(st_global("dir"),st_local("curso")))

	javacall com.leam.stata.pecs.StataPECs getSintaxis, args(`"`orig'"' `"`sint'"' `"`cd'"')       ///
			jars(statapecs.jar)

	di as res "Proceso terminado"
end

program define buides
	version 15
	syntax [anything]

	frame copy default temp
	* datos solución
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")>0) local sol = "`f'"
	}
	frame create sol
	frame change sol
	use "$dir/`sol'", clear
	* eliminar preguntas no eval prof
	foreach i of numlist 1/`c(N)' {
		if (tipo[`i']!=1) {
			local n = p[`i']
			frame temp: drop `n'
		}
	}
	frame change temp
	foreach v of varlist P*_* {
		qui generate __`v' = (`v'=="?")
	}
	capture drop __buides
	qui egen __buides = rowtotal(__P*)
	qui drop __P*

	list DNI P*_* if __buides == 1, clean
	
	frame change default
	frame drop temp 
	frame drop sol
end

program define PEC0
	version 15
	syntax [anything]

	* obtener el nombre del archivo de datos
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) local dta = "`f'"
	}
	* abrir el archivo de datos
	use "$dir/`dta'", clear
	capture drop PEC1

	* obtener el nombre del archivo xlsx
	local files : dir "$dir" files "*.xlsx", respectcase
	foreach f in `files' {
		local xlsx = "`f'"
	}
	local name = subinstr("`xlsx'",".xlsx","",.)
	* abrir el archivo xlsx
	frame create xls
	frame xls: import excel using "$dir/`xlsx'", sheet("`name'") firstrow
	frame xls: rename Periodo periodo
	* linkar e importar PEC0
	frlink 1:1 periodo DNI, frame(xls)
	frget PEC0, from(xls)
	* deshacer vínculo y borrar xls dataset
	drop xls
	frame drop xls
	order PEC0, after(clase)

	label variable PEC0 ""
	save, replace
end

/* ABANDONADO
program define notafin
	version 15

	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) local dta = "`f'"
	}
	use "$dir/`dta'", clear
	capture drop NOTA

	quietly{
		generate NOTA = PEC, after(PEC)
		capture confirm variable PEC1
		if (_rc==0) {
			* sumar la nota de la PEC1, hasta un máximo de 9.5
			generate __plus = PEC1 * 0.125
			replace __plus = 0 if __plus == .
			replace NOTA = min(9.5, PEC + __plus) if PEC < 9.5
			drop __plus
		}
		replace NOTA = round(NOTA,0.1)
		* sumar las notas de clase para las notas al filo
		replace NOTA = 7 if (inrange(NOTA,6.6,7) & clase >=3)
		replace NOTA = 9 if (inrange(NOTA,8.6,9) & clase >=4)
		format NOTA %3.1f
		* las copias, los no presentados y los suspensos se convierten en 5
		replace NOTA = 5 if (copia==1 | PEC==. | NOTA<5)
	}
	save, replace
end

ABANDONADO
program define export_data
	version 15

	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) local dta = "`f'"
	}
	use "$dir/`dta'", clear

	quietly{
		local curso = curso[1]
		local periodo = periodo[1]
		if ("`curso'"=="ST1") {
			* exportar los datos de la PEC1
			preserve
			keep if PEC0<.
			generate t1 = substr(grupo,4,2)
			generate t2 = substr(grupo,6,2)
			local name = "`curso'_`periodo'_PEC0_datos"
			export delimited DNI curso t1 t2 PEC0 using "$dir/`name'.txt", delimiter(";") novarnames nolabel quote replace
			restore
		}
		preserve
		keep if entrega==1
		if ("`curso'"=="ST1") local name = "`curso'_`periodo'_PEC2_datos"
		if ("`curso'"=="ST2") local name = "`curso'_`periodo'_PEC1_datos"
		export delimited ape1 ape2 nombre DNI honor P*_* using "$dir/`name'.txt", delimiter(",") novarnames nolabel quote replace
		restore
	}
	di "Proceso finalizado"
end
*/

program define alumnos
	version 15
	syntax [anything], using(string)

	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) local dta = "`f'"
	}
	use "$dir/`dta'", clear

	quietly{
		drop ePEC1 hPEC1 correg honor problema R*_* T*_* P*_* w*
		save "$dir/__alumnos.dta", replace

		use "`using'", clear
		append using "$dir/__alumnos.dta"
		save, replace

		erase "$dir/__alumnos.dta"
	}
	di "Proceso finalizado"
end

program define getxlsx
	version 15
	syntax [anything], [j(integer 25)]

	* abrir el dta con los DNIs de los alumnos
	local files : dir "$dir" files "*.dta", respectcase
	foreach f in `files' {
		if (strpos("`f'","sol")==0) local dta = "`f'"
	}
	frame create semillas
	frame change semillas
	use "$dir/`dta'", clear
	keep DNI
	* generar semilla s a partir del DNI
	gen s = DNI
	* eliminar las letras del DNI
	foreach i of numlist 65/90 {
	    local c = char(`i')
	    replace s = subinstr(s,"`c'","",.)
	}
	* desempatar posibles semillas repetidas
	by s, sort: gen _t = _n
	replace s =  string(real(s) + runiformint(20,50),"%12.0f") if _t > 1
	drop _t

	* generar los archivos de excel de cada alumno a partir de los datos originales
	foreach i of numlist 1/`c(N)' {
		* DNI del alumno y semilla asociada de la tabla
		local dni = DNI[`i']
		local seed = s[`i']

	    preserve
	    import excel "$PEC1/Salud.xlsx", sheet("Salud") firstrow clear

		* modificar las variables aleatoriamente
		set seed `seed'
		replace SexFe = runiformint(0,1) in `j'/L
		replace Peso = Peso + round(runiform(-10,10),0.1) in `j'/L
		replace Talla = Talla + runiformint(-10,10) in `j'/L
		replace FN = FN + runiformint(-365,365) in `j'/L
		replace PAS = PAS + runiformint(-10,10) in `j'/L
		replace PAD = PAD + runiformint(-5,5) in `j'/L
		replace Fuma = runiformint(0,2) in `j'/L
		replace EdadF = . if Fuma==0 in `j'/L
		replace EdadF = runiformint(13,20) if Fuma>0 & Fuma<. in `j'/L
		replace Tab = 0 if Fuma<2 in `j'/L
		replace Tab = runiformint(5,40) if Fuma==2 in `j'/L
		replace H1 = runiformint(0,2) in `j'/L
		replace H2 = runiformint(0,2) in `j'/L
		replace H3 = runiformint(0,2) in `j'/L
		replace H4 = runiformint(1,3) in `j'/L
		replace H5 = runiformint(1,3) in `j'/L

		* exportar a excel
		export excel using "$PEC1/xlsx/`dni'.xlsx", sheet("Salud") firstrow(variables) replace
		di "`dni'"

		restore
	}
	frame reset
	di "Proceso finalizado"
end

program define get_results_tuto
	version 15
	syntax [anything]

	* añadir las variables para almacenar las respuestas
	foreach i of numlist 65/74 {
		local n = char(`i')
		capture drop R01_`n' T01_`n'
		qui gen double R01_`n' = .
		qui gen double T01_`n' = .
	}
	format T*_* R*_* %5.2f
	format *_F *_H %5.3f

	cd "$PEC1"

	* generar los resultados de cada alumno para sus datos personalizados
	foreach i of numlist 1/`c(N)' {
		* DNI del alumno
		local dni = DNI[`i']

		preserve
		* ejecutar sintaxis para generar dta con variables calculadas
		run Salud.do `dni'

		* obtener y almacenar resultados
		quietly {
			tabulate NivObs, matcell(F)
			local T01_A = 100 * F[3,1] / r(N)
			tabulate HabitFum, matcell(F)
			local T01_B = 100 * F[2,1] / r(N)
			tabulate H6, matcell(F)
			local T01_C = 100 * F[3,1] / r(N)
			tabulate H4 SexFe, matcell(F)
			mata: st_numscalar("T01_D", 100 * st_matrix("F")[1,2] / colsum(st_matrix("F"))[1,2])
			local T01_D = T01_D
			tabulate NivObs SexFe, matcell(F)
			mata: st_numscalar("T01_E", 100 * st_matrix("F")[2,1] / colsum(st_matrix("F"))[1,1])
			local T01_E = T01_E
			tabstat PT IMC EdadF, statistics(mean median sd) save
			matrix R = r(StatTotal)
			local T01_F = R[1,1]
			local T01_G = R[2,2]
			local T01_H = R[3,3]
			summarize Edad if SexFe == 1
			local T01_I = r(min)
			summarize Talla if SexFe == 0
			local T01_J = r(max)
		}
		restore

		* almacenar resultados en la matriz de alumnos
		quietly {
			foreach n in A B C D E G I J {
				replace T01_`n' = round(`T01_`n'',0.01) in `i'
			}
			replace T01_F = round(`T01_F',0.001) in `i'
			replace T01_H = round(`T01_H',0.001) in `i'
		}
		di "`dni' (`i' de `c(N)')"
	}
	
	save, replace
	export excel DNI T*_* using "results.xlsx", sheet("resultados") firstrow(variables) replace
	*export delimited DNI T01_* using "results.csv", delimiter(";") datafmt replace
end

program define PEC1
	version 15
	syntax [anything]

	* leer las respuestas de los alumnos de los archivos PDF
	foreach i of numlist 1/`c(N)' {
		* DNI del alumno
		local dni = DNI[`i']
		local name = "PEC1_ST1_`dni'.pdf"

		* ruta del archivo
		mata: st_local("file", pathjoin(st_global("PEC1"),"pdf"))
		mata: st_local("file", pathjoin(st_local("file"),st_local("name")))

		javacall com.leam.stata.pecs.StataPECs getPEC1, args(`"`file'"' `"`i'"' "10")       ///
				jars(statapecs.jar)
		di "`dni'"
	}

	quietly{
		* obtener resultados PEC1 comparando variables T (correctas) con R (respuestas)
		foreach n in A B C D E G I J {
			replace T01_`n' = round(T01_`n',0.01)
			replace R01_`n' = round(R01_`n',0.01)
		}
		foreach n in F H {
			replace T01_`n' = round(T01_`n',0.001)
			replace R01_`n' = round(R01_`n',0.001)
		}
		foreach n in A B C D E F G H I J {
			gen V01_`n' = (R01_`n' == T01_`n')
		}
		* calcular la nota sobre 10 sumando
		capture drop PEC1
		egen PEC1 = rowtotal(V01_*) if ePEC1==1, missing
		order PEC1, after(hPEC1)
		drop V01_*
	}

	qui count if ePEC1 == 0
	if (r(N)>0) {
		di "`r(N)' PEC1 no entregadas"
		list grupo DNI nomcomp if ePEC1 ==0, noobs sep(0)
	}

	qui count if hPEC1 == 0
	if (r(N)>0) {
		di "`r(N)' PEC1 sin HONOR"
		list grupo DNI nomcomp email if hPEC1 ==0, noobs sep(0)
	}

	qui count if ePEC1 == 1 & missing(hPEC1)
	if (r(N)>0) {
		di "`r(N)' PEC1 problemas"
		list grupo DNI nomcomp if ePEC1 == 1 & missing(hPEC1), noobs sep(0)
	}
	
	* duplicados
	di "PEC1 duplicadas"
	duplicates list R*_*
		
	* suspendidos
	list grupo DNI nomcomp PEC1 email if PEC1 < 5, noobs sep(0) N(PEC1)
	* estadística (solo aprobados)
	summarize PEC1 if PEC1 >= 5
	
	di "Proceso finalizado"

end
