{smcl}
{* *! version 1.1.7 24dec2018}{...}
{viewerdialog agree "dialog agree"}{...}
{viewerjumpto "Syntax" "agree##syntax"}{...}
{viewerjumpto "Description" "agree##description"}{...}
{viewerjumpto "Examples" "agree##examples"}{...}
{viewerjumpto "Stored results" "agree##results"}{...}
{viewerjumpto "Version" "agree##version"}{...}
{viewerjumpto "Authors" "agree##authors"}{...}
{viewerjumpto "References" "agree##references"}{...}
{title:Title}

{phang}
{bf:agree} {hline 2} Agreement: Passing-Bablok & Bland-Altman methods


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:agree} {it:{help varname:varnameY}} {it:{help varname:varnameX}} {ifin} [{cmd:,} {it:{help agree##options:options}}]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt ba}}calculate Bland-Altman comparison of two measurements methods; the {bf:default}{p_end}
{synopt :{opt pb}}calculate Passing-Bablok estimation of regression line{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); default is {bf:level(95)}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{syntab:{it:Bland-Altman method}}
{synopt :{opt pct}}compute percentage values and graphic{p_end}
{synopt :{opt line}}show regression line on Bland-Altman graphics{p_end}
{syntab:{it:Passing-Bablok method}}
{synopt :{opt ci}}show confidence intervals on Passing-Bablok graphic{p_end}
{synopt :{opt list}}list input data; the report include X-Y changes (Passing-Bablok only){p_end}
{synopt :{opt id(varname)}}name of variable with identifier of cases for the list;  default is {bf:{help _n:_n}}{p_end}
{synoptline}
{phang}
{cmd:by} is allowed; see {manhelp by D}.


{marker description}{...}
{title:Description}

{p 4 4 2}
Passing-Bablok and Bland-Altman methods of agreement. The command needs the names of the numeric variables
with method X (reference) and method Y.

{p 4 4}
You can click {dialog agree:here} to pop up a {dialog agree:dialog} or type {inp: db agree}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install.

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate agree, update} to update the {bf:agree} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help tabstat}, {help summarize}, {help swilk}, {help sktest} and {help spearman} Stata commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://www.graunt.cat/stata/agree_data.dta":. use http://www.graunt.cat/stata/agree_data.dta}{p_end}
{p 4 4}{cmd:. agree Instrumental Manual}{p_end}
{p 4 4}{cmd:. agree Instrumental Manual, ba pct line nst(Study name)}{p_end}
{p 4 4}{cmd:. agree Instrumental Manual, pb ci list id(Especimen)}{p_end}


{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following in {cmd:r()}:

{p 4 4}Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(N)}}valid number of cases (listwise){p_end}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}
{synopt:{cmd:r(lin)}}Lin's concordance correlation coeff. of absolute agreement{p_end}

{p2col 7 15 19 2: {it:Passing-Bablok regression line}}{p_end}
{synopt:{cmd:r(a)}}{bf:A}{p_end}
{synopt:{cmd:r(a_lb)}}lower bound of {bf:A} confidence interval{p_end}
{synopt:{cmd:r(a_ub)}}upper bound of {bf:A} confidence interval{p_end}
{synopt:{cmd:r(b)}}{bf:B}{p_end}
{synopt:{cmd:r(b_lb)}}lower bound of {bf:B} confidence interval{p_end}
{synopt:{cmd:r(b_ub)}}upper bound of {bf:B} confidence interval{p_end}

