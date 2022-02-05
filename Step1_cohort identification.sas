
/** AFIB patients functional outcome after stroke **/ 
/** Data: Health and Retirement Survey/ Medicare  **/
/** Written by Sun Jeon **/

/** This code is to identify the study cohort, merge various data sources, and prepare data for analysis */
/** Cohort Flow 
(1) 	HRS ALL PARTICIPANTS 	        43,216 
(2)		AGE 65+	           				28,927 
(3)		HAVE MEDICARE LINKAGE	        25,109 
(4)		AF Dx (CCW) AT AGE 65+	        4,964 
(5) 	HAVE A CORE INTERVIEW BEFORE AF dx within 2.5 years	     3,809 
((5)-1 	STROKE AFTER AF DX              261)

 (+)Defining censoring date -- incorporating exit (censor_dt=dod)
**/

libname mdcr 'V:\Health and Retirement Study\DATAinSAS2018\HRS_Provider_Distribution HRS018 - NCIRE 51424';
libname trk 'V:\Health and Retirement Study\Grisell\HRS_data\trk2016earlyv3'; 
libname doi 'V:\Health and Retirement Study\DATAinSAS\doi_gdr';
libname dod 'V:\Health and Retirement Study\DATAinSAS\dod_gdr';
libname randp 'V:\Health and Retirement Study\Grisell\HRS_data\rand\randhrs1992_2016v1';
proc format cntlin=randp.sasfmts;run;
libname fat 'V:\Health and Retirement Study\Grisell\HRS_data\rand\fatfiles';
libname AF 'V:\Health and Retirement Study\Sun\Anna Park\SAS interim'; 


/**************************************/
/*===1. HRS ALL PARTICIPANTS - TRK ****/
/**************************************/
data trk2016;
set trk.trk2016tr_r;
HHIDPN=HHID*1000 + PN;
run; /*43216*/


/******************************/
/*===2. AGE 65+ by 12/31/2015 */
/******************************/
data cohort_0;   
set trk2016 (keep=HHIDPN birthyr);  
if birthyr = 0 then delete; 
if birthyr<=1950 ; 
proc sort; by HHIDPN; run; /*28927*/


/************************/
/*===3. Medicare linkage*/
/************************/
data cmsxref (drop=HHIDPNC);
	set mdcr.XREF2015Medicare (keep=BID_HRS_22  HHIDPN rename=(HHIDPN=HHIDPNC));
	HHIDPN=input(HHIDPNC,9.0);
proc sort; by HHIDPN; run;

data cohort_1 (drop=birthyr);
	merge cohort_0 (in=A) cmsxref (in=B);
	by hhidpn;
	if A=1 and B=1;
proc sort; by hhidpn; run; /*25109*/
proc sql; select count(HHIDPN), count(Distinct HHIDPN) from cohort_1; quit; 


/***************************/
/*===4-(1) AF dx using CCW */
/***************************/
proc contents data=mdcr.basf_1991_2015; run;
data af_mdcr_1 (keep=BID_HRS_22 af_ccw_dx); 
set mdcr.basf_1991_2015 (keep=BID_HRS_22 ATRIAL_FIB_EVER); 

if ATRIAL_FIB_EVER ~='00000000' then AF_ccw_dx = input(ATRIAL_FIB_EVER, yymmdd10.); 

format  AF_ccw_dx mmddyy10.;
label  AF_ccw_dx = 'Earliest indication of AFib in Medicare';

if AF_ccw_dx ~=. ; 
run; 
proc sort data=af_mdcr_1 nodup; by BID_HRS_22; run;

proc sql; select count(BID_HRS_22), count(distinct BID_HRS_22) from af_mdcr_1; quit; /*5203*/

proc sort data=cohort_1; by BID_HRS_22; run;
data cohort_2; 
merge cohort_1 (in=B) af_mdcr_1(in=A); 
by BID_HRS_22; 
if A & B; run; 


/*****************************/
/*===4-(2). AAGE 65 at AF dx */
/*****************************/

