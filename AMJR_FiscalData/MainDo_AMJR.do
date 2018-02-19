set more off
clear all
**************************************************************************************************************************
*MainDo_AMJR.do				@Amichaud v.2/15/2018 (v1.1/25/2017)
**************************************************************************************************************************

 cd "C:\Users\ammichau\Desktop\AMJR_FiscalData\Data"
 global IN_dir "Infiles"
 global OUT_dir "Outfiles"

**************************************************************************************************************************
*This is the main data file for the empirical analysis of AMJR Fiscal paper.
*	-Inputs: WDI_clean.do, GFS_data.xlsx, GFS_clean.do, FINDEX_clean.do, FINDEX_Data.csv, GFS_clean.dta, WDI_clean.dta 
*	-Outputs: WDI_clean.dta, GFS_clean.dta, FINDEX_clean.dta, FinalDataset.dta
*			  Tables: 
*------------------------------------------------------------------------------------------------------------------------
*  Step 1) Run Cleaning Programs and import data
*  Step 2) Calculate cyclical and average statistics for fiscal data
*  Step 3) Classify by groups according to IMF classification
*------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------

*SETUP----------------------------------------------------------------------------------------------------------------------
	*Run cleaning files
		*World Development Indicators- National Accounts
			run "WDI_clean.do"
		*Global Financial Statistics- Fiscal Accounts.
			run "GFS_clean.do"	
		*Need to run these twice because we use the cyclical components in each. 
			run "WDI_clean.do"
			run "GFS_clean.do"	
		*Global financial index.
			run "FINDEX_clean.do"
		
*IMPORT---------------------------------------------------------------------------------		
		use $IN_dir\GFS_clean.dta, clear
		merge m:1 countrycode Year using $IN_dir\WDI_clean.dta, force
			drop _merge
		merge m:1 countrycode using "FINDEX_clean.dta"
			drop _merge	
		
		tsset countrycode Year			
	
	*Removing oil countries: Bahrain and Norway
		drop if (countrycode == 419 | countrycode ==142 )
		
		save $IN_dir\FinalDataset.dta, replace			
		
	*Load Inequality Stats
		*See \InequalityData\ReadME.txt
		import delimited "InequalityData\sInc_Rich.csv", clear 
			rename v1 countrycode
			rename v2 RshareInc
			replace RshareInc = RshareInc*100		

		merge 1:m countrycode using $IN_dir\FinalDataSet.dta	
		drop _merge
		
		save $IN_dir\FinalDataset.dta, replace	
		
*ANALYZE----------------------------------------------------------------------------------------------------------------------
	
*************************************************************************************************************************************************************************************
*COUNTRY SPECIFIC STATISTICS
******************************************************************
	*Calc BC stats----
		sort ccode2
		ssc install egenmore

		foreach var of varlist EmplExp-GoodsServExp residExp {
			*Standard deviations; raw and relative to GDP
				by ccode2: egen sd_`var' = sd(`var'_cycle)
					replace sd_`var' = 100*sd_`var'
				by ccode2: egen sd_`var'_FD = sd(`var'_cycle_FD)	
					replace sd_`var'_FD = 100*sd_`var'_FD
				gen rd`var' = sd_`var'/sd_lrgdpn4GFS
				gen rd`var'_FD = sd_`var'_FD/sd_lrgdpn_FD 
			*Correlations with GDP
				by ccode2: egen corr_GDP_`var' = corr(lrgdpn_cycle4GFS `var'_cycle)
				by ccode2: egen corr_GDP_`var'_FD  = corr(lrgdpn_cycle_FD  `var'_cycle_FD )
			*Covariance with GDP
				by ccode2: egen cov_GDP_`var' = corr(lrgdpn_cycle4GFS `var'_cycle), covariance
				by ccode2: egen cov_GDP_`var'_FD = corr(lrgdpn_cycle_FD `var'_cycle_FD), covariance				
			}			

	*Calc average spending levels
	sort country
	*Average Levels
	foreach var of varlist EmplExp-GoodsServExp residExp {
		by country: egen av_`var' = mean(`var')
	}
	
*************************************************************************************************************************************************************************************
*GROUP STATISTICS
******************************************************************

