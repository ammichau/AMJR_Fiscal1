set more off
clear all
cd "H:\AMJR\GinSOErbc\Data"

**************************************************************************************************************************
*FINDEX_clean.do				@Amichaud v.1/25/2017
**************************************************************************************************************************
*This file imports statistics from the world bank global financial index.
*	-Inputs: FINDEX_Data.csv
*	-Outputs: FINDEX_clean.dta
*------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------------

import delimited $IN_dir\FINDEX_Data.csv, varnames(1) clear

*SETUP----------------------------------------------------------------------------------------------------------------------
	gen sSaveAny = mrvmrv if seriescode=="WP11645.1"
	gen Nrich = mrvmrv if seriescode=="WP11648.1"

	rename countryname country
	drop countrycode
	gen countrycode=.
	
		replace countrycode =512 if country=="Afghanistan"
		replace countrycode =914 if country=="Albania"
		replace countrycode =612 if country=="Algeria"
		replace countrycode =614 if country=="Angola"
		replace countrycode =312 if country=="Anguilla"
		replace countrycode =311 if country=="Antigua and Barbuda"
		replace countrycode =311 if country=="Antigua"		
		replace countrycode =213 if country=="Argentina"
		replace countrycode =911 if country=="Armenia"		
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
	replace countrycode =963 if country=="Bosnia and Herzegovina"
	replace countrycode =616 if country=="Botswana"
	replace countrycode =223 if country=="Brazil"
	replace countrycode =918 if country=="Bulgaria"
	replace countrycode =748 if country=="Burkina Faso"
	replace countrycode =618 if country=="Burundi"

	replace countrycode =522 if country=="Cambodia"
	replace countrycode =622 if country=="Cameroon"
	replace countrycode =156 if country=="Canada"
	replace countrycode =624 if country=="Cape Verde"
	replace countrycode =626 if country=="Central African Republic"
	replace countrycode =628 if country=="Chad"
	replace countrycode =228 if country=="Chile"
	replace countrycode =924 if country=="China"
	replace countrycode =233 if country=="Colombia"
	replace countrycode =632 if country=="Comoros"
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

	replace countrycode =248 if country=="Ecuador"
	replace countrycode =469 if country=="Egypt"
	replace countrycode =469 if country=="Egypt, Arab Rep."	
	replace countrycode =253 if country=="El Salvador"
	replace countrycode =642 if country=="Equatorial Guinea"
	replace countrycode =939 if country=="Estonia"
	replace countrycode =644 if country=="Ethiopia"

	replace countrycode =819 if country=="Fiji"
	replace countrycode =172 if country=="Finland"
	replace countrycode =132 if country=="France"

	replace countrycode =646 if country=="Gabon"
	replace countrycode =648 if country=="Gambia"
	replace countrycode =648 if country=="Gambia, The"	
	replace countrycode =134 if country=="Germany"
	replace countrycode =652 if country=="Ghana"
	replace countrycode =174 if country=="Greece"
	replace countrycode =328 if country=="Grenada"
	replace countrycode =258 if country=="Guatemala"
	replace countrycode =654 if country=="Guinea-Bissau"
	replace countrycode =654 if country=="Guinea"	
	replace countrycode =336 if country=="Guyana"

	replace countrycode =263 if country=="Haiti"
	replace countrycode =268 if country=="Honduras"
	replace countrycode =532 if country=="China, P.R.: Hong Kong"	
	replace countrycode =532 if country=="Hong Kong, China"	
	replace countrycode =944 if country=="Hungary"

	replace countrycode =176 if country=="Iceland"
	replace countrycode =534 if country=="India"
	replace countrycode =536 if country=="Indonesia"
	replace countrycode =429 if country=="Iran"
	replace countrycode =429 if country=="Iran, Islamic Rep."	
	replace countrycode =433 if country=="Iraq"
	replace countrycode =178 if country=="Ireland"
	replace countrycode =436 if country=="Israel"
	replace countrycode =136 if country=="Italy"

	replace countrycode =343 if country=="Jamaica"
	replace countrycode =158 if country=="Japan"
	replace countrycode =439 if country=="Jordan"

	replace countrycode =916 if country=="Kazakhstan"
	replace countrycode =664 if country=="Kenya"
	replace countrycode =542 if country=="Korea, Republic of"
	replace countrycode =542 if country=="Korea, Rep."	
	replace countrycode =967 if country=="Kosovo, Republic of"
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
	replace countrycode =962 if country=="Macedonia, FYR"
	replace countrycode =674 if country=="Madagascar"
	replace countrycode =676 if country=="Malawi"
	replace countrycode =548 if country=="Malaysia"
	replace countrycode =556 if country=="Maldives"
	replace countrycode =678 if country=="Mali"
	replace countrycode =181 if country=="Malta"
	replace countrycode =682 if country=="Mauritania"
	replace countrycode =684 if country=="Mauritius"
	replace countrycode =273 if country=="Mexico"
	replace countrycode =921 if country=="Moldova"
	replace countrycode =948 if country=="Mongolia"
	replace countrycode =351 if country=="Montserrat"
	replace countrycode =686 if country=="Morocco"
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
	replace countrycode =922 if country=="Russian Federation"
	replace countrycode =714 if country=="Rwanda"

	replace countrycode =361 if country=="St. Kitts and Nevis"
	replace countrycode =361 if country=="St. Kitts & Nevis"	
	replace countrycode =362 if country=="St. Lucia"
	replace countrycode =364 if country=="St. Vincent and the Grenadines"
	replace countrycode =364 if country=="St. Vincent & Grenadines"	
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
	replace countrycode =366 if country=="Suriname"	
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
	replace countrycode =926 if country=="Ukraine"
	replace countrycode =466 if country=="United Arab Emirates"
	replace countrycode =112 if country=="United Kingdom"
	replace countrycode =111 if country=="United States"
	replace countrycode =298 if country=="Uruguay"

	replace countrycode =846 if country=="Vanuatu"
	replace countrycode =299 if country=="Venezuela"
	replace countrycode =299 if country=="Venezuela, RB"
	replace countrycode =582 if country=="Vietnam"
	replace countrycode =862 if country=="Western Somoa"
	replace countrycode =474 if country=="Yemen"
	replace countrycode =474 if country=="Yemen, Rep."
	replace countrycode =636 if country=="Zaire"
	replace countrycode =754 if country=="Zambia"
	replace countrycode =698 if country=="Zimbabwe"
	
drop if countrycode==.

drop seriesname seriescode mrvmrv  

by countrycode, sort: egen nSaveAny = max(sSaveAny)
	drop sSaveAny
	drop if Nrich==.
			
save "FINDEX_clean.dta", replace			




	
	
	
	
	
	
	
	
	
	