/*---(i) DOB */
	DATA dn (keep=BID_HRS_22 dob);
		set MDCR.DN_1998 MDCR.DN_1999 MDCR.DN_2000-MDCR.DN_2012;
		if BENE_DOB='00000000' then dob=.;
		else dob=input(BENE_DOB, yymmdd10.);
		format dob mmddyy10.;
	run;
	proc sort data=dn; by BID_HRS_22 dob; run;
	proc sort data=dn nodupkey; by BID_HRS_22; run;

	/*#### UPDATED 2013-2015. SHOULD USE MBSF */
	DATA dn_1315 (keep=BID_HRS_22 dob); 
		SET MDCR.MBSF_2013-MDCR.MBSF_2015; 
		dob_c=put(BENE_BIRTH_DT, mmddyy10.);	
		dob=input(dob_c, mmddyy10.);
		format dob mmddyy10.;
		run;

		DATA dn_1; 
		SET dn dn_1315;
		proc sort data=dn_1; by BID_HRS_22 dob; run;
		proc sort data=dn_1 nodupkey; by BID_HRS_22; run; 
	
	data cmsxref (drop=HHIDPNC);
	set mdcr.XREF2015Medicare (keep=BID_HRS_22  HHIDPN rename=(HHIDPN=HHIDPNC));
	HHIDPN=input(HHIDPNC,9.0);
	proc sort data=cmsxref; by BID_HRS_22; run; 
	DATA dn2 (drop=BID_HRS_22); merge dn_1 (in=A) cmsxref;  by BID_HRS_22; if A; run;
	proc sort; by hhidpn; run;
                      
	data randage; set randp.Randhrs1992_2016v1(keep=HHIDPN RABDATE); 
	proc sort; by hhidpn; run;

/* (ii) Merge all DOB sources and only include AF dx above 65*/
	proc sort data=cohort_2; by HHIDPN; run;

	DATA cohort_3 (drop=RABDATE);
		merge cohort_2 (in=A) dn2 randage ; 
		by hhidpn; 
		IF A ;
		if dob=. then dob=RABDATE;

		if dob~=. then age_at_af_dx = yrdif(dob, AF_ccw_dx, 'actual'); 
		else age_at_af_dx=.; 

		if age_at_Af_Dx>65;
		run; /*4964*/

/***********************************************************/
/*===5. Have a core interview before AF dx within 2.5 years*/
/***********************************************************/

data cohort_4 (drop=PIWMONTH PIWYEAR);
merge cohort_3(in=A)
	 doi.doi2017_gdr (keep=HHIDPN AIWDATE  BIWDATE  CIWDATE  DIWDATE  EIWDATE  FIWDATE  GIWDATE 
	 					   HIWDATE JIWDATE KIWDATE LIWDATE MIWDATE NIWDATE OIWDATE )
	 trk2016 (keep=HHIDPN PIWMONTH PIWYEAR 
					 AIWTYPE BIWTYPE  CIWTYPE  DIWTYPE  EIWTYPE  FIWTYPE  GIWTYPE HIWTYPE  JIWTYPE 
					 KIWTYPE LIWTYPE MIWTYPE NIWTYPE OIWTYPE PIWTYPE);
by HHIDPN;
if A; 

/*DX_DT_1st = mdy(month(ADMIT_DT_initial), 1, year(ADMIT_DT_initial)); /** We go month-level */

PIWDATE =mdy(PIWMONTH,1,PIWYEAR); 

post_itv_no = 0; 
first_itv_dt_after_AF =.;  
last_int_dt_before_AF = . ; 

ARRAY IWDATE [14] AIWDATE  BIWDATE  CIWDATE  DIWDATE  EIWDATE  FIWDATE  GIWDATE 
			 	 HIWDATE JIWDATE KIWDATE LIWDATE MIWDATE NIWDATE OIWDATE ;
ARRAY IWTYPE [14]  AIWTYPE BIWTYPE  CIWTYPE  DIWTYPE  EIWTYPE  FIWTYPE  GIWTYPE HIWTYPE  JIWTYPE 
					 KIWTYPE LIWTYPE MIWTYPE NIWTYPE OIWTYPE;

