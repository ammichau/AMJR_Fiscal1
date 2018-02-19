set more off
clear all

**************************************************************************************************************************
*WDI_clean.do				@Amichaud v.2/15/2018 (v1.1/25/2017)
**************************************************************************************************************************
*This file calculates Business Cycle statistics from the World Development Indicators data on National Accounts.
*	-Inputs: uses wbopendata package
*	-Outputs: WDI_clean.dta
*------------------------------------------------------------------------------------------------------------------------
*PROCEDURE
	* Step 1) Detrend the data.
	*		  -Log-quadratic detrending following Ravn, Schmitt-Grohe, Uribe 2012	
	*		  -First-differencing also provided
	* Step 2) Calculate the following:
	*		  - Standard deviation and correlation w/ GDP residuals for each series.
*------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------

*Import WDI data---------------------------------------------------------------------------------------------------------------
 
ssc install wbopendata
	wbopendata, language(en - English) indicator(NY.GDP.MKTP.CD; NY.GDP.PCAP.KN; NE.CON.GOVT.ZS; NE.CON.PETC.ZS; ///
				NE.EXP.GNFS.ZS; NE.IMP.GNFS.ZS; NE.GDI.TOTL.ZS; SP.POP.TOTL; NY.GDP.PCAP.PP.KD; PX.REX.REER; ///
				BN.CAB.XOKA.GD.ZS; FR.INR.RINR; DT.INR.OFFT; DT.INR.DPPG) long clear

	rename ne_con_govt_zs Gc_share	
	rename ne_con_petc_zs HHc_share
	rename ne_exp_gnfs_zs exports_share
	rename ne_imp_gnfs_zs imports_share
	rename ny_gdp_pcap_kn rgdpn
	rename ny_gdp_mktp_cd rgdpn2
	rename ny_gdp_pcap_pp_kd rgdpn3
	rename fr_inr_rinr irate
	rename sp_pop_totl pop
	rename ne_gdi_totl_zs gkformation
	rename bn_cab_xoka_gd_zs CurrentAcc
	rename px_rex_reer reer
	rename dt_inr_offt IntrAll
	rename dt_inr_dppg IntrOffic	
	gen Tc_share = Gc_share+HHc_share
	
	save $IN_dir\WDI_raw.dta, replace	
		 
*SETUP----------------------------------------------------------------------------------------------------------------------
rename year Year
rename countrycode ccode
rename countryname country

