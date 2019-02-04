{smcl}
{* *! version 1.1.4 04feb2019}{...}
{viewerdialog dt "dialog dt"}{...}
{viewerdialog dti "dialog dti"}{...}
{viewerjumpto "Syntax" "dt##syntax"}{...}
{viewerjumpto "Description" "dt##description"}{...}
{viewerjumpto "Examples" "dt##examples"}{...}
{viewerjumpto "Stored results" "dt##results"}{...}
{viewerjumpto "Version" "dt##version"}{...}
{viewerjumpto "Authors" "dt##authors"}{...}
{viewerjumpto "References" "dt##references"}{...}
{title:Title}

{phang}
{bf:dt} {hline 2} Diagnostic Tests


{marker syntax}{...}
{title:Syntax}

{phang}Syntax for {cmd:dt} - cross-sectional & case-control studies

{p 8 12 2}
{cmd:dt} {it:{help varname:var_test}} {it:{help varname:var_reference}} {ifin} [{cmd:,} {it:{help dt##options:options}}]


{phang}Immediate command

{p 8 12 2}
{cmd:dti} {it:#a1 #a0 #b1 #b0} [{cmd:,} {it:{help dt##options:options}}]


{phang}Syntax for Bayes theorem

{p 8 12 2}
{cmd:dti} {it:#sensitivity #specificity}{cmd:, st(bt) p(}{it:{help dt##pnumlist:numlist}}{cmd:)}

{phang}or

{p 8 12 2}
{cmd:dti} {it:#a1 #a0 #b1 #b0}{cmd:, st(bt) p(}{it:{help dt##pnumlist:numlist}}{cmd:)}


{marker options}{...}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt st(type)}}study type; valid values are:{break}
{bf:cs} Cross-sectional{space 3}({bf:default}){break}
{bf:cc} Case-control{break}
{bf:bt} Bayes theorem{p_end}
{marker pnumlist}{...}
{synopt :{opt p(numlist)}}list of hypothetical population prevalence (%){break}
This option is needed for Bayes theorem{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{syntab:{it:Cross-sectional & Case-control}}
{synopt :{opt valtest(#neg #pos)}}diagnostic test variable values for {it:negative}, {it:positive}; default is {cmd:valtest(0 1)}{p_end}
{synopt :{opt valref(#noncase #case)}}reference criterion variable values for {it:noncase}, {it:case}; default is {cmd:valref(0 1)}{p_end}
{synopt :{opt w:ilson}}calculate Wilson confidence intervals; the {bf:default}{p_end}
{synopt :{opt e:xact}}calculate exact confidence intervals{p_end}
{synopt :{opt wa:ld}}calculate Wald confidence intervals{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); default is {bf:level(95)}{p_end}
{syntab:{it:Case-control only}}
{synopt :{opt m1(#)}}total cases in a population sample{p_end}
{synopt :{opt n(#)}}size of population sample{break}
{bf:m1} and {bf:n} options go together, {cmd:n > m1}{p_end}
{synoptline}
{phang}
{cmd:by} is allowed; see {manhelp by D}.


{marker description}{...}
{title:Description}

{p 4 4 2}
Diagnostic Tests for Cross-sectional, Case-Control studies and Bayes theorem.

{dlgtab:Cross-sectional & Case-Control}

{p 4 4}
Cross-sectional and case-control studies are available. The command needs the diagnostic test and
reference criterion variables to compute the results.

{p 4 4}
For case-control studies it is possible to provide {bf:m1, n} options to compute the prevalence in a
population sample. Monsour, Evans and Kupper (1991) confidence
intervals are computed for positive and negative predictive values for case-control estudies.

{p 4 4}
{cmd:dti} is the immediate form of {cmd:dt}; see {help immed}.

{p 4 4}
The sequence of {it:#a1}, {it:#a0}, {it:#b1} and {it:#b0} for {cmd:dti} come from a contingency table:{break}

{p 4 4}
{space 10}{c |}NonCases{c |} Cases{break}
{hline 10}{c +}{hline 8}{c +}{hline 8}{break}
{space 1}Positive {c |}{space 3}{bf:b1}{space 3}{c |}{space 3}{bf:a1}{break}
{space 1}Negative {c |}{space 3}{bf:b0}{space 3}{c |}{space 3}{bf:a0}{break}
{hline 10}{c BT}{hline 8}{c BT}{hline 8}{p_end}

{dlgtab:Bayes theorem}

{p 4 4}
For the Bayes theorem, the immediate command needs the Sensitivity (%) and Specificity (%) values, or the
{it:#a1} {it:#a0} {it:#b1} {it:#b0} values (sensitivity an specificity are computed by the command). The
list of hypothetical population prevalences is also needed to compute the results.

{p 4 4}
You can click {dialog dt:here} to pop up a {dialog dt:dialog} or type {inp: db dt}. For the
immediate command, you can click {dialog dti:here} to pop up a {dialog dti:dialog} or type {inp: db dti}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install.

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate dt, update} to update the {bf:dt} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
This command uses the {help csi} and {help cii} Stata commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}
{p 4 4}{stata "use http://www.graunt.cat/stata/DiabGluc.dta":. use http://www.graunt.cat/stata/DiabGluc.dta}{p_end}

{it:Cross-Sectional}
{p 4 4}{cmd:. dt Glucose Diabetes, st(cs) valtest(0 1) valref(0 1) p(0.5 1(1)10)}{p_end}
{p 4 4}{cmd:. dti 65 90 48 396, st(cs) p(0.5 1(1)10)}{p_end}

{it:Case-Control}
{p 4 4}{cmd:. dt Glucose Diabetes, st(cc) p(2 4 6 8 10 12 15)}{p_end}
{p 4 4}{cmd:. dt Glucose Diabetes, st(cc) m1(98) n(765)}{p_end}
{p 4 4}{cmd:. dti 65 90 48 396, st(cc) p(2 4 6 8 10 12 15)}{p_end}
{p 4 4}{cmd:. dti 65 90 48 396, st(cc) m1(98) n(765)}{p_end}

{it:Bayes theorem}
{p 4 4}{cmd:. dti 90 80, st(bt) p(5 10 15 20 30 40)}{p_end}
{p 4 4}{cmd:. dti 65 90 48 396, st(bt) p(2 4 6 8 10)}{p_end}

{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following in {cmd:r()}:

{p 4 4}Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}

{p2col 7 15 19 2: {it:Cross-Sectional & Case-control}}{p_end}
{synopt:{cmd:r(a1)}}number of cases positive{p_end}
{synopt:{cmd:r(a0)}}number of cases negative{p_end}
{synopt:{cmd:r(b1)}}number of noncases positives{p_end}
{synopt:{cmd:r(b0)}}number of noncases negatives{p_end}
{synopt:{cmd:r(m1)}}total number of cases{p_end}
{synopt:{cmd:r(m0)}}total number of noncases{p_end}
{synopt:{cmd:r(n0)}}total number of negative {space 6}({cmd:st(cs)} only){p_end}
{synopt:{cmd:r(n1)}}total number of positive {space 6}({cmd:st(cs)} only){p_end}
{synopt:{cmd:r(n)}}total number of observations {space 2}({cmd:st(cs)} only){p_end}
{synopt:{cmd:r(m1_sample)}}total number of cases in the population sample {space 9}({cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(m0_sample)}}total number of noncases in the population sample {space 6}({cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(n_sample)}}total number of observations in the population sample {space 2}({cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(se)}}sensitivity{p_end}
{synopt:{cmd:r(lb_se)}}lower bound of sensitivity CI{p_end}
{synopt:{cmd:r(ub_se)}}upper bound of sensitivity CI{p_end}
{synopt:{cmd:r(sp)}}specificity{p_end}
{synopt:{cmd:r(lb_sp)}}lower bound of specificity CI{p_end}
{synopt:{cmd:r(ub_sp)}}upper bound of specificity CI{p_end}
{synopt:{cmd:r(fp)}}false positive{p_end}
{synopt:{cmd:r(lb_fp)}}lower bound of false positive CI{p_end}
{synopt:{cmd:r(ub_fp)}}upper bound of false positive CI{p_end}
{synopt:{cmd:r(fn)}}false negative{p_end}
{synopt:{cmd:r(lb_fn)}}lower bound of false negative CI{p_end}
{synopt:{cmd:r(ub_fn)}}upper bound of false negative CI{p_end}
{synopt:{cmd:r(lrp)}}likelihood ratio +{p_end}
{synopt:{cmd:r(lb_lrp)}}lower bound of likelihood ratio + CI{p_end}
{synopt:{cmd:r(ub_lrp)}}upper bound of likelihood ratio + CI{p_end}
{synopt:{cmd:r(lrn)}}likelihood ratio -{p_end}
{synopt:{cmd:r(lb_lrn)}}lower bound of likelihood ratio - CI{p_end}
{synopt:{cmd:r(ub_lrn)}}upper bound of likelihood ratio - CI{p_end}
{synopt:{cmd:r(or)}}odds ratio {space 28}({cmd:st(cs)} only){p_end}
{synopt:{cmd:r(lb_or)}}lower bound of odds ratio CI {space 10}({cmd:st(cs)} only){p_end}
{synopt:{cmd:r(ub_or)}}upper bound of odds ratio CI {space 10}({cmd:st(cs)} only){p_end}
{synopt:{cmd:r(pre)}}sample prevalence {space 21}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(lb_pre)}}lower bound of sample prevalence CI {space 3}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(ub_pre)}}upper bound of sample prevalence CI {space 3}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(pvp)}}predictive value + {space 20}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(lb_pvp)}}lower bound of predictive value + CI {space 2}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(ub_pvp)}}upper bound of predictive value + CI {space 2}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(pvn)}}predictive value - {space 20}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(lb_pvn)}}lower bound of predictive value - CI {space 2}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(ub_pvn)}}upper bound of predictive value - CI {space 2}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(eff)}}efficiency {space 28}({cmd:st(cs)} or {cmd:st(cc)} with {cmd:m1} & {cmd:n} options only){p_end}
{synopt:{cmd:r(lb_eff)}}lower bound of efficiency CI {space 10}({cmd:st(cs)} only){p_end}
{synopt:{cmd:r(ub_eff)}}upper bound of efficiency CI {space 10}({cmd:st(cs)} only){p_end}

