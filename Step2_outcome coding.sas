
/** AFIB patients functional outcome after stroke **/ 
/** Data: Health and Retirement Survey/ Medicare  **/
/** Written by Sun Jeon **/

/** This code is to identify OUTCOMES (ADL/IADL/NH)
Note1: We are incorporating Activities of daily living(ADL) and Instrumental activities of daily living (IADL) info from exit interview if a patient died 
Note2: If a patient died and didn't have an exit interview, we create a fake exit interview row and 
assume that they were ADL/IADL impaired at death.

ADL (6 items) Bathing, bedding, dressing, eating, toileting, and walking across a room
IADL (5 items) Making a phone call, financing (money), taking medications, shopping, and preparing meals 
*/

libname mdcr 'V:\Health and Retirement Study\DATAinSAS2018\HRS_Provider_Distribution HRS018 - NCIRE 51424';
libname trk 'V:\Health and Retirement Study\Grisell\HRS_data\trk2016earlyv3'; 
libname doi 'V:\Health and Retirement Study\DATAinSAS\doi_gdr';
libname dod 'V:\Health and Retirement Study\DATAinSAS\dod_gdr';
libname randp 'V:\Health and Retirement Study\Grisell\HRS_data\rand\randhrs1992_2016v1';
proc format cntlin=randp.sasfmts;run;
libname fat 'V:\Health and Retirement Study\Grisell\HRS_data\rand\fatfiles';
libname AF 'V:\Health and Retirement Study\Sun\Anna Park\SAS interim'; 


/**********************/
/**(1) ADL coding *****/
/**********************/

/* (i) bringing in adl difficulty and dependent variables and creating a binary variable (0=independent or difficult, 1=dependent)
from all HRS waves for all 6 ADL items*/

data adl_iadl; set randp.Derived_adl_iadl_gdr_20190702; run;
data adl_iadl_cat(keep=HHIDPN  R1BATH_cat 	R1BED_cat  		R1DRESS_cat 	R1EAT_cat 	R1TOILT_cat 	R1WALKR_cat 
				   R2BATH_cat 	R2BED_cat  		R2DRESS_cat 	R2EAT_cat 	R2TOILT_cat 	R2WALKR_cat 
				   R3BATH_cat 	R3BED_cat  		R3DRESS_cat 	R3EAT_cat 	R3TOILT_cat 	R3WALKR_cat  
				   R4BATH_cat 	R4BED_cat  		R4DRESS_cat 	R4EAT_cat 	R4TOILT_cat 	R4WALKR_cat 
				   R5BATH_cat 	R5BED_cat  		R5DRESS_cat 	R5EAT_cat 	R5TOILT_cat 	R5WALKR_cat
				   R6BATH_cat 	R6BED_cat  		R6DRESS_cat 	R6EAT_cat 	R6TOILT_cat 	R6WALKR_cat
				   R7BATH_cat 	R7BED_cat  		R7DRESS_cat 	R7EAT_cat 	R7TOILT_cat 	R7WALKR_cat
				   R8BATH_cat 	R8BED_cat  		R8DRESS_cat 	R8EAT_cat 	R8TOILT_cat 	R8WALKR_cat 
				   R9BATH_cat 	R9BED_cat  		R9DRESS_cat 	R9EAT_cat 	R9TOILT_cat 	R9WALKR_cat  
				   R10BATH_cat R10BED_cat  		R10DRESS_cat 	R10EAT_cat R10TOILT_cat 	R10WALKR_cat 
				   R11BATH_cat R11BED_cat  		R11DRESS_cat 	R11EAT_cat R11TOILT_cat 	R11WALKR_cat 
				   R12BATH_cat	R12BED_cat		R12DRESS_cat	R12EAT_cat	R12TOILT_cat	R12WALKR_cat
				   ); 
set adl_iadl ; 

ARRAY ADL_DIFF [*] R1BATHW 	R1BEDW  	R1DRESSW 	R1EATW 	R1TOILTW 	R1WALKRW 
				   R2BATHA 	R2BEDA  	R2DRESSA 	R2EATA 	R2TOILTA 	R2WALKRA 
				   R3BATHA 	R3BEDA  	R3DRESSA 	R3EATA 	R3TOILTA 	R3WALKRA  
				   R4BATHA 	R4BEDA  	R4DRESSA 	R4EATA 	R4TOILTA 	R4WALKRA 
				   R5BATHA 	R5BEDA  	R5DRESSA 	R5EATA 	R5TOILTA 	R5WALKRA
				   R6BATHA 	R6BEDA  	R6DRESSA 	R6EATA 	R6TOILTA 	R6WALKRA 
				   R7BATHA 	R7BEDA  	R7DRESSA 	R7EATA 	R7TOILTA 	R7WALKRA
				   R8BATHA 	R8BEDA  	R8DRESSA 	R8EATA 	R8TOILTA 	R8WALKRA 
				   R9BATHA 	R9BEDA  	R9DRESSA 	R9EATA 	R9TOILTA 	R9WALKRA  
				   R10BATHA R10BEDA  	R10DRESSA 	R10EATA R10TOILTA 	R10WALKRA 
				   R11BATHA R11BEDA  	R11DRESSA 	R11EATA R11TOILTA 	R11WALKRA 
				   R12BATHA	R12BEDA		R12DRESSA	R12EATA	R12TOILTA	R12WALKRA
				   R13BATHA	R13BEDA		R13DRESSA	R13EATA	R13TOILTA	R13WALKRA;

ARRAY ADL_DEP[*] R1BATDE  	R1BEDDE   	R1DRESSDE 	R1EATDE   	R1TOILTDE 	R1WALKRDE 
				 R2BATDE  	R2BEDDE   	R2DRESSDE 	R2EATDE   	R2TOILTDE 	R2WALKRDE 
				 R3BATDE  	R3BEDDE   	R3DRESSDE 	R3EATDE   	R3TOILTDE 	R3WALKRDE 
				 R4BATDE  	R4BEDDE   	R4DRESSDE 	R4EATDE   	R4TOILTDE 	R4WALKRDE
				 R5BATDE 	R5BEDDE  	R5DRESSDE 	R5EATDE   	R5TOILTDE 	R5WALKRDE
				 R6BATDE   	R6BEDDE   	R6DRESSDE 	R6EATDE   	R6TOILTDE 	R6WALKRDE
				 R7BATDE   	R7BEDDE   	R7DRESSDE 	R7EATDE   	R7TOILTDE 	R7WALKRDE
				 R8BATDE   	R8BEDDE   	R8DRESSDE 	R8EATDE  	R8TOILTDE 	R8WALKRDE 
				 R9BATDE   	R9BEDDE   	R9DRESSDE 	R9EATDE   	R9TOILTDE 	R9WALKRDE 
				 R10BATDE   R10BEDDE   	R10DRESSDE 	R10EATDE   	R10TOILTDE 	R10WALKRDE 
				 R11BATDE	R11BEDDE	R11DRESSDE	R11EATDE	R11TOILTDE	R11WALKRDE
				 R12BATDE	R12BEDDE	R12DRESSDE	R12EATDE	R12TOILTDE	R12WALKRDE
				 R13BATDE	R13BEDDE	R13DRESSDE	R13EATDE	R13TOILTDE	R13WALKRDE;