gen countrycode=.
		replace countrycode =512 if country=="Afghanistan"
		replace countrycode =612 if country=="Algeria"
		replace countrycode =614 if country=="Angola"
		replace countrycode =312 if country=="Anguilla"
		replace countrycode =311 if country=="Antigua and Barbuda"
		replace countrycode =213 if country=="Argentina"
		replace countrycode =314 if country=="Aruba"
		replace countrycode =193 if country=="Australia"
		replace countrycode =122 if country=="Austria"

	replace countrycode =313 if country=="Bahamas"
	replace countrycode =419 if country=="Bahrain"
	replace countrycode =513 if country=="Bangladesh"
	replace countrycode =316 if country=="Barbados"
	replace countrycode =913 if country=="Belarus"
	replace countrycode =124 if country=="Belgium"
	replace countrycode =339 if country=="Belize"
	replace countrycode =638 if country=="Benin"
	replace countrycode =514 if country=="Bhutan"
	replace countrycode =218 if country=="Bolivia"
	replace countrycode =616 if country=="Botswana"
	replace countrycode =223 if country=="Brazil"
	replace countrycode =748 if country=="Burkina Faso"
	replace countrycode =618 if country=="Burundi"

	replace countrycode =622 if country=="Cameroon"
	replace countrycode =156 if country=="Canada"
	replace countrycode =624 if country=="Cape Verde"
	replace countrycode =626 if country=="Central African Republic"
	replace countrycode =628 if country=="Chad"
	replace countrycode =228 if country=="Chile"
	replace countrycode =924 if country=="China"
	replace countrycode =233 if country=="Colombia"
	replace countrycode =632 if country=="Comoros"
	replace countrycode =634 if country=="Congo"
	replace countrycode =238 if country=="Costa Rica"
	replace countrycode =662 if country=="Cote d'Ivoire"
	replace countrycode =960 if country=="Croatia"
	replace countrycode =423 if country=="Cyprus"
	replace countrycode =934 if country=="Czechoslovakia"
	replace countrycode =935 if country=="Czech Republic"

	replace countrycode =128 if country=="Denmark"
	replace countrycode =611 if country=="Djibouti"
	replace countrycode =321 if country=="Dominica"
	replace countrycode =243 if country=="Dominican Republic"

	replace countrycode =248 if country=="Equador"
	replace countrycode =469 if country=="Egypt"
	replace countrycode =253 if country=="El Salvador"
	replace countrycode =642 if country=="Equatorial Guinea"
	replace countrycode =939 if country=="Estonia"
	replace countrycode =644 if country=="Ethiopia"

	replace countrycode =819 if country=="Fiji"
	replace countrycode =172 if country=="Finland"
	replace countrycode =132 if country=="France"

	replace countrycode =646 if country=="Gabon"
	replace countrycode =648 if country=="Gambia"
	replace countrycode =134 if country=="Germany"
	replace countrycode =652 if country=="Ghana"
	replace countrycode =174 if country=="Greece"
	replace countrycode =328 if country=="Grenada"
	replace countrycode =258 if country=="Guatemala"
	replace countrycode =654 if country=="Guinea-Bissau"
	replace countrycode =336 if country=="Guyana"

	replace countrycode =263 if country=="Haiti"
	replace countrycode =268 if country=="Honduras"
	replace countrycode =944 if country=="Hungary"

	replace countrycode =176 if country=="Iceland"
	replace countrycode =534 if country=="India"
	replace countrycode =536 if country=="Indonesia"
	replace countrycode =429 if country=="Iran"
	replace countrycode =433 if country=="Iraq"
	replace countrycode =178 if country=="Ireland"
	replace countrycode =436 if country=="Israel"
	replace countrycode =136 if country=="Italy"

	replace countrycode =343 if country=="Jamaica"
	replace countrycode =158 if country=="Japan"
	replace countrycode =439 if country=="Jordan"

	replace countrycode =664 if country=="Kenya"
	replace countrycode =542 if country=="Korea, Republic of"
	replace countrycode =443 if country=="Kuwait"
	replace countrycode =917 if country=="Kyrgyzstan"

	replace countrycode =941 if country=="Latvia"
	replace countrycode =446 if country=="Lebanon"
	replace countrycode =666 if country=="Lesotho"
	replace countrycode =668 if country=="Liberia"
	replace countrycode =672 if country=="Libya"
	replace countrycode =946 if country=="Lithuania"
	replace countrycode =137 if country=="Luxembourg"

	replace countrycode =546 if country=="Macao"
	replace countrycode =674 if country=="Madagascar"
	replace countrycode =676 if country=="Malawi"
	replace countrycode =548 if country=="Malaysia"
	replace countrycode =556 if country=="Maldives"
	replace countrycode =678 if country=="Mali"
	replace countrycode =181 if country=="Malta"
	replace countrycode =682 if country=="Mautitania"
	replace countrycode =684 if country=="Mauritius"
	replace countrycode =273 if country=="Mexico"
	replace countrycode =921 if country=="Moldova"
	replace countrycode =948 if country=="Mongolia"
	replace countrycode =351 if country=="Montserrat"
	replace countrycode =686 if country=="Moroco"
	replace countrycode =688 if country=="Mozambique"
	replace countrycode =518 if country=="Myanmar"

	replace countrycode =728 if country=="Namibia"
	replace countrycode =558 if country=="Nepal"
	replace countrycode =138 if country=="Netherlands"
	replace countrycode =353 if country=="Netherlands Antilles"
	replace countrycode =196 if country=="New Zealand"
	replace countrycode =278 if country=="Nicaragua"
	replace countrycode =692 if country=="Niger"
	replace countrycode =694 if country=="Nigeria"
	replace countrycode =142 if country=="Norway"
	

	replace countrycode =449 if country=="Oman"
	replace countrycode =564 if country=="Pakistan"
	replace countrycode =283 if country=="Panama"
	replace countrycode =853 if country=="Papua New Guinea"
	replace countrycode =288 if country=="Paraguay"
	replace countrycode =293 if country=="Peru"
	replace countrycode =566 if country=="Philippines"
	replace countrycode =964 if country=="Poland"
	replace countrycode =182 if country=="Portugal"

	replace countrycode =453 if country=="Qatar"
	replace countrycode =968 if country=="Romania"
	replace countrycode =922 if country=="Russia"
	replace countrycode =714 if country=="Rwanda"

	replace countrycode =361 if country=="St. Kitts and Nevis"
	replace countrycode =362 if country=="St. Lucia"
	replace countrycode =364 if country=="St. Vincent and the Grenadines"
	replace countrycode =456 if country=="Saudi Arabia"
	replace countrycode =722 if country=="Senegal"
	replace countrycode =726 if country=="Somalia"
	replace countrycode =718 if country=="Seychelles"
	replace countrycode =724 if country=="Sierra Leone"
	replace countrycode =576 if country=="Singapore"
	replace countrycode =936 if country=="Slovak Republic"
	replace countrycode =961 if country=="Slovenia"
	replace countrycode =813 if country=="Solomon Islands"
	replace countrycode =726 if country=="Somalia"
	replace countrycode =199 if country=="South Africa"
	replace countrycode =184 if country=="Spain"
	replace countrycode =524 if country=="Sri Lanka"
	replace countrycode =732 if country=="Sudan"
	replace countrycode =366 if country=="Surinam"
	replace countrycode =734 if country=="Swaziland"
	replace countrycode =144 if country=="Sweden"
	replace countrycode =146 if country=="Switzerland"
	replace countrycode =463 if country=="Syrian Arab Republic"

	replace countrycode =738 if country=="Tanzania"
	replace countrycode =578 if country=="Thailand"
	replace countrycode =742 if country=="Togo"
	replace countrycode =866 if country=="Tonga"
	replace countrycode =369 if country=="Trinidad and Tobago"
	replace countrycode =744 if country=="Tunisia"
	replace countrycode =186 if country=="Turkey"

	replace countrycode =746 if country=="Uganda"
	replace countrycode =466 if country=="United Arab Emirates"
	replace countrycode =112 if country=="United Kingdom"
	replace countrycode =111 if country=="United States"
	replace countrycode =298 if country=="Uruguay"

	replace countrycode =846 if country=="Vanuatu"
	replace countrycode =299 if country=="Venezuela"
	replace countrycode =862 if country=="Western Somoa"
	replace countrycode =636 if country=="Zaire"
	replace countrycode =754 if country=="Zambia"
	replace countrycode =698 if country=="Zimbabwe"
	