*Code IMP Classification: 1=developed, 0=emerging "Advanced vs Emerging and Developing"
		gen IMFdevlp = .
		replace IMFdevlp = 1 if (countrycode==193 | countrycode==122 | countrycode==124 | countrycode==156 | countrycode==128 | countrycode==172 | ///
								 countrycode==132 | countrycode==134 | countrycode==178 | countrycode==436 | countrycode==136 | countrycode==158 | ///
								 countrycode==137 | countrycode==138 | countrycode==196 | countrycode==182 | countrycode==184 | countrycode==144 | ///
								 countrycode==112 | countrycode==935 | countrycode==939 | countrycode==174 | countrycode==146 | countrycode==176 | ///
								 countrycode==936 | countrycode==961 )
		replace IMFdevlp = 0 if (countrycode==213 | countrycode==218 | countrycode==223 | countrycode==228 | countrycode==243 ///
								| countrycode==278 | countrycode==968 | countrycode==578  | countrycode==298 ///
								| countrycode==964 | countrycode==944)
									
		*Code switchers as emerging( 176== iceland; 436 israel; 936 slovakia)
			replace IMFdevlp=0 if (countrycode==436 | countrycode==176 | countrycode==936)
		*Lost this label somewhere
			replace country="Argentina" if (countrycode==213 )   
		*drop US
			drop if countrycode==111	
		*drop what we don't use
			drop if IMFdevlp==.
		*Nicaragua and NZ/Australia have reliability/consistancy issues, respectively. 
			drop if countrycode==278 | countrycode==193 | countrycode==196
		*The volatility of interest rates in Boliva are a large outliar. Suspicious.
			replace corr_GDP_irate=. if countrycode==218
			replace corr_GDP_irate_FD=. if countrycode==218
			replace sd_irate_FD=. if countrycode==218
			replace sd_irate=. if countrycode==218

save $IN_dir\FinalDataset.dta, replace		


*************************************************************************************************************************************************************************************
*VARIANCE DECOMPOSITIONS
******************************************************************
*-->Contribution of component var(X) = sum_i[var(x_i)+2sum_jcov(x_i,x_j)]
*-->These calculations must be completed from covariance tables in excel.
*-----------------------------------
use $IN_dir\FinalDataset.dta, clear	
*-----------------------------------
*	-Overall spending
*	-Cyclicality of spending
************************************
preserve

*Set up tables
	ssc inst outtable 	

	matrix covAvComponents = J(8,7,0.) /* allocates a 8 X 7 matrix */
	matrix winCycle = J(8,7,0.) 
	mat mv = J(6,36,0.)

	matrix colnames covAvComponents= "Total Expenditures" "Social Benefits" "Goods" "Employment" "Interest" "Subsidies" "Other" 
	matrix rownames covAvComponents= "Total Expenditures" "Social Benefits" "Goods" "Employment" "Interest" "Subsidies" "Other" "Contribution to Total Variance"
	matrix rownames winCycle= "Total Expenditures" "Social Benefits" "Goods" "Employment" "Interest" "Subsidies" "Other" "Contribution to Total Variance"

*Calculate covariance of the deviations from trend in Expenditures
	sort countrycode Year
	egen cgroup2 = group(countrycode)
	

	su cgroup2, meanonly
	forvalues i = 1/`r(max)'{
 capture noisily correlate win_TotExp_cycle win_SocBenExp_cycle win_GoodsServExp_cycle win_EmplExp_cycle win_IntrstExp_cycle win_SubsidyExp_cycle win_residExp_cycle if cgroup2==`i', covariance
	matrix list r(C)
	mat mA2 = r(C)
	forvalues  v = 2/7 {
		local vv=`v'-1
		mat mv[`vv',`i'] = mA2[`v',2] + mA2[`v',3] + mA2[`v',4] + mA2[`v',5] + mA2[`v',6]
		}
		sca tv = mv[1,`i']+mv[2,`i']+mv[3,`i']+mv[4,`i']+mv[5,`i']+mv[6,`i']
		forvalues  v = 2/7 {
			local vv=`v'-1
		mat mv[`vv',`i'] = (mA2[`v',2] + mA2[`v',3] + mA2[`v',4] + mA2[`v',5] + mA2[`v',6])/tv
		}
		}
	
	matrix  winCycle = mv

*This Excel table will give the statistic in each country. Take the average across columns to replicate table 5, column 2

putexcel set CovDecomp_winCycle, replace
putexcel A1=("Total Expenditures")
putexcel A2=("Social Benefits")
putexcel A3=("Goods") 
putexcel A4=("Employment") 
putexcel A5=("Interest")
putexcel A6=("Subsidy") 
putexcel A7=("Other")
putexcel B2=matrix(mv)


