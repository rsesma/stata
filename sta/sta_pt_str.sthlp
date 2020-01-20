{smcl}
{* *! version 1.1.3 20jan2020}{...}
{viewerdialog sta "dialog sta"}{...}
{viewerdialog stai "dialog stai"}{...}
{viewerjumpto "Syntax" "sta_pt_str##syntax"}{...}
{viewerjumpto "Description" "sta_pt_str##description"}{...}
{viewerjumpto "Examples" "sta_pt_str##examples"}{...}
{viewerjumpto "Stored results" "sta_pt_str##results"}{...}
{title:Title}

{phang}
{bf:sta} {hline 2} Association Measures (stratified person-time data)


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:sta} {it:{help varname:var_response}} {it:{help varname:var_exposure}} {it:{help varname:var_time}} {ifin}{cmd:, data(pt)}
{cmd:by({it:{help varname:stratify_var}})} [{it:{help sta_pt_str##options:options}}]

{p 8 8 2}
{cmd:stai} {it:#a11 #a01 #t11 #t01} \ [...] \ {it:#a1i #a0i #t1i #t0i} \ [...] \
{it:#a1k #a0k #t1k #t0k}{cmd:, data(pt)} [{it:{help sta_pt_str##options:options}}]{break}
(where {it:k} is the number of strata)



{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt method(weight)}}method of weighting: {space 16} default is {bf:method(mh)}{break}
{bf:mh} Mantel-Haenszel{break}
{bf:iv} Inverse of Variance{break}
{bf:is} Internal Standardization{break}
{bf:es} External Standardization{p_end}
{synopt :{opt notables}}do not show 2x2 tables; by default, 2x2 are shown{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); the {bf:default} is {bf:level(95)}{p_end}
{synopt :{opt det:ail}}display additional statistics{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Measures of Association for stratified person-time data.

{p 4 4}
The command needs the response, exposure, time and stratify variables to compute the results.

{p 4 4}
{cmd:stai} is the immediate form of {cmd:sta}; see {help immed}. The sequence of {it:#a1i}, {it:#a0i}, {it:#t1i} 
and {it:#t0i} come from a contingency table, given {it:k} strata:{break}

{p 4 4}
{space 18}{c |}Str 1{c |} .. {c |}Str i{c |} .. {c |}Str k{break}
{hline 18}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{break}
Exposed{space 5}Cases {c |} {bf:a11} {c |} .. {c |} {bf:a1i} {c |} .. {c |} {bf:a1k}{break}
{space 6}Person-time {c |} {bf:t11} {c |} .. {c |} {bf:t1i} {c |} .. {c |} {bf:t1k}{break}
{hline 18}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{break}
UnExposed{space 3}Cases {c |} {bf:a01} {c |} .. {c |} {bf:a0i} {c |} .. {c |} {bf:a0k}{break}
{space 6}Person-time {c |} {bf:t01} {c |} .. {c |} {bf:t0i} {c |} .. {c |} {bf:t0k}{break}
{hline 18}{c BT}{hline 5}{c BT}{hline 4}{c BT}{hline 5}{c BT}{hline 4}{c BT}{hline 5}{break}


{marker examples}{...}
{title:Examples}

{p 4 4}{stata "use http://metodo.uab.cat/stata/LungFruitSmoking.dta":. use http://metodo.uab.cat/stata/LungFruitSmoking.dta}{p_end}
{p 4 4}{cmd:. sta Lung Fruit Time, data(pt) by(Smoking) method(mh)}{p_end}
{p 4 4}{cmd:. stai 2 18 5144 124474 \ 6 26 3984 28539, data(pt) method(mh)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
The command stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: {it:Matrices}}{p_end}
{synopt:{cmd:r(Data)}}2x2 table data{p_end}
{synopt:{cmd:r(Ratios)}}ratios (incidence) for each stratum and for the overall{p_end}
{synopt:{cmd:r(Estim)}}estimations (incidence) for the different methods{p_end}
{synopt:{cmd:r(Chi2)}}chi2 results{p_end}
{p2colreset}{...}

