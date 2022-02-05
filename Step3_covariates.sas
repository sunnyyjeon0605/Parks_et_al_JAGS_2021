/** AFIB patients functional outcome after stroke **/ 
/** Data: Health and Retirement Survey/ Medicare  **/
/** Written by Sun Jeon **/

/** Covariate at basline codings --chronic conditions/CHADSVASC score/Demographics
The list of covariates is in Table 1 of the manuscript 
Chronic conditions were identified using (1) Self-report (in HRS survey) (2) Medicare claims (CCW flag) 
*/

libname mdcr 'V:\Health and Retirement Study\DATAinSAS2018\HRS_Provider_Distribution HRS018 - NCIRE 51424';
libname trk 'V:\Health and Retirement Study\Grisell\HRS_data\trk2016earlyv3'; 
libname doi 'V:\Health and Retirement Study\DATAinSAS\doi_gdr';
libname dod 'V:\Health and Retirement Study\DATAinSAS\dod_gdr';
libname randp 'V:\Health and Retirement Study\Grisell\HRS_data\rand\randhrs1992_2016v1';
proc format cntlin=randp.sasfmts;run;
libname fat 'V:\Health and Retirement Study\Grisell\HRS_data\rand\fatfiles';
libname AF 'V:\Health and Retirement Study\Sun\Anna Park\SAS interim'; 
libname sachin "V:\Health and Retirement Study\Sun\Sachin\AF_longitudinal\SAS interim\af_frailty_v6_to_syj_20200714"; 


/******************************************/
/**(1) CHRONIC CONDITION ******************/
/******************************************/

/*** (i) Self- reported */
data rand_chronic; set randp.Randhrs1992_2016v1
	(keep= HHIDPN 

	R1HIBPE			R1DIABE			R1CANCRE		R1HEARTE	R1STROKE	
	R2HIBPE			R2DIABE			R2CANCRE		R2HEARTE	R2STROKE	
	R3HIBPE			R3DIABE			R3CANCRE		R3HEARTE	R3STROKE	
	R4HIBPE			R4DIABE			R4CANCRE		R4HEARTE	R4STROKE	
	R5HIBPE			R5DIABE			R5CANCRE		R5HEARTE	R5STROKE	
	R6HIBPE			R6DIABE			R6CANCRE		R6HEARTE	R6STROKE	
	R7HIBPE			R7DIABE			R7CANCRE		R7HEARTE	R7STROKE	
	R8HIBPE			R8DIABE			R8CANCRE		R8HEARTE	R8STROKE	
	R9HIBPE			R9DIABE			R9CANCRE		R9HEARTE	R9STROKE	
	R10HIBPE		R10DIABE		R10CANCRE		R10HEARTE	R10STROKE	
	R11HIBPE		R11DIABE		R11CANCRE		R11HEARTE	R11STROKE	
	R12HIBPE		R12DIABE		R12CANCRE		R12HEARTE	R12STROKE		)
;
RUN; 

proc sort data=cohort_12; by HHIDPN; run;

data cohort_15 (drop=R1HIBPE			R1DIABE			R1CANCRE		R1HEARTE	R1STROKE	
	R2HIBPE			R2DIABE			R2CANCRE		R2HEARTE	R2STROKE	
	R3HIBPE			R3DIABE			R3CANCRE		R3HEARTE	R3STROKE	
	R4HIBPE			R4DIABE			R4CANCRE		R4HEARTE	R4STROKE	
	R5HIBPE			R5DIABE			R5CANCRE		R5HEARTE	R5STROKE	
	R6HIBPE			R6DIABE			R6CANCRE		R6HEARTE	R6STROKE	
	R7HIBPE			R7DIABE			R7CANCRE		R7HEARTE	R7STROKE	
	R8HIBPE			R8DIABE			R8CANCRE		R8HEARTE	R8STROKE	
	R9HIBPE			R9DIABE			R9CANCRE		R9HEARTE	R9STROKE	
	R10HIBPE		R10DIABE		R10CANCRE		R10HEARTE	R10STROKE	
	R11HIBPE		R11DIABE		R11CANCRE		R11HEARTE	R11STROKE	
	R12HIBPE		R12DIABE		R12CANCRE		R12HEARTE	R12STROKE); 
