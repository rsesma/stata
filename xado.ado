*! version 1.0.3  26jul2019 R. Sesma

/*
Update user-defined commands
*/

program define xado
	version 12
	syntax anything, [codedir(string) adodir(string)]

	*command name and first letter
	local command = "`anything'"
	local letter = substr("`command'",1,1)

	*get default dir values
	if ("`codedir'"=="") {
		if ("`c(os)'"=="Windows") local c "C:/Users/`c(username)'"
		if ("`c(os)'"=="MacOSX") local c "/Users/`c(username)'"
		local codedir = "`c'/git/stata/"
	}
	if ("`adodir'"=="") local adodir "`c(sysdir_plus)'"
	local extradir = "`adodir'_"

	*build origin and destination path
	mata: st_local("orig",pathjoin(st_local("codedir"),st_local("command")))
	mata: st_local("dest",pathjoin(st_local("adodir"),st_local("letter")))

	*copy ado, sthlp & dlg files from origin to destination
	local files : dir "`orig'" files "*"
	local n : word count `files'
	local version
	foreach i of numlist 1/`n' {
		local file : word `i' of `files'
		*get file extension
		mata: st_local("ext",pathsuffix(st_local("file")))

		if (upper("`ext'")==".ADO" | upper("`ext'")==".STHLP" | upper("`ext'")==".DLG") {
			mata: st_local("name",pathbasename(pathjoin(st_local("orig"),st_local("file"))))
			local extra = (substr("`name'",1,1)=="_")
			mata: st_local("file1",pathjoin(st_local("orig"),st_local("file")))
			if (`extra') mata: st_local("file2",pathjoin(st_local("extradir"),st_local("file")))
			else mata: st_local("file2",pathjoin(st_local("dest"),st_local("file")))

			copy "`file1'" "`file2'", public replace
			di as txt "file updated: `file'"

			if ("`version'"=="" & upper("`ext'")==".ADO") {
				*get version from first ado file
				mata: st_local("version",tokens(cat(st_local("file1"), 1, 1))[1,3])
			}
		}
	}

	*force update
	discard
	program drop _allado

	di as res "`command' v`version' UPDATED"
end