DO I=1 to 14; 
IF IWDATE[I]>=AF_ccw_dx & IWTYPE[I] in (1, 11) then post_itv_no= post_itv_no+1; 
IF IWDATE[I]>=AF_ccw_dx & first_itv_dt_after_AF = .  & IWTYPE[I] in (1, 11) then first_itv_dt_after_AF=IWDATE[I]; 
IF IWDATE[I]>=AF_ccw_dx & IWTYPE[I] NOT in (1, 11) then IWDATE[I] = . ; 

IF .<IWDATE[I]<AF_ccw_Dx  and IWTYPE[I] =1 then do; 
	last_int_dt_before_AF=IWDATE[I]; 
	last_wave_before_af = I; 
	END; 	
END; DROP I; 

format PIWDATE mmddyy10. first_itv_dt_after_AF last_int_dt_before_AF mmddyy10.; 

/**10/23/2020:: 2016 is special case; we don't use 2016 core, but we do use 2016 exit */
if PIWDATE ~=. & PIWTYPE = 11 then post_itv_no = post_itv_no+1; 

if last_int_dt_before_AF~=.; 
if yrdif(last_int_dt_before_AF, AF_ccw_Dx, 'exact')<=2.5; 

run; /*3809*/

		/***06/21/2020 Censoring at the first month of Part A disenrollment **/
		data cohort_4a; set cohort_4 (keep=HHIDPN BID_HRS_22 AF_ccw_dx); run; 

		%MACRO HMOIND(INDATA,YR);
		DATA A (KEEP=BID_HRS_22 HMOIND12 BUYIN12 rename=(BUYIN12=BUYIN12_&YR HMOIND12=HMOIND12_&YR)); SET &INDATA ;
		PROC SORT; BY BID_HRS_22 HMOIND12_&YR; RUN;
		PROC SORT DATA=A OUT=DN&YR nodupkey; BY BID_HRS_22; RUN;
		%MEND HMOIND;

		%HMOIND(mdcr.DN_1991,91)
		%HMOIND(mdcr.DN_1992,92)
		%HMOIND(mdcr.DN_1993,93)
		%HMOIND(mdcr.DN_1994,94)
		%HMOIND(mdcr.DN_1995,95)
		%HMOIND(mdcr.DN_1996,96)
		%HMOIND(mdcr.DN_1997,97)
		%HMOIND(mdcr.DN_1998,98)
		%HMOIND(mdcr.DN_1999,99)
		%HMOIND(mdcr.DN_2000,00)
		%HMOIND(mdcr.DN_2001,01)
		%HMOIND(mdcr.DN_2002,02)
		%HMOIND(mdcr.DN_2003,03)
		%HMOIND(mdcr.DN_2004,04)
		%HMOIND(mdcr.DN_2005,05)
		%HMOIND(mdcr.DN_2006,06)
		%HMOIND(mdcr.DN_2007,07)
		%HMOIND(mdcr.DN_2008,08)
		%HMOIND(mdcr.DN_2009,09)
		%HMOIND(mdcr.DN_2010,10)
		%HMOIND(mdcr.DN_2011,11)
		%HMOIND(mdcr.DN_2012,12)
		DATA HMOIND; MERGE DN91-DN99 DN00-DN12; BY BID_HRS_22; PROC SORT; BY BID_HRS_22; RUN;
		/*### UPDATED MBSF 2013-2015 */	
		%MACRO HMOIND1(INDATA,YR);
			DATA A (keep=BID_HRS_22 HMOIND12_&YR BUYIN12_&YR); 
			SET &INDATA;
			HMOIND12_&YR = catt(HMO_IND_01,HMO_IND_02,HMO_IND_03,HMO_IND_04,HMO_IND_05,HMO_IND_06,HMO_IND_07,HMO_IND_08,HMO_IND_09,HMO_IND_10,HMO_IND_11,HMO_IND_12);
			BUYIN12_&YR =catt(MDCR_ENTLMT_BUYIN_IND_01,MDCR_ENTLMT_BUYIN_IND_02,MDCR_ENTLMT_BUYIN_IND_03,MDCR_ENTLMT_BUYIN_IND_04,MDCR_ENTLMT_BUYIN_IND_05,
							MDCR_ENTLMT_BUYIN_IND_06,MDCR_ENTLMT_BUYIN_IND_07,MDCR_ENTLMT_BUYIN_IND_08,MDCR_ENTLMT_BUYIN_IND_09,MDCR_ENTLMT_BUYIN_IND_10,
							MDCR_ENTLMT_BUYIN_IND_11,MDCR_ENTLMT_BUYIN_IND_12);
			PROC SORT; BY BID_HRS_22 HMOIND12_&YR; RUN;
			PROC SORT DATA=A OUT=DN&YR nodupkey; BY BID_HRS_22; RUN;
			%MEND HMOIND1;
		%HMOIND1(mdcr.mbsf_2013,13)
		%HMOIND1(mdcr.mbsf_2014,14)
		%HMOIND1(mdcr.mbsf_2015,15)

		/*### CROSS WALK + MEDICARE */

		DATA DN9115; MERGE DN91-DN99 DN00-DN15; BY BID_HRS_22; PROC SORT; BY BID_HRS_22;  run;

		proc sort data=DN9115; by BID_HRS_22; 
		proc sort data=cohort_4a; by BID_HRS_22; run; 

		data cohort_4b (drop=  	BUYIN BUYIN_to_AF AF_year AF_month month_from_JAN91 check 
								BUYIN12_91	BUYIN12_92	BUYIN12_93	BUYIN12_94	BUYIN12_95	
								BUYIN12_96	BUYIN12_97	BUYIN12_98	BUYIN12_99	BUYIN12_00
								BUYIN12_01	BUYIN12_02	BUYIN12_03	BUYIN12_04	BUYIN12_05
								BUYIN12_06	BUYIN12_07	BUYIN12_08	BUYIN12_09	BUYIN12_10
								BUYIN12_11	BUYIN12_12	BUYIN12_13	BUYIN12_14	BUYIN12_15); 
		merge cohort_4a (in=A) DN9115 (keep=BID_HRS_22 	BUYIN12_91	BUYIN12_92	BUYIN12_93	BUYIN12_94	BUYIN12_95	
													BUYIN12_96	BUYIN12_97	BUYIN12_98	BUYIN12_99	BUYIN12_00
													BUYIN12_01	BUYIN12_02	BUYIN12_03	BUYIN12_04	BUYIN12_05
													BUYIN12_06	BUYIN12_07	BUYIN12_08	BUYIN12_09	BUYIN12_10
													BUYIN12_11	BUYIN12_12	BUYIN12_13	BUYIN12_14	BUYIN12_15);
		by BID_HRS_22; 
		if A;


		length BUYIN $300.; 
		length BUYIN_to_AF $300.; 

		ARRAY BUYIN12 [*] BUYIN12_91	BUYIN12_92	BUYIN12_93	BUYIN12_94	BUYIN12_95	
						BUYIN12_96	BUYIN12_97	BUYIN12_98	BUYIN12_99	BUYIN12_00
						BUYIN12_01	BUYIN12_02	BUYIN12_03	BUYIN12_04	BUYIN12_05
						BUYIN12_06	BUYIN12_07	BUYIN12_08	BUYIN12_09	BUYIN12_10
						BUYIN12_11	BUYIN12_12	BUYIN12_13	BUYIN12_14	BUYIN12_15;

		 DO I=1 to 25; 
		IF BUYIN12[I] = '            ' then BUYIN12[I] = "XXXXXXXXXXXX";
		END; DROp I; 

		label   BUYIN12_91= "91"
			    BUYIN12_92= "92"
			    BUYIN12_93= "93"	
			    BUYIN12_94= "94"	
			    BUYIN12_95= "95"	
			    BUYIN12_96= "96"	
				BUYIN12_97= "97"	
				BUYIN12_98= "98"	
				BUYIN12_99= "90"	
				BUYIN12_00= "00"

				BUYIN12_01= "01"	
				BUYIN12_02= "02"	
				BUYIN12_03= "03"	
				BUYIN12_04= "04"	
				BUYIN12_05= "05"
				BUYIN12_06= "06"	
				BUYIN12_07= "07"	
				BUYIN12_08= "08"	
				BUYIN12_09= "09"	
				BUYIN12_10= "10"

				BUYIN12_11= "11"	
				BUYIN12_12= "12"	
				BUYIN12_13= "13"	
				BUYIN12_14= "14"	
				BUYIN12_15= "15";

		BUYIN = catt (BUYIN12_91,	BUYIN12_92,	BUYIN12_93,	BUYIN12_94,	BUYIN12_95,	
					  BUYIN12_96,	BUYIN12_97,	BUYIN12_98,	BUYIN12_99,	BUYIN12_00,
					  BUYIN12_01,	BUYIN12_02,	BUYIN12_03,	BUYIN12_04,	BUYIN12_05,
					  BUYIN12_06,	BUYIN12_07,	BUYIN12_08,	BUYIN12_09,	BUYIN12_10,
					  BUYIN12_11,	BUYIN12_12,	BUYIN12_13,	BUYIN12_14,	BUYIN12_15);

		AF_year = year(AF_ccw_dx); 
		AF_month = month(AF_ccw_dx);


		month_from_Jan91 = (AF_year-1991)*12 + AF_month; 
		BUYIN_to_AF = substr(BUYIN, month_from_Jan91, 300-month_from_Jan91 + 1); 


		check='13AC'; 
		partA_mo_after_AF = verify(BUYIN_to_af, check)-1; 

		censor_dt = intnx('month', AF_ccw_dx, partA_mo_after_AF-1, 'E'); 
		format censor_dt mmddyy10.; 
		run;

		proc freq data=cohort_4b; tables PartA_mo_after_AF; run; 
		proc means data=cohort_4b min max mean std q1 median q3; var PartA_mo_after_AF; run; 

		data cohort_4c; set cohort_4b (keep=HHIDPN censor_dt); run;
		proc sort data=cohort_4c; by HHIDPN ;run;


