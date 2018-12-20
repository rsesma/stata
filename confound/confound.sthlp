{smcl}
{* *! version 1.1.2  20feb2018}{...}
{viewerdialog confound "dialog confound"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] logit" "help logit"}{...}
{vieweralsosee "[R] stcox" "help stcox"}{...}
{vieweralsosee "[R] stset" "help stset"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[P] _rmcoll" "help _rmcoll"}{...}
{viewerjumpto "Syntax" "confound##syntax"}{...}
{viewerjumpto "Description" "confound##description"}{...}
{viewerjumpto "Examples" "confound##examples"}{...}
{viewerjumpto "Version" "confound##version"}{...}
{viewerjumpto "Authors" "confound##authors"}{...}
{viewerjumpto "References" "confound##refrences"}{...}
{title:Title}

{phang}
{bf:confound} {hline 2} Modelling confounding in Linear, Logistic and Cox Regression


{marker syntax}{...}
{title:Syntax}

{phang}Syntax for {bf:Linear} or {bf:Logistic} regression

{p 8 12 2}
{cmd:confound} {depvar} {it:{help varname:exposition}} {indepvars} {ifin} {weight}{cmd:, linear | logistic} [{it:{help allsets##options:options}}]


{phang}Syntax for {bf:Cox} regression

{p 8 12 2}
{cmd:confound} {it:{help varname:exposition}} {indepvars} {ifin}{cmd:, cox} [{it:{help allsets##options:options}}]


{marker options}{...}
{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt :{opt lin:ear}}Linear regression; see {help regress}{p_end}
{synopt :{opt log:istic}}Logistic regression; see {help logit}{p_end}
{synopt :{opt cox}}Cox regression; see {help stcox}. You must {cmd:stset} your data before using {cmd:cox}; see {manhelp stset ST}{p_end}
{synopt :{opth ch:ange(real)}}percentage of change that is considered important; by default {cmd:change(10)}{p_end}
{synopt :{opt min:imum}}use minimum model as reference{p_end}
{synopt :{opth val:ues(values_list)}}list of values for continuous interactions; by default {cmd:values(p5 p50 p95)}{break}
Literal values or percentiles p1 p5 p10 p25 p50 p75 p90 p96 p99 may be used{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); by default {cmd:level(95)}{p_end}
{synopt :{opth fixed(varlist)}}fixed variables{p_end}
{synopt :{opth using(filename)}}{it:{help filename}} to store the results dataset; by default a dataset named
{it:confound_results} is saved in the current (working) directory{p_end}
{synopt :{opt noreplace}}if {it:{help filename}} exists, do not replace; by default existing datasets are replaced{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}
INCLUDE help fvvarlist
{p 4 4 2}{bf:pweight} is allowed for {opt linear} and {opt logistic} regression; see {help weight:weight}.{break}
You may use {cmd:stset} to weight your data before using {cmd:cox}; see {manhelp stset ST}.


{marker description}{...}
{title:Description}

{p 4 4}
This command helps the assessment of confounding for Linear, Logistic and Cox regression according with
the rules proposed by Kleinbaum, Kupper, Nizam & Muller (2008, pp. 198-202).

{p 4 4}
For logistic regression, the Hosmer-Lemeshow goodness-of-fit test (variable pfitHL) is computed using 10 quantiles to group
data: {cmd:estat gof, group(10)}.

{p 4 4}
The results are stored in a new dataset named by default {it:confound_results} and saved in the current (working)
directory. Existing datasets are replaced by default.

{p 4 4}
You can click {dialog confound:here} to pop up a {dialog confound:dialog} or type {inp: db confound}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install.

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate confound, update} to update the {bf:confound} command.{break}
Execute {cmd: confound, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help regress}, {help logit}, {help logistic estat gof}, {help stcox} and {help _rmcoll} Stata commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}

Linear regression
{p 4 4}{stata "use http://www.graunt.cat/stata/Datatest_confound_MR.dta":. use http://www.graunt.cat/stata/Datatest_confound_MR.dta}{p_end}
{p 4 4}{cmd:. confound y x1 z1 z2 z3 i.z4, linear}{p_end}
{p 4 4}{cmd:. confound y i.x2 z1 z3, linear}{p_end}
{p 4 4}{cmd:. confound y x1 z1 z2 z3 c.x1#c.z2, linear values(p5 p50 p95 60 75) using(results_lr_cont.dta)}{p_end}
{p 4 4}{cmd:. confound y x1 z2 z3 i.z4r c.x1#i.z4r, linear}{p_end}

Logistic regression
{p 4 4}{stata "use http://www.graunt.cat/stata/Datatest_confound_LR.dta":. use http://www.graunt.cat/stata/Datatest_confound_LR.dta}{p_end}
{p 4 4}{cmd:. confound y x1 z1 z2 z3 c.x1#c.z3, logistic values(p5 p50 p95 90 104)}{p_end}

Cox regression
{p 4 4}{stata "use http://www.graunt.cat/stata/Datatest_confound_Cox.dta":. use http://www.graunt.cat/stata/Datatest_confound_Cox.dta}{p_end}
{p 4 4}{cmd:. stset tr, failure(estado==1)}{p_end}
{p 4 4}{cmd:. confound x1 z1 z2 z3 i.z4 c.x1#c.z2, cox}{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.2 {hline 2} 20 December 2018


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech & JB.Navarro{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@graunt.cat{p_end}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM, Navarro JB. Find the best subset for Linear, Logistic and Cox Regression:{break}
User-written command confound for Stata [computer program].{break}
V1.1.2. Barcelona: Graunt21; 2018.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Dom{c e'}nech JM, Navarro JB. Regresi{c o'}n m{c u'}ltiple con predictores categ{c o'}ricos y cuantitativos. 7{c 170} ed. Barcelona: Signo; 2014.{p_end}

{p 0 2}
Dom{c e'}nech JM, Navarro JB. Regresi{c o'}n log{c i'}stica binaria, multinomial, de Poisson y binomial negativa. 7{c 170} ed. Barcelona: Signo; 2014.{p_end}

{p 0 2}
Dom{c e'}nech JM, Navarro JB. An{c a'}lisis de la supervivencia y modelo de riesgos proporcionales de Cox. 7{c 170} ed. Barcelona: Signo; 2014.{p_end}

{p 0 2}
Kleinbaum DG, Kupper LL, Morgenstern H. Epidemiologic research.
Principles and quantitative methods. New York: Van Nostrand Reinhold Company; 1983.{p_end}

{p 0 2}
Kleinbaum DG, Kupper LL, Nizam A, Muller K. Applied Regression Analysis and
other Multivariable Methods. (4{c 170} ed.). Belmont (CA): Thomson Learning, Inc; 2008.{p_end}

{p 0 2}
Maldonado G, Greenland S. Simulation study of confounder-selection strategies. Am J Epidemiol. 1993;138:923-36.{p_end}