ARRAY ADL[*] 	   R1BATH_cat 	R1BED_cat  		R1DRESS_cat 	R1EAT_cat 	R1TOILT_cat 	R1WALKR_cat 
				   R2BATH_cat 	R2BED_cat  		R2DRESS_cat 	R2EAT_cat 	R2TOILT_cat 	R2WALKR_cat 
				   R3BATH_cat 	R3BED_cat  		R3DRESS_cat 	R3EAT_cat 	R3TOILT_cat 	R3WALKR_cat  
				   R4BATH_cat 	R4BED_cat  		R4DRESS_cat 	R4EAT_cat 	R4TOILT_cat 	R4WALKR_cat 
				   R5BATH_cat 	R5BED_cat  		R5DRESS_cat 	R5EAT_cat 	R5TOILT_cat 	R5WALKR_cat
				   R6BATH_cat 	R6BED_cat  		R6DRESS_cat 	R6EAT_cat 	R6TOILT_cat 	R6WALKR_cat
				   R7BATH_cat 	R7BED_cat  		R7DRESS_cat 	R7EAT_cat 	R7TOILT_cat 	R7WALKR_cat
				   R8BATH_cat 	R8BED_cat  		R8DRESS_cat 	R8EAT_cat 	R8TOILT_cat 	R8WALKR_cat 
				   R9BATH_cat 	R9BED_cat  		R9DRESS_cat 	R9EAT_cat 	R9TOILT_cat 	R9WALKR_cat  
				   R10BATH_cat R10BED_cat  		R10DRESS_cat 	R10EAT_cat R10TOILT_cat 	R10WALKR_cat 
				   R11BATH_cat R11BED_cat  		R11DRESS_cat 	R11EAT_cat R11TOILT_cat 	R11WALKR_cat 
				   R12BATH_cat	R12BED_cat		R12DRESS_cat	R12EAT_cat	R12TOILT_cat	R12WALKR_cat
				   R13BATH_cat	R13BED_cat		R13DRESS_cat	R13EAT_cat	R13TOILT_cat	R13WALKR_cat;
Do I =1 to 78; 
if ADL_DIFF[I] = 0 then ADL[I]=0;  /*indep*/
if ADL_DIFF[I] = 1 & ADL_DEP[I] ~=1 then ADL[I] =0;  /*diff*/
if ADL_DEP[I] = 1 then ADL[I] = 1; /*dep*/
END; DROP I; 

run; 


/* (ii)coding an overall ADL dependency as a single binary variable -- if a dependency with any ADL item is observed, R#ADL =1. Otherwise =0*/
data adl; 
set adl_iadl_cat; 

ARRAY BATH[*] 	R1BATH_cat	R2BATH_cat	R3BATH_cat	R4BATH_cat	R5BATH_cat	R6BATH_cat	R7BATH_cat	R8BATH_cat	R9BATH_cat	R10BATH_cat		R11BATH_cat		R12BATH_cat		;
ARRAY BED[*]	R1BED_cat 	R2BED_cat 	R3BED_cat 	R4BED_cat 	R5BED_cat 	R6BED_cat 	R7BED_cat 	R8BED_cat 	R9BED_cat 	R10BED_cat 		R11BED_cat 		R12BED_cat 		;
ARRAY DRES[*]	R1DRESS_cat	R2DRESS_cat	R3DRESS_cat	R4DRESS_cat	R5DRESS_cat	R6DRESS_cat	R7DRESS_cat	R8DRESS_cat	R9DRESS_cat	R10DRESS_cat	R11DRESS_cat	R12DRESS_cat	;
ARRAY EAT[*] 	R1EAT_cat	R2EAT_cat	R3EAT_cat	R4EAT_cat	R5EAT_cat	R6EAT_cat	R7EAT_cat	R8EAT_cat	R9EAT_cat	R10EAT_cat		R11EAT_cat		R12EAT_cat		;
ARRAY TOIL[*]	R1TOILT_cat	R2TOILT_cat	R3TOILT_cat	R4TOILT_cat	R5TOILT_cat	R6TOILT_cat	R7TOILT_cat	R8TOILT_cat	R9TOILT_cat	R10TOILT_cat	R11TOILT_cat	R12TOILT_cat	;
ARRAY WALK[*] 	R1WALKR_cat	R2WALKR_cat	R3WALKR_cat	R4WALKR_cat	R5WALKR_cat	R6WALKR_cat	R7WALKR_cat	R8WALKR_cat	R9WALKR_cat	R10WALKR_cat	R11WALKR_cat	R12WALKR_cat	;

ARRAY ADL[*]	R1ADL		R2ADL		R3ADL		R4ADL		R5ADL		R6ADL		R7ADL		R8ADL		R9ADL		R10ADL		R11ADL		R12ADL	;

DO I=1 to 12; 
	IF BATH[I]~=. & BED[I]~=. & DRES[I]~=. & EAT[I]~=. & TOIL[I]~=. & WALK[I]~=. then ADL[I] = MAX(BATH[I], BED[I], DRES[I], EAT[I], TOIL[I], WALK[I]) ;
	ELSE IF  BATH[I]=. | BED[I]=. |  DRES[I]=. |  EAT[I]=. |  TOIL[I]=. |  WALK[I]=. then do; 
				if  MAX(BATH[I], BED[I], DRES[I], EAT[I], TOIL[I], WALK[I])=0 then ADL[I] = . ; 
				else if MAX(BATH[I], BED[I], DRES[I], EAT[I], TOIL[I], WALK[I])~=0 then ADL[I] = MAX(BATH[I], BED[I], DRES[I], EAT[I], TOIL[I], WALK[I]); 
				END;
END; DROP I; 

run; 

proc sort data=cohort_6a; by HHIDPN; run;
proc sort data=adl; by HHIDPN;run;


