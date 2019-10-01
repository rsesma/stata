{smcl}
{* *! version 1.1.2  30sep2019}{...}
{viewerdialog cir "dialog cir"}{...}
{viewerdialog ciri "dialog ciri"}{...}
{vieweralsosee "[R] correlate" "help correlate"}{...}
{vieweralsosee "[R] spearman" "help spearman"}{...}
{viewerjumpto "Syntax" "cir##syntax"}{...}
{viewerjumpto "Description" "cir##description"}{...}
{viewerjumpto "Examples" "cir##examples"}{...}
{viewerjumpto "Stored results" "agree##results"}{...}
{viewerjumpto "Version" "cir##version"}{...}
{viewerjumpto "Authors" "cir##authors"}{...}
{viewerjumpto "References" "cir##references"}{...}
{title:Title}

{phang}
{bf:cir} {hline 2} Confidence Interval for Pearson and Spearman Correlation


{phang}Syntax for {cmd:cir}

{p 8 12 2}
{cmd:cir} {it:{help varname:varnameY}} {it:{help varname:varnameX}} {ifin} [{cmd:,} {it:{help cir##options:options}}]


{phang}Immediate command

{p 8 12 2}
{cmd:ciri} {it:#rho1 #n1} [{it:#rho0 #n0}] [{cmd:,} {it:{help cir##options:options}}]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt pe:arson}}calculate confidence interval for Pearson correlation; the {bf:default}{p_end}
{synopt :{opt sp:earman}}calculate confidence interval for Spearman correlation{p_end}
{synopt :{opt by(varname)}}binary variable that defines two groups (not available in the immediate commad){p_end}
{synopt :{opt r:ho(#)}}hypothetical correlation to compare with{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); default is {bf:level(95)}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}
{phang}
{cmd:by} is allowed; see {manhelp by D}.


{marker description}{...}
{title:Description}

{p 4 4 2}
Option {cmd:pearson} calculates the Pearson correlation 
and computes the confidence interval, using Fisher's transformation. With option {cmd:spearman}, Spearman 
correlation is calculated. It is possible to compare two correlations using the {cmd:by()} option to define
two groups in the dataset with a binary variable. Option {cmd:rho()} allows to compare to a hypothetical correlation.

{p 4 4}
{cmd:ciri} is the immediate form of {cmd:cir}; see {help immed}. {it:#rho1} and {it:#n1} are the correlation coefficient 
and the sample size of group 1. To compare two correlations, {it:#rho0} and {it:#n0} (correlation coefficient and
sample size of group 0) are needed. Option {cmd:rho()} allows to compare to a hypothetical correlation.

{p 4 4}
You can click {dialog cir:here} to pop up a {dialog cir:dialog} or type {inp: db cir}. For the 
immediate command, you can click {dialog ciri:here} to pop up a {dialog ciri:dialog} or type {inp: db ciri}.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate cir, update} to update the {bf:cir} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help correlate} and {help spearman} Stata commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://metodo.uab.cat/stata/CreaHemo.dta":. use http://metodo.uab.cat/stata/CreaHemo.dta}{p_end}
{p 4 4}{cmd:. cir Creatin Hemoglo, pearson}{p_end}
{p 4 4}{cmd:. cir Creatin Hemoglo, spearman rho(-0.7)}{p_end}
{p 4 4}{cmd:. cir Creatin Hemoglo, pearson by(Tratamiento) level(90)}{p_end}

{p 4 4}{cmd:. ciri 0.7700 50, spearman}{p_end}
{p 4 4}{cmd:. ciri 0.4869 47, rho(0.30) level(90)}{p_end}
{p 4 4}{cmd:. ciri 0.65 84 0.40 101}{p_end}


{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following scalars in {cmd:r()}:

{synoptset 15 tabbed}{...}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}

{p2col 7 15 19 2: {it:One correlation}}{p_end}
{synopt:{cmd:r(rho)}}rho{p_end}
{synopt:{cmd:r(lb_rho)}}lower bound of rho confidence interval{p_end}
{synopt:{cmd:r(ub_rho)}}upper bound of rho confidence interval{p_end}
{synopt:{cmd:r(p)}}significance{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}

{p2col 7 15 19 2: {it:Comparing a correlation to a hypotetical value}}{p_end}
{synopt:{cmd:r(rho)}}rho{p_end}
{synopt:{cmd:r(lb_rho)}}lower bound of rho confidence interval{p_end}
{synopt:{cmd:r(ub_rho)}}upper bound of rho confidence interval{p_end}
{synopt:{cmd:r(rd)}}difference{p_end}
{synopt:{cmd:r(rb_rho)}}lower bound of difference confidence interval{p_end}
{synopt:{cmd:r(rb_rho)}}upper bound of difference confidence interval{p_end}
{synopt:{cmd:r(p)}}significance (two-sided){p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}

{p2col 7 15 19 2: {it:Comparing two correlations}}{p_end}
{synopt:{cmd:r(rho1)}}rho (sample 1){p_end}
{synopt:{cmd:r(lb_rho1)}}lower bound of rho confidence interval (sample 1){p_end}
{synopt:{cmd:r(ub_rho1)}}upper bound of rho confidence interval (sample 1){p_end}
{synopt:{cmd:r(N1)}}number of observations (sample 1){p_end}
{synopt:{cmd:r(rho0)}}rho (sample 0){p_end}
{synopt:{cmd:r(lb_rho0)}}lower bound of rho confidence interval (sample 0){p_end}
{synopt:{cmd:r(ub_rho0)}}upper bound of rho confidence interval (sample 0){p_end}
{synopt:{cmd:r(N0)}}number of observations (sample 0){p_end}
{synopt:{cmd:r(rd)}}difference{p_end}
{synopt:{cmd:r(rb_rho)}}lower bound of difference confidence interval{p_end}
{synopt:{cmd:r(rb_rho)}}upper bound of difference confidence interval{p_end}
{synopt:{cmd:r(p)}}significance (two-sided){p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.2 {hline 2} 30 September 2019


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@metodo.uab.cat{break}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM. Confidence Interval for Pearson and Spearman Correlation: User-written command cir for Stata [computer program].{break}
V1.1.2. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2019.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Altman DG, Machin D, Bryant TN, Gardner MJ. Statistics with confidence. Confidence intervals and
statistical guidelines. 2{c 170} ed. London: BMJ Books; 2000.{p_end}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 13. Correlaci{c o'}n y regresi{c o'}n lineal. 15{c 170} ed. Barcelona: Signo; 2014.{p_end}
