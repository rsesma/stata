*! version 0.0.1  ?jul2018 R. Sesma
/*
dtable: command to add descriptive tables to DOCX or PDF documents
*/

program define dtable
	version 12
	// parse call to the subcommands
	_parse comma args opts : 0
	gettoken type args : args
	
	dtable_`type' `args' `opts'
end