/* (iii) Outcome merging by HHIDPN and wave*/
data cohort_7 (drop=  R1ADL		R2ADL		R3ADL		R4ADL		R5ADL		R6ADL		R7ADL		R8ADL		R9ADL		R10ADL		R11ADL		R12ADL	
 				   R1BATH_cat 	R1BED_cat  		R1DRESS_cat 	R1EAT_cat 	R1TOILT_cat 	R1WALKR_cat 
				   R2BATH_cat 	R2BED_cat  		R2DRESS_cat 	R2EAT_cat 	R2TOILT_cat 	R2WALKR_cat 
				   R3BATH_cat 	R3BED_cat  		R3DRESS_cat 	R3EAT_cat 	R3TOILT_cat 	R3WALKR_cat  
				   R4BATH_cat 	R4BED_cat  		R4DRESS_cat 	R4EAT_cat 	R4TOILT_cat 	R4WALKR_cat 
				   R5BATH_cat 	R5BED_cat  		R5DRESS_cat 	R5EAT_cat 	R5TOILT_cat 	R5WALKR_cat
				   R6BATH_cat 	R6BED_cat  		R6DRESS_cat 	R6EAT_cat 	R6TOILT_cat 	R6WALKR_cat
				   R7BATH_cat 	R7BED_cat  		R7DRESS_cat 	R7EAT_cat 	R7TOILT_cat 	R7WALKR_cat
				   R8BATH_cat 	R8BED_cat  		R8DRESS_cat 	R8EAT_cat 	R8TOILT_cat 	R8WALKR_cat 
				   R9BATH_cat 	R9BED_cat  		R9DRESS_cat 	R9EAT_cat 	R9TOILT_cat 	R9WALKR_cat  
				   R10BATH_cat R10BED_cat  		R10DRESS_cat 	R10EAT_cat R10TOILT_cat 	R10WALKR_cat 
				   R11BATH_cat R11BED_cat  		R11DRESS_cat 	R11EAT_cat R11TOILT_cat 	R11WALKR_cat 
				   R12BATH_cat	R12BED_cat		R12DRESS_cat	R12EAT_cat	R12TOILT_cat	R12WALKR_cat
); 
merge cohort_6a (in=A) adl; 
by HHIDPN;
if A; 

ARRAY W1 [*]  R1ADL 	R1BATH_cat	R1BED_cat 	R1DRESS_cat		R1EAT_cat	R1TOILT_cat		R1WALKR_cat	;
ARRAY W2 [*]  R2ADL 	R2BATH_cat	R2BED_cat 	R2DRESS_cat		R2EAT_cat	R2TOILT_cat		R2WALKR_cat	;
ARRAY W3 [*]  R3ADL 	R3BATH_cat	R3BED_cat 	R3DRESS_cat		R3EAT_cat	R3TOILT_cat		R3WALKR_cat	;
ARRAY W4 [*]  R4ADL 	R4BATH_cat	R4BED_cat 	R4DRESS_cat		R4EAT_cat	R4TOILT_cat		R4WALKR_cat	;
ARRAY W5 [*]  R5ADL 	R5BATH_cat	R5BED_cat 	R5DRESS_cat		R5EAT_cat	R5TOILT_cat		R5WALKR_cat	;
ARRAY W6 [*]  R6ADL 	R6BATH_cat	R6BED_cat 	R6DRESS_cat		R6EAT_cat	R6TOILT_cat		R6WALKR_cat	;
ARRAY W7 [*]  R7ADL 	R7BATH_cat	R7BED_cat 	R7DRESS_cat		R7EAT_cat	R7TOILT_cat		R7WALKR_cat	;
ARRAY W8 [*]  R8ADL 	R8BATH_cat	R8BED_cat 	R8DRESS_cat		R8EAT_cat	R8TOILT_cat		R8WALKR_cat	;
ARRAY W9 [*]  R9ADL 	R9BATH_cat	R9BED_cat 	R9DRESS_cat		R9EAT_cat	R9TOILT_cat		R9WALKR_cat	;
ARRAY W10 [*] R10ADL 	R10BATH_cat	R10BED_cat 	R10DRESS_cat	R10EAT_cat	R10TOILT_cat	R10WALKR_cat	;
ARRAY W11 [*] R11ADL 	R11BATH_cat	R11BED_cat 	R11DRESS_cat	R11EAT_cat	R11TOILT_cat	R11WALKR_cat	;
ARRAY W12 [*] R12ADL 	R12BATH_cat	R12BED_cat 	R12DRESS_cat	R12EAT_cat	R12TOILT_cat	R12WALKR_cat	;
ARRAY VAR [*] ADL		ADL_BATH	ADL_BED		ADL_DRESS		ADL_EAT		ADL_TOILT		ADL_WALK	;

DO I=1 to DIM(W1); 

IF trk_wave="AIWDATE" then VAR[I] = W1[I]; 
IF trk_wave="BIWDATE" then VAR[I] = W2[I] ; 
IF trk_wave="CIWDATE" then VAR[I] = W2[I] ; 
IF trk_wave="DIWDATE" then VAR[I] = W3[I] ; 
IF trk_wave="EIWDATE" then VAR[I] = W3[I] ; 
IF trk_wave="FIWDATE" then VAR[I] = W4[I] ; 
IF trk_wave="GIWDATE" then VAR[I] = W5[I] ; 
IF trk_wave="HIWDATE" then VAR[I] = W6[I] ; 
IF trk_wave="JIWDATE" then VAR[I] = W7[I] ; 
IF trk_wave="KIWDATE" then VAR[I] = W8[I] ; 
IF trk_wave="LIWDATE" then VAR[I] = W9[I] ; 
IF trk_wave="MIWDATE" then VAR[I] = W10[I] ; 
IF trk_wave="NIWDATE" then VAR[I] = W11[I] ; 
IF trk_wave="OIWDATE" then VAR[I] = W12[I] ; 

END; DROP I; 

