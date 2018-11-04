{smcl}
{* *! version 1.1.3  22oct2018}{...}
{viewerdialog statmis "dialog statmis"}{...}
{viewerjumpto "Syntax" "statmis##syntax"}{...}
{viewerjumpto "Description" "statmis##description"}{...}
{viewerjumpto "Examples" "statmis##examples"}{...}
{viewerjumpto "Stored results" "statmis##results"}{...}
{viewerjumpto "Version" "statmis##version"}{...}
{viewerjumpto "Authors" "statmis##authors"}{...}
{title:Title}

{phang}
{bf:statmis} {hline 2} Statistics of missing values


{marker syntax}{...}
{title:Syntax}

{p 4 12 2}
{cmd:statmis} [{varlist}] {ifin}{cmd:,} [excluded nst({it:string})]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt excluded}}exclude variables; obtain results for all variables except those of {varlist}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Statistics of missing values. 

{p 4 4}
This command adds an auxiliary variable named {bf:_NMiss} to the dataset. If a variable with this name
already exists, it is overwritten. This variable allows to identify and/or drop observations with missing values,
as it contains the number of missing values for each observation for the given variables. 

{p 4 4}
Not applicable values previously coded as .z are excluded from the missing group.

{p 4 4}
By default all the variables in the dataset are used.

{p 4 4}
You can click {dialog statmis:here} to pop up a {dialog statmis:dialog} or type {inp: db statmis}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate statmis, update} to update the {bf:statmis} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help summarize} and {help tabulate} Stata commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}
{p 4 4}{stata "use http://www.graunt.cat/stata/Salud.dta":. use http://www.graunt.cat/stata/Salud.dta}{p_end}
{p 4 4}{cmd:. statmis}{p_end}
{p 4 4}{cmd:. statmis Sexo HabitFum PTc IMC Edad HTA}{p_end}
{p 4 4}{cmd:. statmis HabitFum EdadF Tab CIE}{p_end}
{p 4 4}{cmd:. statmis PAS PAD H1 - NivObs, excluded}{p_end}


{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following scalars in {cmd:r()}:

{synoptset 18 tabbed}{...}
{synopt:{cmd:r(nsysmis)}}total number of sysmis values{p_end}
{synopt:{cmd:r(nuser)}}total number of user-missing values{p_end}
{synopt:{cmd:r(nmissing)}}total number of missing values{p_end}
{synopt:{cmd:r(pmissing)}}total percent of missing values{p_end}
{synopt:{cmd:r(na)}}total number of not applicable values{p_end}
{synopt:{cmd:r(nvalid)}}total number of valid values{p_end}
{synopt:{cmd:r(pvalid)}}total percent of valid values{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.3 {hline 2} 22 October 2018


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@graunt.cat


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM. Statistics of missing values: User-written command statmis for Stata [computer program].{break}
V1.1.3. Barcelona: Graunt21; 2018.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}