drop if countrycode==.
	*Drop those with few observations, or prev. split
	*Colombia, West Bank/Gaza, Vanuatu, UAE, Timor-Leste, Tajikistan, St. Vincent & Grenadines, Serbia/Montenegro, Rwanda, San Marino, Niger Netherlands Antilles, Lebanon, Jordan, Hong Kong, Honduras, Benin, Congo, Ethiopia, Gambia, Ghana
	drop if (countrycode==233 | countrycode==487 | countrycode==846 | countrycode==466 | countrycode==537 | countrycode==923 ///
			| countrycode==364 | countrycode==942 | countrycode==965 | countrycode==135 | countrycode==714 | countrycode==692 ///
			| countrycode==353 | countrycode==446 | countrycode==439 | countrycode==532 | countrycode==268 | countrycode==652 ///
			| countrycode==638 | countrycode==636 | countrycode==634 | countrycode==644 | countrycode==648 | countrycode==238 ///
			| countrycode==556 | countrycode==518 | countrycode==726 )
		
	save $IN_dir\WDI_loadTemp.dta, replace	

************************************************************************************************
*	Analyze
**************************************************************************************************
use $IN_dir\GFS_clean.dta, clear
keep countrycode Year SocBenExp_t SocBenExp_t2 max_tSocBenExp
merge 1:1 countrycode Year using $IN_dir\WDI_loadTemp.dta	

*Require 25 years of data for WDI stats.
gen tmax = 25
encode ccode, gen(ccode2)
xtset ccode2 Year, yearly
drop if Year<1980

