{smcl}
{* *! version 1.1.5 17mar2021}{...}
{viewerdialog sta "dialog sta"}{...}
{viewerdialog stai "dialog stai"}{...}
{viewerjumpto "Syntax" "sta_freq_str##syntax"}{...}
{viewerjumpto "Description" "sta_freq_str##description"}{...}
{viewerjumpto "Examples" "sta_freq_str##examples"}{...}
{viewerjumpto "Stored results" "sta_freq_str##results"}{...}
{title:Title}

{phang}
{bf:sta} {hline 2} Association Measures (stratified frequency data)


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:sta} {it:{help varname:var_response}} {it:{help varname:var_exposure}} {ifin}{cmd:, data(freq)}
{cmd:by({it:{help varname:stratify_var}})} [{it:{help sta_freq_str##options:options}}]

{p 8 8 2}
{cmd:stai} {it:#a11 #a01 #b11 #b01} \ [...] \ {it:#a1i #a0i #b1i #b0i} \ [...] \
{it:#a1k #a0k #b1k #b0k}{cmd:, data(freq)} [{it:{help sta_freq_str##options:options}}]{break}
(where {it:k} is the number of strata)

{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt st(type)}}study type; valid values are: {space 7} default is {bf:st(co)}{break}
{bf:co} (cohort){break}{bf:cc} (case-control){p_end}
{synopt :{opt method(weight)}}method of weighting: {space 16} default is {bf:method(mh)}{break}
{bf:mh} Mantel-Haenszel{break}
{bf:iv} Inverse of Variance{break}
{bf:is} Internal Standardization{break}
{bf:es} External Standardization{p_end}
{synopt :{opt zero(correct)}}continuity correction for cells with zero events:{break}
{bf:n} None {space 28} default is {bf:zero(n)}{break}
{bf:c} Constant, add k=0.5 to each cell{break}
{bf:p} Proportional, add k1=N1/N and k0=N0/N for {bf:co} studies{break}
{space 15} add k1=M1/N and k0=M0/N for {bf:cc} studies{break}
{bf:r} Reciprocal, add k1=1/N0 and k0=1/N1 for {bf:co} studies{break}
{space 14}add k1=1/M0 and k0=1/M1 for {bf:cc} studies{break}
The recommended correction is {bf:reciprocal}{p_end}
{synopt :{opt co:rnfield}}use Cornfield approximation to calculate CI of the odds ratio ({bf:cc} studies only){p_end}
{synopt :{opt w:oolf}}use Woolf approximation to calculate SE and CI of the odds ratio ({bf:cc} studies only){break}
by default, {bf:sta} reports an exact interval of the odds ratio{p_end}
{synopt :{opt notables}}do not show 2x2 frequency tables; by default, 2x2 tables are shown{p_end}
{synopt :{opt l:evel(#)}}confidence level (%); the {bf:default} is {bf:level(95)}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Measures of Association for stratified frequency data.

{p 4 4}
Cohort and case-control studies are available. The command needs the response, exposure and
stratify variables to compute the results.

{p 4 4}
{cmd:stai} is the immediate form of {cmd:sta}; see {help immed}. The sequence of {it:#a1i}, {it:#a0i}, {it:#b1i} 
and {it:#b0i} come from a contingency table, given {it:k} strata:{break}

{p 4 4}
{space 18}{c |}Str 1{c |} .. {c |}Str i{c |} .. {c |}Str k{break}
{hline 18}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{break}
Exposed{space 5}Cases {c |} {bf:a11} {c |} .. {c |} {bf:a1i} {c |} .. {c |} {bf:a1k}{break}
{space 9}NonCases {c |} {bf:b11} {c |} .. {c |} {bf:b1i} {c |} .. {c |} {bf:b1k}{break}
{hline 18}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{c +}{hline 4}{c +}{hline 5}{break}
UnExposed{space 3}Cases {c |} {bf:a01} {c |} .. {c |} {bf:a0i} {c |} .. {c |} {bf:a0k}{break}
{space 9}NonCases {c |} {bf:b01} {c |} .. {c |} {bf:b0i} {c |} .. {c |} {bf:b0k}{break}
{hline 18}{c BT}{hline 5}{c BT}{hline 4}{c BT}{hline 5}{c BT}{hline 4}{c BT}{hline 5}{break}


{marker examples}{...}
{title:Examples}

{it:Cohort}
{p 4 4}{stata "use http://metodo.uab.cat/stata/RaceDeathStage.dta":. use http://metodo.uab.cat/stata/RaceDeathStage.dta}{p_end}
{p 4 4}{cmd:. sta Death Race, data(freq) st(co) by(Stage) method(mh)}{p_end}

{p 4 4}{cmd:. stai 84 727 710 9055 \ 322 2277 553 5193, data(freq) st(co) method(mh)}{p_end}
{p 4 4}{cmd:. stai 84 727 0 9055 \ 322 2277 553 5193, data(freq) st(co) method(mh) zero(c)}{p_end}

{it:Case-Control}
{p 4 4}{stata "use http://metodo.uab.cat/stata/TubeBlanketSeason.dta":. use http://metodo.uab.cat/stata/TubeBlanketSeason.dta}{p_end}
{p 4 4}{cmd:. sta NeuralTubeDef Blanket, data(freq) st(cc) by(Season) method(iv)}{p_end}

{p 4 4}{cmd:. stai 10 104 15 97 \ 11 99 9 103, data(freq) st(cc) method(iv)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
The command stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: {it:Matrices}}{p_end}
{synopt:{cmd:r(Data)}}2x2 table data{p_end}
{synopt:{cmd:r(Ratios)}}ratios (risk/odds) for each stratum and for the overall{p_end}
{synopt:{cmd:r(Estim)}}estimations (risk/odds) for the different methods{p_end}
{synopt:{cmd:r(Chi2)}}chi2 results{p_end}
{p2colreset}{...}

