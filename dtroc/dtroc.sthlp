{smcl}
{* *! version 1.1.2 11may2018}{...}
{viewerdialog dtroc "dialog dtroc"}{...}
{viewerjumpto "Syntax" "dtroc##syntax"}{...}
{viewerjumpto "Description" "dtroc##description"}{...}
{viewerjumpto "Examples" "dtroc##examples"}{...}
{viewerjumpto "Stored results" "dtroc##results"}{...}
{viewerjumpto "Version" "dtroc##version"}{...}
{viewerjumpto "Authors" "dtroc##authors"}{...}
{viewerjumpto "References" "dtroc##references"}{...}
{title:Title}

{phang}
{bf:dtroc} {hline 2} ROC Analysis & Optimal Cutoff Point


{marker syntax}{...}
{title:Syntax}

{p 4 12 2}
{cmd:dtroc} {it:{help varname:refvar}} {it:{help varname:classvar}} {ifin} [{cmd:,} {it:{help dtroc##options:options}}]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt st(type)}}study type; valid values are:{break}
{bf:cs} Cross-sectional{space 3}({bf:default}){break}
{bf:cc} Case-control{p_end}
{synopt :{opt ic(#)}}code of {it:illness} group; default is {cmd:ic(1)}{break}
{it:non-illness} group: codes not equal to {cmd:ic}{p_end}
{synopt :{opt [no]inc}}{it:illness} increases {it:classvar} variable; default is {cmd:inc}{break}
If {it:illness} decreases {it:classvar} variable, specify {cmd:noinc}{p_end}
{synopt :{opt prev(#)}}Prevalence of {it:illness} in the population; by default: sample prevalence{p_end}
{synopt :{opt cost(#)}}ratio false-negative/positive cost (FNC/FPC); default is{cmd:cost(1)}{p_end}
{synopt :{opt detail}}show & save to a file details on sensitivity/specificity for each cutoff point{p_end}
{synopt :{opth using(filename)}}{it:{help filename}} to store the cutoff points data created by the {cmd:detail} option; by default a dataset named 
{it:dtroc_cutoff} is saved in the current (working) directory{p_end}
{synopt :{opt noreplace}}if {it:{help filename}} exists, do not replace; by default existing datasets are replaced{p_end}
{synopt :{opt graph}}graph sensitivity and specificity depending on each cutpoint{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); default is {bf:level(95)}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4}
Receiver Operating Characteristic (ROC) analysis and Optimal Cutoff Point. 

{p 4 4}
{it:refvar} and {it:classvar} variables must be numeric. The reference variable indicates the true state of the 
observation, such as diseased and nondiseased. By default the {it:illness} code is 1, see the {cmd:ic()} option to 
change this behaviour. The rating or outcome of the diagnostic test is saved in classvar. By default higher values 
indicate higher risk, see {cmd:noinc}.

{p 4 4}
{cmd:dtroc} performs nonparametric ROC analyses, and by default shows the area under the roc curve (AUC) and the optimal cutoff
point, as defined by Zweig & Campbell. Optimal cutoff points for maximum efficiency and based on ROC curve are also 
computed. Optionally it is possible to show and save to a file a detailed table with sensibility, specificity, efficiency, Youden index, 
likelihood ratios and prevalence values for each cutpoint, see options {cmd:detail} and {cmd:using}. Option {cmd:graph} creates a graph of 
sensibility and specificity depending on each cutoff point.

{p 4 4}
You can click {dialog dtroc:here} to pop up a {dialog dtroc:dialog} or type {inp: db dtroc}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate dtroc, update} to update the {bf:dtroc} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://www.graunt.cat/stata/GlucoseDiabetes.dta":. use http://www.graunt.cat/stata/GlucoseDiabetes.dta}{p_end}
{p 4 4}{cmd:. dtroc Diabetes Glucose, st(cs) detail graph}{p_end}
{p 4 4}{cmd:. dtroc Diabetes Glucose, st(cc) detail using(C:\test.dta)}{p_end}
{p 4 4}{cmd:. dtroc Diabetes Glucose, st(cc) prev(30)}{p_end}


{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following in {cmd:r()}:

{p 4 4}Scalars{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(N)}}valid number of observations{p_end}
{synopt:{cmd:r(level)}}confidence level for confidence intervals{p_end}
{synopt:{cmd:r(auc)}}area under the ROC curve{p_end}
{synopt:{cmd:r(lb_auc)}}lower bound of AUC CI{p_end}
{synopt:{cmd:r(ub_auc)}}upper bound of AUC CI{p_end}
{synopt:{cmd:r(prev)}}prevalence (sample or provided){p_end}

{p 4 4}Matrices{p_end}
{synopt:{cmd:r(efficiency)}}optimal cutoff point(s) for maximum efficency{p_end}
{synopt:{cmd:r(roc)}}optimal cutoff point(s) based on ROC curve{p_end}
{synopt:{cmd:r(ratio)}}optimal cutoff point(s) for FNcost/FPcost ratio and prevalence 
({cmd:st(cs)} and {cmd:st(cc)} with {cmd:prev} option only){p_end}
{synopt:{cmd:r(hypothetical)}}optimal cutoff points for hypothetical prevalence and FNcost/FPcost ratio{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.2 {hline 2} 11 May 2018


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@graunt.cat{p_end}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM. ROC Analysis & Optimal Cutoff Point: User-written command dtroc for Stata [computer program].{break}
V1.1.2. Barcelona: Graunt21; 2018.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 3. Teor{c i'}a y c{c a'}lculo de probabilidades.
Pruebas diagn{c o'}sticas. 16{c 170} ed. Barcelona: Signo; 2015.{p_end}

{p 0 2}
Zweig MH, Campbell C. Receiver-Operating Characteristic (ROC) Plots: A Fundamental Evaluation Tool in Clinical Medicine.
Clin Chem. 1993;39:561-77. [Erratum in Clin Chem. 1993;39(8):1589].{p_end}