run; 


		/****(iv) INCORPORATE EXIT INTERVIEW ANSWERS for those who died during the follow-up****/
		libname exit 'V:\Health and Retirement Study\Grisell\HRS_data\exit'; 
		
		data all_exit (drop=days_bed HHID PN); 
		set exit.x95e_r  (keep=HHID PN N1819	N1897 N1920 N1887 	N1907 	N1877 	N1930 rename=(N1819=days_Bed	N1897=exitADL_bath N1920=exitADL_bed  N1887=exitADL_dress 	N1907=exitADL_eat 	N1877=exitADL_walk 	N1930=exitADL_toilt))
			exit.x96e_r  (keep=HHID PN P1400	P1437 P1458  P1425 	P1445 	P1415 	P1468 rename=(P1400=days_Bed	P1437=exitADL_bath P1458=exitADL_bed  P1425=exitADL_dress 	P1445=exitADL_eat 	P1415=exitADL_walk 	P1468=exitADL_toilt))
			exit.x98e_r  (keep=HHID PN Q1842	Q1881 Q1911  Q1852   Q1896 	Q1859 	Q1929 rename=(Q1842=days_Bed	Q1881=exitADL_bath Q1911=exitADL_bed  Q1852=exitADL_dress   Q1896=exitADL_eat 	Q1859=exitADL_walk 	Q1929=exitADL_toilt))
			exit.x00e_r  (keep=HHID PN R1862	R1894 R1924  R1872 	R1909 	R1879 	R1942 rename=(R1862=days_Bed	R1894=exitADL_bath R1924=exitADL_bed  R1872=exitADL_dress 	R1909=exitADL_eat 	R1879=exitADL_walk 	R1942=exitADL_toilt))
			exit.x02g_r  (keep=HHID PN SG129	SG022 SG029  SG015   SG024 	SG020 	SG031 rename=(SG129=days_Bed	SG022=exitADL_bath SG029=exitADL_bed  SG015=exitADL_dress   SG024=exitADL_eat 	SG020=exitADL_walk 	SG031=exitADL_toilt))
			exit.x04g_r  (keep=HHID PN TG129	TG022 TG029  TG015   TG024 	TG020 	TG031 rename=(TG129=days_Bed	TG022=exitADL_bath TG029=exitADL_bed  TG015=exitADL_dress   TG024=exitADL_eat 	TG020=exitADL_walk 	TG031=exitADL_toilt))
			exit.x06g_r  (keep=HHID PN UG129	UG022 UG029  UG015   UG024 	UG020 	UG031 rename=(UG129=days_Bed	UG022=exitADL_bath UG029=exitADL_bed  UG015=exitADL_dress   UG024=exitADL_eat  	UG020=exitADL_walk 	UG031=exitADL_toilt))
			exit.x08g_r  (keep=HHID PN VG129	VG022 VG029  VG015   VG024 	VG020 	VG031 rename=(VG129=days_Bed	VG022=exitADL_bath VG029=exitADL_bed  VG015=exitADL_dress   VG024=exitADL_eat 	VG020=exitADL_walk 	VG031=exitADL_toilt))
			exit.x10g_r  (keep=HHID PN WG129	WG022 WG029  WG015   WG024 	WG020 	WG031 rename=(WG129=days_Bed	WG022=exitADL_bath WG029=exitADL_bed  WG015=exitADL_dress   WG024=exitADL_eat 	WG020=exitADL_walk 	WG031=exitADL_toilt))
			exit.x12g_r  (keep=HHID PN XG129	XG022 XG029  XG015   XG024 	XG020 	XG031 rename=(XG129=days_Bed	XG022=exitADL_bath XG029=exitADL_bed  XG015=exitADL_dress   XG024=exitADL_eat 	XG020=exitADL_walk 	XG031=exitADL_toilt))
			exit.x14g_r  (keep=HHID PN YG129	YG022 YG029  YG015   YG024 	YG020 	YG031 rename=(YG129=days_Bed	YG022=exitADL_bath YG029=exitADL_bed  YG015=exitADL_dress   YG024=exitADL_eat 	YG020=exitADL_walk 	YG031=exitADL_toilt))
			exit.x16g_r  (keep=HHID PN ZG129	ZG022 ZG029  ZG015   ZG024 	ZG020 	ZG031 rename=(ZG129=days_Bed	ZG022=exitADL_bath ZG029=exitADL_bed  ZG015=exitADL_dress   ZG024=exitADL_eat 	ZG020=exitADL_walk 	ZG031=exitADL_toilt))
		;
		HHIDPN = HHID*1000 + PN; 

		ARRAY ITEM [6] exitADL_BATH 	exitADL_BED 	exitADL_DRESS 	exitADL_EAT 	exitADL_WALK 	exitADL_TOILT;

		DO I=1 to 6; 
		if ITEM[I] = 5 then ITEM[I] = 0; 
		if ITEM[I] in (1, 6, 7) then ITEM[I] = 1; 
		if ITEM[I] in (8, 9) then ITEM[I] = . ; 
		END; DROP I; 

		if days_bed>85 & days_bed not in (998, 999) then do; 
			ADL_exit=1; 
			exitADL_BATH=1; 
			exitADL_BED=1;
			exitADL_DRESS=1; 
			exitADL_EAT=1; 
			exitADL_WALK=1; 
			exitADL_TOILT=1; END; 
		
		IF exitADL_BATH~=. & exitADL_BED~=. & exitADL_DRESS~=. & exitADL_EAT~=. & exitADL_WALK~=. & exitADL_TOILT~=.  then
		 	ADL_exit = MAX(exitADL_BATH, exitADL_BED, exitADL_DRESS, exitADL_EAT, exitADL_WALK, exitADL_TOILT);

		ELSE IF exitADL_BATH=. | exitADL_BED=. | exitADL_DRESS=. | exitADL_EAT=. | exitADL_WALK=. | exitADL_TOILT=. then do;   
			if MAX(exitADL_BATH, exitADL_BED, exitADL_DRESS, exitADL_EAT, exitADL_WALK, exitADL_TOILT) = 0 then ADL_Exit = . ; 
			else if MAX(exitADL_BATH, exitADL_BED, exitADL_DRESS, exitADL_EAT, exitADL_WALK, exitADL_TOILT) ~= 0 then ADL_Exit = MAX(exitADL_BATH, exitADL_BED, exitADL_DRESS, exitADL_EAT, exitADL_WALK, exitADL_TOILT);
			end; 

		run; 
		proc freq data=all_Exit; tables days_bed; where ADL_exit=.; run;
	
		proc sort data=cohort_5; by hhidpn; run;	
		proc sql; 
		create table cohort_6b as 
		select distinct HHIDPN from cohort_6a; quit; /*3809 */

		proc sort data=cohort_6b; by HHIDPN; run;
		proc sort data=all_Exit; by hhidpn; run;	
		data cohort_5_exit (keep=HHIDPN ADL_EXIT exitADL_BATH exitADL_BED exitADL_DRESS exitADL_EAT exitADL_WALK exitADL_TOILT); 
		merge cohort_6b(in=A) 
			  all_exit ; /*3372*/		
		by HHIDPN; 
		if A; 
/**/
/*		ARRAY IWDATE [15] AIWDATE  BIWDATE  CIWDATE  DIWDATE  EIWDATE  FIWDATE  GIWDATE HIWDATE JIWDATE KIWDATE LIWDATE MIWDATE NIWDATE OIWDATE PIWDATE;*/
/*		ARRAY IWTYPE [15]  AIWTYPE BIWTYPE  CIWTYPE  DIWTYPE  EIWTYPE  FIWTYPE  GIWTYPE HIWTYPE  JIWTYPE KIWTYPE LIWTYPE MIWTYPE NIWTYPE OIWTYPE PIWTYPE;*/
/**/
/*		DO I = 1 to 15; */
/*		IF IWTYPE[I] = 11 then do; EXIT_DT = IWDATE[I];  END; */
/*		END; DROP I; */
/**/
/*		format EXIT_DT mmddyy10.; */
		run; 

		proc sort data=cohort_7; by HHIDPN; 
		proc sort data=cohort_5_exit; by HHIDPN; run; 

		data cohort_8 (drop=ADL_exit exitADL_BATH exitADL_BED exitADL_DRESS exitADL_EAT exitADL_WALK exitADL_TOILT); 
		merge cohort_7 cohort_5_exit; 
		by HHIDPN;
		if exit_flag =1  then do; 
			ADL=ADL_exit; 