merge cohort_12 (in=A) rand_chronic; 
by HHIDPN; 
if A; 

ARRAY CH1[*]	R1HIBPE			R1DIABE			R1CANCRE		R1HEARTE	R1STROKE	;
ARRAY CH2[*]	R2HIBPE			R2DIABE			R2CANCRE		R2HEARTE	R2STROKE	;
ARRAY CH3[*]	R3HIBPE			R3DIABE			R3CANCRE		R3HEARTE	R3STROKE	;
ARRAY CH4[*]	R4HIBPE			R4DIABE			R4CANCRE		R4HEARTE	R4STROKE	;
ARRAY CH5[*]	R5HIBPE			R5DIABE			R5CANCRE		R5HEARTE	R5STROKE	;
ARRAY CH6[*]	R6HIBPE			R6DIABE			R6CANCRE		R6HEARTE	R6STROKE	;
ARRAY CH7[*]	R7HIBPE			R7DIABE			R7CANCRE		R7HEARTE	R7STROKE	;
ARRAY CH8[*]	R8HIBPE			R8DIABE			R8CANCRE		R8HEARTE	R8STROKE	;
ARRAY CH9[*]	R9HIBPE			R9DIABE			R9CANCRE		R9HEARTE	R9STROKE	;
ARRAY CH10[*]	R10HIBPE		R10DIABE		R10CANCRE		R10HEARTE	R10STROKE	;
ARRAY CH11[*]	R11HIBPE		R11DIABE		R11CANCRE		R11HEARTE	R11STROKE	;
ARRAY CH12[*]	R12HIBPE		R12DIABE		R12CANCRE		R12HEARTE	R12STROKE	;
ARRAY CH[*]		SR_HIBPE		SR_DIABE		SR_CANCRE		SR_HEARTE	SR_STROKE	;

DO I=1 to 5; 
IF trk_wave="AIWDATE" then  do; CH[I] = CH1[I]; wave_yr = 'wave_yr_92'; end; 
IF trk_wave="BIWDATE" then  do; CH[I] = CH2[I]; wave_yr = 'wave_yr_94'; end; 
IF trk_wave="CIWDATE" then  do; CH[I] = CH2[I]; wave_yr = 'wave_yr_94'; end; 
IF trk_wave="DIWDATE" then  do; CH[I] = CH3[I]; wave_yr = 'wave_yr_96'; end;  
IF trk_wave="EIWDATE" then  do; CH[I] = CH3[I]; wave_yr = 'wave_yr_96'; end; 
IF trk_wave="FIWDATE" then  do; CH[I] = CH4[I]; wave_yr = 'wave_yr_98'; end;  
IF trk_wave="GIWDATE" then  do; CH[I] = CH5[I]; wave_yr = 'wave_yr_00'; end; 
IF trk_wave="HIWDATE" then  do; CH[I] = CH6[I]; wave_yr = 'wave_yr_02'; end; 
IF trk_wave="JIWDATE" then  do; CH[I] = CH7[I]; wave_yr = 'wave_yr_04'; end; 
IF trk_wave="KIWDATE" then  do; CH[I] = CH8[I]; wave_yr = 'wave_yr_06'; end; 
IF trk_wave="LIWDATE" then  do; CH[I] = CH9[I]; wave_yr = 'wave_yr_08'; end;  
IF trk_wave="MIWDATE" then  do; CH[I] = CH10[I];  wave_yr = 'wave_yr_10'; end;  
IF trk_wave="NIWDATE" then  do; CH[I] = CH11[I];  wave_yr = 'wave_yr_12'; end; 
IF trk_wave="OIWDATE" then  do; CH[I] = CH12[I];  wave_yr = 'wave_yr_14'; end; 
END; DROP I; 

RUN; 
	proc sort data=cohort_15; by HHIDPN int_dt; run;

	/*QC*/
	data test; set cohort_15; 
	by HHIDPN;
	if last.HHIDPN;
	time_gap = censor_dt - int_dt; 
	; run;
	proc freq data=test; tables time_gap; run;
	proc freq data=test; tables SR_stroke * stroke_flag/missing; run;


