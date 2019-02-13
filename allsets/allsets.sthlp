{smcl}
{* *! version 1.2.5 13feb2019}{...}
{viewerdialog allsets "dialog allsets"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] logit" "help logit"}{...}
{vieweralsosee "[R] stcox" "help stcox"}{...}
{vieweralsosee "[R] stset" "help stset"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[P] _rmcoll" "help _rmcoll"}{...}
{viewerjumpto "Syntax" "allsets##syntax"}{...}
{viewerjumpto "Description" "allsets##description"}{...}
{viewerjumpto "Examples" "allsets##examples"}{...}
{viewerjumpto "Version" "allsets##version"}{...}
{viewerjumpto "Authors" "allsets##authors"}{...}
{viewerjumpto "References" "allsets##references"}{...}
{title:Title}

{phang}
{bf:allsets} {hline 2} Find the best subset for Linear, Logistic and Cox Regression


{marker syntax}{...}
{title:Syntax}

{phang}Syntax for {bf:Linear} or {bf:Logistic} regression

{p 8 12 2}
{cmd:allsets} {depvar} {indepvars} {ifin} {weight}{cmd:, linear | logistic} [{it:{help allsets##options:options}}]


{phang}Syntax for {bf:Cox} regression

{p 8 12 2}
{cmd:allsets} {indepvars} {ifin}{cmd:, cox} [{it:{help allsets##options:options}}]


{marker options}{...}
{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt :{opt lin:ear}}Linear regression; see {help regress}{p_end}
{synopt :{opt log:istic}}Logistic regression; see {help logit}{p_end}
{synopt :{opt cox}}Cox regression; see {help stcox}. You must {cmd:stset} your data before using {cmd:cox}; see {manhelp stset ST}{p_end}
{synopt :{opth fixed(varlist)}}fixed variables{p_end}
{synopt :{opth maxvar(integer)}}maximum number of variables included in the combinations; by default combinations are built with ALL independent variables{p_end}
{synopt :{opth minvar(integer)}}minimum number of variables included in the combinations; by default 1{p_end}
{synopt :{opt nohierarchical}}allow  non hierarchical submodels; by default only hierarchical submodels are evaluated{p_end}
{synopt :{opth using(filename)}}{it:{help filename}} to store the results dataset; by default a dataset named
{it:allsets_results} is saved in the current (working) directory{p_end}
{synopt :{opt noreplace}}if {it:{help filename}} exists, do not replace; by default existing datasets are replaced{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}
INCLUDE help fvvarlist
{p 4 4 2}{bf:pweight} is allowed for {opt linear} and {opt logistic} regression; see {help weight:weight}.{break}
(weight on logistic regression will highly increase computation time){break}
You may use {cmd:stset} to weight your data before using {cmd:cox}; see {manhelp stset ST}.


{marker description}{...}
{title:Description}

{p 4 4 2}
This command helps to find the best subset for Linear, Logistic and Cox regression. All the possible combinations
of the independent variables are computed and evaluated to find a set of parameters for each subset.

{p 4 4}
For Linear regression Mallow's Cp, Akaike Information Criteria (AIC), Schwarz Bayesian Criterion (BIC),
R-squared (R2) and adjusted R-squared (R2Adj) are computed for each subset.

{p 4 4}
For Logistic regression Akaike Information Criteria (AIC), Schwarz Bayesian Criterion (BIC), the Area Under the Curve (AUC),
Sensitivity (Se), Specificity (Sp) and Hosmer-Lemeshow goodness-of-fit (pfitHL) are computed for each subset. The
Hosmer-Lemeshow goodness-of-fit test is computed using 10 quantiles to group data: {cmd:estat gof, group(10)}. If
Hosmer-Lemeshow test is not evaluable, Pearson Chi2 is used instead and result is marked with a * on the results dataset.

{p 4 4}
For Cox regression Akaike Information Criteria (AIC), Schwarz Bayesian Criterion (BIC), Harrell's C (HarrellC) and
-2 logarithm of the likelihood (_2ll) are computed for each subset. For models including Time Variable Covariates, {bf:somersd}
user defined program is necessary to compute Harrell's C. This module may be installed from within Stata by typing {bf:ssc install somersd}

{p 4 4}
If {opt maxvar} or {opt minvar} option is used the significance of model test is computed for all types of regression and stored at
the pValue variable. If {opt maxvar(1)} the Coefficients of the linear regression (b variable), Odds Ratios of the logistic regression
(OR variable) or Hazard Ratios of the Cox regression (HR variable) are stored on the results dataset.

{p 4 4}
The results are stored in a new dataset named by default {it:allsets_results} and stored in the current (working)
directory. Option {cmd: using} allows to use another path for results dataset. Existing datasets are replaced by default.

{p 4 4}
You can click {dialog allsets:here} to pop up a {dialog allsets:dialog} or type {inp: db allsets}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install.

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate allsets, update} to update the {bf:allsets} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help regress}, {help logit}, {help logistic estat gof}, {help lroc}, {help rocreg}, {help stcox}, {help estat concordance}
and {help _rmcoll} Stata commands. It also uses the {stata "net describe somersd, from(http://www.imperial.ac.uk/nhli/r.newson/stata12)":somersd}
user defined program.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}

Linear regression
{p 4 4}{stata "use http://www.graunt.cat/stata/allsets_linear.dta":. use http://www.graunt.cat/stata/allsets_linear.dta}{p_end}
{p 4 4}{cmd:. allsets Y X1 X2 B i.C, linear}{p_end}
{p 4 4}{cmd:. allsets Y X1 X2 B i.C, linear fixed(X1)}{p_end}
{p 4 4}{cmd:. allsets Y X1 X2 B i.C, linear maxvar(1)}{p_end}
{p 4 4}{cmd:. allsets Y X1 X2 B i.C c.X1#c.X2 c.X1#c.B, linear using(results_linear.dta)}{p_end}

Logistic regression
{p 4 4}{stata "use http://www.graunt.cat/stata/allsets_logistic.dta":. use http://www.graunt.cat/stata/allsets_logistic.dta}{p_end}
{p 4 4}{cmd:. allsets Y X1 X2 X3 i.C, logistic using(results_log.dta) noreplace}{p_end}

Cox regression
{p 4 4}{stata "use http://www.graunt.cat/stata/allsets_cox.dta":. use http://www.graunt.cat/stata/allsets_cox.dta}{p_end}
{p 4 4}{cmd:. stset TR, failure(Estado==1)}{p_end}
{p 4 4}{cmd:. allsets X2 X3 i.C, cox using(allsets_cox.dta)}{p_end}
{it:Time dependent covariates}
{p 4 4}{stata "use http://www.graunt.cat/stata/allsets_cox_vdt.dta":. use http://www.graunt.cat/stata/allsets_cox_vdt.dta}{p_end}
{p 4 4}{cmd:. stset Stop, id(Caso) failure(Estado==1) time0(Start)}{p_end}
{p 4 4}{cmd:. allsets X1 X2 X3 i.C c.X1#c.X2, cox}{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.2.5 {hline 2} 13 February 2019


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech & JB.Navarro{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@graunt.cat{break}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM, Navarro JB. Find the best subset for Linear, Logistic and Cox Regression: User-written command allsets for Stata [computer program].{break}
V1.2.5. Barcelona: Graunt21; 2019{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Dom{c e'}nech JM, Navarro JB. Regresi{c o'}n m{c u'}ltiple con predictores categ{c o'}ricos y cuantitativos. 7{c 170} ed. Barcelona: Signo; 2014.{p_end}

{p 0 2}
Dom{c e'}nech JM, Navarro JB. Regresi{c o'}n log{c i'}stica binaria, multinomial, de Poisson y binomial negativa. 7{c 170} ed. Barcelona: Signo; 2014.{p_end}

{p 0 2}
Dom{c e'}nech JM, Navarro JB. An{c a'}lisis de la supervivencia y modelo de riesgos proporcionales de Cox. 7{c 170} ed. Barcelona: Signo; 2014.{p_end}