/*			EXIT_FLAG = 1; */
			ADL_BATH = exitADL_BATH;
			ADL_BED = exitADL_BED;
			ADL_DRESS = exitADL_DRESS;
			ADL_EAT = exitADL_EAT;
			ADL_TOILT =exitADL_TOILT;
			ADL_WALK = exitADL_WALK;
		END; 
		run; 
		
		proc freq data=cohort_8; tables ADL/missing; run;

/**********************/
/**(2) IADL coding *****/
/**********************/

/* (i) bringing in iadl difficulty and dependent variables and creating a binary variable (0=independent or difficult, 1=dependent)
from all HRS waves for all 5 IADL items*/

data iadl_cat(keep=HHIDPN    
				 R2PHONE_cat 	R2MONEY_cat 	R2MEDS_cat 		R2SHOP_cat 		R2MEALS_cat 
					R3PHONE_cat  	R3MONEY_cat 	R3MEDS_cat 		R3SHOP_cat 		R3MEALS_cat 
					R4PHONE_cat  	R4MONEY_cat 	R4MEDS_cat 		R4SHOP_cat 		R4MEALS_cat 
					R5PHONE_cat  	R5MONEY_cat 	R5MEDS_cat 		R5SHOP_cat 		R5MEALS_cat 
					R6PHONE_cat  	R6MONEY_cat 	R6MEDS_cat 		R6SHOP_cat 		R6MEALS_cat 
					R7PHONE_cat  	R7MONEY_cat 	R7MEDS_cat 		R7SHOP_cat 		R7MEALS_cat 
					R8PHONE_cat  	R8MONEY_cat 	R8MEDS_cat 		R8SHOP_cat 		R8MEALS_cat 
					R9PHONE_cat  	R9MONEY_cat 	R9MEDS_cat 		R9SHOP_cat 		R9MEALS_cat 
					R10PHONE_cat  	R10MONEY_cat 	R10MEDS_cat 	R10SHOP_cat 	R10MEALS_cat 
					R11PHONE_cat  	R11MONEY_cat 	R11MEDS_cat 	R11SHOP_cat 	R11MEALS_cat 
					R12PHONE_cat 	R12MONEY_cat 	R12MEDS_cat 	R12SHOP_cat 	R12MEALS_cat 
				   ); 
set adl_iadl ; 

ARRAY IADL_DIFF [*] R2PHONEA 	R2MONEYA	R2MEDSA		R2SHOPA		R2MEALSA
					R3PHONEA 	R3MONEYA	R3MEDSA		R3SHOPA		R3MEALSA
					R4PHONEA 	R4MONEYA	R4MEDSA		R4SHOPA		R4MEALSA
					R5PHONEA 	R5MONEYA	R5MEDSA		R5SHOPA		R5MEALSA
					R6PHONEA 	R6MONEYA	R6MEDSA		R6SHOPA		R6MEALSA
					R7PHONEA 	R7MONEYA	R7MEDSA		R7SHOPA		R7MEALSA
					R8PHONEA 	R8MONEYA	R8MEDSA		R8SHOPA		R8MEALSA
					R9PHONEA 	R9MONEYA	R9MEDSA		R9SHOPA		R9MEALSA
					R10PHONEA 	R10MONEYA	R10MEDSA	R10SHOPA	R10MEALSA
					R11PHONEA 	R11MONEYA	R11MEDSA	R11SHOPA	R11MEALSA
					R12PHONEA 	R12MONEYA	R12MEDSA	R12SHOPA	R12MEALSA
				    R13PHONEA 	R13MONEYA	R13MEDSA	R13SHOPA	R13MEALSA
					;

ARRAY iADL_DEP[*]   R2PHONEDE 	R2MONEYDE	R2MEDSDE		R2SHOPDE		R2MEALSDE
					R3PHONEDE 	R3MONEYDE	R3MEDSDE		R3SHOPDE		R3MEALSDE
					R4PHONEDE 	R4MONEYDE	R4MEDSDE		R4SHOPDE		R4MEALSDE
					R5PHONEDE 	R5MONEYDE	R5MEDSDE		R5SHOPDE		R5MEALSDE
					R6PHONEDE 	R6MONEYDE	R6MEDSDE		R6SHOPDE		R6MEALSDE
					R7PHONEDE 	R7MONEYDE	R7MEDSDE		R7SHOPDE		R7MEALSDE
					R8PHONEDE 	R8MONEYDE	R8MEDSDE		R8SHOPDE		R8MEALSDE
					R9PHONEDE 	R9MONEYDE	R9MEDSDE		R9SHOPDE		R9MEALSDE
					R10PHONEDE 	R10MONEYDE	R10MEDSDE		R10SHOPDE		R10MEALSDE
					R11PHONEDE 	R11MONEYDE	R11MEDSDE		R11SHOPDE		R11MEALSDE
					R12PHONEDE	R12MONEYDE	R12MEDSDE		R12SHOPDE		R12MEALSDE
				    R13PHONEDE 	R13MONEYDE	R13MEDSDE		R13SHOPDE		R13MEALSDE
					;

ARRAY iADL[*] 	    R2PHONE_cat 	R2MONEY_cat 	R2MEDS_cat 		R2SHOP_cat 		R2MEALS_cat 
					R3PHONE_cat  	R3MONEY_cat 	R3MEDS_cat 		R3SHOP_cat 		R3MEALS_cat 
					R4PHONE_cat  	R4MONEY_cat 	R4MEDS_cat 		R4SHOP_cat 		R4MEALS_cat 
					R5PHONE_cat  	R5MONEY_cat 	R5MEDS_cat 		R5SHOP_cat 		R5MEALS_cat 
					R6PHONE_cat  	R6MONEY_cat 	R6MEDS_cat 		R6SHOP_cat 		R6MEALS_cat 
					R7PHONE_cat  	R7MONEY_cat 	R7MEDS_cat 		R7SHOP_cat 		R7MEALS_cat 
					R8PHONE_cat  	R8MONEY_cat 	R8MEDS_cat 		R8SHOP_cat 		R8MEALS_cat 
					R9PHONE_cat  	R9MONEY_cat 	R9MEDS_cat 		R9SHOP_cat 		R9MEALS_cat 
					R10PHONE_cat  	R10MONEY_cat 	R10MEDS_cat 	R10SHOP_cat 	R10MEALS_cat 
					R11PHONE_cat  	R11MONEY_cat 	R11MEDS_cat 	R11SHOP_cat 	R11MEALS_cat 
					R12PHONE_cat 	R12MONEY_cat 	R12MEDS_cat 	R12SHOP_cat 	R12MEALS_cat 
				    R13PHONE_cat  	R13MONEY_cat 	R13MEDS_cat 	R13SHOP_cat 	R13MEALS_cat 
					;

