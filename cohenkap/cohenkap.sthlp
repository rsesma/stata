{smcl}
{* *! version 1.1.1 04may2018}{...}
{viewerdialog cohenkap "dialog cohenkap"}{...}
{viewerdialog cohenkapi "dialog cohenkapi"}{...}
{vieweralsosee "[R] kappa" "help kappa"}{...}
{viewerjumpto "Syntax" "cohenkap##syntax"}{...}
{viewerjumpto "Description" "cohenkap##description"}{...}
{viewerjumpto "Examples" "cohenkap##examples"}{...}
{viewerjumpto "Stored results" "cohenkap##results"}{...}
{viewerjumpto "Version" "cohenkap##version"}{...}
{viewerjumpto "Authors" "cohenkap##authors"}{...}
{viewerjumpto "References" "cohenkap##references"}{...}
{title:Title}

{phang}
{bf:cohenkap} {hline 2} Kappa and Weighted kappa


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:cohenkap} {it:{help varname:varnameY}} {it:{help varname:varnameX}} 
[{cmd:,} {it:{help cohenkap##options:options}}]

{phang}Immediate command

{p 8 12 2}
{cmd:cohenkapi} {it:#n11 #n12 ... #n1k \ #n21 #n22 ... #n2k \ ... \ #nk1 #nk2 ... #nkk} [{cmd:,} {it:{help cohenkapi##options:options}}]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt ordered}}ordered categories; by default categories are {bf:not ordered}{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); default is {bf:level(95)}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{syntab:2x2 tables only}
{synopt :{opt w:ilson}}calculate Wilson confidence intervals; the {bf:default}{p_end}
{synopt :{opt e:xact}}calculate exact confidence intervals{p_end}
{synopt :{opt wa:ld}}calculate Wald confidence intervals{p_end}
{synoptline}
{phang}
{cmd:by} is allowed; see {manhelp by D}.


{marker description}{...}
{title:Description}

{p 4 4 2}
Kappa and Weighted kappa.

{p 4 4}
{space 9}{c |} Rating X{space 19}{c |} Rating X{break}
Rating Y {c |}{space 1}1(-){c |}{space 1}2(+){space 8}Rating Y {c |}{space 2}1{space 2}{c |}{space 2}2{space 2}{c |} ... {c |}{space 2}k{break}
{hline 9}{c +}{hline 5}{c +}{hline 5}{space 8}{hline 9}{c +}{hline 5}{c +}{hline 5}{c +}{hline 5}{c +}{hline 5}{break}
{space 4}1(-) {c |} n11 {c |} n12{space 16}1 {c |} n11 {c |} n12 {c |} ... {c |} n1k{break}
{space 4}2(+) {c |} n21 {c |} n22{space 16}2 {c |} n21 {c |} n22 {c |} ... {c |} n2k{break}
{hline 9}{c BT}{hline 5}{c BT}{hline 5}{space 15}. {c |} ... {c |} ... {c |} ... {c |} ...{break}
{space 36}k {c |} nk1 {c |} nk2 {c |} ... {c |} nkk{break}
{space 29}{hline 9}{c BT}{hline 5}{c BT}{hline 5}{c BT}{hline 5}{c BT}{hline 5}{break}

{p 4 4 2}
The command needs two variables with the values for each rater to compute the results.
{break}
{cmd:cohenkapi} is the immediate form of
{cmd:cohenkap}; see {help immed}. The immediate command needs {it: k} numlists, one for each category, separated by {bf:'\'}.

{p 4 4}
You can click {dialog cohenkap:here} to pop up a {dialog cohenkap:dialog} or type {inp: db cohenkap}. For the 
immediate command, you can click {dialog cohenkapi:here} to pop up a {dialog cohenkapi:dialog} or type {inp: db conhenkapi}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate cohenkap, update} to update the {bf:cohenkap} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://www.graunt.cat/stata/kappa_data.dta":. use http://www.graunt.cat/stata/kappa_data.dta}{p_end}

{p 4 4}{cmd:. cohenkap Rating2 Rating1, ordered}{p_end}
{p 4 4}{cmd:. cohenkapi 15 4 2 0 \ 5 16 4 1 \ 3 6 18 6 \ 1 2 3 14, ordered}{p_end}

{p 4 4}{cmd:. cohenkap QoL2 QoL1, nst(Study name)}{p_end}
{p 4 4}{cmd:. cohenkapi 25 63 0 3 \ 0 0 0 0 \ 7 122 0 40 \ 1 21 0 66, nst(Study name)}{p_end}

{p 4 4}{cmd:. cohenkap RatingY RatingX}{p_end}
{p 4 4}{cmd:. cohenkapi 171 1 \ 19 9}{p_end}


{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following in {cmd:r()}:

{p 4 4}Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}

{p2col 7 15 19 2: {it:k>2 ordered categories}}{p_end}
{synopt:{cmd:r(po_u)}}observed agreement, unweighted{p_end}
{synopt:{cmd:r(kappa_u)}}kappa, unweighted{p_end}
{synopt:{cmd:r(se0_u)}}standard error 0, unweighted{p_end}
{synopt:{cmd:r(se1_u)}}standard error 1, unweighted{p_end}
{synopt:{cmd:r(p_u)}}significance, unweighted{p_end}
{synopt:{cmd:r(lb_u)}}lower bound of confidence interval, unweighted{p_end}
{synopt:{cmd:r(ub_u)}}upper bound of confidence interval, unweighted{p_end}
{synopt:{cmd:r(po_l)}}observed agreement, lineal weight{p_end}
{synopt:{cmd:r(kappa_l)}}kappa, lineal weight{p_end}
{synopt:{cmd:r(se0_l)}}standard error 0, lineal weight{p_end}
{synopt:{cmd:r(se1_l)}}standard error 1, lineal weight{p_end}
{synopt:{cmd:r(p_l)}}significance, lineal weight{p_end}
{synopt:{cmd:r(lb_l)}}lower bound of confidence interval, lineal weight{p_end}
{synopt:{cmd:r(ub_l)}}upper bound of confidence interval, lineal weight{p_end}
{synopt:{cmd:r(po_q)}}observed agreement, lineal weight{p_end}
{synopt:{cmd:r(kappa_q)}}kappa, quadratic weight{p_end}
{synopt:{cmd:r(se0_q)}}standard error 0, quadratic weight{p_end}
{synopt:{cmd:r(se1_q)}}standard error 1, quadratic weight{p_end}
{synopt:{cmd:r(p_q)}}significance, quadratic weight{p_end}
{synopt:{cmd:r(lb_q)}}lower bound of confidence interval, quadratic weight{p_end}
{synopt:{cmd:r(ub_q)}}upper bound of confidence interval, quadratic weight{p_end}

{p2col 7 15 19 2: {it:k>2 not ordered categories}}{p_end}
{synopt:{cmd:r(po)}}observed agreement{p_end}
{synopt:{cmd:r(kappa)}}kappa{p_end}
{synopt:{cmd:r(se0)}}standard error 0{p_end}
{synopt:{cmd:r(se1)}}standard error 1{p_end}
{synopt:{cmd:r(p)}}significance{p_end}
{synopt:{cmd:r(lb)}}lower bound of confidence interval{p_end}
{synopt:{cmd:r(ub)}}upper bound of confidence interval{p_end}

{p2col 7 15 19 2: {it:k==2 categories}}{p_end}
{synopt:{cmd:r(kappa)}}kappa{p_end}
{synopt:{cmd:r(se0)}}standard error 0{p_end}
{synopt:{cmd:r(se1)}}standard error 1{p_end}
{synopt:{cmd:r(p)}}significance{p_end}
{synopt:{cmd:r(lb)}}lower bound of confidence interval{p_end}
{synopt:{cmd:r(ub)}}upper bound of confidence interval{p_end}
{synopt:{cmd:r(agr_p)}}specific agreement (+){p_end}
{synopt:{cmd:r(lb_agr_p)}}lower bound of specific agreement (+) confidence interval{p_end}
{synopt:{cmd:r(ub_agr_p)}}upper bound of specific agreement (+) confidence interval{p_end}
{synopt:{cmd:r(agr_n)}}specific agreement (-){p_end}
{synopt:{cmd:r(lb_agr_n)}}lower bound of specific agreement (-) confidence interval{p_end}
{synopt:{cmd:r(ub_agr_n)}}upper bound of specific agreement (-) confidence interval{p_end}
{synopt:{cmd:r(agr)}}global agreement{p_end}
{synopt:{cmd:r(lb_agr)}}lower bound of global agreement confidence interval{p_end}
{synopt:{cmd:r(ub_agr)}}upper bound of global agreement confidence interval{p_end}
{synopt:{cmd:r(kappa_min)}}kappa minimum{p_end}
{synopt:{cmd:r(kappa_max)}}kappa maximum{p_end}
{synopt:{cmd:r(obs_dis_p)}}observed disagreement X-Y+{p_end}
{synopt:{cmd:r(obs_dis_n)}}observed disagreement X+Y-{p_end}
{synopt:{cmd:r(bias)}}bias index{p_end}
{synopt:{cmd:r(bak)}}bias adjusted kappa (BAK){p_end}
{synopt:{cmd:r(obs_agr_p)}}observed agreement (+){p_end}
{synopt:{cmd:r(obs_agr_n)}}observed agreement (-){p_end}
{synopt:{cmd:r(pi)}}prevalence index{p_end}
{synopt:{cmd:r(bak)}}prev. & bias adjusted kappa (PABAK){p_end}

{p 4 4}Matrices{p_end}
{synopt:{cmd:r(Categories)}}Categories results for k>2 not ordered{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.1 {hline 2} 04 May 2018


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
Dom{c e'}nech JM. Weighted kappa: User-written command cohenkap for Stata [computer program].{break}
V1.1.1. Barcelona: Graunt21; 2018.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Byrt T, Bishop J, Carlin JB. Bias, prevalence and kappa. J Clin Epidemiol. 1993; 46(5):423-9.{p_end}

{p 0 2}
Cicchetti D, Feinstein AR. High agreement but low kappa: II. Resolving the paradoxes. J Clin Epidemiol. 1990; 43:551-8.{p_end}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 14. Medida  del cambio: An{c a'}lisis de
dise{c n~}os con medidas intrasujeto. 16{c 170} ed. Barcelona: Signo; 2015.{p_end}

{p 0 2}
Fleiss JL, Levin B, Paik MC. Statistical Methods for Rates and Proportions. 3rd ed. Hoboken, NJ: John Wiley & Sons; 2003. pp. 598-610.{p_end}
