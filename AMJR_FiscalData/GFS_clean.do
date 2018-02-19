set more off
clear all

**************************************************************************************************************************
*GFS_clean.do				@Amichaud v.2/15/2018 (v1.1/25/2017)
**************************************************************************************************************************
*This file calculates Business Cycle statistics from the World Development Indicators data on National Accounts.
*	-Inputs: WDI_Data.csv
*	-Outputs: WDI_clean.dta
*------------------------------------------------------------------------------------------------------------------------
*PROCEDURE
	* Step 1) Detrend the data.
	*		  -Log-quadratic detrenting following Ravn, Schmitt-Grohe, Uribe 2012		 
	*		  -First Differences also provided
	* Step 2) Calculate the following:
	*		  - Standard deviation of residual real household consumption per capita.
	*		  - Standard deviation of residual real GDP per capita.
*------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------

import excel $IN_dir\GFS_data.xlsx, sheet("GFS_main2017") firstrow

*SETUP----------------------------------------------------------------------------------------------------------------------
		drop UnitCode SectorCode
		
		rename CountryName country
		rename CountryCode countrycode
		rename TimePeriod Year
		rename SectorName sectorname

		drop if Year<1989
		
		replace country = "Afghanistan" if country == "Afghanistan, Islamic Republic of"
		replace country = "Armenia" if country == "Armenia, Republic of"
		replace country = "Azerbaijan" if country == "Azerbaijan, Republic of"
		replace country = "Bahamas" if country == "Bahamas, The"
		replace country = "Bahrain" if country == "Bahrain, Kingdom of"
		replace country = "Cape Verde" if country == "Cabo Verde"
		replace country = "Hong Kong" if country == "China, P.R.: Hong Kong"
		replace country = "Macao" if country == "China, P.R.: Macao"
		replace country = "China" if country == "China, P.R.: Mainland"
		replace country = "Congo, Dem. Rep." if country == "Congo, Democratic Republic of"
		replace country = "Iran" if country == "Iran, Islamic Republic of"
		replace country = "Kyrgyzstan" if country == "Kyrgyz Republic"
		replace country = "Laos" if country == "Lao People's Democratic Republic"
		replace country = "Macedonia" if country == "Macedonia, FYR"
		replace country = "Marshall Islands" if country == "Marshall Islands, Republic of"
		replace country = "Micronesia, Fed. Sts." if country == "Micronesia, Federated States of"
		replace country = "Russia" if country == "Russian Federation"
		replace country = "Serbia" if country == "Serbia, Republic of"
		replace country = "Syria" if country == "Syrian Arab Republic"
		replace country = "Timor-Leste" if country == "Timor-Leste, Dem. Rep. of"
		replace country = "Venezuela" if country == "Venezuela, Republica Bolivariana de"
		replace country = "Yemen" if country == "Yemen, Republic of"
		
		
		rename  CompensationofemployeesG21_  EmplExp 
		rename ExpenseG2_Z TotExp
		rename GrantsexpenseG26_Z GrantsExp
		rename GrantsrevenueG13_Z GrantsRev
		rename InterestexpenseG24_Z IntrstExp
		rename OtherexpenseG28_Z OtherExp
		rename OtherrevenueG14_Z OtherRev
		rename RevenueG1_Z TotRev
		rename SocialbenefitsG27_Z SocBenExp
		rename SocialcontributionsG12_Z SocContrRev
		rename SubsidiesG25_Z SubsidyExp
		rename TaxrevenueG11_Z TaxRev
		rename UseofgoodsandservicesG22_ GoodsServExp
			
		label variable EmplExp "Expense: Compensation of Employees (Percent of GDP)"
		label variable TotExp "Expense: Total Expenses (Percent of GDP)"
		label variable SocBenExp "Expense: Social Benefits (Percent of GDP)"
		label variable GrantsRev "Revenue: Grants (Percent of GDP)"
		label variable GrantsExp "Expense: Grants (Percent of GDP)"
		label variable IntrstExp "Expense: Interest (Percent of GDP)"
		label variable OtherExp "Expense: Other (Percent of GDP)"
		label variable OtherRev "Revenue: Other (Percent of GDP)"
		label variable TotRev "Revenue: Total (Percent of GDP)"
		label variable SocContrRev "Revenue: Social Contributions (Percent of GDP)"
		label variable SubsidyExp "Expense: Subsidies and Transfers (Percent of GDP)"
		label variable TaxRev "Revenue: Tax (Percent of GDP)"	
		label variable GoodsServExp "Expense: Goods and Services (Percent of GDP)"

