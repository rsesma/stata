{smcl}
{* *! version 1.1.5 17mar2021}{...}
{title:Association measures}
{viewerdialog sta "dialog sta"}{...}
{viewerdialog stai "dialog stai"}{...}
{viewerjumpto "Notes" "notes##version"}{...}
{viewerjumpto "Version" "sta##version"}{...}
{viewerjumpto "Authors" "sta##authors"}{...}
{viewerjumpto "References" "sta##references"}{...}

    See

{p 8 32 2}
{helpb sta_freq: sta, data(freq)}{space 8}for non stratified frequency data

{p 8 32 2}
{helpb sta_freq_str: sta, data(freq) by()}{space 3}for stratified frequency data

{p 8 32 2}
{helpb sta_pt: sta, data(pt)}{space 10}for non stratified person-time data

{p 8 32 2}
{helpb sta_pt_str: sta, data(pt) by()}{space 5}for stratified person-time data

    and see

{p 8 32 2}
{helpb sta_paired: sta, data(paired)}{space 6}for paired data
{p_end}


{marker notes}{...}
{title:Notes}

{p 4 4}
{cmd:stai} is the immediate form of {cmd:sta}; see {help immed}. 

{p 4 4}
You can click {dialog sta:here} to pop up a {dialog sta:dialog} or type {inp: db sta}. For the 
immediate command, you can click {dialog stai:here} to pop up a {dialog stai:dialog} or type {inp: db stai}.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate sta, update} to update the {bf:sta} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help csi} and {help cci} Stata commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.5 {hline 2} 17 March 2021


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
Dom{c e'}nech JM. Association Measures (frequency, person-time & paired data):{break}
User-written command sta for Stata [computer program]{break}
V1.1.5. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2021.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Altman DG, Machin D, Bryant TN, Gardner MJ. Statistics with confidence. Confidence
intervals and statistical guidelines. 2nd ed. London: BMJ Books; 2000.{p_end}

{p 0 2}
Altman DG. {it:Confidence intervals for the number needed to treat}. BMJ. 1998; 317:1309-12.{p_end}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 9. Comparaci{c o'}n de dos
proporciones. Medidas de asociaci{c o'}n y de efecto. 18{c 170} ed. Barcelona: Signo; 2017.{p_end}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 14. Medida  del cambio: An{c a'}lisis de dise{c n~}os con
medidas intrasujeto. 18{c 170} ed. Barcelona: Signo; 2017.{p_end}

{p 0 2}
Delgado M, Llorca J, Dom{c e'}nech JM. Investigaci{c o'}n cient{c i'}fica: Fundamentos metodol{c o'}gicos y estad{c i'}sticos. 8{c 170}
ed. Barcelona: Signo; 2017.{p_end}

{p 0 2}
Newcombe RG. Two-sided confidence intervals for a single proportion: comparison of seven methods. Stat Med. 1998; 17:857-72.{p_end}

{p 0 2}
Newcombe RG. Interval estimation for the difference between independent
proportions: comparison of eleven methods. Stat Med. 1998;17(8):873-90. Erratum in: Stat Med.
1999;18(10):1293.{p_end}

{p 0 2}
Rothman KJ, Greenland S, Lash, TL. Modern Epidemiology. 3rd ed. Philadelphia: Lippincott Williams & Wilkins; 2008.{p_end}

{p 0 2}
Sweeting MJ, Sutton AJ, Lambert PC. What to add to nothing? Use and avoidance of continuity
corrections in meta-analysis of sparse data. Stat Med. 2004; 23:1351-75.{p_end}
