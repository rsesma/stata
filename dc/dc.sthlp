{smcl}
{* *! version 1.1.0 30sep2019}{...}
{viewerdialog dc "dialog dc"}{...}
{vieweralsosee "dcreport" "help dcreport"}{...}
{viewerjumpto "Syntax" "dc##syntax"}{...}
{viewerjumpto "Description" "dc##description"}{...}
{viewerjumpto "Examples" "dc##examples"}{...}
{viewerjumpto "Version" "dc##version"}{...}
{viewerjumpto "Authors" "dc##authors"}{...}
{viewerjumpto "References" "dc##references"}{...}
{title:Title}

{phang}
{bf:dc} {hline 2} Data Check


{marker syntax}{...}
{title:Syntax}

{p 4 12 2}
{cmd:dc} {varlist} [{cmd:,} {it:{help dc##options:options}}]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{it:Identifier}}
{synopt :{opt isid}}checks whether the specified variables uniquely identify the observations (there are no missing or duplicates values){p_end}
{syntab:{it:Range}}
{synopt :{opt vl(valid_list)}}list of valid values; examples: 150/200, 0/80 99, 1 2 3, F M{p_end}
{syntab:{it:Dictionary File}}
{synopt :{opth table(filename)}}use a dictionary to check the values of the specified variables{p_end}
{synopt :{opth vk(varname)}}variable name with the valid values on the dictionary file{p_end}
{syntab:{it:Date Range}}
{synopt :{opt di(date)}}Initial Date, DMY format; examples: 01/04/2006, 01jan2012, 15-6-1997{p_end}
{synopt :{opt df(date)}}Final Date, DMY format; examples: 01/04/2006, 01jan2012, 15-6-1997{p_end}
{syntab:{it:Date Difference}}
{synopt :{opt dd(date_diff)}}Date difference expression, as a substraction{p_end}
{synopt :{opt ddl(min_val)}}Minimum value of the date difference{p_end}
{synopt :{opt ddl(max_val)}}Maximum value of the date difference{p_end}
{synopt :{opt ddunit(units)}}Date difference units; valid values are days (default) or years{p_end}
{syntab:{it:General}}
{synopt :{opth id(varlist)}}Identifier variables{p_end}
{synopt :{opt nd(num_dec)}}Number of allowed decimals; by default {bf:nd(0)}{p_end}
{synopt :{opth varl(varlist)}}List of additional variables to list{p_end}
{synopt :{opt nomissing}}Treat missing values as errors; by default missing values are allowed{p_end}
{synopt :{opt nodups}}Treat duplicate values as errors; by default duplicate values are allowed{p_end}
{syntab:{it:Logical Check}}
{synopt :{opt code1(#)}}Error code for logical check 1{p_end}
{synopt :{opt expr1(expr)}}Logical expression that identifies the logical check 1{p_end}
{synopt :{opt code2(#)}}Error code for logical check 2{p_end}
{synopt :{opt expr2(expr)}}Logical expression that identifies the logical check 2{p_end}
{synopt :{opt code3(#)}}Error code for logical check 3{p_end}
{synopt :{opt expr3(expr)}}Logical expression that identifies the logical check 3{p_end}
{synopt :{opt code4(#)}}Error code for logical check 4{p_end}
{synopt :{opt expr4(expr)}}Logical expression that identifies the logical check 4{p_end}
{synopt :{opt code5(#)}}Error code for logical check 5{p_end}
{synopt :{opt expr5(expr)}}Logical expression that identifies the logical check 5{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Data Check. 

{p 4 4}
An observation number variable called {bf:_ObsNum} must exist in the dataset before {bf: any} {cmd: dc} call.
To create this variable, execute:{break}
{cmd:. generate _ObsNum = _n}{break}

{p 4 4}
Auxiliary variables named {bf:_Er_varname} are added to the dataset for each checked variable (any existing variable
with the same name will be replaced). These auxiliary variables 
are used to store error codes, and allow the {cmd:dcreport} command to create an Incidence Report, see {help dcreport}.

{p 4 4}
Up to 5 optional logical checks are available. To define a logical ckeck, assign an error code greater than or equal to 10 
and write the logical expression that identifies the error; the expression must be true when there's an error.

{p 4 4}
You can click {dialog dc:here} to pop up a {dialog dc:dialog} or type {inp: db dc}.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate dc, update} to update the {bf:dc} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker examples}{...}
{title:Examples}
{p 4 4}{cmd:. dc Id, isid}{p_end}
{p 4 4}{cmd:. dc Peso, vl(45/120) nd(1) id(Id)}{p_end}
{p 4 4}{cmd:. dc H1 H2 H3, vl(0 1 2) id(Id)}{p_end}
{p 4 4}{cmd:. dc Sex, vl(F M) id(Id)}{p_end}
{p 4 4}{cmd:. dc CIE, table(C:\...\CIE9.dta) vk(cie9) id(Id)}{p_end}
{p 4 4}{cmd:. dc FR, di(01/04/2006) df(15/04/2006) nomissing id(Id)}{p_end}
{p 4 4}{cmd:. dc FN, dd(FR-FN) ddl(18) ddu(90) ddunit(years) id(Id)}{p_end}
{p 4 4}{cmd:. dc PAS, vl(100/200) id(Id) code1(10) expr1(PAD>=PAS & PAD<.)}{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.0 {hline 2} 30 September 2019


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
Dom{c e'}nech JM. Data Check: User-written command dc for Stata [computer program].{break}
V1.1.0. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2019.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Bonillo-Mart{c i'}n A. Sistematizaci{c o'}n del proceso de depuraci{c o'}n de los datos en estudios con
seguimientos [Tesis doctoral]. Barcelona: Universitat Aut{c o'g}noma de Barcelona; 2003.{p_end}
