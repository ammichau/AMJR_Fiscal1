ReadMe.txt
*********************************************************************************************************************************
Replication Files for "Redistributive Fiscal Policies and Business Cycles in Emerging Economies," Michaud & Rothert (v.2/15/2018)
---------------------------------------------------------------------------------------------------------------------------------
Decription:
	-These files perform the analyses for Section 2: Empirical Regularities in Fiscal Components
	-Computations performed on Stata/SE v14.2
	-Input/Output uses Microsoft Excel v2016
	-The package wbopendata and access to the internet is required to download the neccessary data series.
*********************************************************************************************************************************
Contents
--------
-Inputs:
	STATA Do's
		-MainDo_AMJR.do: This is the main .do file. It calls all other .do files.
		-WDI_clean.do: Loads and cleans World devlopment indicators for national accounts
		-GFS_clean.do: Loads and cleans Global Financial Statistics for fiscal accounts
		-FINDEX_clean.do: Loads and cleans global financial index for our measure of "rich" and "poor"
	Raw Data
		-GFS_data.xlsx: Global Financial Statistics raw data download from WB.
		-FINDEX_Data.csv: Global Financial Index rarw data download from WB.
	Data from other files
		-InequalityData\sInc_Rich.csv: Our calculation of income shares using the STATA file we obtained from Maxim Pinkovskiy
			+We do not have permission to distribute the raw data, but our computational codes are provided. 
			+See the subdirectory \InequalityData\ReadME.txt
-----------------------
-Outputs, Intermediate:
	-STATA .dta
		-WDI_loadTemp.dta, 
----------------
-Outputs, Final:

*********************************************************************************************************************************
Additional notes:
	-The codes are commented in detail. Please refer to the line comments and preamble for explainations.





