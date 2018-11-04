*! version 1.0.0  26oct2017 R. Sesma

/*
create command version copy
*/

program define xver
	version 12
	syntax anything

	local command = "`anything'"
	
	local os = c(os)
	if ("`os'"=="MacOSX") local dir = "/Users/r/Dropbox/Stata/_commands"
	if ("`os'"=="Windows") local dir = "C:\Users\R\Dropbox\Stata\_commands"

	*create code and ado file paths
	mata: st_local("codepath",pathjoin(pathjoin(st_local("dir"),"code"),st_local("command")))
	mata: st_local("adopath",pathjoin(st_local("codepath"),st_local("command")))
	local adopath = "`adopath'.ado"
	
	*get version from ado file first line
	mata: st_local("version",tokens(cat(st_local("adopath"), 1, 1))[1,3])

	*create version path
	mata: st_local("versionpath",pathjoin(pathjoin(pathjoin(st_local("dir"),"versiones"),st_local("command")),st_local("version")))

	*create version folder
	mata: mkdir(st_local("versionpath"))
	
	*copy files from code folder to version folder
	local files : dir "`codepath'" files "*"
	local n : word count `files'
	foreach i of numlist 1/`n' {
		local file : word `i' of `files'

		if ("`file'"!=".DS_Store") {
			mata: st_local("file1",pathjoin(st_local("codepath"),st_local("file")))
			mata: st_local("file2",pathjoin(st_local("versionpath"),st_local("file")))

			copy "`file1'" "`file2'", public
			di as txt "file copied: `file'"
		}
	}
	
	di as res "`command' v`version' created successfully"
end
