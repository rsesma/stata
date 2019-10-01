{smcl}
{* *! version 1.1.2 30sep2019}{...}
{viewerdialog sta "dialog sta"}{...}
{viewerdialog stai "dialog stai"}{...}
{viewerjumpto "Syntax" "sta_pt##syntax"}{...}
{viewerjumpto "Description" "sta_pt##description"}{...}
{viewerjumpto "Examples" "sta_pt##examples"}{...}
{viewerjumpto "Stored results" "sta_pt##results"}{...}
{title:Title}

{phang}
{bf:sta} {hline 2} Association Measures (non stratified person-time data)


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:sta} {it:{help varname:var_response}} {it:{help varname:var_exposure}} {it:{help varname:var_time}} {ifin}{cmd:, data(pt)} [{it:{help sta_pt##options:options}}]

{p 8 4 2}
{cmd:stai} {it:#a1 #a0 #t1 #t0}{cmd:, data(pt)} [{it:{help sta_pt##options:options}}]


{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt notables}}do not show 2x2 tables; by default, 2x2 tables are shown{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); the {bf:default} is {bf:level(95)}{p_end}
{synopt :{opt det:ail}}display additional statistics{p_end}
{synopt :{opt pe(#)}}proportion of exposed in the population; {cmd: detail} option only{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Measures of Association for non stratified person-time data.

{p 4 4}
The command needs the response, exposure and time variables to compute the results.

{p 4 4}
Proportion of exposed in the population [{cmd:pe()}] may be included when additional statistics [{cmd:detail}] are 
computed.

{p 4 4}
{cmd:stai} is the immediate form of {cmd:sta}; see {help immed}. The sequence of {it:#a1}, {it:#a0}, {it:#t1} 
and {it:#t0} come from a contingency table:{break}

{p 4 4}
{space 12}{c |}UnExposed{c |} Exposed {c |} Total{break}
{hline 12}{c +}{hline 9}{c +}{hline 9}{c +}{hline 6} {break}
{space 6}Cases {c |} {space 2}{bf:a0} {space 2} {c |} {space 2}{bf:a1} {space 2} {c |}{space 2} m1 {break}
Person-time {c |} {space 2}{bf:t0} {space 2} {c |} {space 2}{bf:t1}  {space 2} {c |}{space 2} t {break}
{hline 12}{c BT}{hline 9}{c BT}{hline 9}{c BT}{hline 6} {break}


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://metodo.uab.cat/stata/BladderSmoking.dta":. use http://metodo.uab.cat/stata/BladderSmoking.dta}{p_end}
{p 4 4}{cmd:. sta Bladder Smoking Time, data(pt) detail}{p_end}
{p 4 4}{cmd:. stai 23 25 44607 141634, data(pt) detail}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
The command stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: {it:Scalars}}{p_end}
{synopt:{cmd:r(a0)}}number of cases unexposed{p_end}
{synopt:{cmd:r(a1)}}number of cases exposed{p_end}
{synopt:{cmd:r(m1)}}total number of cases{p_end}
{synopt:{cmd:r(t0)}}unexposed person-time{p_end}
{synopt:{cmd:r(t1)}}exposed person-time{p_end}
{synopt:{cmd:r(t)}}total person-time{p_end}
{synopt:{cmd:r(i0)}}unexposed incidence rate{p_end}
{synopt:{cmd:r(i1)}}exposed incidence rate{p_end}
{synopt:{cmd:r(i)}}total incidence rate{p_end}
{synopt:{cmd:r(id)}}incidence rate difference{p_end}
{synopt:{cmd:r(lb_id)}}lower bound of CI for {bf:id}{p_end}
{synopt:{cmd:r(ub_id)}}upper bound of CI for {bf:id}{p_end}
{synopt:{cmd:r(ir)}}incidence rate ratio{p_end}
{synopt:{cmd:r(lb_ir)}}lower bound of CI for {bf:ir}{p_end}
{synopt:{cmd:r(ub_ir)}}upper bound of CI for {bf:ir}{p_end}
{synopt:{cmd:r(se_ir)}}estimate of standard error of {bf:ir}{p_end}
{synopt:{cmd:r(lb_ir_exact)}}exact lower bound of CI for {bf:ir}{p_end}
{synopt:{cmd:r(ub_ir_exact)}}exact upper bound of CI for {bf:ir}{p_end}
{synopt:{cmd:r(chi2)}}chi-squared{p_end}
{synopt:{cmd:r(p)}}two-sided p-value{p_end}

{synopt:{cmd:r(pe_pop)}}proportion of exposed in the population ({bf:detail} only){p_end}
{synopt:{cmd:r(idp)}}incidence rate difference in the population ({bf:detail} only){p_end}
{synopt:{cmd:r(lb_idp)}}lower bound of CI for {bf:idp} ({bf:detail} only){p_end}
{synopt:{cmd:r(ub_idp)}}upper bound of CI for {bf:idp} ({bf:detail} only){p_end}
{synopt:{cmd:r(se_idp)}}estimate of standard error of {bf:idp} ({bf:detail} only){p_end}
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
{p2colreset}{...}