*Normalize
gen gdptemp = rgdpn if Year==2000
bysort countrycode: egen fGDP = mean(gdptemp)
gen nrmGDP = rgdpn/fGDP
replace rgdpn = nrmGDP
drop fGDP gdptemp nrmGDP
replace irate = ln(irate)


*log things
	gen lHHc= ln(HHc_share*rgdpn/100)
	gen lGc= ln(Gc_share*rgdpn/100)
	gen lInv= ln(gkformation*rgdpn/100)
	gen lTc = ln(Tc_share*rgdpn/100)
	gen lrgdpn= ln(rgdpn)
	gen nx = exports_share/100-imports_share/100
	
*Calculate t0 and max_t for each time-series, individually.
	foreach var of varlist lHHc lGc lTc lInv lrgdpn  IntrAll IntrOffic irate reer nx {
			replace `var'=. if Year==1980
			gen `var'_t = .
			bysort countrycode (Year) : replace `var'_t =cond((!missing(`var') & missing(`var'[_n-1])), 1, `var'_t[_n-1] + 1,.) 
			replace `var'_t = . if `var'==.
			gen `var'_t2 = `var'_t^2
			egen max_t`var' = max(`var'_t), by(countrycode) 	
			gen `var'_cycle = . 
			gen s`var'=0
			replace s`var' = 1 if max_t`var'>tmax
			
		}	
	*Drop if do not meet data length requirement
		drop if (max_tlrgdpn<tmax |	max_tlHHc<tmax | max_tlHHc==.)

*
	drop if country=="United States"
	sort ccode2 Year
	egen cgroup = group(ccode2)
	su cgroup, meanonly
	
	*Main Regression
	forvalues i = 1/`r(max)' {
	foreach var of varlist lHHc lGc lInv lrgdpn nx  {
	if s`var'==1 {
		 regress `var' `var'_t `var'_t2 if ( cgroup == `i' )
		predict ttemp2, residuals
		replace `var'_cycle = ttemp2 if (cgroup == `i')
			local mx1= max_t`var'-1	
			replace `var'=. if (`var'_t==1 | `var'_t==2 | `var'_t==max_t`var' | `var'_t==`mx1')	
		drop  ttemp2
		}
	}	
	}
	drop cgroup
	
	gen ccode3 = ccode2
	replace sirate = 1 if max_tirate>10
	replace ccode3 = . if sirate==0
	sort ccode3 Year
	egen cgroup = group(ccode3)
	su cgroup, meanonly
	
	forvalues i = 1/`r(max)' {
	foreach var of varlist  irate  {
		capture regress irate irate_t irate_t2 if ( cgroup == `i' & sirate==1)
		capture predict ttemp2, residuals
		capture replace irate_cycle = ttemp2 if (cgroup == `i')
			local mx1= max_t`var'-1	
			capture replace irate=. if (irate_t==1 | irate_t==2 | irate_t==max_t`var' | irate_t==`mx1')	
		capture drop  ttemp2
		
	}	
	}	
	