collapse (median) pop RshareInc EmplExp-GoodsServExp EmplExp_cycle-GoodsServExp_cycle EmplExp_cycle_FD-GoodsServExp_cycle_FD lHHc_cycle-IMFdevlp , by(countrycode)
*Calculate covariance of each component pair of expenditure
correlate av_TotExp av_SocBenExp av_GoodsServExp av_EmplExp av_IntrstExp av_SubsidyExp av_residExp, covariance
	matrix list r(C)
	mat A = r(C)
	mat AA = A
	sca b = A[1,1]
	mat D = AA/b
matrix  covAvComponents = D


*This Excel table will give the covariance matrix. Use the formula to calculate the decomposition in table 5, column 1.

putexcel set CovDecomp_ExpLevel, replace
putexcel A1=("Total Expenditures")
putexcel B1=("Social Benefits")
putexcel C1=("Goods") 
putexcel D1=("Employment") 
putexcel E1=("Interest")
putexcel F1=("Subsidy") 
putexcel G1=("Other")
putexcel A2=matrix(D)

restore



*********************************************************************************************************************************
*GRAPHS
*****************************************************
* Bar charts with group shading
*	+Excess Volatility
*	+Average Level of Expenditures
*		-all
*		-G
*		-Social Transfers
*	+Correlation of cyclical components
*		-all
*		-G
*		-Social Transfers
*-------------------
use $IN_dir\FinalDataset.dta, clear	

*-----------------------------------------------------------
* Need to chooose the grouping to use
*---> We use IMF classification 
 gen group = IMFdevlp
*-----------------------------------------------------------

