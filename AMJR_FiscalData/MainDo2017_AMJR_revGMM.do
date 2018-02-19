set more off
clear all

**************************************************************************************************************************
*MainDo_AMJR.do				@Amichaud v.2/15/2018 (v1.1/25/2017)
**************************************************************************************************************************


 cd "C:\Users\ammichau\Desktop\AMJR_FiscalData\Data"
 global IN_dir "Infiles"
 global OUT_dir "Outfiles"
 *global OUT_dir "Figures"
 
**************************************************************************************************************************
*This file computes GMM standard errors for the main statistics we target in the calibration.

*********************************************************************************************************************************
*-------------------
*	-Macro Stats: sd(y), st(d)/st(y)
*	-Average Share of GDP: Taxes and Revenues
*	-Cyclicality: Taxes and Revenues
*-------------------


use $IN_dir\FinalDataset.dta, clear	

		egen tY = total(!missing(lrgdpn_cycle)), by(countrycode)
		egen tC = total(!missing(lHHc_cycle)), by(countrycode)
		egen tI = total(!missing(lInv_cycle)), by(countrycode)
		egen tR = total(!missing(irate_cycle)), by(countrycode)
		egen tNX = total(!missing(nx_cycle)), by(countrycode)
		egen tExp = total(!missing(TotExp_cycle)), by(countrycode)
		egen tRev = total(!missing(TotRev_cycle)), by(countrycode)
		egen tSB = total(!missing(SocBenExp_cycle)), by(countrycode)
		egen tG = total(!missing(GoodsServExp_cycle)), by(countrycode)		

drop if tY==0
drop if countrycode==278

		
*>>> Try to show robustness with standard errors <<<
*	-->Calculate standard errors using GMM

*-----First the developed---------------------------------------------
	drop if IMFdevlp==0 | IMFdevlp==.
		xtset countrycode Year
			
		egen IMFgroup = group(countrycode)
		
		*drop if Year>2012