*SAMPLE SELECTION----------------------------------------------------------------------------------------------------------------------		

		*-----------------------------------------------------------------------------------------------
		*Drop countries with PWT grade less than a D
		************************************************************************************************
			*Code PWT grades: A=1, B=2, C=3, D=4, F=5
		gen PWTgrade = .
		replace PWTgrade = 1 if (countrycode==111 | countrycode==112 | countrycode==144 | countrycode==146 | countrycode==142 | countrycode==138 | countrycode==137 | countrycode==158 | countrycode==436 | countrycode==178 | countrycode==172 | countrycode==132 | countrycode==128 | countrycode==156 | countrycode==193 | countrycode==122 | countrycode==124)
		replace PWTgrade = 2 if (countrycode==298 | countrycode==184 | countrycode==576 | countrycode==182 | countrycode==964 | countrycode==196 | countrycode==542 | countrycode==176 | countrycode==174 | countrycode==134 | countrycode==213 | countrycode==228)
		replace PWTgrade = 3 if (countrycode==698 | countrycode==299 | countrycode==926 | countrycode==744 | countrycode==186 | countrycode==369 | countrycode==578 | countrycode==463 | countrycode==361 | countrycode==199 | countrycode==936 | countrycode==961 | countrycode==622 | countrycode==968 | countrycode==964 | countrycode==283 | countrycode==288 | countrycode==564 | countrycode==278 | countrycode==558 | countrycode==686 | countrycode==921 | countrycode==684 | countrycode==273 | countrycode==678 | countrycode==674 | countrycode==548 | countrycode==546 | countrycode==962 | countrycode==946 | countrycode==443 | countrycode==941 | countrycode==916 | countrycode==343 | countrycode==136 | countrycode==429 | countrycode==534 | countrycode==536 | countrycode==944 | countrycode==915 | countrycode==253 | countrycode==939 | countrycode==243 | countrycode==469 | countrycode==935 | countrycode==238 | countrycode==662 | countrycode==924 | countrycode==233 | countrycode==622 | countrycode==748 | countrycode==618 | countrycode== 223 | countrycode==218 | countrycode==914 | countrycode==911 | countrycode==912 | countrycode==313 | countrycode==419 | countrycode==513 | countrycode==316 | countrycode==913)
		replace PWTgrade = 4 if (countrycode==927 | countrycode==742 | countrycode==718 | countrycode==948 | countrycode==181 | countrycode==666 | countrycode==336 | countrycode==423 | countrycode==514 | countrycode==624)
		replace PWTgrade = 5 if (countrycode==518 | countrycode==556 | countrycode==668 | countrycode==960 | countrycode==918 | countrycode==512)
			
		
		drop if (PWTgrade>3)
		
		
		*-----------------------------------------------------------------------------------------------
		*Here I choose consistant measures within countries
		*Algorithm:
			*1) Choose between Central and General.
				*General is chosen when available: includes all strata of gov (state, local, federal)
				*Central is chosen when General is not available consistently. 
				*Sum local and federal where possible.
			*2) Drop series if the most consistant measure is not available for 10 consecutive years.
			*3)  if Social Transfers not available for 10 consec. years.
			
			*--- Note: All commented out countries have a PWT grade "D" or "F" 
		************************************************************************************************
		encode sectorname, gen(sector)	
		keep country countrycode sector Year EmplExp TotExp GrantsExp GrantsRev IntrstExp OtherExp OtherRev TotRev SocBenExp SocContrRev SubsidyExp TaxRev GoodsServExp
		sort country sector Year
		
		save "GFS_temp.dta", replace
			
			*Afghanistan: Cash, Budgetary Central
				*drop if countrycode==512 
			*Albania: Cash, Budgetary = Central, later listed as "General"
				*drop if countrycode==914 
			*Algeria: Cash, Budgetary Central
				*drop if countrycode==612 
				
	use "GFS_temp.dta", clear	
	*Argentia: Sum Central and State
	replace country="Argentina" if countrycode==213
			drop if (countrycode~=213)
			keep if ( sector==3 | sector== 8)	
			collapse (sum) EmplExp-GoodsServExp (mean) countrycode sector, by(Year)
			replace sector=3
			save "GFS_clean.dta", replace
			
			*Armenia: Cash,  Central
				*drop if countrycode==911 
			*Aruba
				*drop if countrycode==314
			
	*Australia: General.
		use "GFS_temp.dta", clear
			keep if (countrycode==193 & sector==5)
			replace SocContrRev= .
			*Break in data, only use latter.
			drop if Year<1999
			 
			append using "GFS_clean.dta"
			save "GFS_clean.dta", replace
	

	*Austria: Cash,  Central
			use "GFS_temp.dta", clear
				keep if (countrycode==122 & sector==5)
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace

		
			*Azerbaijan, Drop
				*drop if countrycode==912
			*Bahamas: Budgetary Central, Cash
				*drop if countrycode==313 & (sector~=1 | atype~=1)
	*Bahrain: Central
				use "GFS_temp.dta", clear
				keep if (countrycode==419 & sector==3)
				replace SocBenExp=. if SocBenExp==0
				replace OtherExp=.
				replace GrantsExp=.
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
						
				
	*Bangladesh: Central
				use "GFS_temp.dta", clear
				keep if (countrycode==513 & sector==3)
				replace SocContrRev=. 
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace

    *Barbados: Budgetary Central
				use "GFS_temp.dta", clear
				keep if (countrycode==316 & sector==1)
				replace OtherExp=. 
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
			
	*Belarus: General
				use "GFS_temp.dta", clear
				keep if (countrycode==913 & sector==5)
				replace GrantsRev=. 
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
			
	*Belguim: General
				use "GFS_temp.dta", clear
				keep if (countrycode==124 & sector==5)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Benin
				*drop if countrycode==638
				*bhutan Central, Cash
				*drop if countrycode==514 & (sector~=2 | atype~=1)
				
	*Bolivia: Central, local government is very small
				use "GFS_temp.dta", clear
				keep if (countrycode==218 & sector==3)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
		
				*Bosnia: General, nonCash
				*drop if countrycode==963 & (sector~=3)
				*Botswana
				*drop if countrycode==616
		
	*Brazil: Central,most SB by central & longer time series.
				use "GFS_temp.dta", clear
				keep if (countrycode==223 & sector==3)
				replace OtherExp=. if OtherExp==0
				replace GrantsRev=. if GrantsRev==0			
				 *Brazil has break in 1995/1996, use latter data only.
				 drop if Year<1997
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

				*Bulgaria Central, Cash
				*drop if countrycode==918 & (sector~=2 | atype~=1)
		*Burkina Faso- Drop, no SB data
				drop if countrycode==748
		*Burundi- Drop, insufficient SB data
				drop if countrycode==618
				
				*Cambodia: Budgetary, NonCash
				*drop if countrycode==522 & (sector~=1)
				*Cameroon 
				*drop if countrycode==622	
				
	*Canada: General
				use "GFS_temp.dta", clear
				keep if (countrycode==156 & sector==5)	
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

				*Cape Verde
				*drop if countrycode==624
				*Central African Republic
				*drop if countrycode==626
	*Chile: General
				use "GFS_temp.dta", clear
				keep if (countrycode==228 & sector==5)	
				replace GrantsExp=. if GrantsExp==0
				replace GrantsRev=. if GrantsRev==0
				drop if Year<2000 
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

		
			*China- Drop no SB data
			drop if countrycode==924
			
				*Colombia: Central, Cash
				*drop if countrycode==233
				*Congo
				*drop if countrycode==636 | countrycode==634
		
	*Costa Rica: Central, almost all SB spending is central
				use "GFS_temp.dta", clear
				keep if (countrycode==238 & sector==3)	
				replace SubsidyExp=. if SubsidyExp==0
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
		*Cote d'Ivoire: Insufficient SB data
			drop if countrycode==662
			
				*Croatia: Central, Cash
				*drop if countrycode==960 & (sector~=2 | atype~=1)
				*Cyprus: Too much switching between cash and noncash
				*drop if countrycode==423
		
	*Czech Rep: General
				use "GFS_temp.dta", clear
				keep if (countrycode==935 & sector==5)	
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				

	*Denmark: General
				use "GFS_temp.dta", clear
				keep if (countrycode==128 & sector==5)	
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace

	*Dominican Rep: Central, SB by central gov
				use "GFS_temp.dta", clear
				keep if (countrycode==243 & sector==3)	
				drop if Year<1993
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace

				*Egypt: Central, Cash
				*drop if countrycode==469 & (sector~=2 | atype~=1)
				
	*El Salvador: General Gov
				use "GFS_temp.dta", clear
				keep if (countrycode==253 & sector==5)	
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Estonia: General
				use "GFS_temp.dta", clear
				keep if (countrycode==939 & sector==5)	
				 
				append using "GFS_clean.dta"		
				save "GFS_clean.dta", replace

				*Ethiopia, Fiji: not enough data
				*drop if countrycode==644 | countrycode==819
				
	*Finland: General
				use "GFS_temp.dta", clear
				keep if (countrycode==172 & sector==5)	
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*France: General
				use "GFS_temp.dta", clear
				keep if (countrycode==132 & sector==5)	
				replace GrantsRev=.
				replace OtherRev=.
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Gambia
				*drop if countrycode==648
				*Georgia: General, Cash
				*drop if countrycode==915 & (sector~=3 | atype~=1)
				
	*Germany: general
				use "GFS_temp.dta", clear
				keep if (countrycode==134 & sector==5)	
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Ghana
				*drop if countrycode==652
				
	*Greece: General
				use "GFS_temp.dta", clear
				keep if (countrycode==174 & sector==5)	
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Grenada: Budgetary, Cash (gap)
				*drop if countrycode==328 & year<1999
				*Hondoras: general, non-Cash
				*drop if countrycode==268 & (sector~=3 | atype~=2)
				*Hong Kong: genral, nonCash
				*drop if countrycode==532 & (sector~=3 | atype~=2)
				
	*Hungary: General
				use "GFS_temp.dta", clear
				keep if (countrycode==944 & sector==5)	
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Iceland: General
				use "GFS_temp.dta", clear
				keep if (countrycode==176 & sector==5)	
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

			*India- No SB data
				drop if countrycode==534
			*Indonesia: gap
				drop if countrycode==536
				*Iran
				*drop if countrycode==429
				
	*Ireland: General
				use "GFS_temp.dta", clear
				keep if (countrycode==178 & sector==5)	
				drop if Year<1995
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				

	*Isreal: General
				use "GFS_temp.dta", clear
				keep if (countrycode==436 & sector==5)
				drop if Year<2000
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				
	*Italy: General
				use "GFS_temp.dta", clear
				keep if (countrycode==136 & sector==5)	
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Jamaica: General
				use "GFS_temp.dta", clear
				keep if (countrycode==343 & sector==5)
				replace SubsidyExp=.
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Japan: General
				use "GFS_temp.dta", clear
				keep if (countrycode==158 & sector==5)
				replace GrantsRev=. if Year<2005
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

		
				*Jordan: Budgetary, Cash
				*drop if countrycode==439 & (sector~=1 | atype~=1)
				*Kazakhsan: 
				*drop if countrycode==916 | countrycode==664
				*Korea: Central, Cash
				drop if countrycode==542 
				*Kuwait: Large gap
				drop if countrycode==443 
				
	*Latvia: General
				use "GFS_temp.dta", clear
				keep if (countrycode==941 & sector==5)
				replace GrantsRev=. if Year<2005
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace

				*Lesotho: Central, Cash
				*drop if countrycode==666 & (sector~=2 | atype~=1) 
				*Liberia
				*drop if countrycode==668
				
	*Lithuania: general
				use "GFS_temp.dta", clear
				keep if (countrycode==946 & sector==5)
				replace GrantsRev=. 
				replace GrantsExp=.
				replace OtherExp=.
				replace OtherRev=.
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Luxembourg: general
				use "GFS_temp.dta", clear
				keep if (countrycode==137 & sector==5)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Macao: Central, Cash
				*drop if countrycode==546 & (sector~=2 | atype~=1)
				*Macedonia
				*drop if (countrycode==962 | countrycode==674 | countrycode==676)
	*Malaysia: Central (but central is general?)
				use "GFS_temp.dta", clear
				keep if (countrycode==548 & sector==3)
				replace GrantsRev=.
				replace SocContrRev=.
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Maldives, Mali: Gaps
				drop if countrycode==678				
				*Malta, Marshall
				*drop if countrycode==181 | countrycode==867
				
	*Mauritius: General
				use "GFS_temp.dta", clear
				keep if (countrycode==684 & sector==5)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Mexico insufficent SB data (zero)
				drop if countrycode==273 	
				*Micronesia
				*drop if countrycode==868
				
	*Moldova: General
				use "GFS_temp.dta", clear
				keep if (countrycode==921 & sector==5)
				replace GrantsExp=.
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Mongolia: central, Cash
				*drop if countrycode==948 & (sector~=2 | atype~=1)
				*Morroco: Central, nonCash
				*drop if countrycode==686 & (sector~=2 | atype~=1 | year<2002)
				*Mozambique
				*drop if (countrycode==688 | countrycode==518 | countrycode==728 | countrycode==558)
				*Nepal: insufficent SB data
				drop if countrycode==921
				
	*Netherlands: General
				use "GFS_temp.dta", clear
				keep if (countrycode==138 & sector==5)
				drop if Year<1995
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				

	*New Zealand: Central
				use "GFS_temp.dta", clear
				keep if (countrycode==196 & sector==3)
				replace GrantsRev=.
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				

	*Nicaragua: budgetary Central
				use "GFS_temp.dta", clear
				keep if (countrycode==278 & sector==1)
				replace SubsidyExp=.
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Niger, Nigeria
				*drop if countrycode==692 | countrycode==694
				
	*Norway: General
				use "GFS_temp.dta", clear
				keep if (countrycode==142 & sector==5)
				drop if Year<1995
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				
				*Oman: missing
				*drop if countrycode==449 | countrycode==564 |countrycode==565
				*Panama: Central, Cash
				*drop if countrycode==283 & (sector~=2 | atype~=1)
			*Pakistan: insufficient SB observations
				drop if countrycode==564
				
	*Paraguay: General
				use "GFS_temp.dta", clear
				keep if (countrycode==288 & sector==5)
				replace SubsidyExp=.
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				
	*Peru: General
				*drop if countrycode==293 & (sector~=2 | atype~=1 | year<1990)
				*Philippines: missing
				*drop if countrycode==566
				
	*Poland: General
				use "GFS_temp.dta", clear
				keep if (countrycode==964 & sector==5)
				drop if Year==1994
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Portugal: General
				use "GFS_temp.dta", clear
				keep if (countrycode==182 & sector==5)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
	
				*Qatar
				*drop if countrycode==453
				
	*Romania: General
				use "GFS_temp.dta", clear
				keep if (countrycode==968 & sector==5)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Russia:Central, Cash & non
				*drop if countrycode==922 & (sector~=2 )
				*Rwanda:
				*drop if countrycode==714 | countrycode==862 
				*San Marino: Central, nonCash
				*drop if countrycode==135 & (sector~=2 )
				*Sao tome, Senegal
				*drop if countrycode==716 | countrycode==722 | countrycode==942
				*Seychelles: Central, Cash
				*drop if countrycode==718 & (sector~=2 | atype~=1)
				*Sierra Leone:
				*drop if countrycode==724
		
			*Singapore: Insufficient SB data (8yrs)
				drop if countrycode==576 
				
	*Slovakia: General
				use "GFS_temp.dta", clear
				keep if (countrycode==936 & sector==5)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
	*Slovenia: General
				use "GFS_temp.dta", clear
				keep if (countrycode==961 & sector==5)
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace

	*South Africa: General
				use "GFS_temp.dta", clear
				keep if (countrycode==199 & sector==5)
				 
				append using "GFS_clean.dta"
				
	*Spain: General
				use "GFS_temp.dta", clear
				keep if (countrycode==184 & sector==5)
				drop if Year<1995
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

			*St Kitts: too few observations
				*drop if countrycode==361 
				*St Vincent
				*drop if countrycode==364 & year<2000
				*Sudan
				*drop if countrycode==732 | countrycode==366
				
	*Sweden: General
				use "GFS_temp.dta", clear
				keep if (countrycode==144 & sector==5)
				drop if Year<1995
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Swiss: General
				use "GFS_temp.dta", clear
				keep if (countrycode==146 & sector==5)
				drop if Year<2002
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Syria:
				*drop if countrycode==463
				*Tajikistan
				*drop if countrycode==923 | countrycode==738
				
	*Thailand: General
				use "GFS_temp.dta", clear
				keep if (countrycode==578 & sector==5)
				drop if Year<2000
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				
	*Trinidad: Central
				use "GFS_temp.dta", clear
				keep if (countrycode==369 & sector==3)
				drop if Year>2010
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Tunisia: Central
				use "GFS_temp.dta", clear
				keep if (countrycode==744 & sector==3)
				drop if Year>1999
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace
				
				*Timor
				*drop if countrycode==537 | countrycode==742 | countrycode==369 | countrycode==744
				*Turkey: Insufficient observations (2008-)
				drop if countrycode==186
				

				*Ukraine: general, Cash
				*drop if countrycode==926 & (sector~=3 | atype~=1)
				*UAE
				*drop if countrycode==466
				
	*UK: general
				use "GFS_temp.dta", clear
				keep if (countrycode==112 & sector==5)
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*US: General
				use "GFS_temp.dta", clear
				keep if (countrycode==111 & sector==5)
				drop if Year<2001
				 
				append using "GFS_clean.dta"	
				save "GFS_clean.dta", replace

	*Uruguay: Central
				use "GFS_temp.dta", clear
				keep if (countrycode==298 & sector==3)
				 
				append using "GFS_clean.dta"
				save "GFS_clean.dta", replace
				
	drop if countrycode==698	