/** (ii) MERGE Self-reported AMI and ANGINA from the pre-cleaned file***/
data hrs_sachin; 
set sachin.Af_frailty_v6_to_syj_20200714(keep=HHIDPN wave_yr EVER_HF VASCULAR_DZ); 
run; 
data cohort_16; 
merge cohort_15 (in=A) hrs_sachin; 
by HHIDPN wave_yr; 
if A; 
run; 
proc sort data=cohort_16; by HHIDPN; run;


/** (iii) chronic condition from medicare files (3 variables per condition; CCW, self-reported, either)**/

proc contents data=mdcr.basf_1991_2015; run;

data af_mdcr_1 (keep=BID_HRS_22 END_DT 
					CHF_ccw_dt 
					AMI_ccw_dt
					IHE_ccw_dt
					HYPERT_ccw_dt 
					DIABETES_ccw_dt
					STROKE_TIA_ccw_dt 
					CANCER_ccw_dt); 
set mdcr.basf_1991_2015 ; 

if CHF_EVER ~='00000000' then CHF_ccw_dt = input(CHF_EVER, yymmdd10.);
if AMI_EVER ~='00000000' then AMI_ccw_dt = input(AMI_ever, yymmdd10.); 
if ISCHEMICHEART_EVER ~='00000000' then IHE_ccw_dt = input(ISCHEMICHEART_EVER, yymmdd10.); 
if HYPERT_EVER ~='00000000' then HYPERT_ccw_dt = input(HYPERT_EVER, yymmdd10.);
if DIABETES_EVER ~='00000000' then DIABETES_ccw_dt = input(DIABETES_EVER, yymmdd10.);
if STROKE_TIA_EVER ~='00000000' then STROKE_TIA_ccw_dt = input(STROKE_TIA_EVER, yymmdd10.);
if CANCER_BREAST_EVER~='00000000' then CANCER_BREAST_ccw_dt = input(CANCER_BREAST_EVER, yymmdd10.);
if CANCER_COLORECTAL_EVER ~='00000000' then CANCER_COLORECTAL_ccw_dt = input(CANCER_COLORECTAL_EVER, yymmdd10.);
if CANCER_ENDOMETRIAL_EVER ~='00000000' then CANCER_ENDOMETRIAL_ccw_dt = input(CANCER_ENDOMETRIAL_EVER, yymmdd10.);
if CANCER_LUNG_EVER ~='00000000' then CANCER_LUNG_ccw_dt = input(CANCER_LUNG_EVER, yymmdd10.);
if CANCER_PROSTATE_EVER ~='00000000' then CANCER_PROSTATE_ccw_dt = input(CANCER_PROSTATE_EVER, yymmdd10.);

CANCER_ccw_dt = min(CANCER_BREAST_ccw_dt,
CANCER_COLORECTAL_ccw_dt, 
CANCER_ENDOMETRIAL_ccw_dt, 
CANCER_LUNG_ccw_dt, 
CANCER_PROSTATE_ccw_dt); 

format  
AMI_ccw_dt
IHE_ccw_dt
HYPERT_ccw_dt 
DIABETES_ccw_dt
STROKE_TIA_ccw_dt 
CHF_ccw_dt 
CANCER_BREAST_ccw_dt
CANCER_COLORECTAL_ccw_dt 
CANCER_ENDOMETRIAL_ccw_dt 
CANCER_LUNG_ccw_dt 
CANCER_PROSTATE_ccw_dt 
CANCER_ccw_dt
mmddyy10.; 

run; 

proc sort data=af_mdcr_1; by BID_HRS_22 END_DT; run; 

data af_mdcr_2; set af_mdcr_1; 
by BID_HRS_22; 
if last.BID_HRS_22; 
run; 

proc sort data=cohort_16; by BID_HRS_22; run;

