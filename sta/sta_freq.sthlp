{smcl}
{* *! version 1.1.4 14apr2020}{...}
{viewerdialog sta "dialog sta"}{...}
{viewerdialog stai "dialog stai"}{...}
{viewerjumpto "Syntax" "sta_freq##syntax"}{...}
{viewerjumpto "Description" "sta_freq##description"}{...}
{viewerjumpto "Examples" "sta_freq##examples"}{...}
{viewerjumpto "Stored results" "sta_freq##results"}{...}
{title:Title}

{phang}
{bf:sta} {hline 2} Association Measures (non stratified frequency data)


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:sta} {it:{help varname:var_response}} {it:{help varname:var_exposure}} {ifin}{cmd:, data(freq)} [{it:{help sta_freq##options:options}}]

{p 8 4 2}
{cmd:stai} {it:#a1 #a0 #b1 #b0}{cmd:, data(freq)} [{it:{help sta_freq##options:options}}]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt st(type)}}study type; valid values are: {space 7} default is {bf:st(cs)}{break}{bf:cs} (cross-sectional){break}
{bf:co} (cohort){break}{bf:ex} (experimental){break}{bf:cc} (case-control){p_end}
{synopt :{opt w:ilson}}calculate Wilson confidence intervals; the {bf:default}{p_end}
{synopt :{opt e:xact}}calculate exact confidence intervals{p_end}
{synopt :{opt wa:ld}}calculate Wald confidence intervals{p_end}
{synopt :{opt p:earson}}calculate Pearson association chi-squared; the {bf:default}{p_end}
{synopt :{opt mh}}calculate Mantel-Haenszel association chi-squared{p_end}
{synopt :{opt zero(correct)}}continuity correction for cells with zero events:{break}
{bf:n} None {space 28} default is {bf:zero(n)}{break}
{bf:c} Constant, add k=0.5 to each cell{break}
{bf:p} Proportional, add k1=N1/N and k0=N0/N for {bf:ex}, {bf:co} & {bf:cs} studies{break}
{space 15} add k1=M1/N and k0=M0/N for {bf:cc} studies{break}
{bf:r} Reciprocal, add k1=1/N0 and k0=1/N1 for {bf:ex}, {bf:co} & {bf:cs} studies{break}
{space 14}add k1=1/M0 and k0=1/M1 for {bf:cc} studies{break}
The recommended correction is {bf:reciprocal}{p_end}
{synopt :{opt notables}}do not show 2x2 frequency tables; by default, 2x2 tables are shown{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); the {bf:default} is {bf:level(95)}{p_end}
{synopt :{opt det:ail}}display additional statistics{p_end}
{synopt :{opt pe(#)}}proportion of exposed in the population{p_end}
{synopt :{opt r(#)}}proportion of cases in the population; {bf: case-control} type only{p_end}
{synopt :{opt rare}}rare disease; {bf: case-control} type only{p_end}
{synopt :{opt nnt(#)}}compute number needed to treat. The code is 1 for a benefit outcome (default) and 0 for a harmful outcome; {bf:experimental} type only{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Measures of Association for non stratified frequency data.

{p 4 4}
Cross-sectional, cohort, experimental and case-control studies are available. The command needs the response and 
exposure variables to compute the results.

{p 4 4}
For experimental studies [{cmd:st(ex)}] the {bf:number needed to treat} may be computed with option {cmd:nnt}.

{p 4 4}
For case-control studies [{cmd:st(cc)}] only one of {cmd:r} or {cmd:pe} may be included.

{p 4 4}
Proportion of exposed in the population [{cmd:pe()}] may be included when additional statistics [{cmd:detail}] are 
computed for cross-sectional, cohort and experimental studies.

{p 4 4}
Newcombe (method 10) and Wald confidence intervals are computed for the Risk Difference (RD).

{p 4 4}
{cmd:stai} is the immediate form of {cmd:sta}; see {help immed}. The sequence of {it:#a1}, {it:#a0}, {it:#b1} 
and {it:#b0} come from a contingency table:{break}

{p 4 4}
{space 9}{c |}UnExposed{c |} Exposed {c |} Total{break}
{hline 9}{c +}{hline 9}{c +}{hline 9}{c +}{hline 6} {break}
{space 3}Cases {c |} {space 2}{bf:a0} {space 2} {c |} {space 2}{bf:a1} {space 2} {c |}{space 2} m1 {break}
NonCases {c |} {space 2}{bf:b0}  {space 2} {c |} {space 2}{bf:b1}  {space 2} {c |}{space 2} m0 {break}
{hline 9}{c +}{hline 9}{c +}{hline 9}{c +}{hline 6} {break}
{space 3}Total {c |} {space 2}n0 {space 2} {c |} {space 2}n1 {space 2} {c |} {space 2}n {break}


{marker examples}{...}
{title:Examples}

{it:Cross-Sectional}
{p 4 4}{stata "use http://metodo.uab.cat/stata/ObesArt.dta":. use http://metodo.uab.cat/stata/ObesArt.dta}{p_end}
{p 4 4}{cmd:. sta Art Obes, data(freq) st(cs) wilson nst(Study name)}{p_end}

{p 4 4}{cmd:. stai 9 1 1191 999, data(freq) st(cs) wilson}{p_end}
{p 4 4}{cmd:. stai 9.4 1 1190.6 999, data(freq) st(cs)}{p_end}

{it:Cohort}
{p 4 4}{stata "use http://metodo.uab.cat/stata/SmokePreterm.dta":. use http://metodo.uab.cat/stata/SmokePreterm.dta}{p_end}
{p 4 4}{cmd:. sta Preterm Smoke, data(freq) st(co) wilson}{p_end}
{p 4 4}{cmd:. sta Preterm Smoke, data(freq) st(co) wilson pe(0.4) detail}{p_end}

{p 4 4}{cmd:. stai 100 90 100 990, data(freq) st(co) exact}{p_end}

{it:Experimental}
{p 4 4}{stata "use http://metodo.uab.cat/stata/TreatHeal.dta":. use http://metodo.uab.cat/stata/TreatHeal.dta}{p_end}
{p 4 4}{cmd:. sta Heal Treat, data(freq) st(ex) wilson}{p_end}

{p 4 4}{cmd:. stai 100 90 100 990, data(freq) st(ex) nnt(1)}{p_end}
{p 4 4}{cmd:. stai 100 0 100 1080, data(freq) st(ex) zero(c)}{p_end}

{it:Case-Control}
{p 4 4}{stata "use http://metodo.uab.cat/stata/SmokeCancer.dta":. use http://metodo.uab.cat/stata/SmokeCancer.dta}{p_end}
{p 4 4}{cmd:. sta Cancer Smoke, data(freq) st(cc) wilson}{p_end}

{p 4 4}{stata "use http://metodo.uab.cat/stata/ContrCancer.dta":. use http://metodo.uab.cat/stata/ContrCancer.dta}{p_end}
{p 4 4}{cmd:. sta Cancer Contr, data(freq) st(cc) wilson}{p_end}
{p 4 4}{cmd:. sta Cancer Contr, data(freq) st(cc) wilson r(0.0003) detail rare}{p_end}

{p 4 4}{cmd:. stai 10 90 2 198, data(freq) st(cc) wald}{p_end}
{p 4 4}{cmd:. stai 10 90 2 198, data(freq) st(cc) r(0.0900909)}{p_end}
{p 4 4}{cmd:. stai 100 0 2 198, data(freq) st(cc) pe(0.018108) zero(r)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
The command stores the following scalars in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: {it:All}}{p_end}
{synopt:{cmd:r(a0)}}number of cases unexposed{p_end}
{synopt:{cmd:r(a1)}}number of cases exposed{p_end}
{synopt:{cmd:r(m1)}}total number of cases{p_end}
{synopt:{cmd:r(b0)}}number of noncases/controls unexposed{p_end}
{synopt:{cmd:r(b1)}}number of noncases/controls exposed{p_end}
{synopt:{cmd:r(m0)}}total number of noncases/controls{p_end}
{synopt:{cmd:r(n0)}}total number of unexposed{p_end}
{synopt:{cmd:r(n1)}}total number of exposed{p_end}
{synopt:{cmd:r(n)}}total number of observations{p_end}
{synopt:{cmd:r(or)}}odds ratio{p_end}
{synopt:{cmd:r(lb_or_corn)}}Cornfield lower bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(ub_or_corn)}}Cornfield upper bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(lb_or_exact)}}Exact lower bound of CI for {bf:or} (Case-Control only){p_end}
{synopt:{cmd:r(ub_or_exact)}}Exact upper bound of CI for {bf:or} (Case-Control only){p_end}
{synopt:{cmd:r(lb_or_woolf)}}Woolf lower bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(ub_or_woolf)}}Woolf upper bound of CI for {bf:or}{p_end}
{synopt:{cmd:r(se_or_woolf)}}Woolf estimate of standard error of {bf:or}{p_end}
{synopt:{cmd:r(chi2)}}chi-squared{p_end}
{synopt:{cmd:r(p)}}two-sided p-value{p_end}
{synopt:{cmd:r(chi2_corr)}}corrected chi-squared{p_end}
{synopt:{cmd:r(p_corr)}}corrected two-sided p-value{p_end}
{synopt:{cmd:r(p_exact)}}Fisher exact test two-sided p-value{p_end}
{synopt:{cmd:r(pe_pop)}}Proportion of exposed in the population ({bf:detail} only for Cross-Sectional, Cohort & Experimental){p_end}
{synopt:{cmd:r(afe)}}attributable fraction exposed ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(lb_afe)}}lower bound of CI for {bf:afe} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(ub_afe)}}upper bound of CI for {bf:afe} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(afp)}}attributable fraction population ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(lb_afp)}}lower bound of CI for {bf:afp} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(ub_afp)}}upper bound of CI for {bf:afp} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(se_afp)}}estimate of standard error of {bf:afp} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(pfe)}}preventable fraction exposed ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(lb_pfe)}}lower bound of CI for {bf:pfe} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(ub_pfe)}}upper bound of CI for {bf:pfe} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(pfp)}}preventable fraction population ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(lb_pfp)}}lower bound of CI for {bf:pfp} ({bf:detail} only, whenever it's convenient){p_end}
{synopt:{cmd:r(ub_pfp)}}upper bound of CI for {bf:pfp} ({bf:detail} only, whenever it's convenient){p_end}

{p2col 5 15 19 2: {it:Cross-sectional}}{p_end}
{synopt:{cmd:r(pd)}}prevalence difference{p_end}
{synopt:{cmd:r(lb_pd_new)}}Newcombe lower bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(ub_pd_new)}}Newcombe upper bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(lb_pd_wald)}}Wald lower bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(ub_pd_wald)}}Wald upper bound of CI for {bf:pd}{p_end}
{synopt:{cmd:r(se_pd_wald)}}Wald estimate of standard error of {bf:pd}{p_end}
{synopt:{cmd:r(pr)}}prevalence ratio{p_end}
{synopt:{cmd:r(lb_pr)}}lower bound of CI for {bf:pr}{p_end}
{synopt:{cmd:r(ub_pr)}}upper bound of CI for {bf:pr}{p_end}
{synopt:{cmd:r(se_pr)}}estimate of standard error of {bf:pr}{p_end}
{synopt:{cmd:r(pdp)}}prevalence difference in the population ({bf:detail} only){p_end}
{synopt:{cmd:r(lb_pdp)}}lower bound of CI for {bf:pdp} ({bf:detail} only){p_end}
{synopt:{cmd:r(ub_pdp)}}upper bound of CI for {bf:pdp} ({bf:detail} only){p_end}
{synopt:{cmd:r(se_pdp)}}estimate of standard error of {bf:pdp} ({bf:detail} only){p_end}