save $IN_dir\GFS_clean.dta, replace	


************************************************************************************************
*	Analyze
**************************************************************************************************
use $IN_dir\WDI_clean.dta, clear
keep countrycode Year rgdpn lrgdpn
merge 1:1 countrycode Year using $IN_dir\GFS_clean.dta	


gen tmax = 14
xtset countrycode Year, yearly
drop sector
	drop if country=="United States"
	
gen residExp = TotExp-EmplExp-IntrstExp-SocBenExp-SubsidyExp-GoodsServExp
gen residExp_Simple = TotExp-EmplExp-SocBenExp-GoodsServExp-IntrstExp


*Calculate t0 and max_t for each time-series, individually.
	foreach var of varlist EmplExp-GoodsServExp residExp residExp_Simple {
		replace `var'=. if (`var'==0 )
		replace `var'=. if Year==1989
		gen l`var' = ln(`var'*rgdpn/100)	
		*For w/in variation
			gen win_l`var' = `var'*rgdpn/100
			gen `var'_t = .
			bysort countrycode (Year) : replace `var'_t =cond((!missing(l`var') & missing(l`var'[_n-1])), 1, `var'_t[_n-1] + 1,.) 
			replace `var'_t = . if l`var'==.
			gen `var'_t2 = `var'_t^2
			egen max_t`var' = max(`var'_t), by(countrycode) 
				
		}	
	