/**(iv) incorporating chronic conditions from self-report and claims*/
data cohort_17 (drop= DIABETES_ccw_dt
HYPERT_ccw_dt AMI_ccw_dt IHE_ccw_dt CHF_ccw_dt CANCER_ccw_dt STROKE_TIA_ccw_dt EVER_HF 
VASCULAR_DZ CCW_AMI wave_yr SR_: CCW_:
); 
merge cohort_16 (in=A) af_mdcr_2 (drop=END_dt); 

by BID_HRS_22; 
if A;

if 0<AMI_ccw_dt<=int_dt then CCW_AMI = 1; 
	else CCW_AMI = 0; 
if 0<IHE_ccw_dt<=int_dt then CCW_IHE =1; 
	else CCW_IHE=0;
if 0<HYPERT_ccw_dt<=int_dt then CCW_HIBPE = 1; 
	else CCW_HIBPE=0; 
if 0<DIABETES_ccw_dt<=int_dt then CCW_DIABE = 1; 
	else CCW_DIABE = 0;
if 0<CANCER_ccw_dt<=int_dt then CCW_CANCRE =1; 
	else CCW_CANCRE =0; 
if 0<CHF_ccw_dt <=int_dt then CCW_CHFE = 1; 
	else CCW_CHFE = 0;
if 0<STROKE_TIA_ccw_dt <=int_dt then CCW_STROKE = 1; 
	else  CCW_STROKE = 0; 

if exit_flag = 1 then do;
CCW_AMI = . ; 
CCW_IHE=.; 
CCW_HIBPE =.;
CCW_DIABE = .; 
CCW_CANCRE =.; 
CCW_CHFE = .; 
CCW_STROKE = .; 
END; 

ANY_HEARTF = max(EVER_HF, CCW_CHFE); 
ANY_HIBPE = max(SR_HIBPE, CCW_HIBPE		);
ANY_DIABE = max(SR_DIABE, CCW_DIABE		);
ANY_STROKE = max(SR_STROKE, CCW_STROKE );
ANY_VASCE = max(VASCULAR_DZ, CCW_AMi, CCW_IHE); 
/*ANY_HEARTE = max(SR_HEARTE, CCW_HEARTE 	);*/
ANY_CANCRE = max(SR_CANCRE, CCW_CANCRE	);	
run; 
proc sort data=cohort_17; by HHIDPN int_dt; run;

data af.cohort_17_10222020; set cohort_17; run;
data cohort_17; set af.cohort_17_10222020; run;



/*********************************************/
/**(2) BASELINE CHADS SCORE ******************/
/*********************************************/

data chads_1 (keep= HHIDPN BID_HRS_22 AF_ccw_dx age_at_af_dx SR_HIBPE SR_DIABE SR_CANCRE SR_HEARTE SR_STROKE EVER_HF VASCULAR_DZ RAGENDER); 
set cohort_16; 
if int_dt = last_int_dt_before_AF; run;  

proc sort data=chads_1; by BID_HRS_22; run;

data chads_2 (keep=HHIDPN CHADSVASC ANY_STROKE rename=(ANY_STROKE = stroke_base)); 
merge chads_1 (in=A) af_mdcr_2 (drop=END_dt); 
by BID_HRS_22; 
if A;

if 0<AMI_ccw_dt<=AF_ccw_dx then CCW_AMI = 1; 
	else CCW_AMI = 0; 
if 0<IHE_ccw_dt<=AF_ccw_dx then CCW_IHE =1; 
	else CCW_IHE=0;
if 0<HYPERT_ccw_dt<=AF_ccw_dx then CCW_HIBPE = 1; 
	else CCW_HIBPE=0; 
if 0<DIABETES_ccw_dt<=AF_ccw_dx then CCW_DIABE = 1; 
	else CCW_DIABE = 0;
if 0<CHF_ccw_dt <=AF_ccw_dx then CCW_CHFE = 1; 
	else CCW_CHFE = 0;
if 0<STROKE_TIA_ccw_dt <=AF_ccw_dx then CCW_STROKE = 1; 
	else  CCW_STROKE = 0; 

ANY_HEARTF = max(EVER_HF, CCW_CHFE); 
ANY_HIBPE = max(SR_HIBPE, CCW_HIBPE		);
ANY_DIABE = max(SR_DIABE, CCW_DIABE		);
ANY_STROKE = max(SR_STROKE, CCW_STROKE );
ANY_VASCE = max(VASCULAR_DZ, CCW_AMi, CCW_IHE); 