{p2col 5 15 19 2: {it:Cohort} & {it:Experimental}}{p_end}
{synopt:{cmd:r(rd)}}risk difference{p_end}
{synopt:{cmd:r(lb_rd_new)}}Newcombe lower bound of CI for {bf:rd}{p_end}
{synopt:{cmd:r(ub_rd_new)}}Newcombe upper bound of CI for {bf:rd}{p_end}
{synopt:{cmd:r(lb_rd_wald)}}Wald lower bound of CI for {bf:rd}{p_end}
{synopt:{cmd:r(ub_rd_wald)}}Wald upper bound of CI for {bf:rd}{p_end}
{synopt:{cmd:r(se_rd_wald)}}Wald estimate of standard error of {bf:rd}{p_end}
{synopt:{cmd:r(rr)}}risk ratio{p_end}
{synopt:{cmd:r(lb_rr)}}Woolf lower bound of CI for {bf:rr}{p_end}
{synopt:{cmd:r(ub_rr)}}Woolf upper bound of CI for {bf:rr}{p_end}
{synopt:{cmd:r(se_rr)}}Woolf estimate of standard error of {bf:rr}{p_end}
{synopt:{cmd:r(nnt)}}number needed to treat (Experimental only){p_end}
{synopt:{cmd:r(lb_nnt)}}lower bound of CI for {bf:nnt} (Experimental only){p_end}
{synopt:{cmd:r(ub_nnt)}}upper bound of CI for {bf:nnt} (Experimental only){p_end}
{synopt:{cmd:r(rdp)}}risk difference in the population ({bf:detail} only){p_end}
{synopt:{cmd:r(lb_rdp)}}lower bound of CI for {bf:rdp} ({bf:detail} only){p_end}
{synopt:{cmd:r(ub_rdp)}}upper bound of CI for {bf:rdp} ({bf:detail} only){p_end}
{synopt:{cmd:r(se_rdp)}}estimate of standard error of {bf:rdp} ({bf:detail} only){p_end}

{p2col 5 15 19 2: {it:Case-Control}}{p_end}
{synopt:{cmd:r(r)}}population risk (when available){p_end}
{synopt:{cmd:r(pe)}}exposed proportion (when available){p_end}
{synopt:{cmd:r(pr)}}proportion ratio (when available){p_end}
{synopt:{cmd:r(pd)}}proportion difference (when available){p_end}
{synopt:{cmd:r(pdp)}}proportion difference in the population ({bf:detail} only}){p_end}
{p2colreset}{...}