{p2col 7 15 19 2: {it:Bland-Altman Interval of Agreement}}{p_end}
{synopt:{cmd:r(mean)}}Y-X: Bias{space 29} {it:Absolute values}{p_end}
{synopt:{cmd:r(mean_se)}}Y-X: Bias std. error{space 18} {it:Absolute values}{p_end}
{synopt:{cmd:r(LoA_lb)}}lower bound of LoA{space 20} {it:Absolute values}{p_end}
{synopt:{cmd:r(LoA_ub)}}upper bound of LoA{space 20} {it:Absolute values}{p_end}
{synopt:{cmd:r(LoA_se)}}std. error of LoA{space 21} {it:Absolute values}{p_end}
{synopt:{cmd:r(mean_pct)}}Y-X: Bias{space 29} {it:Percentage values}{p_end}
{synopt:{cmd:r(mean_se_pct)}}Y-X: Bias std. error{space 18} {it:Percentage values}{p_end}
{synopt:{cmd:r(LoA_lb_pct)}}lower bound of LoA{space 20} {it:Percentage values}{p_end}
{synopt:{cmd:r(LoA_ub_pct)}}upper bound of LoA{space 20} {it:Percentage values}{p_end}
{synopt:{cmd:r(LoA_se_pct)}}std. error of LoA{space 21} {it:Percentage values}{p_end}
{synopt:{cmd:r(rho)}}Spearman correlation between (Y-X) and (X+Y)/2{p_end}
{synopt:{cmd:r(p_rho)}}significance of Spearman correlation{p_end}
{synopt:{cmd:r(W)}}Shapiro-Wilk {space 25} {it:Tests of Normality}{p_end}
{synopt:{cmd:r(p_W)}}significance of Shapiro-Wilk {space 9} {it:Tests of Normality}{p_end}
{synopt:{cmd:r(sk)}}Skewness {space 29} {it:Tests of Normality}{p_end}
{synopt:{cmd:r(p_sk)}}significance of Skewness {space 13} {it:Tests of Normality}{p_end}
{synopt:{cmd:r(ku)}}Kurtosis-3 {space 27} {it:Tests of Normality}{p_end}
{synopt:{cmd:r(p_ku)}}significance of Kurtosis-3 {space 11} {it:Tests of Normality}{p_end}
{synopt:{cmd:r(chi2)}}Skewness & Kurtosis {space 18} {it:Tests of Normality}{p_end}
{synopt:{cmd:r(p_chi2)}}significance of Skewness & Kurtosis {space 2} {it:Tests of Normality}{p_end}

{p 4 4}Macros{p_end}
{synopt:{cmd:r(cusum)}}Passing-Bablok CUSUM Test for deviation from linearity{p_end}

{p 4 4}Matrices{p_end}
{synopt:{cmd:r(Stats)}}Passing-Bablok statistics{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.7 {hline 2} 24 December 2018


{marker authors}{...}
{title:Authors}

{p 4 4 2}
JM.Dom{c e'}nech{break}
Programmer: R.Sesma{break}
Laboratori d'Estad{c i'}stica Aplicada{break}
Universitat Aut{c o'g}noma de Barcelona{break}
stata@graunt.cat{break}


{title:Vancouver reference}

{p 4 6 2}
Dom{c e'}nech JM. Passing-Bablok & Bland-Altman methods: User-written command agree for Stata [computer program].{break}
V1.1.7s. Barcelona: Graunt21; 2018.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Bablok W, Passing H, Bender R, Schneider B. A general regression procedure for method transformation. Application
of linear regression procedures for method comparison studies in clinical chemistry. Part III. J Clin
Chem Clin Biochem. 1988;26:783-90.{p_end}

{p 0 2}
Bland M, Altman DG. Statistical methods for assessing agreement between two methods of clinical measurement. Lancet. 1986;1:307-10.{p_end}

{p 0 2}
Bland M, Altman DG. Comparing two methods of clinical measurement: a personal history. Int J Epidemiol. 1995;24 (Suppl. 1):S7-S14.{p_end}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 14. Medida  del cambio: An{c a'}lisis de dise{c n~}os con medidas
intrasujeto. 20{c 170} ed. Barcelona: Signo; 2019.{p_end}

{p 0 2}
Giavarina D. Understanding Bland Altman analysis. Biochem Med (Zagreb). 2015;25(2):141-51.

{p 0 2}
Lin LI. Concordance Correlation Coefficient to Evaluate Reproducibility. Biometrics. 1989;45:255-68.{p_end}

{p 0 2}
Lin LI. Assay Validation Using the Concordance Correlation Coefficient. Biometrics. 1992;48:599-604.{p_end}

{p 0 2}
Passing H, Bablok W. A new biometrical procedure for testing the equality of measurements from two different
analytical methods. Application of linear regression procedures for method comparison studies in clinical
chemistry. Part I. J Clin Chem Clin Biochem. 1983;21:709-20.{p_end}

{p 0 2}
Passing H, Bablok W. Comparison of several regression procedures for method comparison studies and determination
of sample size. Application of linear regression procedures for method comparison studies in clinical
chemistry. Part II. J Clin Chem Clin Biochem. 1984;22:431-45.{p_end}

{p 0 2}
Passing H, Bablok W. Application of statistical procedures in analytical instrument testing. J Automat
Chem. 1985;7(2):74-9.{p_end}