Do I =1 to 60; 
if iADL_DIFF[I] in (0, .X) then iADL[I]=0; 
if iADL_DIFF[I] = 1 & iADL_DEP[I] ~=1 then iADL[I] =0; 
if iADL_DEP[I] = 1 then iADL[I] = 1; 
END; DROP I; 

run; 


/* (ii)coding an overall IADL dependency as a single binary variable -- if a dependency with any IADL item is observed, R#IADL =1. Otherwise =0*/

data iadl ; 
set iadl_cat; 

ARRAY PHONE[*]	R2PHONE_cat	R3PHONE_cat	R4PHONE_cat	R5PHONE_cat	R6PHONE_cat	R7PHONE_cat	R8PHONE_cat	R9PHONE_cat	R10PHONE_cat	R11PHONE_cat	R12PHONE_cat	;
ARRAY MONEY[*]	R2MONEY_cat	R3MONEY_cat	R4MONEY_cat	R5MONEY_cat	R6MONEY_cat	R7MONEY_cat	R8MONEY_cat	R9MONEY_cat	R10MONEY_cat	R11MONEY_cat	R12MONEY_cat	;
ARRAY MEDS[*]	R2MEDS_cat	R3MEDS_cat	R4MEDS_cat	R5MEDS_cat	R6MEDS_cat	R7MEDS_cat	R8MEDS_cat	R9MEDS_cat	R10MEDS_cat		R11MEDS_cat		R12MEDS_cat		;
ARRAY SHOP[*]	R2SHOP_cat	R3SHOP_cat	R4SHOP_cat	R5SHOP_cat	R6SHOP_cat	R7SHOP_cat	R8SHOP_cat	R9SHOP_cat	R10SHOP_cat		R11SHOP_cat		R12SHOP_cat		;
ARRAY MEAL[*]	R2MEALS_cat	R3MEALS_cat	R4MEALS_cat	R5MEALS_cat	R6MEALS_cat	R7MEALS_cat	R8MEALS_cat	R9MEALS_cat	R10MEALS_cat	R11MEALS_cat	R12MEALS_cat	;
ARRAY ADL[*]	R2iADL		R3iADL		R4iADL		R5iADL		R6iADL		R7iADL		R8iADL		R9iADL		R10iADL			R11iADL			R12iADL		;

DO I=1 to 11; 
	IF PHONE[I]~=. & MONEY[I]~=. & MEDS[I]~=. & SHOP[I]~=. & MEAL[I]~=.  then ADL[I] = MAX(PHONE[I], MONEY[I], MEDS[I], SHOP[I], MEAL[I]) ;
	ELSE IF  PHONE[I]=. | MONEY[I]=. | MEDS[I]=. | SHOP[I]=. | MEAL[I]~=.   then do; 
				if  MAX(PHONE[I], MONEY[I], MEDS[I], SHOP[I], MEAL[I])=0 then ADL[I] = . ; 
				else if MAX(PHONE[I], MONEY[I], MEDS[I], SHOP[I], MEAL[I]) ~=0 then ADL[I] = MAX(PHONE[I], MONEY[I], MEDS[I], SHOP[I], MEAL[I]); 
				END;
END; DROP I; 

run; 


/* (iii) Outcome merging by HHIDPN and wave*/
data cohort_9 (drop=  R2PHONE_cat 	R2MONEY_cat 	R2MEDS_cat 		R2SHOP_cat 		R2MEALS_cat 
					R3PHONE_cat  	R3MONEY_cat 	R3MEDS_cat 		R3SHOP_cat 		R3MEALS_cat 
					R4PHONE_cat  	R4MONEY_cat 	R4MEDS_cat 		R4SHOP_cat 		R4MEALS_cat 
					R5PHONE_cat  	R5MONEY_cat 	R5MEDS_cat 		R5SHOP_cat 		R5MEALS_cat 
					R6PHONE_cat  	R6MONEY_cat 	R6MEDS_cat 		R6SHOP_cat 		R6MEALS_cat 
					R7PHONE_cat  	R7MONEY_cat 	R7MEDS_cat 		R7SHOP_cat 		R7MEALS_cat 
					R8PHONE_cat  	R8MONEY_cat 	R8MEDS_cat 		R8SHOP_cat 		R8MEALS_cat 
					R9PHONE_cat  	R9MONEY_cat 	R9MEDS_cat 		R9SHOP_cat 		R9MEALS_cat 
					R10PHONE_cat  	R10MONEY_cat 	R10MEDS_cat 	R10SHOP_cat 	R10MEALS_cat 
					R11PHONE_cat  	R11MONEY_cat 	R11MEDS_cat 	R11SHOP_cat 	R11MEALS_cat 
					R12PHONE_cat 	R12MONEY_cat 	R12MEDS_cat 	R12SHOP_cat 	R12MEALS_cat 
					R2iADL		R3iADL		R4iADL		R5iADL		R6iADL		R7iADL		R8iADL		R9iADL		R10iADL			R11iADL			R12iADL		);
 
merge cohort_8 (in=A) iadl; 
by HHIDPN;
if A; 

ARRAY W2[*] R2PHONE_cat		R2MONEY_cat		R2MEDS_cat	R2SHOP_cat	R2MEALS_cat		R2iADL ;
ARRAY W3[*] R3PHONE_cat		R3MONEY_cat		R3MEDS_cat	R3SHOP_cat	R3MEALS_cat		R3iADL;
ARRAY W4[*] R4PHONE_cat		R4MONEY_cat		R4MEDS_cat	R4SHOP_cat	R4MEALS_cat		R4iADL;
ARRAY W5[*] R5PHONE_cat		R5MONEY_cat		R5MEDS_cat	R5SHOP_cat	R5MEALS_cat		R5iADL;
ARRAY W6[*] R6PHONE_cat		R6MONEY_cat		R6MEDS_cat	R6SHOP_cat	R6MEALS_cat		R6iADL;
ARRAY W7[*] R7PHONE_cat		R7MONEY_cat		R7MEDS_cat	R7SHOP_cat	R7MEALS_cat		R7iADL;
ARRAY W8[*] R8PHONE_cat		R8MONEY_cat		R8MEDS_cat	R8SHOP_cat	R8MEALS_cat		R8iADL;
ARRAY W9[*] R9PHONE_cat		R9MONEY_cat		R9MEDS_cat	R9SHOP_cat	R9MEALS_cat		R9iADL;
ARRAY W10[*] R10PHONE_cat	R10MONEY_cat	R10MEDS_cat	R10SHOP_cat	R10MEALS_cat	R10iADL;
ARRAY W11[*] R11PHONE_cat	R11MONEY_cat	R11MEDS_cat	R11SHOP_cat	R11MEALS_cat	R11iADL;
ARRAY W12[*] R12PHONE_cat	R12MONEY_cat	R12MEDS_cat	R12SHOP_cat	R12MEALS_cat	R12iADL;
ARRAY VAR[*] iADL_PHONE		iADL_MONEY		iADL_MEDS	iADL_SHOP	iADL_MEALS		iADL;

