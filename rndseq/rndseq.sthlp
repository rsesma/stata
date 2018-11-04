{smcl}
{* *! version 1.0.4 05oct2016}{...}
{viewerdialog rndseq "dialog rndseq"}{...}
{viewerjumpto "Syntax" "rndseq##syntax"}{...}
{viewerjumpto "Description" "rndseq##description"}{...}
{viewerjumpto "Examples" "rndseq##examples"}{...}
{viewerjumpto "Version" "rndseq##version"}{...}
{viewerjumpto "Authors" "rndseq##authors"}{...}
{viewerjumpto "References" "rndseq##references"}{...}
{title:Title}

{phang}
{bf:rndseq} {hline 2} Generation of Random Sequences


{marker syntax}{...}
{title:Syntax}

{phang}Syntax for {bf:simple} randomization

{p 8 12 2}
{cmd:rndseq simple,} drug({it:string}) prot({it:string}) treat({it:string}) n(#) [{it:{help rndseq##options:options}}]


{phang}Syntax for {bf:block} randomization

{p 8 12 2}
{cmd:rndseq block,} drug({it:string}) prot({it:string}) treat({it:string}) n(#) bs(#) [{it:{help rndseq##options:options}}]


{phang}Syntax for {bf:efron} randomization

{p 8 12 2}
{cmd:rndseq efron,} drug({it:string}) prot({it:string}) treat({it:string}) n(#) lp(#) hp(#) [{it:{help rndseq##options:options}}]


{marker options}{...}
{synoptset 18 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{it:Simple randomization}}
{synopt :{opt n(#)}}number of subjects{space 15}(integer multiple of num. {bf:treat}){p_end}
{synopt :{opt r:atio(numlist)}}list of randomization ratios{space 5}(integers){break}
By default equal sample sizes are considered{p_end}

{syntab:{it:Block randomization}}
{synopt :{opt n(#)}}number of subjects{space 15}(integer multiple of {bf:bs}){p_end}
{synopt :{opt bs(#)}}block size{space 23}(integer multiple of {bf:ratio} sum){p_end}
{synopt :{opt r:atio(numlist)}}list of randomization ratios{space 5}(integers){break}
By default equal sample sizes are considered{p_end}

{syntab:{it:Efron randomization}}
{synopt :{opt n(#)}}number of subjects{space 15}(integer multiple of num. {bf:treat}){p_end}
{synopt :{opt lp(#)}}low probability of assignment{space 4}(0 < {bf:lp} < 0.5){p_end}
{synopt :{opt hp(#)}}high probability of assignment{space 3}(0.5 < {bf:hp} < 1){p_end}

{syntab:{it:Common parameters}}
{synopt :{opt t:reat(string)}}{bf:comma}-separated list with the Treatments labels{p_end}
{synopt :{opt d:rug(string)}}Drug label{p_end}
{synopt :{opt p:rot(string)}}Protocol label{p_end}
{synopt :{opt c:enter(string)}}{bf:comma}-separated list with the Labels of Centers {p_end}
{synopt :{opt s:trata(string)}}{bf:comma}-separated list with the Labels of Strata for Center{p_end}
{synopt :{opt pc:enter(numlist)}}expected proportions for each Center{p_end}
{synopt :{opt ps:trata(numlist)}}expected proportions for each Strata{break}
The proportions expected in each center/stratum must add 1{break}
By default equal proportions are considered{p_end}
{synopt :{opt pre:fix(string)}}{bf:blank}-separated list with the Prefix of subject number{p_end}
{synopt :{opt seed(#)}}specify initial value of random-number {help seed:seed}{break}
By default no seed is specified and RANDOM sequences are generated{p_end}
{synopt :{opt noprint}}do not print results{p_end}
{synopt :{opth using(filename)}}{it:{help filename}} to store the results dataset; by default a dataset named 
{it:rndseq_results} is saved in the current (working) directory{p_end}
{synopt :{opt noreplace}}if {it:{help filename}} exists, do not replace; by default existing datasets are replaced{p_end}
{synopt :{opt nst(string)}}name of the study (label){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{p 4 4 2}
Generation of Random Sequences. Three methods are available:{break}
{space 2}- {bf:simple}{space 2}Simple randomization{break}
{space 2}- {bf:block}{space 3}Blocking, balanced restricted randomization{break}
{space 2}- {bf:efron}{space 3}Efron adaptative biased-coin randomization{break}

{p 4 4}
Some restrictions apply to the parameters, see the {help rndseq##options:options}. Optionally it is possible to define
a list of Centers and a list of by-Center Strata. If a {cmd:prefix} option is 
specified, the number of elements must be equal to the multiplication of the number of centers and strata.

{p 4 4}
The results are stored in a new dataset named by default {it:rndseq_results} and saved in the current (working) 
directory. Existing datasets are replaced by default.

{p 4 4}
You can click {dialog rndseq:here} to pop up a {dialog rndseq:dialog} or type {inp: db rndseq}.

{p 4 4}
Execute {cmd: net from http://www.graunt.cat/stata} for install. 

{p 4 4}
It is important to keep the commands updated. Execute {cmd: adoupdate rndseq, update} to update the {bf:rndseq} command.{break}
Execute {cmd: adoupdate, update} to update {bf:all} the user-written commands.

{p 4 4}
If you find any bugs or want to suggest any improvements, please send an e-mail to: stata@graunt.cat.


{marker examples}{...}
{title:Examples}

{p 2 4}{it:Simple}{break}
{cmd:. rndseq simple, drug(YEMR) prot(Y.1A) treat(50 mg, Placebo) n(86) center(Clinic BCN) prefix(PR) seed(1987653) using(HTA_Ruti_results.dta) nst(HTA_Ruti)}{p_end}

{p 2 4}{it:Block}{break}
{cmd:. rndseq block, drug(YEMR) prot(Y.1A) treat(Placebo, 50mg, 100mg) n(30) bs(5) ratio(1 2 2) center(Center A, Center B) prefix(A B)}{p_end}

{p 2 4}{it:Efron}{break}
{cmd:. rndseq efron, drug(AZX) prot(AZX.014) treat(A, B) n(24) lp(0.33333) hp(0.66667) center(Clinic, Sant Pau) pcenter(0.7 0.3)}{p_end}


{marker version}{...}
{title:Version}

{p 4}
Version 1.0.4 {hline 2} 05 October 2016


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
Dom{c e'}nech JM. Generation of Random Sequences: User-written command rndseq for Stata [computer program].{break}
V1.0.4. Barcelona: Graunt21; 2016.{break}
Available executing from Stata: net from http://www.graunt.cat/stata{break}


{marker references}{...}
{title:References}

{p 0 2}
Delgado M, Llorca J, Dom{c e'}nech JM. Estudios experimentales. 5{c 170} ed. Barcelona: Signo; 2012{p_end}