*+++ Excess Volatility +++*
graph bar (median) rdlHHc, over(group) over(country, sort(rdlHHc) label(nolabel)) blabel(group, size(vsmall) orientation(vertical)) ///
	ytitle(Excess Volatility of Consumption) asyvars stack bar(1, color(blue*0.8) lcolor(black) lwidth(0.25)) bar(2, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	legend(order( 1 "Emerging" 2 "Developed" ))

graph export $OUT_dir\exVol_bar.eps, replace
graph export $OUT_dir\exVol_bar.pdf, as(pdf) replace	

*+++ Average Level of Exp +++*
*All
	graph bar (mean) TotExp, over(group) over(country, sort(TotExp) label(nolabel)) blabel(group, size(vsmall) orientation(vertical)) ///
		ytitle(Percent of GDP) asyvars stack bar(1, color(blue*0.8) lcolor(black) lwidth(0.25)) bar(2, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	legend(order( 1 "Emerging" 2 "Developed" ))
	
	graph export $OUT_dir\avTotExp_bar.eps, replace
	graph export $OUT_dir\avTotExp_bar.pdf, as(pdf) replace	
	
*G
	graph bar (mean) GoodsServExp, over(group) over(country, sort(GoodsServExp) label(nolabel)) blabel(group, size(vsmall) orientation(vertical)) ///
		ytitle(Percent of GDP) asyvars stack bar(1, color(blue*0.8) lcolor(black) lwidth(0.25)) bar(2, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	legend(order( 1 "Emerging" 2 "Developed" )) ysc(r(0 60)) ylabel(#10)
		
	graph export $OUT_dir\avGExp_bar.eps, replace
	graph export $OUT_dir\avGExp_bar.pdf, as(pdf) replace	
	
*Soc Trans
	graph bar (mean) SocBenExp, over(group) over(country, sort(SocBenExp) label(nolabel)) blabel(group, size(vsmall) orientation(vertical)) ///
		ytitle(Percent of GDP) asyvars stack bar(1, color(blue*0.8) lcolor(black) lwidth(0.25)) bar(2, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	legend(order( 1 "Emerging" 2 "Developed" )) ysc(r(0 60)) ylabel(#10)

	graph export $OUT_dir\avSBExp_bar.eps, replace
	graph export $OUT_dir\avSBExp_bar.pdf, as(pdf) replace	

*+++ Correlation of Cyclical Component Level of Exp +++*
*All
	graph bar (mean) corr_GDP_TotExp, over(group) over(country, sort(corr_GDP_TotExp) label(nolabel)) blabel(group, size(vsmall) orientation(vertical)) ///
		ytitle(Cyclical Correlation to GDP) asyvars stack bar(1, color(blue*0.8) lcolor(black) lwidth(0.25)) bar(2, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	legend(order( 1 "Emerging" 2 "Developed" )) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)

	graph export $OUT_dir\corrTotExp_bar.eps, replace
	graph export $OUT_dir\corrTotExp_bar.pdf, as(pdf) replace	
	
*G
	graph bar (mean) corr_GDP_GoodsServExp, over(group) over(country, sort(corr_GDP_GoodsServExp) label(nolabel)) blabel(group, size(vsmall) orientation(vertical)) ///
		ytitle(Cyclical Correlation to GDP) asyvars stack bar(1, color(blue*0.8) lcolor(black) lwidth(0.25)) bar(2, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	legend(order( 1 "Emerging" 2 "Developed" )) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)
	
	graph export $OUT_dir\corravGExp_bar.eps, replace
	graph export $OUT_dir\corravGExp_bar.pdf, as(pdf) replace	
	
*Soc Trans
	graph bar (mean) corr_GDP_SocBenExp, over(group) over(country, sort(corr_GDP_SocBenExp) label(nolabel)) blabel(group, size(vsmall) orientation(vertical)) ///
		ytitle(Cyclical Correlation to GDP) asyvars stack bar(1, color(blue*0.8) lcolor(black) lwidth(0.25)) bar(2, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	legend(order( 1 "Emerging" 2 "Developed" )) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)

	graph export $OUT_dir\corravSBExp_bar.eps, replace
	graph export $OUT_dir\corravSBExp_bar.pdf, as(pdf) replace		

	
*********************************************************************************************************************************
*GROUP MEAN TABLES
*****************************************************
*	-Macro Stats: sd(y), st(d)/st(y)
*	-Average Share of GDP: Taxes and Revenues
*	-Cyclicality: Taxes and Revenues
*-------------------
					
use $IN_dir\FinalDataset.dta, clear	

	collapse (mean)  pop RshareInc EmplExp-GoodsServExp EmplExp_cycle-GoodsServExp_cycle EmplExp_cycle_FD-GoodsServExp_cycle_FD lHHc_cycle-IMFdevlp , by(countrycode)


preserve	
		collapse (mean)  EmplExp-GoodsServExp EmplExp_cycle-GoodsServExp_cycle EmplExp_cycle_FD-GoodsServExp_cycle_FD lHHc_cycle-av_GoodsServExp  , by(IMFdevlp)
							
* Table 2
	tabstat sd_lrgdpn rdlHHc corr_GDP_nx3  , by(IMFdevlp) stat( mean  ) save
	matrix Devlp = r(Stat2)
	matrix Emerg = r(Stat1)
	putexcel set $OUT_dir\MainVars.xls, sheet(wMean) modify
	putexcel A1 = matrix(Devlp), names nformat(number_d2)
	putexcel B3 = matrix(Emerg), nformat(number_d2) 

* Table 3
	tabstat TotExp SocBenExp GoodsServExp EmplExp GrantsExp SubsidyExp IntrstExp  TotRev, by(IMFdevlp) stat( mean  ) save
	matrix Devlp = r(Stat2)
	matrix Emerg = r(Stat1)
	putexcel set $OUT_dir\GFSmeans.xls, sheet(wMean) modify
	putexcel A1 = matrix(Devlp), names nformat(number_d2)
	putexcel B3 = matrix(Emerg), nformat(number_d2) 
	
* Table 5
	tabstat rdTotExp corr_GDP_TotExp rdTotRev corr_GDP_TotRev rdSocBenExp corr_GDP_SocBenExp rdGoodsServExp corr_GDP_GoodsServExp if SocBenExp>1, by(IMFdevlp) stat( mean ) save
	matrix Devlp = r(Stat2)
	matrix Emerg = r(Stat1)
	putexcel set $OUT_dir\GFScycle.xls, sheet(wMean) modify
	putexcel A1 = matrix(Devlp), names nformat(number_d2)
	putexcel B3 = matrix(Emerg), nformat(number_d2) 
	
*First differences- Appx
	tabstat sd_lrgdpn_FD rdlHHc_FD corr_GDP_nx_FD rdnx_FD sd_TotExp_FD corr_GDP_TotExp_FD sd_TotRev_FD corr_GDP_TotRev_FD sd_SocBenExp_FD corr_GDP_SocBenExp_FD sd_GoodsServExp_FD corr_GDP_GoodsServExp_FD , by(IMFdevlp) stat( mean  ) save
	matrix Devlp = r(Stat2)
	matrix Emerg = r(Stat1)
	putexcel set $OUT_dir\CycleFD.xls, sheet(wMean) modify
	putexcel A1 = matrix(Devlp), names nformat(number_d2)
	putexcel B3 = matrix(Emerg), nformat(number_d2) 
restore


