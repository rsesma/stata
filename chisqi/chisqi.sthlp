{smcl}
{* *! version 1.1.2 30sep2019}{...}
{viewerdialog chisqi "dialog chisqi"}{...}
{viewerjumpto "Syntax" "chisqi##syntax"}{...}
{viewerjumpto "Description" "chisqi##description"}{...}
{viewerjumpto "Examples" "chisqi##examples"}{...}
{viewerjumpto "Stored results" "chisqi##results"}{...}
{viewerjumpto "Version" "chisqi##version"}{...}
{viewerjumpto "Authors" "chisqi##authors"}{...}
{viewerjumpto "References" "chisqi##references"}{...}
{title:Title}

{phang}
{bf:chisqi} {hline 2} Goodness of fit Chi-squared test


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:chisqi} {it:#1 #2} [...] \ {it:#o11 #o12} [...]  [\ {it:#o21 #o22} ... \ ....][{cmd:,} {bf:{ul:l}abels({it:string})} {bf:nst({it:string})}]

{marker description}{...}
{title:Description}

{p 4 4 2}
Immediate command to compute the goodness of fit Chi-squared test for several samples.

{p 4 4}
The command uses the specified values. First numlist {it:#1 #2} is the theoretical distribution of the categories. 
Observed cases of each sample come after, each sample separated by {bf:'\'}. The number of elements of each sample
must be the same, and equal to the number of elements of the theoretical distribution. At least one sample is required.

{p 4 4}
The {bf:labels} option receives a list of labels to label each category in the output table.

{p 4 4}
The {bf:nst} option receives the name of the study to label the output.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate chisqi, update} to update the {bf:chisqi} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker examples}{...}
{title:Examples}

{p 4 4}{cmd:. chisqi 2 3 2 \ 19 41 31}{p_end}
{p 4 4}{cmd:. chisqi 2 3 2 \ 19 41 31 \ 6 23 20}{p_end}
{p 4 4}{cmd:. chisqi 2 3 2 \ 19 41 31 \ 6 23 20, labels(AA Aa aa)}{p_end}


{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following scalars in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 7 15 19 2: {it:One sample}}{p_end}
{synopt:{cmd:r(chi2)}}Pearson's chi-squared{p_end}
{synopt:{cmd:r(p)}}significance of Pearson's chi-squared{p_end}

{p2col 7 15 19 2: {it:Two or more samples}}{p_end}
{synopt:{cmd:r(chi2_i)}}Pearson's chi-squared for sample i{p_end}
{synopt:{cmd:r(p_i)}}significance of Pearson's chi-squared for sample i{p_end}
{synopt:{cmd:r(chi2)}}overall Pearson's chi-squared{p_end}
{synopt:{cmd:r(p)}}overall significance of Pearson's chi-squared{p_end}


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
stata@metodo.uab.cat{p_end}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM. Goodness of fit Chi-squared test: User-written command chisqi for Stata [computer program].{break}
V1.1.2. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2019.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 10. Relaci{c o'}n entre dos variables categ{c o'}ricas. Pruebas
de X2. 15{c 170} ed. Barcelona: Signo; 2014.{p_end}

{p 0 2}
Fisher RA. Statistical methods, experimental design and scientific inference. Oxford: Oxford University Press; 1991.{p_end}
