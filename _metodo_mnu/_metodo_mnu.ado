*! version 1.0.1  30sep2019 JM Domenech, R. Sesma

/*
Create menu User > Metodo for the user-written commands 
of "Master de Metodologia de la Investigacion en Ciencias de la Salud (Prof. JM Domenech)"
*/

program define _metodo_mnu
	version 12
	syntax [anything]
	
	*Add menu items for the user-written commands
	window menu append submenu "stUser" "Metodo"
	window menu append submenu "Metodo" "Agreement"
	window menu append item "Agreement" "Bland-Altman and Passing-Bablok" "DB agree"
	window menu append item "Agreement" "Kappa and Weighted Kappa" "DB cohenkap"
	window menu append item "Agreement" "Kappa and Weighted Kappa calculator" "DB cohenkapi"
	window menu append submenu "Metodo" "Regression"
	window menu append item "Regression" "All Possible Subsets" "DB allsets"
	window menu append item "Regression" "Modelling Confound" "DB confound"
	window menu append item "Metodo" "Meta-Analysis combined" "DB mar"
	window menu append item "Metodo" "Sample Size and Power" "DB nsize"
	window menu append item "Metodo" "Trend Test" "DB rtrend"
	window menu append item "Metodo" "Trend Test calculator" "DB rtrendi"
	window menu append item "Metodo" "Association Measures" "DB sta"
	window menu append item "Metodo" "Association Measures calculator" "DB stai"
	window menu append submenu "Metodo" "Data Check"
	window menu append item "Data Check" "Data Check" "DB dc"
	window menu append item "Data Check" "Incidence Report" "DB dcreport"
	window menu append submenu "Metodo" "Diagnostic Tests"
	window menu append item "Diagnostic Tests" "Diagnostic Tests" "DB dt"
	window menu append item "Diagnostic Tests" "Diagnostic Tests calculator" "DB dti"
	window menu append item "Diagnostic Tests" "ROC Analysis and optimal cutoff point" "DB dtroc"
	window menu append item "Metodo" "Random Sequences" "DB rndseq"
	window menu append item "Metodo" "Statistics of missing values" "DB statmis"
	window menu append submenu "Metodo" "Other"
	window menu append item "Other" "Goodness of fit Chi-squared" "DB chisqi"
	window menu append item "Other" "CI for Pearson and Spearman Corr." "DB cir"
	window menu append item "Other" "CI for Pearson and Spearman Corr. calculator" "DB ciri"
	window menu append item "Other" "Kruskal-Wallis rank test and pairwise comparisons" "DB pwkwallis"
	window menu append item "Other" "Stochastic Curtailment: Clinical trials" "DB scct"
	
	*Refresh to update changes
	window menu refresh
end