/*****************************/
/**5-(1)== STROKE AFTER AF dx*/
/******************************/

/* (i) MedPar file in medicare claim :: STROKE **/
proc contents data=mdcr.mp_1998; run; 
data allmedpar(keep= BID_HRS_22 ADMSNDT AD_DGNS DGNS_CD01-DGNS_CD25);
set Mdcr.mp_1991 Mdcr.mp_1999 Mdcr.mp_2000-Mdcr.mp_2015;
proc sort data=allmedpar; by BID_HRS_22 ADMSNDT; run;

proc sort data=allmedpar; by BID_HRS_22; run;

DATA stroke(drop=dx_3 dx_4 AD_DGNS DGNS_CD01-DGNS_CD25 ADMSNDT stroke rename=(admit_dt = stroke_dt)); 
set allmedpar; 

stroke = 0;
ARRAY dxcode [1] AD_DGNS /* DGNS_CD01 -DGNS_CD25*/ ;

do i=1 to 1;
	dx_3=substr(dxcode[i],1,3);
	dx_4=substr(dxcode[i],1,4);
	IF dx_3 in ('434', '436', '430', '431') | dx_4 in ('I639', 'I634', 'I619') then stroke=1; 
	END;  drop i; 
if stroke=1; 

admit_dt = DATEJUL(ADMSNDT*1); 
format admit_dt MMDDYY10.;