DO I=1 to DIM(W2); 

IF trk_wave="BIWDATE" then VAR[I] = W2[I] ; 
IF trk_wave="CIWDATE" then VAR[I] = W2[I] ; 
IF trk_wave="DIWDATE" then VAR[I] = W3[I] ; 
IF trk_wave="EIWDATE" then VAR[I] = W3[I] ; 
IF trk_wave="FIWDATE" then VAR[I] = W4[I] ; 
IF trk_wave="GIWDATE" then VAR[I] = W5[I] ; 
IF trk_wave="HIWDATE" then VAR[I] = W6[I] ; 
IF trk_wave="JIWDATE" then VAR[I] = W7[I] ; 
IF trk_wave="KIWDATE" then VAR[I] = W8[I] ; 
IF trk_wave="LIWDATE" then VAR[I] = W9[I] ; 
IF trk_wave="MIWDATE" then VAR[I] = W10[I] ; 
IF trk_wave="NIWDATE" then VAR[I] = W11[I] ; 
IF trk_wave="OIWDATE" then VAR[I] = W12[I] ; 
END; DROP I; 

run; 

		/*(iv) INCORPORATING EXIT INTERVIEW ANSWERS for those who died */
		data all_exit_IADL /*(keep=HHIDPn iADL_exit)*/;
		set exit.x95e_r (keep=HHID PN 	N2027	N2102	N2035	N2019	N2011 	
										N2028	N2103   N2036	N2020	N2012
						 rename = (N2027 =phone 	N2102=money 	N2035=meds		N2019=shop		N2011=meal
						 		   N2028 =phone_r	N2103=money_r	N2036=meds_r	N2020=shop_r	N2012=meal_r ))

			exit.x96e_r (keep=HHID PN 	P1565	P1640	P1573	P1557	P1549 
										P1566	P1641	P1574	P1558	P1550
						 rename = (P1565 = phone	P1640=money		P1573=meds		P1557=shop		P1549=meal)
						 rename = (P1566 = phone_r	P1641=money_r	P1574=meds_r	P1558=shop_r	P1550=meal_r))

			exit.x98e_r (keep=HHID PN   Q2030	Q2084	Q2040	Q2020	Q2010 
										Q2032	Q2085	Q2041	Q2022	Q2012
						 rename = (Q2030 = phone	Q2084=money			Q2040=meds		Q2020=shop		Q2010=meal)
						 rename = (Q2032 = phone_r	Q2085=money_r		Q2041=meds_r	Q2022=shop_r	Q2012=meal_r))

			exit.x00e_r (keep=HHID PN 	R2022	R2077 	R2032 	R2012	R2002 
										R2024	R2078	R2033	R2014	R2004
						 rename = (R2022 = phone	R2077=money 	R2032=meds 		R2012=shop		R2002=meal)
						 rename = (R2024 = phone_r	R2078=money_r 	R2033=meds_r 	R2014=shop_r	R2004=meal_r))

			exit.x02g_r (keep=HHID PN	SG049	SG061	SG053	SG046	SG043 
										SG161	SG060	SG174	SG173	SG171
						rename = (SG049 = phone		SG061=money			SG053=meds		SG046=shop		SG043=meal)
						rename = (SG161 = phone_r	SG060=money_r		SG174=meds_r	SG173=shop_r	SG171=meal_r))

			exit.x04g_r (keep=HHID PN	TG049	TG061	TG053	TG046	TG043 
										TG161	TG060	TG174	TG173	TG171
						rename = (TG049 = phone		TG061=money			TG053=meds		TG046=shop		TG043=meal)
						rename = (TG161 = phone_r	TG060=money_r		TG174=meds_r	TG173=shop_r	TG171=meal_r))

			exit.x06g_r (keep=HHID PN	UG049	UG061	UG053	UG046	UG043 
										UG161	UG060	UG174	UG173	UG171
						rename = (UG049 = phone		UG061=money			UG053=meds		UG046=shop		UG043=meal)
						rename = (UG161 = phone_r	UG060=money_r		UG174=meds_r	UG173=shop_r	UG171=meal_r)) 

			exit.x08g_r (keep=HHID PN	VG049	VG061	VG053	VG046	VG043 
										VG161	VG060	VG174	VG173	VG171
						rename = (VG049 = phone		VG061=money			VG053=meds		VG046=shop		VG043=meal)
						rename = (VG161 = phone_r	VG060=money_r		VG174=meds_r	VG173=shop_r	VG171=meal_r))

			exit.x10g_r (keep=HHID PN	WG049	WG061	WG053	WG046	WG043 
										WG161	WG060	WG174	WG173	WG171
						rename = (WG049 = phone		WG061=money			WG053=meds		WG046=shop		WG043=meal)
						rename = (WG161 = phone_r	WG060=money_r		WG174=meds_r	WG173=shop_r	WG171=meal_r))

			exit.x12g_r (keep=HHID PN	XG049	XG061	XG053	XG046	XG043 
										XG161	XG060	XG174	XG173	XG171
						rename = (XG049 = phone		XG061=money			XG053=meds		XG046=shop		XG043=meal)
						rename = (XG161 = phone_r	XG060=money_r		XG174=meds_r	XG173=shop_r	XG171=meal_r))

			exit.x14g_r (keep=HHID PN	YG049	YG061	YG053	YG046	YG043 
										YG161	YG060	YG174	YG173	YG171
						rename = (YG049 = phone		YG061=money			YG053=meds		YG046=shop		YG043=meal)
						rename = (YG161 = phone_r	YG060=money_r		YG174=meds_r	YG173=shop_r	YG171=meal_r))
			exit.x16g_r (keep=HHID PN	ZG049	ZG061	ZG053	ZG046	ZG043 
							ZG161	ZG060	ZG174	ZG173	ZG171
			rename = (ZG049 = phone		ZG061=money			ZG053=meds		ZG046=shop		ZG043=meal)
			rename = (ZG161 = phone_r	ZG060=money_r		ZG174=meds_r	ZG173=shop_r	ZG171=meal_r))				
	;

		HHIDPN = HHID*1000 + PN; 

		ARRAY ITEM [5] 		PHONE 	MONEY 	 MEDS 	SHOP 	MEAL;
		ARRAY ITEM_R [5] 	PHONE_r MONEY_r	 MEDS_r SHOP_r 	MEAL_r;


		DO I=1 to 5; 
		if ITEM[I] = 5 then ITEM[I] = 0; 
		if ITEM[I] = 1 then ITEM[I] = 1; 
		if ITEM[I] in (6,7) then do; IF ITEM_R[I] =1 then ITEM[I] =1; 
									 IF ITEM_R[I] =5 then ITEM[I] =0;
									 IF ITEM_R[I] not in (1,5) then ITEM[I] = . ; END; 
		IF ITEM[I] in (8, 9) then ITEM[I]=.; 
		END; DROP I; 
		
		if PHONE ~=. & MONEY ~=. & MEDS~=. & SHOP~=. & MEAL ~=. then IADL_exit = MAX(PHONE, 	MONEY, 	 MEDS, 	SHOP, 	MEAL); 
		ELSE IF PHONE =. | MONEY =. | MEDS =. |  SHOP =. |  MEAL  =. then do; 
			if MAX(PHONE, 	MONEY, 	 MEDS, 	SHOP, 	MEAL)=0 then IADL_exit=.; 
			else if MAX(PHONE, 	MONEY, 	 MEDS, 	SHOP, 	MEAL)~=0 then IADL_exit = MAX(PHONE, 	MONEY, 	 MEDS, 	SHOP, 	MEAL); 
			end; 

		run; 
	
		proc sort data=cohort_6b; by hhidpn; run;	
		proc sort data=all_Exit_iadl; by hhidpn; run;	
		data cohort_5_exit_iadl (keep=HHIDPN iADL_EXIT PHONE 	MONEY 	 MEDS 	SHOP 	MEAL); 
		merge cohort_6b (in=A) 
			  all_exit_iadl ; /*3372*/		
		by HHIDPN; 
		if A; 