if age_at_af_dx<65 then age_chads = 0; 
else if 65<=age_at_af_dx<75 then age_chads=1; 
else if age_at_af_dx>=75 then age_chads=2; 

female = RAGENDER-1; 
CHADSVASC = ANY_HEARTF *1 +  ANY_HIBPE *1 + age_chads + ANY_DIABE*1 + ANY_STROKE*2 + ANY_VASCE*1 +  female*1; 

label CHADSVASC = "CHADSVASC at AF dx";
run; 
proc freq data=chads_2; tables CHADSVASC; run;

data cohort_18; 
merge cohort_17(in=A) chads_2;
by HHIDPN; 
if A; 
run;



/*******************************************/
/***** (3) Additional demographics *********/
/*******************************************/
		
/*** Self- reported */
data rand_demographic; set randp.Randhrs1992_2016v1
	(keep= HHIDPN	RARACEM		RAHISPAN	RAEDEGRM 
	H1HHRES			R1MSTAT			R1PROXY	 
	H2HHRES			R2MSTAT			R2PROXY	
	H3HHRES			R3MSTAT			R3PROXY
	H4HHRES			R4MSTAT			R4PROXY	
	H5HHRES			R5MSTAT			R5PROXY	
	H6HHRES			R6MSTAT			R6PROXY	
	H7HHRES			R7MSTAT			R7PROXY	
	H8HHRES			R8MSTAT			R8PROXY	
	H9HHRES			R9MSTAT			R9PROXY	
	H10HHRES		R10MSTAT		R10PROXY	
	H11HHRES		R11MSTAT		R11PROXY	
	H12HHRES		R12MSTAT		R12PROXY	)
;
RUN; 

data trk2016 (keep=HHIDPN ANURSHM 		BNURSHM 	CNURSHM 	DNURSHM		ENURSHM		
						  FNURSHM		GNURSHM		HNURSHM 	JNURSHM 	KNURSHM 	
						  LNURSHM 		MNURSHM 	NNURSHM		ONURSHM		);
set trk.trk2016tr_r;
HHIDPN=HHID*1000 + PN;
run; /*43216*/


data cohort_19 (drop= ANURSHM 		BNURSHM 		CNURSHM 	DNURSHM		ENURSHM		
					 FNURSHM		GNURSHM			HNURSHM 	JNURSHM 	KNURSHM 	
					 LNURSHM 		MNURSHM 		NNURSHM		ONURSHM		
					RARACEM			RAHISPAN		RAEDEGRM 
					H1HHRES			R1MSTAT			R1PROXY	 
					H2HHRES			R2MSTAT			R2PROXY	
					H3HHRES			R3MSTAT			R3PROXY
					H4HHRES			R4MSTAT			R4PROXY	
					H5HHRES			R5MSTAT			R5PROXY	
					H6HHRES			R6MSTAT			R6PROXY	
					H7HHRES			R7MSTAT			R7PROXY	
					H8HHRES			R8MSTAT			R8PROXY	
					H9HHRES			R9MSTAT			R9PROXY	
					H10HHRES		R10MSTAT		R10PROXY	
					H11HHRES		R11MSTAT		R11PROXY	
					H12HHRES		R12MSTAT		R12PROXY	
					HHRES 		MSTAT		NURSHM


); 
merge cohort_18 (in=A) rand_demographic trk2016; 
by HHIDPN; 
if A;

ARRAY VAR_a [*] H1HHRES				R1MSTAT				R1PROXY			ANURSHM 		;
ARRAY VAR_b [*] H2HHRES				R2MSTAT				R2PROXY		 	BNURSHM 		;
ARRAY VAR_c [*] H2HHRES				R2MSTAT				R2PROXY			CNURSHM 		;
ARRAY VAR_d [*] H3HHRES				R3MSTAT				R3PROXY			DNURSHM 		;
ARRAY VAR_e [*] H3HHRES				R3MSTAT				R3PROXY		 	ENURSHM 		;
ARRAY VAR_f [*] H4HHRES				R4MSTAT				R4PROXY		 	FNURSHM 		;
ARRAY VAR_g [*] H5HHRES				R5MSTAT				R5PROXY		 	GNURSHM 		;

