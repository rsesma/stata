*! version 1.2.5  24apr2017 JM. Domenech, R. Sesma
/*
This command is obsolete (use sta instead)
*/

program define ci2pi
	version 12
	syntax anything(id="argument numlist"), /*
	*/	[PAIRed ST(string) Zero(string) Level(numlist max=1 >50 <100) Wilson Exact WAld   /*
	*/	 Pearson MH R(numlist max=1 >0 <1) PE(numlist max=1 >0 <1) RELatsymm NNT(numlist integer max=1 >=0 <=1) /*
	*/	 nst(string) incall row(varname) col(varname) touse(varname)]

	display in red "ci2p command is obsolete. To install new command {bf:sta} execute:"
	display `"{stata "net from http://www.graunt.cat/stata"}"'
	
end