run; 

proc sort data=cohort_4; by BID_HRS_22; 
proc sort data=stroke; by BID_HRS_22; run; 

/*** (ii) STROKE AFTER THE FIRST INTERVIEW */
DATA stroke_1; merge cohort_4(in=A) stroke ; 
by BID_HRS_22; 
if stroke_dt>= AF_ccw_dx;
if A; 

/*stroke_year = year(admit_dt);*/
stroke_flag=1; 
run; 

	proc sql; select count(BID_HRS_22), count(distinct BID_HRS_22) from stroke_1; quit; 
	proc sort data=stroke_1; by BID_HRS_22 stroke_dt; run;
	data stroke_2; set stroke_1 (keep=BID_HRS_22 stroke_Dt stroke_flag); 
	by BID_HRS_22; 
	if first.BID_HRS_22; /*taking only first stroke per patient*/
	run; 

proc sort data=cohort_4; by BID_HRS_22; run;
data cohort_5; merge cohort_4 (in=A) stroke_2;
by BID_HRS_22; 
if A; 
run;
proc freq data=cohort_5; tables stroke_flag; run;


/************************************************************************/
/**** (+)Defining censoring date -- incorporating exit (censor_dt=dod)***/
/************************************************************************/

proc sort data=cohort_5; by HHIDPN; run;
proc transpose data=cohort_5 out=cohort_5_a prefix=int_dt; 
by HHIDPN; 
var AIWDATE  	BIWDATE  	CIWDATE  	DIWDATE  	EIWDATE  	FIWDATE  GIWDATE  HIWDATE JIWDATE 
	KIWDATE 	LIWDATE 	MIWDATE 	NIWDATE 	OIWDATE 	PIWDATE;
