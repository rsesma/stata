{smcl}
{* *! version 1.2.5 23oct2018}{...}
{viewerdialog rtrend "dialog rtrend"}{...}
{viewerdialog rtrendi "dialog rtrendi"}{...}
{viewerjumpto "Syntax" "rtrend##syntax"}{...}
{viewerjumpto "Description" "rtrend##description"}{...}
{viewerjumpto "Examples" "rtrend##examples"}{...}
{viewerjumpto "Stored results" "rtrend##results"}{...}
{viewerjumpto "Version" "rtrend##version"}{...}
{viewerjumpto "Authors" "rtrend##authors"}{...}
{viewerjumpto "References" "rtrend##references"}{...}
{title:Title}

{phang}
{bf:rtrend} {hline 2} Trend test (2xk or kx2 table) for frequency and person-time data


{marker syntax}{...}
{title:Syntax}

{phang}Syntax for {bf:frequency} analysis

{p 8 12 2}
{cmd:rtrend} {it:var_response} {it:var_exposure}
{ifin}{cmd:,} data({bf:freq}) [{it:{help rtrend##options:options}}]


{phang}Syntax for {bf:person-time} analysis

{p 8 12 2}
{cmd:rtrend} {it:var_response} {it:var_exposure} {it:var_person-time}
{ifin}{cmd:,} data({bf:pt}) [{it:{help rtrend##options:options}}]


{phang}Immediate command (non stratified analysis)

{p 6 10 2}
Cohort/Cross-Sectional{break}
{cmd:rtrendi} {it:#metric1} [...] {it:#metricj} \ {it:#a1} [...] {it:#aj} \ {it:#n1} [...] {it:#nj}{cmd:,}
data({bf:freq}) [{it:{help rtrend##options:options}}]{p_end}

{p 6 10 2}
Case-Control{break}
{cmd:rtrendi} {it:#metric1} [...] {it:#metricj} \ {it:#a1} [...] {it:#aj} \ {it:#b1} [...] {it:#bj}{cmd:,}
data({bf:freq}) st({bf:cc}) [{it:{help rtrend##options:options}}]{p_end}

{p 6 10 15}
Person-Time{break}
{cmd:rtrendi} {it:#metric1} [...] {it:#metricj} \ {it:#a1} [...] {it:#aj} \ {it:#t1} [...] {it:#tj}{cmd:,}
data({bf:pt}) [{it:{help rtrend##options:options}}]{p_end}


{phang}Immediate command (stratified analysis)

{p 6}
Cohort/Cross-Sectional{p_end}
{p 10 18}
{cmd:rtrendi} {it:#metric1 #metric2} [...] {it:#metricj} \ {break} 
{it:#a11 #a12} [...] {it:#a1j} \ [...] \ {it:#ak1 #ak2}  [...] {it:#akj} \ {break}
{it:#n11 #n12} [...] {it:#n1j} \ [...] \ {it:#nk1 #nk2}  [...] {it:#nkj}{cmd:,}
data({bf:freq}) [{it:{help rtrend##options:options}}] {p_end}

{p 6}
Case-Control{p_end}
{p 10 18}
{cmd:rtrendi} {it:#metric1 #metric2} [...] {it:#metricj} \ {break} 
{it:#a11 #a12} [...] {it:#a1j} \ [...] \ {it:#ak1 #ak2}  [...] {it:#akj} \ {break}
{it:#b11 #b12} [...] {it:#b1j} \ [...] \ {it:#bk1 #bk2}  [...] {it:#bkj}{cmd:,}
data({bf:freq}) st({bf:cc}) [{it:{help rtrend##options:options}}] {p_end}

{p 6}
Person-Time{p_end}
{p 10 18}
{cmd:rtrendi} {it:#metric1 #metric2} [...] {it:#metricj} \ {break} 
{it:#a11 #a12} [...] {it:#a1j} \ [...] \ {it:#ak1 #ak2}  [...] {it:#akj} \ {break}
{it:#t11 #t12} [...] {it:#t1j} \ [...] \ {it:#tk1 #tk2}  [...] {it:#tkj}{cmd:,}
data({bf:pt}) [{it:{help rtrend##options:options}}] {p_end}

{p 6 10 2}
where {it:j} is the number of elements in {it:metric} and {it:k} is the number of strata

{marker options}{...}
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{it:Common}}
{synopt :{opt data(string)}}type of data; valid values are: {space 19} default is {bf:data(freq)}{break}
{bf:freq} (Frequency){break}
{bf:pt} {space 2}(Person-Time){break}{p_end}
{synopt :{opt rc(string)}}reference category; valid values are: {space 13} default is {bf:rc(f)}{break}
{bf:f} (First){break}
{bf:l} (Last){break}
{bf:p} (Previous){break}
{bf:s} (Subsequent){break}{p_end}
{synopt :{opt by(varname)}}stratify on {it:varname}; this option is not allowed for the immediate command{p_end}
{synopt :{opt metric(numlist)}}metric; this option is not allowed for the immediate command{p_end}
{synopt :{opt no:ne}}do not calculate confidence intervals of the proportions; the default{p_end}
{synopt :{opt w:ilson}}calculate Wilson confidence intervals (only for frequency data){p_end}
{synopt :{opt e:xact}}calculate exact confidence intervals{p_end}
{synopt :{opt wa:ld}}calculate Wald confidence intervals (only for frequency data){p_end}
{synopt :{opt l:evel(#)}}confidence level (%) {space 30} default is {bf:level(95)}{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}

{syntab:{it:Frequency only}}
{synopt :{opt st(string)}}study type; valid values are: {space 21} default is {bf:st(co rr)}{break}
{space 4}{bf:co} or {bf:co rr} or {bf:co or} (Cohort){break}
{space 4}{bf:cs} or {bf:cs pr} or {bf:cs or} (Cross-Sectional){break}
{space 4}{bf:cc} (Case-Control){break}
{it:Note:} {bf:rr} {bf:pr} {bf:or} specify the required statistic{break}
by default: {bf:rr} for {bf:co} study, {bf:pr} for {bf:cs} study, {bf:or} for {bf:cc} study{p_end}
{synopt :{opt z:ero(correct)}}continuity correction for cells with zero events: {space 1} default is {bf:zero(n)}{break}
{bf:n} None{break}
{bf:c} Constant, add k=0.5 to each cell{break}
{bf:p} Proportional, add k1=N1/N and k0=N0/N for {bf:ex}, {bf:co} & {bf:cs} studies{break}
{space 15} add k1=M1/N and k0=M0/N for {bf:cc} studies{break}
{bf:r} Reciprocal, add k1=1/N0 and k0=1/N1 for {bf:ex}, {bf:co} & {bf:cs} studies{break}
{space 14}add k1=1/M0 and k0=1/M1 for {bf:cc} studies{break}
The recommended correction is {bf:reciprocal}{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{p 4 4 2}
Compute trend test for frequency and person-time data. For {bf:frequency} data the command needs the response and exposure variables 
to compute the results. For {bf:person-time} data the command needs the response, the exposure and the person-time variables 
to compute the results.

{p 4 4}
{cmd:rtrendi} is the immediate form of {cmd:rtrend}; see {help immed}. The immediate command needs at least three numlists, 
separated by {bf:'\'}:{p_end}
{p 6 6}
1. {it:#metric1 #metric2 ... #metricj} {hline 2} Metric{break}
2. {it:#a1 #a2 ... #aj} {hline 2} List of exposed cases{break}
3. {it:#n1 #n2 ... #nj} {hline 2} List of exposed total ({bf:cohort/cross-sectional} calculations) {it:or} {break}
{space 3}{it:#b1 #b2 ... #bj} {hline 2} List of controls {space 5}({bf:case-control} calculations) {it:or} {break}
{space 3}{it:#t1 #t2 ... #tj} {hline 2} List of person-time {space 2}({bf:person-time} calculations){break}
The number of elements of the three numlists must be the same.

{p 4 4}
Stratified analysis is available with the option {cmd:by()}. For the immediate 
form, several lists of values for {cmd:a} and {cmd:n|b|t} must be supplied (see the examples).

{p 4 4}
You can click {dialog rtrend:here} to pop up a {dialog rtrend:dialog} or type {inp: db rtrend}. For the 
immediate command, you can click {dialog rtrendi:here} to pop up a {dialog rtrendi:dialog} or type {inp: db rtrendi}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate rtrend, update} to update the {bf:rtrend} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}

{p 2 4}{it:Frequency}{break}
{stata "use http://www.graunt.cat/stata/SmokeApgar.dta":. use http://www.graunt.cat/stata/SmokeApgar.dta}{break}
{cmd:. rtrend Apgar Smoke, data(freq) metric(0 5 15 30) st(cs) wilson zero(n) nst(Study name)}{break}
{cmd:. rtrendi 0 5 15 30 \ 48 6 17 17 \ 520 108 183 105, data(freq) st(co rr) rc(f)}{break}
{cmd:. rtrendi 0 5 15 30 \ 48 6 17 17 \ 520 108 183 105, data(freq) st(cs or) rc(l)}{break}
{cmd:. rtrendi 0 1 2 3 \ 7 565 445 340 \ 61 706 408 182, st(cc) rc(f)}{p_end}

{p 2 4}{it:Frequency - stratified analysis}{break}
{stata "use http://www.graunt.cat/stata/SmokeApgarAge.dta":. use http://www.graunt.cat/stata/SmokeApgarAge.dta}{break}
{cmd:. rtrend Apgar Smoke, data(freq) metric(1 2 3 4) rc(f) by(Age) st(co rr) wilson zero(n)}{break}
{cmd:. rtrendi 1 2 3 4 \ 42 2 9 10 \ 6 4 8 7 \ 330 12 36 31 \ 190 96 147 74, data(freq) rc(f) st(co rr) wilson zero(n)}{break}

{p 2 4}{it:Person-time}{break}
{stata "use http://www.graunt.cat/stata/SmokeBladder.dta":. use http://www.graunt.cat/stata/SmokeBladder.dta}{break}
{cmd:. rtrend Bladder Smoke Time, data(pt) rc(f)}{break}
{cmd:. rtrendi 0 1 2 3.5 \ 82 0 150 141 \ 31966 49672 44112 37545, data(pt) rc(l)}{break}
{cmd:. rtrendi 0 1 2 3.5 \ 82 140 150 141 \ 31966.7 49672 44112.5 37545.9, data(pt) rc(l)}{p_end}

{p 2 4}{it:Person-time - stratified analysis}{break}
{stata "use http://www.graunt.cat/stata/ArsenicRespiratoryYear.dta":. use http://www.graunt.cat/stata/ArsenicRespiratoryYear.dta}{break}
{cmd:. rtrend Respiratory Arsenic Time, data(pt) by(Year) rc(f)}{break}
{cmd:. rtrendi 1 2 3 4 \ 51 17 13 34 \ 100 38 15 8 \ 19017 2683 2600 3871 \ 74667 13693 5940 2510, data(pt) rc(f)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
The command stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{synopt:{cmd:r(N)}}valid cases{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: {it:Scalars - Non stratified analysis}}{p_end}
{synopt:{cmd:r(trend_chi2)}}MH Test for linear trend - Chi2{p_end}
{synopt:{cmd:r(trend_p)}}MH Test for linear trend - Significance (p){p_end}
{synopt:{cmd:r(lin_chi2)}}Deviation from linearity - Chi2{p_end}
{synopt:{cmd:r(lin_p)}}Deviation from linearity - Significance (p){p_end}
{p2col 5 15 19 2: {it:Matrices - Non stratified analysis}}{p_end}
{synopt:{cmd:r(Results)}}results for each category, matrix form{p_end}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 19 2: {it:Scalars - Stratified analysis}}{p_end}
{synopt:{cmd:r(trend_chi2_i)}}MH Test for linear trend - Chi2{space 17}Stratum {it:i}{p_end}
{synopt:{cmd:r(trend_p_i)}}MH Test for linear trend - Significance (p){space 5}Stratum {it:i}{p_end}
{synopt:{cmd:r(lin_chi2_i)}}Deviation from linearity - Chi2{space 17}Stratum {it:i}{p_end}
{synopt:{cmd:r(lin_p_i)}}Deviation from linearity - Significance (p){space 5}Stratum {it:i}{p_end}
{synopt:{cmd:r(trend_chi2_OVER)}}MH Test for linear trend - Chi2{space 17}OVERALL{p_end}
{synopt:{cmd:r(trend_p_OVER)}}MH Test for linear trend - Significance (p){space 5}OVERALL{p_end}
{synopt:{cmd:r(lin_chi2_OVER)}}Deviation from linearity - Chi2{space 17}OVERALL{p_end}
{synopt:{cmd:r(lin_p_OVER)}}Deviation from linearity - Significance (p){space 5}OVERALL{p_end}
{synopt:{cmd:r(adj_trend_chi2)}}MH Test for linear trend - Chi2{space 17}Adjusted MH{p_end}
{synopt:{cmd:r(adj_trend_p)}}MH Test for linear trend - Significance (p){space 5}Adjusted MH{p_end}
{synopt:{cmd:r(adj_hom_chi2)}}Homogeneity of Linear trends - Chi2{space 13}Adjusted MH{p_end}
{synopt:{cmd:r(adj_hom_p)}}Homogeneity of Linear trends - Significance (p){space 1}Adjusted MH{p_end}
{p2col 5 15 19 2: {it:Matrices - Stratified analysis}}{p_end}
{synopt:{cmd:r(Stri)}}results for each category, matrix form{space 10}Stratum {it:i}{p_end}
{synopt:{cmd:r(OVERALL)}}results for each category, matrix form{space 10}OVERALL{p_end}
{synopt:{cmd:r(AdjustedMH)}}results for each category, matrix form{space 10}Adjusted MH{p_end}
{p2colreset}{...}

{marker version}{...}
{title:Version}

{p 4}
Version 1.2.5 {hline 2} 23 October 2018


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
Dom{c e'}nech JM. Trend Test: User-written command rtrend for Stata [computer program].{break}
V1.2.5. Barcelona: Graunt21; 2018.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}
Breslow N, Day NE. Statistical methods in cancer research. Vol. I: The analysis of case-control
studies. Lyon: I.A.R.C. Scientific Publications n{c 186} 32, 1980.{p_end}

{p 0 2}
Breslow N, Day NE. Statistical methods in cancer research. Vol. II: The design and analysis
of cohort studies. Lyon: I.A.R.C. Scientific Publications n{c 186} 82, 1987.{p_end}
