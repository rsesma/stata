{smcl}
{* *! version 1.0.6 30sep2019}{...}
{viewerdialog scct "dialog scct"}{...}
{viewerjumpto "Syntax" "scct##syntax"}{...}
{viewerjumpto "Description" "scct##description"}{...}
{viewerjumpto "Examples" "scct##examples"}{...}
{viewerjumpto "Version" "scct##version"}{...}
{viewerjumpto "Authors" "scct##authors"}{...}
{viewerjumpto "References" "scct##references"}{...}
{title:Title}

{phang}
{bf:scct} {hline 2} Stochastic Curtailment: Clinical trials


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:ssct} {it:#t} {it:#cp0} {it:#cp1}{cmd:,} {bf:{ul:a}lpha(#)} {bf:{ul:b}eta(#)} [{bf:nst({it:string})}]

{marker description}{...}
{title:Description}

{p 4 4 2}
Immediate command to compute the Stochastic Curtailment for clinical trials.

{p 4 4}
The command uses the specified values:{break}
- {bf:#t} is the percentage of information accrued (0<{it:#t}<=100).{break}
- {bf:#cp0} is the conditional power(%) under null hypothesis (50<={it:#cp0}<100).{break}
- {bf:#cp1} is the conditional power(%) under alternative hypothesis (50<={it:#cp1}<100).{p_end}

{p 4 4}
The {bf:alpha} option receives the alpha risk in % (0<{it:alpha}<50). This option is {bf:required}.

{p 4 4}
The {bf:beta} option receives the beta risk in % (0<{it:beta}<50). This option is {bf:required}.

{p 4 4}
The {bf:nst} option receives the name of the study to label the output.

{p 4 4}
You can click {dialog sccti:here} to pop up a {dialog sccti:dialog} or type {inp: db scct}.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate scct, update} to update the {bf:scct} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker examples}{...}
{title:Examples}

{p 4 4}{cmd:. scct 50 90 90, alpha(5) beta(15)}{p_end}
{p 4 4}{cmd:. scct 60 90 80, alpha(5) beta(10) nst(Study name)}{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.0.6 {hline 2} 30 September 2019


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@metodo.uab.cat{p_end}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM. Stochastic Curtailment, Clinical trials: User-written command scct for Stata [computer program].{break}
V1.0.6. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2019.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Davis BR, Hardy RJ. Data monitoring in clinical trials: the case for stochastic curtailment. J Clin Epidemiol. 1994; 47:1033-42.{p_end}

{p 0 2}
Delgado M, Llorca J, Dom{c e'}nech JM. Estudios experimentales. 5{c 170} ed. Barcelona: Signo; 2012.{p_end}

{p 0 2}
Moy{c e'} LA. Statistical monitoring of clinical trials. Springer: New York, 2006.{p_end}