************************************************************************
* Use analagous time period to detrend GDP for shorter series
***********************************************************************
gen s=1 if SocBenExp_t~=.
*Linear-quadratic regression
	gen lrgdpn_cycle4GFS = .

	drop cgroup
	sort s countrycode SocBenExp_t
	egen cgroup = group(countrycode) if s==1
	su cgroup, meanonly
	
	*Main Regression
	forvalues i = 1/`r(max)' {
	if s==1 {
		regress lrgdpn SocBenExp_t SocBenExp_t2 if ( cgroup == `i')
		predict ttemp2, residuals
		replace lrgdpn_cycle4GFS = ttemp2 if (cgroup == `i')
		replace lrgdpn_cycle4GFS=. if (SocBenExp_t==1 |  SocBenExp_t==max_tSocBenExp)	
		drop  ttemp2
		}
	}	
		drop s cgroup
		
gen s=1 if irate_t~=.
*Linear-quadratic regression
	gen lrgdpn_cycle4irate = .

	sort s countrycode irate_t
	egen cgroup = group(countrycode) if s==1
	su cgroup, meanonly
	
	*Main Regression
	forvalues i = 1/`r(max)' {
	if s==1 {
		regress lrgdpn irate_t irate_t2 if ( cgroup == `i')
		predict ttemp2, residuals
		replace lrgdpn_cycle4irate = ttemp2 if (cgroup == `i')
		replace lrgdpn_cycle4irate=. if (irate_t==1 |  irate_t==max_tirate)	
		drop  ttemp2
		}
	}	
		drop s
		
		
************************************************************************
* FIRST DIFFERENCES
***********************************************************************	
	sort countrycode Year
		xtset countrycode Year
		foreach var of varlist lHHc lGc lTc lInv lrgdpn nx IntrAll IntrOffic reer irate {
		gen `var'_cycle_FD = `var'-L.`var'
	}

*
	*Lagged GDP for autocorrelations
		gen L1GDP_cycle = L.lrgdpn_cycle
		gen L1GDP_cycle_FD = L.lrgdpn_cycle_FD
		gen L1nx = L.nx
		gen L1nx_cycle = L.nx_cycle
		gen L1nx_cycle_FD = L.nx_cycle_FD
		gen F1nx = F.irate
		gen F1nx_cycle = F.nx_cycle
		gen F1nx_cycle_FD = F.nx_cycle_FD
			
*--------------------------------------------------------			
	*Calc BC stats----
		sort ccode2

		*Logged Things
		foreach var of varlist lrgdpn lHHc lTc lGc lInv   {
			*Standard deviations; raw and relative to GDP
				by ccode2: egen sd_`var' = sd(`var'_cycle)
					replace sd_`var' = 100*sd_`var'
				by ccode2: egen sd_`var'_FD = sd(`var'_cycle_FD)	
					replace sd_`var'_FD = 100*sd_`var'_FD
				gen rd`var' = sd_`var'/sd_lrgdpn
				gen rd`var'_FD = sd_`var'_FD/sd_lrgdpn_FD 
			*Correlations with GDP
				by ccode2: egen corr_GDP_`var' = corr(lrgdpn_cycle `var'_cycle)
				by ccode2: egen corr_GDP_`var'_FD  = corr(lrgdpn_cycle_FD  `var'_cycle_FD )
			}
			by countrycode, sort: egen sd_lrgdpn4GFS = sd(lrgdpn_cycle4GFS)
					replace sd_lrgdpn4GFS = 100*sd_lrgdpn4GFS
					
	sort ccode2
				replace nx_cycle = . if  Year>2010
				replace nx_cycle_FD = . if Year>2010
	*Things not in logs
		foreach var of varlist nx reer irate IntrAll IntrOffic L1nx F1nx {
			*Standard deviations; raw and relative to GDP
				by ccode2: egen sd_`var' = sd(`var'_cycle)
					replace sd_`var' = 100*sd_`var'
				by ccode2: egen sd_`var'_FD = sd(`var'_cycle_FD)	
					replace sd_`var'_FD = 100*sd_`var'_FD
				gen rd`var' = sd_`var'/sd_lrgdpn
				gen rd`var'_FD = sd_`var'_FD/sd_lrgdpn_FD 
			*Correlations with GDP
				by ccode2: egen corr_GDP_`var' = corr(lrgdpn_cycle `var'_cycle)
				by ccode2: egen corr_GDP_`var'_FD  = corr(lrgdpn_cycle_FD  `var'_cycle_FD )
			}			
			*Serial correlation of GDP
				by ccode2: egen corr_GDP_L1GDP = corr(lrgdpn_cycle L1GDP_cycle)
				by ccode2: egen corr_GDP_L1GDP_FD = corr(lrgdpn_cycle_FD L1GDP_cycle_FD)
*

drop corr_GDP_irate 
by ccode2: egen corr_GDP_irate = corr(lrgdpn_cycle4irate  irate_cycle )

drop  corr_GDP_nx_FD
	by ccode2: egen  corr_GDP_nx_FD  = corr(lrgdpn_cycle  nx_cycle_FD )
	by ccode2: egen  corr_GDP_nx2  = corr(lrgdpn_cycle  nx )
	by ccode2: egen  corr_GDP_nx3  = corr(lrgdpn_cycle_FD  nx_cycle_FD )


	drop _merge
save $IN_dir\WDI_clean.dta, replace	