/**/
/*		ARRAY IWDATE [15] AIWDATE  BIWDATE  CIWDATE  DIWDATE  EIWDATE  FIWDATE  GIWDATE HIWDATE JIWDATE KIWDATE LIWDATE MIWDATE NIWDATE OIWDATE PIWDATE;*/
/*		ARRAY IWTYPE [15]  AIWTYPE BIWTYPE  CIWTYPE  DIWTYPE  EIWTYPE  FIWTYPE  GIWTYPE HIWTYPE  JIWTYPE KIWTYPE LIWTYPE MIWTYPE NIWTYPE OIWTYPE PIWTYPE;*/
/**/
/*		DO I = 1 to 15; */
/*		IF IWTYPE[I] = 11 then do; EXIT_DT = IWDATE[I];  END; */
/*		END; DROP I; */
/**/
/*		format EXIT_DT mmddyy10.; */
		run; 

		proc sort data=cohort_9; by HHIDPN; 
		proc sort data=cohort_5_exit_iadl; by HHIDPN; run; 

		data cohort_10 (drop=iADL_EXIT PHONE 	MONEY 	 MEDS 	SHOP 	MEAL); 
		merge cohort_9 cohort_5_exit_iadl; 
		by HHIDPN;
		if exit_flag =1  then do; 
		iADL=iADL_exit;
		iADL_Phone = Phone; 
		iADL_money = money; 
		IADL_meds = meds; 
		iADL_shop = shop; 
		iADL_meals = meal; 

		END; 
		run; 
		proc freq data=cohort_10; tables iadl/missing; run;
		proc sql; select count(HHIDPN), count (distinct HHIDPN) from cohort_10; quit; /*2713*/
		proc sql; select count(HHIDPN), count (distinct HHIDPN) from cohort_10 where iadl=.; quit; 


/************************************************************/
/** (+) PI's request-- include GENDER variable in the data **/
/************************************************************/
/** GENDER */
data rand (keep=HHIDPN RAGENDER); set randp.Randhrs1992_2016v1; 
run; 
data cohort_11; merge cohort_10 (in=A ) rand; 
by HHIDPN; 
if A; 
run; 


/*********************************************************************/
/** (3) FAKE EXIT for those who died but don't have exit interview ***/
/*********************************************************************/
/*Note: we are creating a "fake exit" (one additional row) per person who died but didn't have exit interview
we assumed that they were ADL/IADL impaired at death (assuming that death is an ultimate functional decline)*/

proc sql; 
create table fake_exit_1 as 
select HHIDPN, max(BID_HRS_22) as BID_HRS_22, 
	   max(AF_ccw_dx) as AF_ccw_dx format mmddyy10.,
	   max(dob) as dob format mmddyy10., 
	   max(last_int_dt_before_AF) as last_int_dt_before_AF format mmddyy10., 
	   max(stroke_dt) as stroke_dt format mmddyy10., 
	   max(stroke_flag) as stroke_flag,
	   max(censor_dt) as censor_dt format mmddyy10.,
	   1 as ADL, 
	   1 as ADL_BATH,
	   1 as ADL_BED, 
	   1 as ADL_DRESS, 
	   1 as ADL_EAT, 
	   1 as ADL_TOILT, 
	   1 as ADL_WALK, 
	   1 as iADL,
	   1 as iADL_PHONE, 
	   1 as iADL_MONEY, 
	   1 as iADL_MEDS, 
	   1 as IADL_SHOP, 
	   1 as IADL_MEALS,
	   1 as fake_exit_flag,
	   max(RAGENDER) as RAGENDER, 
	   max(int_dt) as last_intv format mmddyy10.,
	   max(dod) as dod format mmddyy10.
from cohort_11
group by HHIDPN 
having dod~=. & max(exit_flag)=.; 
quit;  

/* append to the original data*/
data cohort_12a; set cohort_11 fake_exit_1 (drop=last_intv); 
if fake_exit_flag=1 then age_at_int = yrdif(dob, dod); 
run; 

proc sort data=cohort_12a; by HHIDPN; run;
proc means data=cohort_12b nmiss; var int_dt; run;

data cohort_12; set cohort_12a; 

if (exit_flag=1 | fake_exit_flag =1) & dod~=. then int_dt = dod; 

if int_dt>censor_dt then delete; 
if dod~=. and dod>censor_dt then dod=.; 

if stroke_dt~=. and stroke_dt>censor_dt then do; 
	stroke_dt=. ; 
	stroke_flag=0; 
	end; 

/***10/23/2020 data glitch; there are 2 cases where dod<AF_dx...which does not make sense */
if  dod~=. &  dod<AF_ccw_dx then delete; /* 2 people, 4 rows*/

/***10/23/2020 we want to exclude those whose dod = Af_dx_dt */
if dod = AF_ccw_dx then delete; 
run;

		/*QC*/
		proc sql; select count(Distinct HHIDPN) from cohort_12; quit; 
		data test; set cohort_12; 
		if stroke_dt>censor_dt; run; /*0 cases*/
		proc sql; 
		create table test as
		select HHIDPN, count(int_dt) as int_count
		from cohort_12
		group by HHIDPN; quit; 
		proc freq data=test; tables int_count/missing; run;

data af.cohort_12_10222020; set cohort_12; run;
data cohort_12; set af.cohort_12_10222020; run;
