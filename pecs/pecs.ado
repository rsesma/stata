*! version 0.0.2  ?jun2020
program pecs
	version 15

	if ("`c(os)'" == "Windows") {
		global dir = "C:\CorregirPECs"
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
			if (DNI[`i']=="`dni'") {
				local obs = `i'
			}
		}
		if (`obs'>0) {
			local dni = DNI[`obs']
			local nom = nombre[`obs'] + " " + ape1[`obs'] + " " + ape2[`obs']
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
		if ("`dni'"=="") di as res "Corrigiendo PEC `corr' de `ntot' (`dni' `nom')"
		if ("`dni'"!="") di as res "Corrigiendo PEC `dni' (`nom')"
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
		capture drop sum
		qui egen sum = rowtotal(w*_*), missing
		qui replace PEC = 10 * (sum/wtot) in `obs'
		qui replace correg = 1 in `obs'
		list DNI nombre ape1 ape2 PC clase PEC in `obs'
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
		list grupo DNI nom ape1 ape2 email if problema==0
	}
end

program define getdta
	version 15
	syntax [anything], p(string) folder(string)

	cd "`folder'"

	* obtener todos los xlsx de folder
	local files : dir "`folder'" files "*.xlsx", respectcase
	local dta
	foreach f in `files' {
		* importar excel
		import excel "`f'", sheet("Exported") firstrow clear
		* renombrar, crear variables fijo+corr y diccionarios
		generate periodo = "`p'"
		rename (Grup DNINIE Nom Cognom1 Cognom2 Nota Comentari Provincia Població Feina eMail) ///
			   (grupo DNI nombre ape1 ape2 clase coment prov pobl trabajo email)
		generate curso = substr(grupo,1,3)
		generate fijo = (Fixe=="Si")
		drop Fixe
		generate correg = 0
		generate entrega = .
		generate honor = .
		generate problema = 0
		generate PEC = .
		generate copia = 0
		generate IDcopia = .
		label define dSiNo 0 "No" 1 "Sí"
		label values fijo correg entrega honor problema copia dSiNo
		label define dNotaClase 1 "Aprobado" 2 "Bien" 3 "Notable" 4 "Excelente"
		label values clase dNotaClase
		* asegurar que existe una variable coment string
		local t : type coment
		if (substr("`t'",1,3)!="str") {
			drop coment
			generate coment = "", after(clase)
		}
		* ordenar las variables
		order periodo curso DNI grupo nombre ape1 ape2 PC fijo clase correg entrega  ///
		   honor problema PEC copia ID copia coment prov pobl trabajo email
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
		sort periodo curso grupo PC
		local name = grupo[1]
		save `name'.dta, replace
		local dta "`dta' `name'"
	}
	* unir en un único dta por periodo y grabar
	clear
	append using `dta'

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

	local file = "$dir/`p'.dta"
	save `file', replace
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

	foreach v of varlist P*_* {
		qui generate __`v' = (`v'=="?")
	}
	capture drop __buides
	qui egen __buides = rowtotal(__P*)
	qui drop __P*

	list DNI P*_* if __buides == 1, clean
end
