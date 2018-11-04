*! version 1.1.1  04may2018
program cohenkapi__dlg
	version 12.0
	gettoken subcmd 0 : 0
	`subcmd' `0'
end

program enableDisable
	syntax , clsname(string)
	local dlg .`clsname'
	local k = ``dlg'.main.sp_cat.value' 
		// the actual value of the spinner: number of categories

	//enable & disable cells
	forvalues r = 1/9 {
		forvalues c = 1/9 {
			//enable cells in the range
		    if ((`r'<=`k' & `c'<=`k')) {
				`dlg'.main.ed_r`r'c`c'.enable
			}

			//disable & void cells out of the range
			if ((`r'<=`k' & `c'>`k') | (`c'<=`k' & `r'>`k') | (`c'>`k' & `r'>`k')) {
				`dlg'.main.ed_r`r'c`c'.disable
				`dlg'.main.ed_r`r'c`c'.setvalue ""
			}
		}
	}

end

program genCommand
	syntax , clsname(string)
	local dlg .`clsname'
	local cmdstring cmd
	local k = ``dlg'.main.sp_cat.value' 
		// the actual value of the spinner: number of categories

	local command ""
	forvalues r = 1/`k' {
		forvalues c = 1/`k' {
			local command "`command' ``dlg'.main.ed_r`r'c`c'.value'"
		}
		if `r' < `k' {
			local command "`command' \"
		}
	}
	`dlg'.`cmdstring'.value = "`command'"
end
