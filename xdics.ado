program xdics
	version 12
	syntax [anything]

	*delete duplicate label values (dictionaries)
quietly {
	*get label values info and detect duplicate dictionaries
	preserve
	uselabel, clear								//get label values as dataset
	reshape wide label, i(lname) j(value)
	duplicates tag label*, generate(dup)		//detect duplicate label values
	keep if dup > 0								//keep duplicates only

	*generate a duplicate label values dataset
	sort label*								//group labels with the same value/descrip
	by label*: gen id = _n					//id duplicate labels
	keep lname id							//keep only label name and id

	gen _gr = id if (id==1)					//generate grouping variable: group duplicate labels
	gen group = sum(_gr)
	drop _gr id

	rename lname name						//sort by label name
	sort group name
	by group: gen id = _n
							
	reshape wide name, i(group) j(id)		//create matrix with a row for each duplicate label
	drop group

	local nlabels = _N						//number of diferente value labels

	//use Mata to store the dataset on local macros
	mata: get_duplicate_labels()
	
	restore		//restore original dataset

	*loop through the distinct label names and its duplicates to assign the first
	*label name and delete the duplicate labels
	foreach i of numlist 1/`nlabels' {
		local l : word `i' of `orig'		//name of the first value label: the one to keep
		
		local n : word count `dup`i''		//number of duplicate value labels
		foreach j of numlist 1/`n' {
			//the name of the duplicate value label is the same as the variable it applies
			local d : word `j ' of `dup`i''
			label values `d' `l'
			label drop `d'
		}
	}
}
end

version 12
mata:
void get_duplicate_labels() {
	D = st_sdata(., .)
	N = D[., 1]
	L = D[|1,2 \ (rows(D),cols(D))|]

	st_local("orig",invtokens(N[.,1]'))

	for (i=1; i<=rows(L); i++) {
		name = "dup" + strofreal(i)
		st_local(name,invtokens(L[i,.]))
	}
}
end
