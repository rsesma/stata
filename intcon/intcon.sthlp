{smcl}
{* *! version 1.0.1 20jan2021}{...}
{viewerdialog intcon "dialog intcon"}{...}
{viewerjumpto "Syntax" "intcon##syntax"}{...}
{viewerjumpto "Description" "intcon##description"}{...}
{viewerjumpto "Examples" "intcon##examples"}{...}
{viewerjumpto "Stored results" "intcon##results"}{...}
{viewerjumpto "Version" "intcon##version"}{...}
{viewerjumpto "Authors" "intcon##authors"}{...}
{viewerjumpto "References" "intcon##references"}{...}
{title:Title}

{phang}
{bf:intcon} {hline 2} Internal Consistency


{marker syntax}{...}
{title:Syntax}

{p 4 12 2}
{cmd:intcon} {varlist} {ifin} {weight}{cmd:, {cont | ord}} [nst]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt cont}}Continuous indexes{p_end}
{synopt :{opt ord}}Ordinal indexes{p_end}
{synopt :{opt nst(string)}}Name of the study (label){p_end}
{synoptline}
{p 4 4 2}{bf:aweight}s, {bf:fweight}s and {bf:pweight}s are allowed. {bf:pweight}s may not be used with continuous indexes.{p_end}


{marker description}{...}
{title:Description}

{p 4 4}
This command computes statistical coefficients to evaluate internal consistency. Cronbach's alpha, Armor's theta and McDonald's omega(t)
are computed for continuous indexes, as well as its equivalents for ordinal indexes. At least two numerical variables must be
specified. At least one {cmd:cont} or {cmd:ord} option is needed.

{p 4 4}
You can click {dialog intcon:here} to pop up a {dialog intcon:dialog} or type {inp: db intcon}.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install.

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate intcon, update} to update the {bf:intcon} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help alpha}, {help factor}, {help factormat} and {help sem} Stata commands. It also uses the
{stata "net describe alphawgt, from(http://fmwww.bc.edu/RePEc/bocode/a)":alphawgt} and
{stata "net describe polychoric, from(http://staskolenikov.net/stata)":polychoric}
user defined programs.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://metodo.uab.cat/stata/intcon.dta":. use http://metodo.uab.cat/stata/intcon.dta}{p_end}
{p 4 4}{cmd:. intcon Item1 Item2 Item3 Item4 Item5 Item6, cont ord}{p_end}

{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following in {cmd:r()}:

{synoptset 18 tabbed}{...}
{p 4 4}Continuous measures{p_end}
{synopt:{cmd:r(alpha)}}Cronbach's alpha{p_end}
{synopt:{cmd:r(theta)}}Armor's theta{p_end}
{synopt:{cmd:r(omega)}}McDonald's omega(t){p_end}

{p 4 4}Ordinal measures{p_end}
{synopt:{cmd:r(alpha_ord)}}Ordinal alpha{p_end}
{synopt:{cmd:r(theta_ord)}}Ordinal theta{p_end}
{synopt:{cmd:r(omega_ord)}}Ordinal omega{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.0.1 {hline 2} 20 January 2021


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech & JB.Navarro{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@metodo.uab.cat{p_end}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM, Navarro JB. Internal Consistency: User-written command intcon for Stata [computer program].{break}
V1.0.1. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2021.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Viladrich C, Angulo A, Doval E. Un viaje alrededor de alfa y omega para estimar la fiabilidad de consistencia interna. Anal. Psicol. [online]. 2017; 33(3): 755-82. Available from {browse "http://dx.doi.org/10.6018/analesps.33.3.268401"}{p_end}