run ;

proc sort data=cohort_5_a; by HHIDPN; run;
proc sort data=cohort_5; by HHIDPN; run; 

data cohort_6 (drop=AIWDATE  BIWDATE  CIWDATE  DIWDATE  EIWDATE  FIWDATE  GIWDATE 
				 	 HIWDATE JIWDATE KIWDATE LIWDATE MIWDATE NIWDATE OIWDATE PIWDATE
					 AIWTYPE BIWTYPE  CIWTYPE  DIWTYPE  EIWTYPE  FIWTYPE  GIWTYPE HIWTYPE  JIWTYPE 
				     KIWTYPE LIWTYPE MIWTYPE NIWTYPE OIWTYPE PIWTYPE
			   rename=(int_dt1 = int_dt _NAME_=trk_wave)); 
merge cohort_5_a cohort_5 /*(keep=HHIDPN BID_HRS_22 AF_ccw_dx dob last_int_dt_before_AF last_wave_before_af stroke_dt stroke_flag)*/; 
by HHIDPN; 

ARRAY IWDATE [15] AIWDATE  BIWDATE  CIWDATE  DIWDATE  EIWDATE  FIWDATE  GIWDATE 
			 	 HIWDATE JIWDATE KIWDATE LIWDATE MIWDATE NIWDATE OIWDATE PIWDATE;
ARRAY IWTYPE [15]  AIWTYPE BIWTYPE  CIWTYPE  DIWTYPE  EIWTYPE  FIWTYPE  GIWTYPE HIWTYPE  JIWTYPE 
					 KIWTYPE LIWTYPE MIWTYPE NIWTYPE OIWTYPE PIWTYPE;
label _NAME_= "TRK WAVE";

/**For 2016, we are only using exit **/
if _NAME_="PIWDATE" and PIWTYPE~=11 then int_dt1=.; 

DO I=1 to 15; 
if int_dt1 = IWDATE[I] and IWTYPE[I] = 11 then exit_flag = 1; 
END; drop I; 

if int_dt1 = . then delete; 
if int_dt1 <last_int_dt_before_af then delete; 

age_at_int = yrdif(dob, int_dt1,'actual');
label age_At_int = "Age at interview";

run; 

	/*QC*/
	proc sql; 
	create table test as 
	select HHIDPN, count(distinct int_dt) as count
	from cohort_6 
	group by HHIDPN ; 
	quit; 
	proc freq data=test; tables count; run; /*everyone in the cohort at this point have at least 3 interviews (1 before AF dx, and at least 2 after AF dx)*/
	proc sql; select count(distinct HHIDPN) from cohort_6 where stroke_flag=1 ; quit; 

libname dod 'V:\Health and Retirement Study\DATAinSAS2018\dod_gdr';
data dod; set dod.Dod_gdr_20190717 (keep=HHIDPN dod); 
if dod <= '31DEC2015'd; 
run; 

proc sort data=cohort_4c; by HHIDPn; run;
proc sort data=dod; by HHIDPN; run; 

data cohort_6a; 
merge cohort_6 (in=A) dod cohort_4c; 
by HHIDPN; 
if A; 
if dod~=. and dod<censor_dt then censor_dt = dod;
run; 

	/*QC*/
	data test; set cohort_6a; if exit_flag=1; run;
	proc sql; select count(distinct HHIDPN) from cohort_6a where stroke_flag=0 ; quit; /** How many of people whose stroke=1 has stroke after their censoring date?  1 person **/

	proc sql; 
	create table test1 as 
	select HHIDPN, count(int_dt) as int_count
	from cohort_6a
	group by HHIDPN; quit; 
	proc freq data=test1; tables int_count; run; 
