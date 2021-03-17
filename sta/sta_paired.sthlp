{smcl}
{* *! version 1.1.5 17mar2021}{...}
{viewerdialog sta "dialog sta"}{...}
{viewerdialog stai "dialog stai"}{...}
{viewerjumpto "Syntax" "sta_paired##syntax"}{...}
{viewerjumpto "Description" "sta_paired##description"}{...}
{viewerjumpto "Examples" "sta_paired##examples"}{...}
{viewerjumpto "Stored results" "sta_paired##results"}{...}
{title:Title}

{phang}
{bf:sta} {hline 2} Association Measures (paired data)


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:sta} {it:{help varname:var_Y}} {it:{help varname:var_X}} {ifin}{cmd:, data(paired)}
[{it:{help sta_paired##options:options}}]

{p 8 8 2}
{cmd:stai} {it:#a11 #a10 #a01 #a00}{cmd:, data(paired)} [{it:{help sta_paired##options:options}}]



{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt relatsymm}}relative symmetry results{p_end}
{synopt :{opt notables}}do not show 2x2 tables; by default, 2x2 are shown{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); the {bf:default} is {bf:level(95)}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Measures of Association for paired data.

{p 4 4}
The command needs the Y and X variables to compute the results. 
Only {cmd:relatsymm}, {cmd:level}, {cmd:notables} and {cmd:nst} options make sense.

{p 4 4}
{cmd:stai} is the immediate form of {cmd:sta}; see {help immed}.
The sequence of {it:#a11}, {it:#a10}, {it:#a01} and {it:#a00} come from a contingency table:{break}

{p 4 4}
{space 9}{c |} X{break}
{space 9}{c |}{space 5}(-) {c |}{space 5}(+) {c |}{break}
{hline 9}{c +}{hline 9}{c +}{hline 9}{c RT}{break}
Y{space 4}(+) {c |}{space 2} {bf:a10} {space 2}{c |}{space 2} {bf:a11} {space 2}{c |}{break}
{space 5}(-) {c |}{space 2} {bf:a00} {space 2}{c |}{space 2} {bf:a01} {space 2}{c |}{break}
{hline 9}{c BT}{hline 9}{c BT}{hline 9}{c BRC}{break}


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://metodo.uab.cat/stata/ParacetAspirin.dta":. use http://metodo.uab.cat/stata/ParacetAspirin.dta}{p_end}
{p 4 4}{cmd:. sta Paracetamol Aspirin, data(paired)}{p_end}
{p 4 4}{cmd:. sta Paracetamol Aspirin, data(paired) relatsymm}{p_end}

{p 4 4}{cmd:. stai 2 7 1 0, data(paired)}{p_end}
{p 4 4}{cmd:. stai 3 0 1 5, data(paired) relatsymm}{p_end}


{title:Stored results}

{pstd}
The command stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2colset 8 30 35 2}{...}
{p2col 5 19 20 2: {it:Scalars}}{p_end}
{synopt:{cmd:r(a11)}}number of cases exposed & controls exposed{p_end}
{synopt:{cmd:r(a10)}}number of cases exposed & controls unexposed{p_end}
{synopt:{cmd:r(a01)}}number of cases unexposed & controls exposed{p_end}
{synopt:{cmd:r(a00)}}number of cases unexposed & controls unexposed{p_end}

{p2col 5 19 20 2: {it:Paired samples}}{p_end}
{synopt:{cmd:r(d)}}difference Pr(Y+)-Pr(X+){p_end}
{synopt:{cmd:r(lb_d_exact)}}exact lower bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(ub_d_exact)}}exact upper bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(lb_d_new)}}Newcombe lower bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(ub_d_new)}}Newcombe upper bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(lb_d_asym)}}asymptotic lower bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(ub_d_asym)}}asymptotic upper bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(se_d_asym)}}estimate of standard error of {bf:d}{p_end}
{synopt:{cmd:r(lb_d_asym_corr)}}asymptotic corrected lower bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(ub_d_asym_corr)}}asymptotic corrected upper bound of CI for {bf:d}{p_end}
{synopt:{cmd:r(or)}}odds ratio (exposure-disease){p_end}
{synopt:{cmd:r(lb_or_exact)}}exact lower bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(ub_or_exact)}}exact upper bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(lb_or_wilson)}}Wilson lower bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(ub_or_wilson)}}Wilson upper bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(lb_or_asym)}}asymptotic lower bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(ub_or_asym)}}asymptotic upper bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(se_or_asym)}}estimate of standard error of {bf:or}{p_end}
{synopt:{cmd:r(p_McNemar)}}McNemar matched-pair p-value{p_end}
{synopt:{cmd:r(chi2_exact)}}exact simmetry chi-square{p_end}
{synopt:{cmd:r(p_exact)}}exact simmetry p-value{p_end}
{synopt:{cmd:r(chi2_exact_corr)}}corrected exact simmetry chi-square{p_end}
{synopt:{cmd:r(p_exact_corr)}}corrected exact simmetry p-value{p_end}
{synopt:{cmd:r(or_assoc)}}test of association or{p_end}
{synopt:{cmd:r(chi2_assoc)}}test of association chi-square{p_end}
{synopt:{cmd:r(p_assoc)}}test of association p-value{p_end}
{synopt:{cmd:r(chi2_assoc_corr)}}corrected test of association chi-square{p_end}
{synopt:{cmd:r(p_assoc_corr)}}corrected test of association p-value{p_end}

{p2col 5 19 20 2: {it:Relative simmetry}}{p_end}
{synopt:{cmd:r(pd)}}proportion difference{p_end}
{synopt:{cmd:r(lb_pd_wald)}}Wald lower bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(ub_pd_wald)}}Wald upper bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(lb_pd_new)}}Newcombe lower bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(ub_pd_new)}}Newcombe upper bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(pr)}}proportion ratio{p_end}
{synopt:{cmd:r(lb_pr)}}lower bound of CI for {bf:pr}{p_end}
{synopt:{cmd:r(ub_pr)}}upper bound of CI for {bf:pr}{p_end}
{synopt:{cmd:r(se_pr)}}estimate of standard error of {bf:pr}{p_end}
{synopt:{cmd:r(or)}}odds ratio{p_end}
{synopt:{cmd:r(lb_or)}}lower bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(ub_or)}}upper bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(se_or)}}estimate of standard error of {bf:or}{p_end}
{synopt:{cmd:r(chi2)}}exact simmetry chi-square{p_end}
{synopt:{cmd:r(p)}}exact simmetry p-value{p_end}
{synopt:{cmd:r(chi2_corr)}}corrected exact simmetry chi-square{p_end}
{synopt:{cmd:r(p_corr)}}corrected exact simmetry p-value{p_end}
{p2colreset}{...}