{p2col 7 15 19 2: {it:Bayes theorem}}{p_end}
{p2col 7 15 19 2: {cmd:a1 a0 b1 b0 m1 m0 n1 n0 n} are stored if information provided}{p_end}
{synopt:{cmd:r(se)}}sensitivity{p_end}
{synopt:{cmd:r(sp)}}specificity{p_end}
{synopt:{cmd:r(fp)}}false positive{p_end}
{synopt:{cmd:r(fn)}}false negative{p_end}
{synopt:{cmd:r(lrp)}}likelihood ratio +{p_end}
{synopt:{cmd:r(lrn)}}likelihood ratio -{p_end}

{p 4 4}Matrices{p_end}
{synopt:{cmd:r(P)}}Post-test Probability statistics if option {cmd:p} provided{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.1.4 {hline 2} 4 February 2019


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
Dom{c e'}nech JM. Diagnostic tests: User-written command dt for Stata [computer program].{break}
V1.1.4. Barcelona: Graunt21; 2019.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Monsour MJ, Evans AT, Kupper LL. {it: Confidence intervals for post-test probability}. Stat Med. 1991;10:443-56.{p_end}

{p 0 2}
Dom{c e'}nech JM. Fundamentos de Dise{c n~}o y Estad{c i'}stica. UD 3. Teor{c i'}a y c{c a'}lculo de
probabilidades. Pruebas diagn{c o'}sticas. 16{c 170} ed. Barcelona: Signo; 2015.{p_end}