******************** MAIN Economic AGGREGATES************************		
		gen sigY=.
		gen se_sigY=.
		gen sigC=.
		gen se_sigC=.
		gen sigI=.
		gen se_sigI=.
		gen sigR=.
		gen se_sigR=.		
		gen sigCY=.
		gen se_sigCY=.
		gen sigIY=.
		gen se_sigIY=.		
		gen corrNX=.
		gen se_corrNX=.		
		gen corrC=.
		gen se_corrC=.
		gen corrR=.
		gen se_corrR=.
		gen corrY=.
		gen se_corrY=.		
			
		capture noisily{
	su IMFgroup, meanonly	
	forvalues i = 1/`r(max)' {	
		*Calculate Standard Deviations and their Standard Errors
			*GDP
			gmm (1st:lrgdpn_cycle-{mean1} ) (2nd:(((lrgdpn_cycle-{mean1})^2)/(tY-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigY=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigY=100*_se[/stdev1] if IMFgroup==`i'
			*Consumption
			gmm (1st:lHHc_cycle-{mean1} ) (2nd:(((lHHc_cycle-{mean1})^2)/(tC-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigC=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigC=100*_se[/stdev1] if IMFgroup==`i'
			*Investment
			gmm (1st:lInv_cycle-{mean1} ) (2nd:(((lInv_cycle-{mean1})^2)/(tI-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigI=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigI=100*_se[/stdev1] if IMFgroup==`i'	
			*Interest Rate
			gmm (1st:irate_cycle-{mean1} ) (2nd:(((irate_cycle-{mean1})^2)/(tR-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigR=_b[/stdev1] if IMFgroup==`i'
				replace se_sigR=_se[/stdev1] if IMFgroup==`i'				
		*Calculate ratios and sum Standard Errors	
			*C/Y
				replace sigCY = sigC/sigY
				replace se_sigCY = se_sigY+se_sigC
			*I/Y
				replace sigIY = sigI/sigY
				replace se_sigIY = se_sigY+se_sigI				
		*Calculate correlations and their Standard Errors
			*corr(c,y)
			gmm (1st:lHHc_cycle-{mean1} ) (2nd:(((lHHc_cycle-{mean1})^2)/(tC-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(lHHc_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrC=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrC=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	
			*corr(NX,y)
			gmm (1st:nx_cycle-{mean1} ) (2nd:(((nx_cycle-{mean1})^2)/(tNX-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((tY-{mean2})^2)/(max_tlrgdpn-1))^(0.5)-{stdev2}) ///
				(5th:(nx_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrNX=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrNX=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'
			*corr(R,y)
			gmm (1st:irate_cycle-{mean1} ) (2nd:(((irate_cycle-{mean1})^2)/(tI-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle_FD-{mean2} ) (4th:(((lrgdpn_cycle_FD-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(irate_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrR=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrR=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	
			*corr(y_t,y_t-1)
			gmm (1st:L1GDP_cycle-{mean1} ) (2nd:(((L1GDP_cycle-{mean1})^2)/(tY-2))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle_FD-{mean2} ) (4th:(((lrgdpn_cycle_FD-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(L1GDP_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrY=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrY=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'					
			}
			}
******************** MAIN FISCAL AGGREGATES************************		
		gen sigExp=.
		gen se_sigExp=.
		gen sigRev=.
		gen se_sigRev=.
		gen sigSB=.
		gen se_sigSB=.
		gen sigG=.
		gen se_sigG=.		
		gen sigSBY=.
		gen se_sigSBY=.
		gen sigRevY=.
		gen se_sigRevY=.		
		gen corrRev=.
		gen se_corrRev=.		
		gen corrExp=.
		gen se_corrExp=.
		gen corrSB=.
		gen se_corrSB=.
		gen corrG=.
		gen se_corrG=.		
				
			
	capture {	
	su IMFgroup, meanonly	
	forvalues i = 1/`r(max)' {	
		*Calculate Standard Deviations and their Standard Errors
			*Total Expenditure
			gmm (1st:TotExp_cycle-{mean1} ) (2nd:(((TotExp_cycle-{mean1})^2)/(tExp-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigExp=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigExp=100*_se[/stdev1] if IMFgroup==`i'
			*Total Revenue
			gmm (1st:TotRev_cycle-{mean1} ) (2nd:(((TotRev_cycle-{mean1})^2)/(tRev-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigRev=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigRev=100*_se[/stdev1] if IMFgroup==`i'
			*Social Benefits
			gmm (1st:SocBenExp_cycle-{mean1} ) (2nd:(((SocBenExp_cycle-{mean1})^2)/(tSB-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigSB=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigSB=100*_se[/stdev1] if IMFgroup==`i'	
			*Goods and Serv
			gmm (1st:GoodsServExp_cycle-{mean1} ) (2nd:(((GoodsServExp_cycle-{mean1})^2)/(tG-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigG=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigG=100*_se[/stdev1] if IMFgroup==`i'				
		*Calculate ratios and sum Standard Errors	
			*SB/Y
				replace sigSBY = sigSB/sigY
				replace se_sigSBY = se_sigY+se_sigSB
			*Rev/Y
				replace sigRevY = sigRev/sigY
				replace se_sigRevY = se_sigY+se_sigRev				
		*Calculate correlations and their Standard Errors
			*corr(Rev,y)
			gmm (1st:TotRev_cycle-{mean1} ) (2nd:(((TotRev_cycle-{mean1})^2)/(tRev-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(TotExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrRev=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrRev=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	
			*corr(Exp,y)
			gmm (1st:TotExp_cycle-{mean1} ) (2nd:(((TotExp_cycle-{mean1})^2)/(tExp-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(TotExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrExp=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrExp=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'
			*corr(SB,y)
			gmm (1st:SocBenExp_cycle-{mean1} ) (2nd:(((SocBenExp_cycle-{mean1})^2)/(tSB-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(SocBenExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrSB=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrSB=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	
			*corr(G,y)
			gmm (1st:GoodsServExp_cycle-{mean1} ) (2nd:(((GoodsServExp_cycle-{mean1})^2)/(tG-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(GoodsServExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrG=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrG=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'					
			}			
			}

	save $IN_dir\SumStats_IMF1_rev.dta, replace	
			*/
*-----Second the emerging---------------------------------------------
use $IN_dir\FinalDataset.dta, clear	

	drop if (IMFdevlp==1 | IMFdevlp==. )
	drop if countrycode==278
	*| countrycode==253 | countrycode==744  | countrycode==273 |countrycode==278)
		sort countrycode Year
		egen IMFgroup = group(countrycode)
		*replace TotRev=. if (countrycode==218 & Year==2006)
		
		egen tY = total(!missing(lrgdpn_cycle)), by(countrycode)
		egen tC = total(!missing(lHHc_cycle)), by(countrycode)
		egen tI = total(!missing(lInv_cycle)), by(countrycode)
		egen tR = total(!missing(irate_cycle)), by(countrycode)
		egen tNX = total(!missing(nx_cycle)), by(countrycode)
		egen tExp = total(!missing(TotExp_cycle)), by(countrycode)
		egen tRev = total(!missing(TotRev_cycle)), by(countrycode)
		egen tSB = total(!missing(SocBenExp_cycle)), by(countrycode)
		egen tG = total(!missing(GoodsServExp_cycle)), by(countrycode)	
		

drop if tY==0		

******************** MAIN Economic AGGREGATES************************		
		gen sigY=.
		gen se_sigY=.
		gen sigC=.
		gen se_sigC=.
		gen sigI=.
		gen se_sigI=.
		gen sigR=.
		gen se_sigR=.		
		gen sigCY=.
		gen se_sigCY=.
		gen sigIY=.
		gen se_sigIY=.		
		gen corrNX=.
		gen se_corrNX=.		
		gen corrC=.
		gen se_corrC=.
		gen corrR=.
		gen se_corrR=.
		gen corrY=.
		gen se_corrY=.		
			
		capture noisily{
	su IMFgroup, meanonly	
	forvalues i = 1/`r(max)' {	
		*Calculate Standard Deviations and their Standard Errors
			*GDP
			gmm (1st:lrgdpn_cycle-{mean1} ) (2nd:(((lrgdpn_cycle-{mean1})^2)/(tY-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) level(90) 	
				replace sigY=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigY=100*_se[/stdev1] if IMFgroup==`i'
			*Consumption
			gmm (1st:lHHc_cycle-{mean1} ) (2nd:(((lHHc_cycle-{mean1})^2)/(tC-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigC=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigC=100*_se[/stdev1] if IMFgroup==`i'
			*Investment
			gmm (1st:lInv_cycle-{mean1} ) (2nd:(((lInv_cycle-{mean1})^2)/(tI-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigI=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigI=100*_se[/stdev1] if IMFgroup==`i'	
			*Interest Rate
			gmm (1st:irate_cycle-{mean1} ) (2nd:(((irate_cycle-{mean1})^2)/(tR-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigR=_b[/stdev1] if IMFgroup==`i'
				replace se_sigR=_se[/stdev1] if IMFgroup==`i'				
		*Calculate ratios and sum Standard Errors	
			*C/Y
				replace sigCY = sigC/sigY
				replace se_sigCY = se_sigY+se_sigC
			*I/Y
				replace sigIY = sigI/sigY
				replace se_sigIY = se_sigY+se_sigI				
		*Calculate correlations and their Standard Errors
			*corr(c,y)
			gmm (1st:lHHc_cycle-{mean1} ) (2nd:(((lHHc_cycle-{mean1})^2)/(tC-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(lHHc_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrC=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrC=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	
			*corr(NX,y)
			gmm (1st:nx_cycle-{mean1} ) (2nd:(((nx_cycle-{mean1})^2)/(tNX-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((tY-{mean2})^2)/(max_tlrgdpn-1))^(0.5)-{stdev2}) ///
				(5th:(nx_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrNX=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrNX=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'
			*corr(R,y)
			gmm (1st:irate_cycle-{mean1} ) (2nd:(((irate_cycle-{mean1})^2)/(tI-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle_FD-{mean2} ) (4th:(((lrgdpn_cycle_FD-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(irate_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrR=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrR=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	
			*corr(y_t,y_t-1)
			gmm (1st:L1GDP_cycle-{mean1} ) (2nd:(((L1GDP_cycle-{mean1})^2)/(tY-2))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle_FD-{mean2} ) (4th:(((lrgdpn_cycle_FD-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(L1GDP_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrY=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrY=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'					
			}
			}
******************** MAIN FISCAL AGGREGATES************************		
		gen sigExp=.
		gen se_sigExp=.
		gen sigRev=.
		gen se_sigRev=.
		gen sigSB=.
		gen se_sigSB=.
		gen sigG=.
		gen se_sigG=.		
		gen sigSBY=.
		gen se_sigSBY=.
		gen sigRevY=.
		gen se_sigRevY=.		
		gen corrRev=.
		gen se_corrRev=.		
		gen corrExp=.
		gen se_corrExp=.
		gen corrSB=.
		gen se_corrSB=.
		gen corrG=.
		gen se_corrG=.		
				
			
	capture {	
	su IMFgroup, meanonly	
	forvalues i = 1/`r(max)' {	
		*Calculate Standard Deviations and their Standard Errors
			*Total Expenditure
			gmm (1st:TotExp_cycle-{mean1} ) (2nd:(((TotExp_cycle-{mean1})^2)/(tExp-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigExp=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigExp=100*_se[/stdev1] if IMFgroup==`i'
			*Total Revenue
			gmm (1st:TotRev_cycle-{mean1} ) (2nd:(((TotRev_cycle-{mean1})^2)/(tRev-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigRev=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigRev=100*_se[/stdev1] if IMFgroup==`i'
			*Social Benefits
			gmm (1st:SocBenExp_cycle-{mean1} ) (2nd:(((SocBenExp_cycle-{mean1})^2)/(tSB-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigSB=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigSB=100*_se[/stdev1] if IMFgroup==`i'	
		
		*Calculate ratios and sum Standard Errors	
			*SB/Y
				replace sigSBY = sigSB/sigY
				replace se_sigSBY = se_sigY+se_sigSB
			*Rev/Y
				replace sigRevY = sigRev/sigY
				replace se_sigRevY = se_sigY+se_sigRev				
		*Calculate correlations and their Standard Errors
			*corr(Rev,y)
			gmm (1st:TotRev_cycle-{mean1} ) (2nd:(((TotRev_cycle-{mean1})^2)/(tRev-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(TotExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrRev=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrRev=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	
			*corr(Exp,y)
			gmm (1st:TotExp_cycle-{mean1} ) (2nd:(((TotExp_cycle-{mean1})^2)/(tExp-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(TotExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrExp=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrExp=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'
			*corr(SB,y)
			gmm (1st:SocBenExp_cycle-{mean1} ) (2nd:(((SocBenExp_cycle-{mean1})^2)/(tSB-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(SocBenExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrSB=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrSB=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'	

			drop countrycode==193 				
				
			*Goods and Serv
			gmm (1st:GoodsServExp_cycle-{mean1} ) (2nd:(((GoodsServExp_cycle-{mean1})^2)/(tG-1))^(0.5)-{stdev1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace sigG=100*_b[/stdev1] if IMFgroup==`i'
				replace se_sigG=100*_se[/stdev1] if IMFgroup==`i'					
			*corr(G,y)
			gmm (1st:GoodsServExp_cycle-{mean1} ) (2nd:(((GoodsServExp_cycle-{mean1})^2)/(tG-1))^(0.5)-{stdev1}) ///
				(3rd:lrgdpn_cycle-{mean2} ) (4th:(((lrgdpn_cycle-{mean2})^2)/(tY-1))^(0.5)-{stdev2}) ///
				(5th:(GoodsServExp_cycle-{mean1})*(lrgdpn_cycle-{mean2})-{cov1}) ///
				if IMFgroup==`i' , winitial(identity) 	
				replace corrG=(_b[/cov1]/(_b[/stdev1]*_b[/stdev2]))/100 if IMFgroup==`i'
				replace se_corrG=10*(_se[/cov1]+_se[/stdev2]+_se[/stdev1]) if IMFgroup==`i'					
			}			
			}
	
	save $IN_dir\SumStats_IMF0_rev.dta, replace	
	
	use $IN_dir\SumStats_IMF0_rev.dta, clear
	append using $IN_dir\SumStats_IMF1_rev.dta
	
	collapse (median) pop RshareInc EmplExp-GoodsServExp EmplExp_cycle-GoodsServExp_cycle EmplExp_cycle_FD-GoodsServExp_cycle_FD lHHc_cycle-se_corrG, by(countrycode)

		gen group = IMFdevlp
		by IMFdevlp, sort: egen psum = sum(pop)
		gen cweight = pop/psum
		replace pop=floor(pop)
	
preserve	
	
		collapse (mean) RshareInc EmplExp-GoodsServExp EmplExp_cycle-GoodsServExp_cycle EmplExp_cycle_FD-GoodsServExp_cycle_FD lHHc_cycle-av_GoodsServExp sigY-se_corrG, by(IMFdevlp)
							
* Table 2
	ssc install latab
	latabstat  sigY se_sigY sigCY se_sigCY sigIY se_sigIY, by(IMFdevlp) nototal f(%9.3f)	
	latabstat  sd_lrgdpn rdlHHc rdlInv	, by(IMFdevlp) nototal f(%9.3f)	
	
	latabstat  sigSBY se_sigSBY sigRevY se_sigRevY sigR se_sigR, by(IMFdevlp) nototal f(%9.3f)	
	latabstat  rdSocBenExp rdTotRev	sd_irate, by(IMFdevlp) nototal f(%9.3f)	

	latabstat  corrSB se_corrSB corrRev se_corrRev, by(IMFdevlp) nototal f(%9.3f)	
	latabstat  corr_GDP_SocBenExp corr_GDP_TotRev, by(IMFdevlp) nototal f(%9.3f)	
	
	latabstat  corrNX se_corrNX corrR se_corrR corrY se_corrY, by(IMFdevlp) nototal f(%9.3f)	
	latabstat  corr_GDP_nx corr_GDP_irate_FD corr_GDP_L1GDP, by(IMFdevlp) nototal f(%9.3f)		
	
restore


*/
	sort IMFdevlp countrycode
	egen cgroup = group(countrycode)
	
	*---------Main Aggregate Volatilities*------
	putexcel clear
	putexcel set $OUT_dir/Vldty_Tab_SD_rev.csv, modify
		putexcel A1 = ("Stat") B1 = ("Linear Quadratic") C1 = ("First Difference") D1 = ("NP")  ///
		A2 = ("Developed") A3 = ("sigma(Y)") A5 = ("sigma(NX)") A7 = ("sigma(C)/sigma(Y)") ///
		A9 = ("sigma(I)/sigma(Y)") A11 = ("corr(C,Y)") A13 = ("corr(I,Y)") A15 = ("corr(NX,Y)") ///	
		A17 = ("Emerging") A18 = ("sigma(Y)") A20 = ("sigma(NX)") ///
		A22 = ("sigma(C)/sigma(Y)") A24 = ("sigma(I)/sigma(Y)") A26 = ("corr(C,Y)") A28 = ("corr(I,Y)") A30 = ("corr(NX,Y)") 
		
	*Linear-Quadratic

drop if max_tnx==1
		gmm (1st:lrgdpn_cycle-{mean1} ) (2nd:100*(((lrgdpn_cycle-{mean1})^2)/(max_tlrgdpn-1))^(0.5)-{var1}) ///
			if group==1 , vce(cluster cgroup , independent) winitial(identity) 	
			*matrix list e(V)
				local ssig = 100*_b[/var1]
				local shat = 100*_se[/var1]
				di %6.2f `ssig'
				di %6.2f `shat'
			putexcel B3=(`ssig')
			putexcel B4=(`shat')
	gmm (1st:lrgdpn_cycle-{meanY} ) (2nd:nx_cycle-{mean1} ) ///
		(3rd:((((nx_cycle-{mean1})^2)/(max_tnx-1))^(0.5))/(((((lrgdpn_cycle-{meanY})^2)/(max_tlrgdpn-1))^(0.5)))-{varY})  ///
		if group==1 , vce(cluster cgroup , independent) winitial(identity)	nocommonesample 
				local ssig = 100*_b[/varY]
				local shat = 100*_se[/varY]
				di %6.2f `ssig'
				di %6.2f `shat'
			putexcel B5=(`ssig')
			putexcel B6=(`shat')
		
	gmm (1st:lrgdpn_cycle-{meanY} ) (2nd:lHHc_cycle-{mean1} ) ///
		(3rd:((((lHHc_cycle-{mean1})^2)/( max_tlTc-1))^(0.5))/((((lrgdpn_cycle-{meanY})^2)/(max_tlrgdpn-1))^(0.5))-{varY})  ///
		if group==1 , vce(cluster cgroup , independent) winitial(identity) onestep

	gmm (1st:lrgdpn_cycle-{meanY} ) (2nd:lHHc_cycle-{mean1} ) ///
		(3rd:((((lHHc_cycle-{mean1})^2)/( max_tlTc-1))^(0.5))/((((lrgdpn_cycle-{meanY})^2)/(max_tlrgdpn-1))^(0.5))-{varY})  ///
		if group==1 , vce(cluster cgroup , independent) winitial(identity) onestep		
		
		*igmm igmmeps(1e-4)
	/*	
			
	gmm (1st:lrgdpn_cycle-{meanY} ) (2nd:(((lrgdpn_cycle-{meanY})^2)/(max_tlrgdpn-1))^(0.5)-{varY})  ///
		(3rd:lHHc_cycle-{mean1} ) (4th:(((lHHc_cycle-{mean1})^2)/( max_tlTc-1))^(0.5)-{var1}) ///
		(5th:{var1}/{varY}-{rvar}) ///
		if group==1 , vce(cluster cgroup , independent) winitial(identity)	
		
				local ssig = 100*_b[/rvar]
				local shat = 100*_se[/rvar]
				di %6.2f `ssig'
				di %6.2f `shat'
			putexcel B5=(`ssig')
			putexcel B6=(`shat')
		*/	
	gmm (1st:lHHc_cycle-{mean1} ) (2nd:100*(((lHHc_cycle-{mean1})^2)/( max_tlTc-1))^(0.5)-{var1}) ///
			if group==1 , vce(cluster cgroup , independent) winitial(identity) 	
				local ssig = 100*_b[/var1]
				local shat = 100*_se[/var1]
				di %6.2f `ssig'
				di %6.2f `shat'
			putexcel B7=(`ssig')
			putexcel B8=(`shat')		
	gmm (1st:lInv_cycle-{mean1} ) (2nd:100*(((lInv_cycle-{mean1})^2)/(max_tlInv-1))^(0.5)-{var1}) ///
			if group==1 , vce(cluster cgroup , independent) winitial(identity) 	
				local ssig = 100*_b[/var1]
				local shat = 100*_se[/var1]
				di %6.2f `ssig'
				di %6.2f `shat'
			putexcel B9=(`ssig')
			putexcel B10=(`shat')
			
		ci var rdlInv   if group==1
			putexcel B9=(r(mean))
			putexcel B10=(r(se))	
		ci mean corr_GDP_lHHc   if group==1		
			putexcel B11=(r(mean))
			putexcel B12=(r(se))		
		ci mean corr_GDP_lInv   if group==1		
			putexcel B13=(r(mean))
			putexcel B14=(r(se))
		ci mean corr_GDP_nx   if group==1		
			putexcel B15=(r(mean))
			putexcel B16=(r(se))
			
		ci var sd_lrgdpn  if group==0
			putexcel B18=(r(mean))
			putexcel B19=(r(se))			
		ci var rdnx       if group==0
			putexcel B20=(r(mean))
			putexcel B21=(r(se))			
		ci var rdlHHc     if group==0
			putexcel B22=(r(mean))
			putexcel B23=(r(se))			
		ci var rdlInv     if group==0		
			putexcel B24=(r(mean))
			putexcel B25=(r(se))			
		ci mean corr_GDP_lHHc    if group==0		
			putexcel B26=(r(mean))
			putexcel B27=(r(se))		
		ci mean corr_GDP_lInv     if group==0		
			putexcel B28=(r(mean))
			putexcel B29=(r(se))
		ci mean corr_GDP_nx     if group==0		
			putexcel B30=(r(mean))
			putexcel B31=(r(se))
			
	*Linear-Quadratic- unweighted
		ci var sd_lrgdpn  if group==1
			putexcel C3=(r(mean))
			putexcel C4=(r(se))	
		ci var rdnx       if group==1
			putexcel C5=(r(mean))
			putexcel C6=(r(se))			
		ci var rdlHHc     if group==1
			putexcel C7=(r(mean))
			putexcel C8=(r(se))			
		ci var rdlInv     if group==1
			putexcel C9=(r(mean))
			putexcel C10=(r(se))			
		ci mean corr_GDP_lHHc  if group==1		
			putexcel C11=(r(mean))
			putexcel C12=(r(se))		
		ci mean corr_GDP_lInv   if group==1		
			putexcel C13=(r(mean))
			putexcel C14=(r(se))
		ci mean corr_GDP_nx   if group==1		
			putexcel C15=(r(mean))
			putexcel C16=(r(se))
			
		ci var sd_lrgdpn  if group==0
			putexcel C18=(r(mean))
			putexcel C19=(r(se))			
		ci var rdnx       if group==0
			putexcel C20=(r(mean))
			putexcel C21=(r(se))			
		ci var rdlHHc     if group==0
			putexcel C22=(r(mean))
			putexcel C23=(r(se))			
		ci var rdlInv     if group==0	
			putexcel C24=(r(mean))
			putexcel C25=(r(se))			
		ci mean corr_GDP_lHHc   if group==0		
			putexcel C26=(r(mean))
			putexcel C27=(r(se))		
		ci mean corr_GDP_lInv   if group==0		
			putexcel C28=(r(mean))
			putexcel C29=(r(se))
		ci mean corr_GDP_nx     if group==0		
			putexcel C30=(r(mean))
			putexcel C31=(r(se))
			
	*First Difference
		ci var sd_lrgdpn_FD  if group==1
			putexcel D3=(r(mean))
			putexcel D4=(r(se))	
		ci var rdnx_FD       if group==1
			putexcel D5=(r(mean))
			putexcel D6=(r(se))			
		ci var rdlHHc_FD     if group==1
			putexcel D7=(r(mean))
			putexcel D8=(r(se))			
		ci var rdlInv_FD     if group==1
			putexcel D9=(r(mean))
			putexcel D10=(r(se))			
		ci mean corr_GDP_lHHc_FD     if group==1		
			putexcel D11=(r(mean))
			putexcel D12=(r(se))		
		ci mean corr_GDP_lInv_FD     if group==1		
			putexcel D13=(r(mean))
			putexcel D14=(r(se))
		ci mean corr_GDP_nx_FD     if group==1		
			putexcel D15=(r(mean))
			putexcel D16=(r(se))
			
		ci var sd_lrgdpn_FD  if group==0
			putexcel D18=(r(mean))
			putexcel D19=(r(se))			
		ci var rdnx_FD       if group==0
			putexcel D20=(r(mean))
			putexcel D21=(r(se))			
		ci var rdlHHc_FD    if group==0
			putexcel D22=(r(mean))
			putexcel D23=(r(se))			
		ci var rdlInv_FD     if group==0		
			putexcel D24=(r(mean))
			putexcel D25=(r(se))			
		ci mean corr_GDP_lHHc_FD     if group==0		
			putexcel D26=(r(mean))
			putexcel D27=(r(se))		
		ci mean corr_GDP_lInv_FD     if group==0		
			putexcel D28=(r(mean))
			putexcel D29=(r(se))
		ci mean corr_GDP_nx_FD     if group==0		
			putexcel D30=(r(mean))
			putexcel D31=(r(se))			
			
			
			
			
			
	*			reg lHHc_cycle i.ccode2, noc

	*Collapse to 
	collapse (mean) pop IMFdevlp  sd* rd*   corr_* EmplExp TotExp ///
						GrantsExp GrantsRev IntrstExp OtherExp OtherRev TotRev SocBenExp ///
						SocContrRev SubsidyExp TaxRev GoodsServExp Nrich RshareInc , by(countrycode)
						
		replace pop = floor(pop)
		
	gen group = IMFdevlp
	by group, sort: egen psum = sum(pop)
	gen cweight = floor(100*(pop/psum))
	
*Try to show robustness with standard errors

	*---------Main Aggregate Volatilities*------
	putexcel clear
	putexcel set $OUT_dir/Vldty_Tab_SD_rev.csv, modify
		putexcel A1 = ("Stat") B1 = ("Weighted LQ") C1 = ("Unweighted LQ") D1 = ("Weighted FD") E1 = ("NP") ///
		A2 = ("Developed") A3 = ("sigma(Y)") A5 = ("sigma(NX)") A7 = ("sigma(C)/sigma(Y)") ///
		A9 = ("sigma(I)/sigma(Y)") A11 = ("corr(C,Y)") A13 = ("corr(I,Y)") A15 = ("corr(NX,Y)") ///	
		A17 = ("Emerging") A18 = ("sigma(Y)") A20 = ("sigma(NX)") ///
		A22 = ("sigma(C)/sigma(Y)") A24 = ("sigma(I)/sigma(Y)") A26 = ("corr(C,Y)") A28 = ("corr(I,Y)") A30 = ("corr(NX,Y)") 
		
	*Linear-Quadratic
		ci var sd_lrgdpn  if group==1
			putexcel B3=(r(mean))
			putexcel B4=(r(se))	
		ci var rdnx       if group==1
			putexcel B5=(r(mean))
			putexcel B6=(r(se))			
		ci var rdlHHc     if group==1
			putexcel B7=(r(mean))
			putexcel B8=(r(se))			
		ci var rdlInv     if group==1
			putexcel B9=(r(mean))
			putexcel B10=(r(se))	
		ci mean corr_GDP_lHHc    if group==1		
			putexcel B11=(r(mean))
			putexcel B12=(r(se))		
		ci mean corr_GDP_lInv    if group==1		
			putexcel B13=(r(mean))
			putexcel B14=(r(se))
		ci mean corr_GDP_nx     if group==1		
			putexcel B15=(r(mean))
			putexcel B16=(r(se))
			
		ci var sd_lrgdpn  if group==0
			putexcel B18=(r(mean))
			putexcel B19=(r(se))			
		ci var rdnx      if group==0
			putexcel B20=(r(mean))
			putexcel B21=(r(se))			
		ci var rdlHHc     if group==0
			putexcel B22=(r(mean))
			putexcel B23=(r(se))			
		ci var rdlInv    if group==0		
			putexcel B24=(r(mean))
			putexcel B25=(r(se))			
		ci mean corr_GDP_lHHc     if group==0		
			putexcel B26=(r(mean))
			putexcel B27=(r(se))		
		ci mean corr_GDP_lInv    if group==0		
			putexcel B28=(r(mean))
			putexcel B29=(r(se))
		ci mean corr_GDP_nx     if group==0		
			putexcel B30=(r(mean))
			putexcel B31=(r(se))
			
	*Linear-Quadratic- unweighted
		ci var sd_lrgdpn  if group==1
			putexcel C3=(r(mean))
			putexcel C4=(r(se))	
		ci var rdnx       if group==1
			putexcel C5=(r(mean))
			putexcel C6=(r(se))			
		ci var rdlHHc     if group==1
			putexcel C7=(r(mean))
			putexcel C8=(r(se))			
		ci var rdlInv     if group==1
			putexcel C9=(r(mean))
			putexcel C10=(r(se))			
		ci mean corr_GDP_lHHc  if group==1		
			putexcel C11=(r(mean))
			putexcel C12=(r(se))		
		ci mean corr_GDP_lInv   if group==1		
			putexcel C13=(r(mean))
			putexcel C14=(r(se))
		ci mean corr_GDP_nx   if group==1		
			putexcel C15=(r(mean))
			putexcel C16=(r(se))
			
		ci var sd_lrgdpn  if group==0
			putexcel C18=(r(mean))
			putexcel C19=(r(se))			
		ci var rdnx       if group==0
			putexcel C20=(r(mean))
			putexcel C21=(r(se))			
		ci var rdlHHc     if group==0
			putexcel C22=(r(mean))
			putexcel C23=(r(se))			
		ci var rdlInv     if group==0		
			putexcel C24=(r(mean))
			putexcel C25=(r(se))			
		ci mean corr_GDP_lHHc   if group==0		
			putexcel C26=(r(mean))
			putexcel C27=(r(se))		
		ci mean corr_GDP_lInv   if group==0		
			putexcel C28=(r(mean))
			putexcel C29=(r(se))
		ci mean corr_GDP_nx     if group==0		
			putexcel C30=(r(mean))
			putexcel C31=(r(se))
			
	*First Difference
		ci var sd_lrgdpn_FD  if group==1
			putexcel D3=(r(mean))
			putexcel D4=(r(se))	
		ci var rdnx_FD       if group==1
			putexcel D5=(r(mean))
			putexcel D6=(r(se))			
		ci var rdlHHc_FD     if group==1
			putexcel D7=(r(mean))
			putexcel D8=(r(se))			
		ci var rdlInv_FD     if group==1
			putexcel D9=(r(mean))
			putexcel D10=(r(se))			
		ci mean corr_GDP_lHHc_FD     if group==1		
			putexcel D11=(r(mean))
			putexcel D12=(r(se))		
		ci mean corr_GDP_lInv_FD     if group==1		
			putexcel D13=(r(mean))
			putexcel D14=(r(se))
		ci mean corr_GDP_nx_FD     if group==1		
			putexcel D15=(r(mean))
			putexcel D16=(r(se))
			
		ci var sd_lrgdpn_FD  if group==0
			putexcel D18=(r(mean))
			putexcel D19=(r(se))			
		ci var rdnx_FD       if group==0
			putexcel D20=(r(mean))
			putexcel D21=(r(se))			
		ci var rdlHHc_FD     if group==0
			putexcel D22=(r(mean))
			putexcel D23=(r(se))			
		ci var rdlInv_FD     if group==0		
			putexcel D24=(r(mean))
			putexcel D25=(r(se))			
		ci mean corr_GDP_lHHc_FD     if group==0		
			putexcel D26=(r(mean))
			putexcel D27=(r(se))		
		ci mean corr_GDP_lInv_FD     if group==0		
			putexcel D28=(r(mean))
			putexcel D29=(r(se))
		ci mean corr_GDP_nx_FD     if group==0		
			putexcel D30=(r(mean))
			putexcel D31=(r(se))
	
	
	
*Versus NP
preserve
	collapse (mean) pop sd_lrgdpn sd_lrgdpn_FD sd_nx sd_nx_FD rdlHHc rdlHHc_FD , by(IMFdevlp)
		by IMFdevlp, sort: sum sd_lrgdpn sd_lrgdpn_FD sd_nx sd_nx_FD rdlHHc rdlHHc_FD 
restore

	foreach var of varlist corr_GDP_L1GDP  corr_GDP_lHHc corr_GDP_TotRev  corr_GDP_lGc  corr_GDP_lInv  corr_GDP_nx  corr_GDP_irate   {
		format `var' %9.2f
		ci mean `var' if IMFdevlp==1
		ci mean `var' if IMFdevlp==0
		
	}		
	
	foreach var of varlist  corr_GDP_L1GDP_FD  corr_GDP_lHHc_FD  corr_GDP_TotRev_FD corr_GDP_lGc_FD  corr_GDP_lInv_FD  corr_GDP_nx_FD  corr_GDP_irate_FD  {
		format `var' %9.2f
		ci mean `var' if IMFdevlp==1
		ci mean `var' if IMFdevlp==0
	}		
		
preserve		
	*Second, the ExVol groups-.
		collapse (mean) pop  countrycode sd* rd*  corr_* EmplExp TotExp ///
							GrantsExp GrantsRev IntrstExp OtherExp OtherRev TotRev SocBenExp ///
							SocContrRev SubsidyExp TaxRev GoodsServExp , by(IMFdevlp)
			drop if IMFdevlp==.
			save $OUT_dir\GroupStats_rev.dta, replace
*Table Data
by IMFdevlp, sort: sum sd_lrgdpn rdlHHc corr_GDP_nx
by IMFdevlp, sort: sum TotExp SocBenExp GoodsServExp  EmplExp GrantsExp SubsidyExp IntrstExp OtherExp TotRev TaxRev SocContrRev GrantsRev OtherRev
by IMFdevlp, sort: sum sd_TotExp corr_GDP_TotExp sd_TotRev corr_GDP_TotRev sd_SocBenExp corr_GDP_SocBenExp sd_GoodsServExp corr_GDP_GoodsServExp 


latabstat  scorrY sd_irate sd_GDP_irate corr_GDP_irate corr_GDP_nx, by(exVol) nototal f(%9.2f)			
restore	
/*		
*Export----------------------------------------------------------------------------------------------------------------------
		*--------------------------------------
		* 1) sigma(Y)
		* 2) sigma(C )
		* 3) rho(NX/Y, Y)
		* 4) rho(Soc Ben, Y)
		* 5) sigma (soc ben)
		* 6) sigma(R )
		* 7) rho(Y,R)
		* 8) rho(Y_t, R_{t-1})
		*--------------------------------------
		*Additional stats 
		*--------------------------------------
		* 9) sigma(INV)
		* 10) rho(Y, C)
		* 11) rho(Y, INV)
		* 12) rho(Y_t, Y_{t-1})
preserve

collapse    SocBenExp GoodsServExp sd_rYperN sd_rCperN corr_GDP_nx corr_GDP_SocBenExp sd_SocBenExp  sd_irate corr_GDP_irate corr_GDP_Lirate sd_lInv ///
			corr_GDP_lHHc corr_GDP_lInv corr_GDP_LGDP  corr_GDP_GoodsServExp sd_GoodsServExp sd_TotRev corr_GDP_TotRev Nrich RshareInc [fw=pop], by(IMFdevlp)
			
	export delimited using $OUT_dir\CalibStats.csv, replace

restore

