{smcl}
{* *! version 1.0.8 30sep2019}{...}
{viewerdialog dcreport "dialog dcreport"}{...}
{vieweralsosee "dc" "help dc"}{...}
{viewerjumpto "Syntax" "dcreport##syntax"}{...}
{viewerjumpto "Description" "dcreport##description"}{...}
{viewerjumpto "Examples" "dcreport##examples"}{...}
{viewerjumpto "Version" "dcreport##version"}{...}
{viewerjumpto "Authors" "dcreport##authors"}{...}
{viewerjumpto "References" "dcreport##references"}{...}
{title:Title}

{phang}
{bf:dcreport} {hline 2} Data Check - Incidence Report


{marker syntax}{...}
{title:Syntax}

{p 4 12 2}
{cmd:dcreport} {varlist} {cmd:,} id(varlist) [idnum]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth id(varlist)}}Identifier variables{p_end}
{synopt :{opt idnum}}Use {bf:_ObsNum} observation number variable to identify cases in the error correction commands{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Data Check - Incidence Report. 

{p 4 4}
This command uses the auxiliary variables named {bf:_Er_varname} created by the Data Check {cmd:dc} command (see {help dc})
to print an Incidence Report with the problems found. If no variables are specified, all the {bf:_Er_varname}
variables in the dataset are used.

{p 4 4}
An observation number variable named {bf:_ObsNum} must contain the observation number of the original dataset. 

{p 4 4}
You can click {dialog dcreport:here} to pop up a {dialog dcreport:dialog} or type {inp: db dcreport}.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate dcreport, update} to update the {bf:dcreport} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker examples}{...}
{title:Examples}
{p 4 4}{cmd:. dcreport, id(Caso)}{p_end}
{p 4 4}{cmd:. dcreport _Er_Talla _Er_Peso _Er_H1 _Er_H2 _Er_H3, id(Caso) idnum}{p_end}
{p 4 4}{cmd:. dcreport _Er_Talla - _Er_H3, id(Caso)}{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.0.8 {hline 2} 30 September 2019


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@metodo.uab.cat


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM. Incidence Report: User-written command dcreport for Stata [computer program].{break}
V1.0.8. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2019.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Bonillo-Mart{c i'}n A. Sistematizaci{c o'}n del proceso de depuraci{c o'}n de los datos en estudios con
seguimientos [Tesis doctoral]. Barcelona: Universitat Aut{c o'g}noma de Barcelona; 2003.{p_end}
