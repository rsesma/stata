{smcl}
{* *! version 1.3.2  03feb2020}{...}
{viewerdialog nsize "dialog nsize"}{...}
{viewerjumpto "Syntax" "nsize##syntax"}{...}
{viewerjumpto "Description" "nsize##description"}{...}
{viewerjumpto "Options" "nsize##options"}{...}
{viewerjumpto "Examples" "nsize##examples"}{...}
{viewerjumpto "Stored results" "nsize##results"}{...}
{viewerjumpto "Version" "nsize##version"}{...}
{viewerjumpto "Authors" "nsize##authors"}{...}
{viewerjumpto "References" "nsize##references"}{...}
{title:Title}

{phang}
{bf:nsize} {hline 2} Sample Size & Power


{marker syntax}{...}
{title:Syntax}

{p 8 4 2}
{cmd:nsize} {it:{help nsize##type_table:type}}{cmd:,} {it:{help nsize##options:type_options}} [{bf:nst(}{it:string}{bf:)}]

{p 4}
where {bf:nst()} allows to optionally label the results with the name of the study

{marker type_table}{...}
{p2colset 4 15 18 2}{...}
{p2col :Type}Description{p_end}
{p2line}
{p2col :{helpb nsize##co1p_type:co1p}}Comparison of one proportion to a reference (non equal){p_end}
{p2col :{helpb nsize##co2p_type:co2p}}Comparison of two proportions (non equal){p_end}
{p2col :{helpb nsize##c1pe_type:c1pe}}Comparison of one proportion to a reference (equivalence){p_end}
{p2col :{helpb nsize##c2pe_type:c2pe}}Comparison of two proportions (equivalence){p_end}
{p2col :{helpb nsize##copp_type:copp}}Comparison of paired proportions (matched){p_end}
{p2col :{helpb nsize##co1m_type:co1m}}Comparison of one mean to a reference (non equal){p_end}
{p2col :{helpb nsize##co2m_type:co2m}}Comparison of two means (non equal){p_end}
{p2col :{helpb nsize##c2me_type:c2me}}Comparison of two means (equivalence){p_end}
{p2col :{helpb nsize##cokm_type:cokm}}Comparison of k means (ANOVA){p_end}
{p2col :{helpb nsize##ci1p_type:ci1p}}Estimation of population proportion{p_end}
{p2col :{helpb nsize##ci2p_type:ci2p}}Estimation of the difference between 2 proportions{p_end}
{p2col :{helpb nsize##ci1m_type:ci1m}}Estimation of population mean{p_end}
{p2col :{helpb nsize##ci2m_type:ci2m}}Estimation of the difference between 2 means{p_end}
{p2col :{helpb nsize##co1c_type:co1c}}Comparison of one correlation to a reference{p_end}
{p2col :{helpb nsize##co2c_type:co2c}}Comparison of two correlations{p_end}
{p2col :{helpb nsize##co2r_type:co2r}}Comparison of two risks{p_end}
{p2col :{helpb nsize##co2i_type:co2i}}Comparison of two rates{p_end}
{p2col :{helpb nsize##ncr_type:ncr}}Number of communities (Risk): Intervention trials{p_end}
{p2line}

{marker description}{...}
{title:Description}

{p 4 4 2}
Comparisons and estimations for independent proportions, means, correlations, risks and rates.{break}
There are up to 18 different types of computations. Each type has a different set of options, 
see the {help nsize##options:Options} section for details.

{p 4}
This command does not work with data of the current dataset. Current dataset is not modified.

{p 4}
You can click {dialog nsize:here} to pop up a {dialog nsize:dialog} or type {inp: db nsize}.

{p 4 4}
Execute {cmd: net from http://metodo.uab.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate nsize, update} to update the {bf:nsize} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@metodo.uab.cat.


{marker options}{...}
{title:Options}

{marker co1p_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co1p_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 9}{bf:p}}Proportion(%) of events in reference population {space 3} (0 < p < 100){p_end}
{p2col :{space 7}{c -(}{bf:p1}}Proportion(%) of events in sample {space 17} (0 < p1 < 100){p_end}
{p2col :{space 2}| {bf:{ul:ef}fect}{c )-}}Minimum expected effect size(%); effect = p1-p {space 4} (effect <> 0){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 9}{bf:n}}Sample Size {space 39} (n integer > 1){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2line}
{p 4}
{helpb nsize##co1p_ex:co1p examples} {space 1}{helpb nsize##co1p_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker co2p_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co2p_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:p0}}Proportion(%) of events in reference group {space 8} (0 < p0 < 100){p_end}
{p2col :{space 7}{c -(}{bf:p1}}Proportion(%) of events in new group {space 14} (0 < p1 < 100){p_end}
{p2col :{space 2}| {bf:{ul:ef}fect}{c )-}}Minimum expected effect size(%); effect = p1-p {space 4} (effect <> 0){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 9}{bf:n}}Sample Size (by group) {space 28} (n integer > 1){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2line}
{p 4}
{helpb nsize##co2p_ex:co2p examples} {space 1}{helpb nsize##co1p_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker c1pe_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:c1pe_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:p0}}Proportion (%) of events in reference treatment{space 4} (0 < p0 < 100){p_end}
{p2col :{space 8}{bf:p1}}Proportion (%) of events in experimental treatment{space 1} (0 < p1 < 100){p_end}
{p2col :{space 5}{bf:delta}}Non-Inferiority/Superiority/Equivalence limit{space 6} (delta <> 0){break}
by default Equivalence Test is computed{p_end}
{p2col :{space 3}[{bf:noninf}]}Compute Non-Inferiority Test{p_end}
{p2col :{space 4}[{bf:super}]}Compute Superiority Test{p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 9}{bf:n}}Sample Size {space 39} (n integer > 1){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2line}
{p 4}
{helpb nsize##c1pe_ex:c1pe examples} {space 1}{helpb nsize##c1pe_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}{p_end}

{marker c2pe_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:c2pe_options}}Description{p_end}
{p2line}
{p2col :{space 8}{bf:p0}}Proportion (%) of events in reference treatment{space 4} (0 < p0 < 100){p_end}
{p2col :{space 8}{bf:p1}}Proportion (%) of events in experimental treatment{space 1} (0 < p1 < 100){p_end}
{p2col :{space 5}{bf:delta}}Non-Inferiority/Superiority/Equivalence limit{space 6} (delta <> 0){break}
by default Equivalence Test is computed{p_end}
{p2col :{space 3}[{bf:noninf}]}Compute Non-Inferiority Test{p_end}
{p2col :{space 4}[{bf:super}]}Compute Superiority Test{p_end}
{p2col :{space 8}[{bf:r}]}Ratio n0/n1; by default: 1 {space 24} (r > 0){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 8}{bf:n0}}Sample Size (Reference treatment) {space 17} (n0 integer > 1){p_end}
{p2col :{space 8}{bf:n1}}Sample Size (Experimental treatment) {space 14} (n1 integer > 1){break}
{it:or n0 and r, or n1 and r}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2line}
{p 4}
{helpb nsize##c2pe_ex:c2pe examples} {space 1}{helpb nsize##c2pe_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}{p_end}
{p 4}
{it:Formulas from Fleiss, Levin and Pai, 2003; p.168-74 are used for proportions (non-inferiority and equivalence)}{p_end}

{marker copp_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:copp_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:or}}Expected Response/Exposure Odds Ratio {space 13} (or > 1){p_end}
{p2col :{space 6}[{c -(}{bf:pd}}Proportion of Discordant pairs(%) {space 17} (0 < pd < 100){p_end}
{p2col :{space 6}| {bf:p0}}Proportion in the Reference group(%) {space 14} (0 < p0 < 100){p_end}
{p2col :{space 5}& {bf:ora}{c )-}]}Marginal Odds Ratio {space 31} (ora > 1){p_end}
{p2col :{space 8}[{bf:r}]}Ratio of Matching (1:r);  by default: 1 {space 12} (r integer >= 1){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 9}{bf:n}}Sample Size (Total number of cases) {space 15} (n integer > 1){p_end}
{p2line}
{p 4}
{helpb nsize##copp_ex:copp examples} {space 1}{helpb nsize##copp_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker co1m_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co1m_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:sd}}Common standard deviation {space 25} (sd > 0){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}{bf:{ul:ef}fect}}Minimum expected effect size {space 22} (effect <> 0){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 4}{bf:{ul:ef}fect}}Minimum expected effect size {space 22} (effect <> 0){p_end}
{p2col :{space 9}{bf:n}}Sample Size (by group) {space 28} (n integer > 1){p_end}
{p2col :{it:Effect}}{p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{space 9}{bf:n}}Sample Size (by group) {space 28} (n integer > 1){p_end}
{p2line}
{p 4}
{helpb nsize##co1m_ex:co1m examples} {space 1}{helpb nsize##co1m_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker co2m_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co2m_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:sd}}Common standard deviation of Groups 0 and 1 {space 7} (sd > 0){p_end}
{p2col :{space 8}[{bf:r}]}Ratio n0/n1; by default: 1 {space 24} (r > 0){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}{bf:{ul:ef}fect}}Minimum expected effect size {space 22} (effect <> 0){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 4}{bf:{ul:ef}fect}}Minimum expected effect size {space 22} (effect <> 0){p_end}
{p2col :{space 8}{bf:n1}}Sample Size (Group 1) {space 29} (n1 integer > 1){p_end}
{p2col :{space 7}[{bf:n0}]}Sample Size (Group 0);  by default: r*n1 {space 11} (n0 integer > 1){p_end}
{p2col :{it:Effect}}{p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{space 8}{bf:n1}}Sample Size (Group 1) {space 29} (n1 integer > 1){p_end}
{p2col :{space 7}[{bf:n0}]}Sample Size (Group 0);  by default: r*n1 {space 11} (n0 integer > 1){p_end}
{p2line}
{p 4}
{helpb nsize##co2m_ex:co2m examples} {space 1}{helpb nsize##co2m_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker c2me_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:c2me_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:sd}}Common standard deviation {space 25} (sd > 0){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 5}{bf:{ul:eq}lim}}Equivalence limits {space 32} (eqlim > 0){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 5}{bf:{ul:eq}lim}}Equivalence limits {space 32} (eqlim > 0){p_end}
{p2col :{space 9}{bf:n}}Sample Size (by group) {space 28} (n integer > 1){p_end}
{p2col :{it:Equivalence limits}}{p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{space 9}{bf:n}}Sample Size (by group) {space 28} (n integer > 1){p_end}
{p2line}
{p 4}
{helpb nsize##c2me_ex:c2me examples} {space 1}{helpb nsize##c2me_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker cokm_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:cokm_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 3}{bf:sd}}Common standard deviation estimated {space 15} (sd > 0){p_end}
{p2col :{it:k Simultaneous comparisons}}{p_end}
{p2col :{space 3}{bf:{ul:m}eans}}List of hypothetical means {space 24} (means > 0){break}
{it:For sample size results, the maximum number of groups is k=12}{p_end}
{p2col :{it:c Pairwise comparisons}}{p_end}
{p2col :{space 3}{bf:{ul:ef}fect}}Minimum expected effect size {space 22} (effect <> 0){p_end}
{p2col :{space 3}{bf:c}}Number of pairwise comparisons {space 20} (c integer > 0){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 3}{bf:nk}}Sample size (by group) {space 27} (nk integer > 1){break}
{it:If parameter nk is present, Power results are calculated}{p_end}
{p2line}
{p 4}
{helpb nsize##cokm_ex:cokm examples} {space 1}{helpb nsize##cokm_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker ci1p_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci1p_options}}Description{p_end}
{p2line}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 3}{bf:p0}}Supposed Population Proportion(%) {space 17} (0 < p0 < 100){p_end}
{p2col :{space 3}{bf:{ul:ap}re}}List of CI absolute precision values(%) {space 11} (0 < p0 {c 177} apre < 100){p_end}
{p2col :{space 2}[{bf:cl}]}Confidence level(%); by default: 90 95 99 {space 9} (50 <= CL < 100){p_end}
{p2col :{it:Precission of CI}}{p_end}
{p2col :{space 3}{bf:p0}}List of Supposed Population Proportions(%) {space 8} (0 < p0 < 100){p_end}
{p2col :{space 3}{bf:ns}}List of Sample Sizes {space 30} (ns integer > 1){p_end}
{p2col :{space 2}[{bf:cl}]}Confidence level(%); by default: 95 {space 15} (50 <= CL < 100){p_end}
{p2col :{it:Common}}{p_end}
{p2col :{space 2}[{bf:n}]}Population Size; by default: INFINITE {space 13} (n integer > ns){p_end}
{p2line}
{p 4}
{helpb nsize##ci1p_ex:ci1p examples} {space 1}{helpb nsize##ci1p_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker ci2p_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci2p_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 3}{bf:p0}}Supposed proportion in Pop.0(%) {space 19} (0 < p0 < 100){p_end}
{p2col :{space 3}{bf:p1}}Supposed proportion in Pop.1(%) {space 19} (0 < p1 < 100){p_end}
{p2col :{space 2}[{bf:r}]}Ratio n0/n1; by default: 1 {space 24} (r > 0){p_end}
{p2col :{space 2}[{bf:cl}]}Confidence level(%); by default: 90 95 97.5 99 {space 4} (50 <= CL < 100){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 3}{bf:{ul:ap}re}}List of CI absolute precision values(%) {space 11} (0 < p0 {c 177} apre < 100){p_end}
{p2col :{it:Precission of CI}}{p_end}
{p2col :{space 3}{bf:n1}}Sample Size (Group 1) {space 29} (n1 integer > 1){p_end}
{p2col :{space 2}[{bf:n0}]}Sample Size (Group 0);  by default: r*N1 {space 11} (n0 integer > 1){p_end}
{p2line}
{p 4}
{helpb nsize##ci2p_ex:ci2p examples} {space 1}{helpb nsize##ci2p_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker ci1m_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci1m_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 3}{bf:sd}}Supposed Standard Deviation {space 23} (sd > 0){p_end}
{p2col :{space 2}[{bf:n}]}Population Size; by default: INFINITE {space 13} (n integer > ns){p_end}
{p2col :{space 2}[{bf:cl}]}Confidence level(%); by default: 90 95 99 {space 9} (50 <= CL < 100){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 3}{bf:{ul:ap}re}}List of CI absolute precision values{p_end}
{p2col :{it:Precission of CI}}{p_end}
{p2col :{space 3}{bf:ns}}Sample Size {space 39} (ns integer > 1){p_end}
{p2line}
{p 4}
{helpb nsize##ci1m_ex:ci1m examples} {space 1}{helpb nsize##ci1m_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker ci2m_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci2m_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 3}{bf:sd}}Supposed Standard Deviation {space 23} (sd > 0){p_end}
{p2col :{space 2}[{bf:r}]}Ratio n0/n1; by default: 1 {space 24} (r > 0){p_end}
{p2col :{space 2}[{bf:cl}]}Confidence level(%); by default: 90 95 97.5 99 {space 4} (50 <= CL < 100){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 3}{bf:{ul:ap}re}}List of CI absolute precision values{p_end}
{p2col :{it:Precission of CI}}{p_end}
{p2col :{space 3}{bf:n1}}Sample Size (Group 1) {space 29} (n1 integer > 1){p_end}
{p2col :{space 2}[{bf:n0}]}Sample Size (Group 0);  by default: r*N1 {space 11} (n0 integer > 1){p_end}
{p2line}
{p 4}
{helpb nsize##ci2m_ex:ci2m examples} {space 1}{helpb nsize##ci2m_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker co1c_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co1c_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:cr}}Correlation in a reference population {space 13} (-1 < cr < 1){p_end}
{p2col :{space 6}{c -(}{bf:cr1}}Correlation in a sample {space 27} (-1 < cr1 < 1){p_end}
{p2col :{space 2}| {bf:{ul:ef}fect}{c )-}}Minimum expected effect size(%); effect = cr1-cr {space 2} (effect < 1){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 8}{bf:n1}}Size of sample 1 {space 34} (n1 integer > 3){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2line}
{p 4}
{helpb nsize##co1c_ex:co1c examples} {space 1}{helpb nsize##co1c_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker co2c_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co2c_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 7}{bf:cr0}}Correlation in a sample 0 {space 25} (-1 < cr0 < 1){p_end}
{p2col :{space 6}{c -(}{bf:cr1}}Correlation in a sample 1 {space 25} (-1 < cr1 < 1){p_end}
{p2col :{space 2}| {bf:{ul:ef}fect}{c )-}}Minimum expected effect size(%); effect = cr1-cr0 {space 1} (effect < 1){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 8}{bf:n1}}Size of sample 1 {space 34} (n1 integer > 3){p_end}
{p2col :{space 8}{bf:n0}}Size of sample 0 {space 34} (n0 integer > 3){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2line}
{p 4}
{helpb nsize##co2c_ex:co2c examples} {space 1}{helpb nsize##co1c_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker co2r_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co2r_options}}Description{p_end}
{p2line}
{p2col :{it:Cohort Risk studies}}{p_end}
{p2col :{space 8}{bf:r0}}Event risk in UnExposed(%) {space 24} (0 < r0 < 100){p_end}
{p2col :{space 7}{c -(}{bf:r1}}Event risk in Exposed(%) {space 26} (0 < r1 < 100){p_end}
{p2col :{space 6}| {bf:rr}}Expected Risk Ratio {space 31} (rr > 0){p_end}
{p2col :{space 6}| {bf:rd}}Expected Risk Difference(%) {space 23} (rd <> 0){p_end}
{p2col :{space 6}| {bf:or}{c )-}}Expected Odds Ratio {space 31} (or > 0){p_end}
{p2col :{space 7}{c -(}[{bf:r}}Ratio n0/n1 {space 39} (r > 0){p_end}
{p2col :{space 6}| {bf:pe}]{c )-}}Cohort exposure prevalence(%); r = (100-pe)/pe {space 4} (0 < pe < 100){break}
{it:by default n0 = n1}{p_end}
{p2col :{it:Case-Control studies}}{p_end}
{p2col :{space 7}{bf:pe0}}Proportion of exposed in NonCases(%) {space 14} (0 < pe0 < 100){p_end}
{p2col :{space 6}{c -(}{bf:pe1}}Proportion of exposed in Cases(%) {space 17} (0 < pe1 < 100){p_end}
{p2col :{space 6}| {bf:or}{c )-}}Expected Odds Ratio {space 31} (or > 0){p_end}
{p2col :{space 8}[{bf:r}]}Ratio n0/n1; by default: 1 {space 24} (r > 0){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power - Cohort Risk Studies}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 8}{bf:n1}}Size of sample 1 {space 34} (n1 integer > 1){p_end}
{p2col :{space 8}{bf:n0}}Size of sample 0 {space 34} (n0 integer > 1){break}
{it:or n0 and r|pe, or n1 and r|pe}{p_end}
{p2col :{it:Power - Case-Control Studies}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 8}{bf:m1}}Size of sample 1 {space 34} (m1 integer > 1){p_end}
{p2col :{space 8}{bf:m0}}Size of sample 0 {space 34} (m0 integer > 1){break}
{it:or m0 and r, or m1 and r}{p_end}
{p2line}
{p 4}
{helpb nsize##co2r_ex:co2r examples} {space 1}{helpb nsize##co2r_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker co2i_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co2i_options}}Description{p_end}
{p2line}
{p2col :{it:Common}}{p_end}
{p2col :{space 8}{bf:i0}}Event rate in UnExposed {space 27} (i0 > 0){p_end}
{p2col :{space 7}{c -(}{bf:i1}}Event rate in Exposed {space 29} (i1 > 0){p_end}
{p2col :{space 6}| {bf:ir}}Expected Rate Ratio {space 31} (ir > 0){p_end}
{p2col :{space 6}| {bf:id}{c )-}}Expected Rate Difference {space 26} (id <> 0){p_end}
{p2col :{space 9}{bf:d}}Mean duration of Follow up {space 24} (rd > 0){p_end}
{p2col :{space 8}[{bf:r}]}Ratio n0/n1; by default: 1 {space 24} (r > 0){p_end}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2col :{it:Power}}{p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 8}{bf:n1}}Size of sample 1 {space 34} (n1 integer > 1){p_end}
{p2col :{space 8}{bf:n0}}Size of sample 0 {space 34} (n0 integer > 1){break}
{it:or n0() and r(), or n1() and r()}{p_end}
{p2line}
{p 4}
{helpb nsize##co2i_ex:co2i examples} {space 1}{helpb nsize##co2r_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}

{marker ncr_type}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ncr_options}}Description{p_end}
{p2line}
{p2col :{it:Sample Size}}{p_end}
{p2col :{space 8}{bf:vb}}Supposed Between Group Variance {space 19} (vb > 0){p_end}
{p2col :{space 8}{bf:vw}}Supposed Within Group Variance {space 20} (vw > 0){p_end}
{p2col :{space 4}{bf:{ul:ef}fect}}Minimum expected effect size in proportion {space 8} (0 < effect < 1){p_end}
{p2col :{space 4}[{bf:{ul:a}lpha}]}Alpha risk(%); by default: 5 {space 22} (0 < alpha <= 50){p_end}
{p2col :{space 5}[{bf:{ul:b}eta}]}Beta  risk(%); by default: 20 15 10 {space 16} (0 < beta <= 50){p_end}
{p2line}
{p 4}
{helpb nsize##ncr_ex:ncr examples} {space 1}{helpb nsize##ncr_st:stored results} {space 37} {helpb nsize##syntax:back to syntax}


{marker examples}{...}
{title:Examples}

{marker co1p_ex}{...}
co1p examples
{p 4}{cmd:. nsize co1p, p(30) p1(50)}{p_end}
{p 4}{cmd:. nsize co1p, p(5) effect(-1) alpha(5) beta(15) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co1p, p(40) effect(15) n(80) alpha(5)}{p_end}
{p 4}{helpb nsize##co1p_st:stored results}{space 4} {helpb nsize##co1p_type:co1p options}{space 4} {helpb nsize##syntax:back to syntax}

{marker co2p_ex}{...}
co2p examples
{p 4}{cmd:. nsize co2p, p0(30) effect(20)}{p_end}
{p 4}{cmd:. nsize co2p, p0(6) p1(8) alpha(5) beta(15) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co2p, p0(4) effect(3) n(600) alpha(5)}{p_end}
{p 4}{helpb nsize##co1p_st:stored results}{space 4} {helpb nsize##co2p_type:co2p options}{space 4} {helpb nsize##syntax:back to syntax}

{marker c1pe_ex}{...}
c1pe examples
{p 4}{cmd:. nsize c1pe, p0(90) p1(93) delta(-2) noninf}{p_end}
{p 4}{cmd:. nsize c1pe, p0(50) p1(90) delta(20) super alpha(5) beta(20) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize c1pe, p0(40) p1(40) delta(10) n(211) alpha(5)}{p_end}
{p 4}{helpb nsize##c1pe_st:stored results}{space 4} {helpb nsize##c1pe_type:c1pe options}{space 4} {helpb nsize##syntax:back to syntax}

{marker c2pe_ex}{...}
c2pe examples
{p 4}{cmd:. nsize c2pe, p0(75) p1(80) delta(20) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize c2pe, p0(65) p1(85) delta(5) super alpha(5) beta(20) r(1.5)}{p_end}
{p 4}{cmd:. nsize c2pe, p0(65) p1(85) delta(-10) noninf n1(25) alpha(5)}{p_end}
{p 4}{helpb nsize##c2pe_st:stored results}{space 4} {helpb nsize##c2pe_type:c2pe options}{space 4} {helpb nsize##syntax:back to syntax}

{marker copp_ex}{...}
copp examples
{p 4}{cmd:. nsize copp, or(2) r(1) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize copp, or(2) pd(30.5) r(1) alpha(5) beta(10)}{p_end}
{p 4}{cmd:. nsize copp, or(2.5) p0(42.8) ora(3.0) r(2)}{p_end}
{p 4}{cmd:. nsize copp, or(2.3) pd(26.2) r(1) n(216) alpha(5)}{p_end}
{p 4}{helpb nsize##copp_st:stored results}{space 4} {helpb nsize##copp_type:copp options}{space 4} {helpb nsize##syntax:back to syntax}

{marker co1m_ex}{...}
co1m examples
{p 4}{cmd:. nsize co1m, sd(2.45) effect(2.5) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co1m, sd(10) effect(6) alpha(5) beta(20)}{p_end}
{p 4}{cmd:. nsize co1m, sd(10) effect(6) alpha(5) n(68)}{p_end}
{p 4}{cmd:. nsize co1m, sd(10.45) alpha(5) n(49)}{p_end}
{p 4}{cmd:. nsize co1m, sd(10.45) alpha(5) beta(15) n(49)}{p_end}
{p 4}{helpb nsize##co1m_st:stored results}{space 4} {helpb nsize##co1m_type:co1m options}{space 4} {helpb nsize##syntax:back to syntax}

{marker co2m_ex}{...}
co2m examples
{p 4}{cmd:. nsize co2m, sd(10) effect(6) r(1.5) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co2m, sd(10) effect(6) alpha(5) beta(15)}{p_end}
{p 4}{cmd:. nsize co2m, sd(10) effect(6) alpha(10) n0(55) n1(37)}{p_end}
{p 4}{cmd:. nsize co2m, sd(10) alpha(5) n1(32) n0(32)}{p_end}
{p 4}{cmd:. nsize co2m, sd(10) alpha(5) beta(10) n1(32) n0(32)}{p_end}
{p 4}{helpb nsize##co2m_st:stored results}{space 4} {helpb nsize##co2m_type:co2m options}{space 4} {helpb nsize##syntax:back to syntax}

{marker c2me_ex}{...}
c2me examples
{p 4}{cmd:. nsize c2me, sd(10) eqlim(6)}{p_end}
{p 4}{cmd:. nsize c2me, sd(10) eqlim(6) alpha(5) beta(20) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize c2me, sd(10) eqlim(5) n(60) alpha(5)}{p_end}
{p 4}{cmd:. nsize c2me, sd(10) alpha(5) n(53)}{p_end}
{p 4}{cmd:. nsize c2me, sd(10) alpha(5) beta(10) n(53)}{p_end}
{p 4}{helpb nsize##c2me_st:stored results}{space 4} {helpb nsize##c2me_type:c2me options}{space 4} {helpb nsize##syntax:back to syntax}

{marker cokm_ex}{...}
cokm examples
{p 4}{cmd:. nsize cokm, sd(3.5) means(8.25 11.75 12.00 13.00) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize cokm, sd(3.5) means(8 8 9 12) nk(10 10 10 20)}{p_end}
{p 4}{cmd:. nsize cokm, sd(10) effect(6) c(3)}{p_end}
{p 4}{cmd:. nsize cokm, sd(10) effect(6) c(3) nk(50)}{p_end}
{p 4}{helpb nsize##cokm_st:stored results}{space 4} {helpb nsize##cokm_type:cokm options}{space 4} {helpb nsize##syntax:back to syntax}

{marker ci1p_ex}{...}
ci1p examples
{p 4}{cmd:. nsize ci1p, p0(20) apre(1 2 3 4 5) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize ci1p, p0(20) ns(300)}{p_end}
{p 4}{cmd:. nsize ci1p, p0(5 10 15 20 25 30 40 50) cl(95) n(1350) ns(250 300 350 400)}{p_end}
{p 4}{cmd:. nsize ci1p, p0(20) apre(2 3 4)  n(4000) cl(99.9)}{p_end}
{p 4}{helpb nsize##ci1p_st:stored results}{space 4} {helpb nsize##ci1p_type:ci1p options}{space 4} {helpb nsize##syntax:back to syntax}

{marker ci2p_ex}{...}
ci2p examples
{p 4}{cmd:. nsize ci2p, p0(40) p1(32) apre(5) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize ci2p, p0(40) p1(32) apre(2.5 3 4 5 6) cl(99.9)}{p_end}
{p 4}{cmd:. nsize ci2p, p0(40) p1(32) n1(175)}{p_end}
{p 4}{helpb nsize##ci2p_st:stored results}{space 4} {helpb nsize##ci2p_type:ci2p options}{space 4} {helpb nsize##syntax:back to syntax}

{marker ci1m_ex}{...}
ci1m examples
{p 4}{cmd:. nsize ci1m, sd(1.5) apre(0.5 0.6 0.8 1.0) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize ci1m, sd(1) ns(300) }{p_end}
{p 4}{cmd:. nsize ci1m, sd(1) apre(0.2) n(4000) cl(99.9)}{p_end}
{p 4}{helpb nsize##ci1m_st:stored results}{space 4} {helpb nsize##ci1m_type:ci1m options}{space 4} {helpb nsize##syntax:back to syntax}

{marker ci2m_ex}{...}
ci2m examples
{p 4}{cmd:. nsize ci2m, sd(10) apre(10 2 3) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize ci2m, sd(75) apre(20) r(2) cl(99.9)}{p_end}
{p 4}{cmd:. nsize ci2m, sd(75) n1(175) n0(240)}{p_end}
{p 4}{cmd:. nsize ci2m, sd(75) n1(175) cl(90)}{p_end}
{p 4}{helpb nsize##ci2m_st:stored results}{space 4} {helpb nsize##ci2m_type:ci2m options}{space 4} {helpb nsize##syntax:back to syntax}

{marker co1c_ex}{...}
co1c examples
{p 4}{cmd:. nsize co1c, cr(0) cr1(0.25) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co1c, cr(0) effect(-0.25) alpha(5) beta(20)}{p_end}
{p 4}{cmd:. nsize co1c, cr(0.32) cr1(0.47) n1(100) alpha(5)}{p_end}
{p 4}{helpb nsize##co1c_st:stored results}{space 4} {helpb nsize##co1c_type:co1c options}{space 4} {helpb nsize##syntax:back to syntax}

{marker co2c_ex}{...}
co2c examples
{p 4}{cmd:. nsize co2c, cr0(0.30) cr1(0.50) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co2c, cr0(0) effect(0.25) alpha(5) beta(20)}{p_end}
{p 4}{cmd:. nsize co2c, cr0(0.32) cr1(0.47) n1(100) n0(80) alpha(5)}{p_end}
{p 4}{helpb nsize##co1c_st:stored results}{space 4} {helpb nsize##co2c_type:co2c options}{space 4} {helpb nsize##syntax:back to syntax}

{marker co2r_ex}{...}
co2r examples
{p 4}{cmd:. nsize co2r, r0(30) rd(10) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co2r, pe0(25) or(2.5) r(2)}{p_end}
{p 4}{cmd:. nsize co2r, r0(4) rr(2) pe(15) alpha(5) beta(15)}{p_end}
{p 4}{cmd:. nsize co2r, r0(4) rr(2) r(5.67) alpha(5) n1(363)}{p_end}
{p 4}{cmd:. nsize co2r, pe0(25) or(2.5) m0(205) m1(36) alpha(5)}{p_end}
{p 4}{helpb nsize##co2r_st:stored results}{space 4} {helpb nsize##co2r_type:co2r options}{space 4} {helpb nsize##syntax:back to syntax}

{marker co2i_ex}{...}
co2i examples
{p 4}{cmd:. nsize co2i, i0(0.30) id(0.10) d(2) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize co2i, i0(0.30) id(0.10) d(2) r(2)}{p_end}
{p 4}{cmd:. nsize co2i, i0(0.4) ir(2) d(2) r(3) alpha(5) beta(15)}{p_end}
{p 4}{cmd:. nsize co2i, i0(0.4) ir(2) d(2) n0(69) n1(23) alpha(5)}{p_end}
{p 4}{helpb nsize##co2r_st:stored results}{space 4} {helpb nsize##co2i_type:co2i options}{space 4} {helpb nsize##syntax:back to syntax}

{marker ncr_ex}{...}
ncr examples
{p 4}{cmd:. nsize ncr, vb(0.000001685) vw(0.000001685) effect(0.003) nst(Name of the study)}{p_end}
{p 4}{cmd:. nsize ncr, vb(0.000001685) vw(0.000001685) effect(0.003) alpha(5) beta(10)}{p_end}
{p 4}{helpb nsize##ncr_st:stored results}{space 4} {helpb nsize##ncr_type:ncr options}{space 4} {helpb nsize##syntax:back to syntax}

{marker results}{...}
{title:Stored results}

{p 4 4 2}
The command stores the following scalars or matrices in {cmd:r()}:

{marker co1p_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co1p & co2p results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(nn_2)}}sample size (n) Normal method {space 11} Two-Sided Test{p_end}
{synopt:{cmd:r(nc_2)}}sample size (n) Normal method corrected {space 1} Two-Sided Test{p_end}
{synopt:{cmd:r(na_2)}}sample size (n) ArcoSinus method {space 8} Two-Sided Test{p_end}
{synopt:{cmd:r(nn_1)}}sample size (n) Normal method {space 11} One-Sided Test{p_end}
{synopt:{cmd:r(nc_1)}}sample size (n) Normal method corrected {space 1} One-Sided Test{p_end}
{synopt:{cmd:r(na_1)}}sample size (n) ArcoSinus method {space 8} One-Sided Test{p_end}

{p 4}Sample Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(nn_power_side)}}sample size (n) Normal method{p_end}
{synopt:{cmd:r(nc_power_side)}}sample size (n) Normal method corrected{p_end}
{synopt:{cmd:r(na_power_side)}}sample size (n) ArcoSinus method{p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(pn_2)}}power (p) Normal method {space 11} Two-Sided Test{p_end}
{synopt:{cmd:r(pc_2)}}power (p) Normal method corrected {space 1} Two-Sided Test{p_end}
{synopt:{cmd:r(pa_2)}}power (p) ArcoSinus method {space 8} Two-Sided Test{p_end}
{synopt:{cmd:r(pn_1)}}power (p) Normal method {space 11} One-Sided Test{p_end}
{synopt:{cmd:r(pc_1)}}power (p) Normal method corrected {space 1} One-Sided Test{p_end}
{synopt:{cmd:r(pa_1)}}power (p) ArcoSinus method {space 8} One-Sided Test{p_end}

{p 4}
{helpb nsize##co1p_type:co1p options}{space 2} {helpb nsize##co2p_type:co2p options}{space 4} 
{helpb nsize##co1p_ex:co1p examples}{space 2} {helpb nsize##co2p_ex:co2p examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker c1pe_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:c1pe results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n)}}sample size (n){p_end}

{p 4}Sample Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n_80)}}sample size (n) for power = 80%{p_end}
{synopt:{cmd:r(n_85)}}sample size (n) for power = 85%{p_end}
{synopt:{cmd:r(n_90)}}sample size (n) for power = 90%{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p)}}power (p){p_end}

{p 4}
{helpb nsize##c1pe_type:c1pe options}{space 4} {helpb nsize##c1pe_ex:c1pe examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker c2pe_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:c2pe results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n0)}}sample size, Reference treatment (n0){p_end}
{synopt:{cmd:r(n1)}}sample size, Experimental treatment (n1){p_end}
{synopt:{cmd:r(n)}}sample size, Total (n){p_end}

{p 4}Sample Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 14 tabbed}{...}
{synopt:{cmd:r(n0_power)}}sample size, Reference treatment (n0){p_end}
{synopt:{cmd:r(n1_power)}}sample size, Experimental treatment (n1){p_end}
{synopt:{cmd:r(n_power)}}sample size, Total (n){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p)}}power (p){p_end}

{p 4}
{helpb nsize##c2pe_type:c2pe options}{space 4} {helpb nsize##c2pe_ex:c2pe examples}{space 9} {helpb nsize##syntax:back to syntax}

{p 4}
{helpb nsize##co1p_type:co1p options}{space 2} {helpb nsize##co2p_type:co2p options}{space 4} 
{helpb nsize##co1p_ex:co1p examples}{space 2} {helpb nsize##co2p_ex:co2p examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker copp_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:copp results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 14 tabbed}{...}
{synopt:{cmd:r(Size)}}sample size (n) matrix{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p2)}}power (p), Two-Sided Test{p_end}
{synopt:{cmd:r(p1)}}power (p), One-Sided Test{p_end}

{p 4}
{helpb nsize##copp_type:copp options}{space 4} {helpb nsize##copp_ex:copp examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker co1m_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co1m results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n_2)}}sample size (n), Two-Sided Test{p_end}
{synopt:{cmd:r(n_1)}}sample size (n), One-Sided Test{p_end}

{p 4}Sample Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(n_power_side)}}sample size (n){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_2)}}power (p), Two-Sided Test{p_end}
{synopt:{cmd:r(p_1)}}power (p), One-Sided Test{p_end}

{p 4}Minimum Effect Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(eff_2)}}minimum effect size (eff), Two-Sided Test{p_end}
{synopt:{cmd:r(eff_1)}}minimum effect size (eff), One-Sided Test{p_end}

{p 4}Minimum Effect Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(eff_power_side)}}minimum effect size (eff){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}
{helpb nsize##co1m_type:co1m options}{space 4} {helpb nsize##co1m_ex:co1m examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker co2m_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co2m results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n0_2)}}sample size n0, Two-Sided Test{p_end}
{synopt:{cmd:r(n0_1)}}sample size n0, One-Sided Test{p_end}
{synopt:{cmd:r(n1_2)}}sample size n1, Two-Sided Test{p_end}
{synopt:{cmd:r(n1_1)}}sample size n1, One-Sided Test{p_end}
{synopt:{cmd:r(n_2)}}sample size Total (n), Two-Sided Test{p_end}
{synopt:{cmd:r(n_1)}}sample size Total (n), One-Sided Test{p_end}

{p 4}Sample Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(n0_power_side)}}sample size n0{p_end}
{synopt:{cmd:r(n1_power_side)}}sample size n1{p_end}
{synopt:{cmd:r(n_power_side)}}sample size Total (n){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_2)}}power (p), Two-Sided Test{p_end}
{synopt:{cmd:r(p_1)}}power (p), One-Sided Test{p_end}

{p 4}Minimum Effect Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(eff_2)}}minimum effect size (eff), Two-Sided Test{p_end}
{synopt:{cmd:r(eff_1)}}minimum effect size (eff), One-Sided Test{p_end}

{p 4}Minimum Effect Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(eff_power_side)}}minimum effect size (eff){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}
{helpb nsize##co2m_type:co2m options}{space 4} {helpb nsize##co2m_ex:co2m examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker c2me_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:c2me results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n_2)}}sample size (n), Two-Sided Test{p_end}
{synopt:{cmd:r(n_1)}}sample size (n), One-Sided Test{p_end}

{p 4}Sample Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(n_power_side)}}sample size (n){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_2)}}power (p), Two-Sided Test{p_end}
{synopt:{cmd:r(p_1)}}power (p), One-Sided Test{p_end}

{p 4}Equivalence limits{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(eq_2)}}equivalence  limits (eq), Two-Sided Test{p_end}
{synopt:{cmd:r(eq_1)}}equivalence  limits (eq), One-Sided Test{p_end}

{p 4}Equivalence limits with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(eq_power_side)}}equivalence  limits (eq){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}
{helpb nsize##c2me_type:c2me options}{space 4} {helpb nsize##c2me_ex:c2me examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker cokm_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:cokm results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n_80_5)}}sample size (n) for Alpha Risk=5%, Power=80%{p_end}
{synopt:{cmd:r(n_85_5)}}sample size (n) for Alpha Risk=5%, Power=85%{p_end}
{synopt:{cmd:r(n_90_5)}}sample size (n) for Alpha Risk=5%, Power=90%{p_end}
{synopt:{cmd:r(n_80_1)}}sample size (n) for Alpha Risk=1%, Power=80%{p_end}
{synopt:{cmd:r(n_85_1)}}sample size (n) for Alpha Risk=1%, Power=85%{p_end}
{synopt:{cmd:r(n_90_1)}}sample size (n) for Alpha Risk=1%, Power=90%{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_5)}}power (p) for Alpha Risk=5%{p_end}
{synopt:{cmd:r(p_1)}}power (p) for Alpha Risk=1%{p_end}

{p 4}
{helpb nsize##cokm_type:cokm options}{space 4} {helpb nsize##cokm_ex:cokm examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker ci1p_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci1p results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(Size)}}sample size results matrix{p_end}

{p 4}Precision of CI{p_end}
{synoptset 14 tabbed}{...}
{synopt:{cmd:r(Precision)}}precision of CI results matrix{p_end}

{p 4}
{helpb nsize##ci1p_type:ci1p options}{space 4} {helpb nsize##ci1p_ex:ci1p examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker ci2p_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci2p results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(Size)}}sample size results matrix{p_end}

{p 4}Precision of CI{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_90)}}precision of CI for 90% confidence level{p_end}
{synopt:{cmd:r(p_95)}}precision of CI for 95% confidence level{p_end}
{synopt:{cmd:r(p_975)}}precision of CI for 97.5% confidence level{p_end}
{synopt:{cmd:r(p_99)}}precision of CI for 99% confidence level{p_end}

{p 4}
{helpb nsize##ci2p_type:ci2p options}{space 4} {helpb nsize##ci2p_ex:ci2p examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker ci1m_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci1m results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(Size)}}sample size results matrix{p_end}

{p 4}Precision of CI{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_90)}}precision of CI for 90% confidence level{p_end}
{synopt:{cmd:r(p_95)}}precision of CI for 95% confidence level{p_end}
{synopt:{cmd:r(p_99)}}precision of CI for 99% confidence level{p_end}

{p 4}
{helpb nsize##ci1m_type:ci1m options}{space 4} {helpb nsize##ci1m_ex:ci1m examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker ci2m_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ci2m results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(Size)}}sample size results matrix{p_end}

{p 4}Precision of CI{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_cl)}}precision of CI (p) for a given confidence level (cl){p_end}

{p 4}Precision of CI for default CL{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p_90)}}precision of CI for 90% confidence level{p_end}
{synopt:{cmd:r(p_95)}}precision of CI for 95% confidence level{p_end}
{synopt:{cmd:r(p_975)}}precision of CI for 97.5% confidence level{p_end}
{synopt:{cmd:r(p_99)}}precision of CI for 99% confidence level{p_end}

{p 4}
{helpb nsize##ci2m_type:ci2m options}{space 4} {helpb nsize##ci2m_ex:ci2m examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker co1c_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co1c & co2c results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n2)}}sample size (n), Two-Sided Test{p_end}
{synopt:{cmd:r(n1)}}sample size (n), One-Sided Test{p_end}

{p 4}Sample Size with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(n_power_side)}}sample size (n){p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(p2)}}power (p), Two-Sided Test{p_end}
{synopt:{cmd:r(p1)}}power (p), One-Sided Test{p_end}

{p 4}
{helpb nsize##co1c_type:co1c options}{space 2} {helpb nsize##co2c_type:co2c options}{space 4} 
{helpb nsize##co1c_ex:co1c examples}{space 2} {helpb nsize##co2c_ex:co2c examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker co2r_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:co2r & co2i results}}{p_end}
{p2line}
{p 4}Sample Size{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(Size)}}sample size results matrix{p_end}

{p 4}Power{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(Power)}}power results matrix{p_end}

{p 4}
{helpb nsize##co2r_type:co2r options}{space 2} {helpb nsize##co2i_type:co2i options}{space 4} 
{helpb nsize##co2r_ex:co2r examples}{space 2} {helpb nsize##co2i_ex:co2i examples}{space 9} {helpb nsize##syntax:back to syntax}

{marker ncr_st}{...}
{p2colset 5 20 20 2}{...}
{p2col :{it:ncr results}}{p_end}
{p2line}
{p 4}Number of communities by Group{p_end}
{synoptset 10 tabbed}{...}
{synopt:{cmd:r(n_2)}}number of communities (n), Normal method {space 10}  Two-Sided Test{p_end}
{synopt:{cmd:r(n_1)}}number of communities (n), Normal method {space 10}  One-Sided Test{p_end}
{synopt:{cmd:r(nc_2)}}number of communities (n), Student's correction {space 3}  Two-Sided Test{p_end}
{synopt:{cmd:r(nc_1)}}number of communities (n), Student's correction {space 3}  One-Sided Test{p_end}

{p 4}Number of communities by Group with {it:alpha}, {it:beta} by default{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(n_power_side)}}number of communities (n), Normal method{p_end}
{synopt:{cmd:r(nc_power_side)}}number of communities (n),  Student's correction{p_end}
{p 6}where {it:power} is the power in %: 80 85 90{p_end}
{p 12}{it:side}{space 1} is Two (2) or One (1) Sided Test{p_end}

{p 4}
{helpb nsize##ncr_type:ncr options}{space 4} {helpb nsize##ncr_ex:ncr examples}{space 9} {helpb nsize##syntax:back to syntax}


{marker version}{...}
{title:Version}

{p 4}
Version 1.3.2 {hline 2} 03 February 2020


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
Dom{c e'}nech JM. Sample Size and Power: Comparisons and estimations for independent proportions, means,{break}
correlations, risks and rates: User-written command nsize for Stata [computer program].{break}
V1.3.2. Bellaterra: Universitat Aut{c o'g}noma de Barcelona; 2020.{break}
Available executing from Stata: net from http://metodo.uab.cat/stata{p_end}


{marker references}{...}
{title:References}

{p 0 2}Chow SC, Shao J. A note on statistical methods for assessing therapeutic equivalence. Control Clin Trials. 2002;23(5): 515-20.{p_end}

{p 0 2}Chow SC, Shao J, Wang H. Sample size calculations in clinical research. 2nd ed. Boca Raton: Chapman & Hall/CRC; 2008.{p_end}

{p 0 2}Fleiss JL, Levin B, Pai MC. Statistical Methods for rates and proportions. 3rd ed. Hoboken (NJ): John Wiley& Sons; 2003.{p_end}

{p 0 2}Lemeshow S, Hosmer DW, Klar J, Lwanga SK. Adequacy of Sample Size in Health Studies. World Health Organization. Baffins Lane, Chichester: John Wiley & Sons; 1990.{p_end}

{p 0 2}Meinert C. Clinical Trials. Design, Conduct and Analysis. New York: Oxford University Press; 1986.{p_end}