*NewZealand has break in Subsidies in 2008, need to adjust t for detrending regression
forvalues y = 2008/2015 {
	replace SubsidyExp_t = `y'-2000 if (Year==`y' & countrycode==196)
}

*Linear-quadratic regression
	foreach var of varlist  EmplExp-GoodsServExp residExp residExp_Simple  {
		gen `var'_cycle = .
		gen win_`var'_cycle = .
		*Select only if meets length of time-series requirement
			gen s`var'=1 if max_t`var'>tmax
	}	
		drop if sSocBenExp==.
*
	egen cgroup = group(countrycode)
	sort cgroup
	
	su cgroup, meanonly
	
	*Main Regression
	forvalues i = 1/`r(max)' {
	foreach var of varlist EmplExp-GoodsServExp residExp residExp_Simple {
	cap noisily{
		regress l`var' `var'_t `var'_t2 if ( cgroup == `i')
		predict ttemp2, residuals
		replace `var'_cycle = ttemp2 if (cgroup == `i' & s`var'==1)
		drop  ttemp2
		regress win_l`var' `var'_t `var'_t2 if ( cgroup == `i')
		predict ttemp2, residuals
		replace win_`var'_cycle = ttemp2 if (cgroup == `i' & s`var'==1)
		drop  ttemp2			
	}	
	}
	}

	*First differences 
		xtset countrycode Year
		foreach var of varlist EmplExp-GoodsServExp residExp residExp_Simple {
		gen `var'_cycle_FD = l`var'-L.l`var'
		drop l`var'
	}


	*Odd entry
	replace TotRev_cycle=. if (countrycode==218 & Year==2006)
				
	drop _merge		
save $IN_dir\GFS_clean.dta, replace	