ARRAY VAR_h [*] H6HHRES				R6MSTAT				R6PROXY		 	HNURSHM 		;
ARRAY VAR_j [*] H7HHRES				R7MSTAT				R7PROXY		 	JNURSHM 		;
ARRAY VAR_k [*] H8HHRES				R8MSTAT				R8PROXY		 	KNURSHM 		;
ARRAY VAR_l [*] H9HHRES				R9MSTAT				R9PROXY		 	LNURSHM 		;
ARRAY VAR_m [*] H10HHRES			R10MSTAT			R10PROXY		MNURSHM 		;

ARRAY VAR_n [*] H11HHRES			R11MSTAT			R11PROXY		NNURSHM 		;
ARRAY VAR_o [*] H12HHRES			R12MSTAT			R12PROXY		ONURSHM 		;

ARRAY var [*] 	HHRES				MSTAT				PROXY			NURSHM			;

do i=1 to dim(var_a); 
	if trk_wave ='AIWDATE' then var[I] = var_a[I]; 
	if trk_wave ='BIWDATE' then var[I] = var_b[I]; 
	if trk_wave ='CIWDATE' then var[I] = var_c[I]; 
	if trk_wave ='DIWDATE' then var[I] = var_d[I]; 
	if trk_wave ='EIWDATE' then var[I] = var_e[I]; 
	if trk_wave ='FIWDATE' then var[I] = var_f[I]; 
	if trk_wave ='GIWDATE' then var[I] = var_g[I]; 
	if trk_wave ='HIWDATE' then var[I] = var_h[I]; 
	if trk_wave ='JIWDATE' then var[I] = var_j[I]; 
	if trk_wave ='KIWDATE' then var[I] = var_k[I]; 
	if trk_wave ='LIWDATE' then var[I] = var_l[I]; 
	if trk_wave ='MIWDATE' then var[I] = var_m[I]; 
	if trk_wave ='NIWDATE' then var[I] = var_n[I]; 
	if trk_wave ='OIWDATE' then var[I] = var_o[I]; 
END; drop i; 

/*live alone */
if HHRES = 1 and NURSHM in (1 3) then livealone = 0; 
if HHRES = 1 and NURSHM in (5 6 7) then livealone = 1; 
if HHRES not in (1, .) then livealone = 0; 

/* married */
if mstat in (1 3) then married = 1; 
if mstat in (2 4 5 6 7 8) then married = 0; 

/*edu */
if RAEDEGRM = 0 then highschool_grad =0 ; 
if RAEDEGRM in (1, 2, 3, 4, 5, 6, 7, 8) then highschool_grad  = 1; 
label highschool_grad = "0: lt highschool degree, 1: highschool grad or more"; 

/*race */
if RAHISPAN = 0 and RARACEM = 1 then race_eth = 1; 
else if RAHISPAN = 0 and RARACEM =2 then race_eth = 2; 
else if RAHISPAN = 1 then race_eth=3; 
else if RAHISPAN ~= 1 and RARACEM ~=. then race_eth =4;
label race_eth = "1:NH white, 2:NH black, 3:Hispanic, 4:others";

if race_eth=1 then NH_white=1; 
	else if race_eth in (2, 3, 4) then NH_white=0;
if race_eth=2 then NH_black=1; 
	else if race_eth in (1, 3, 4) then NH_black=0; 
if race_eth=3 then hispanic=1; 
	else if race_Eth in (1, 2, 4) then hispanic=0;
if race_eth=4 then race_other=1; 
	else if race_eth<4 then race_other=0; 

/* age at outcome */

yr_time_from_af = time_from_af_to_outcome/365.25;
age_at_outcome = age_at_af_dx + yr_time_from_af;

run;

data af.cohort_19_10222020; set cohort_19; run;
proc export data=af.cohort_19_10222020 dbms=dta
		outfile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\cohort_19_10222020.dta"
		replace;
		run;
