
/** AFIB patients functional outcome after stroke **/ 
/** Data: Health and Retirement Survey/ Medicare  **/
/** Written by Sun Jeon **/

/*This code is to prepare the  predicted probability calculation grid.
This will be used after performing logistic regression to compute the predicted population rates of anticoagulant use and the average marginal effect
*/

libname mdcr 'V:\Health and Retirement Study\DATAinSAS2018\HRS_Provider_Distribution HRS018 - NCIRE 51424';
libname trk 'V:\Health and Retirement Study\Grisell\HRS_data\trk2016earlyv3'; 
libname doi 'V:\Health and Retirement Study\DATAinSAS\doi_gdr';
libname dod 'V:\Health and Retirement Study\DATAinSAS\dod_gdr';
libname randp 'V:\Health and Retirement Study\Grisell\HRS_data\rand\randhrs1992_2016v1';
proc format cntlin=randp.sasfmts;run;
libname fat 'V:\Health and Retirement Study\Grisell\HRS_data\rand\fatfiles';
libname AF 'V:\Health and Retirement Study\Sun\Anna Park\SAS interim'; 


/*******************************************************************/
/****** Prepping the predicted probability calculation grid ********/
/*******************************************************************/

/** To make the grid; export it to R */
proc sql ;
create table cohort_id as
select distinct HHIDPN 
from af.cohort_19_10222020; 
quit; 
proc export data=cohort_id dbms=csv
outfile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\cohort_id_10232020.csv"
replace;
run;

/* Get the grid created by R and merge it to the cohort data --see Grid_in_R to see how the .csv grid is created */
proc import datafile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\grid_id_time_1022.csv"
out = grid replace dbms=csv; 
run; 

data grid_1; set grid (drop=var1 rename=(id_mx=HHIDPN time_mx=yr_time_from_af)); 
run;
proc sort data=grid_1; by HHIDPN yr_time_from_Af; run;

data cohort_f1; 
set af.cohort_19_10222020 (drop=trk_wave BID_HRS_22 );
run; 
proc sort data=cohort_f1; by HHIDPN yr_time_from_Af; run;

proc sql; 
create table time_inv_cov as
select HHIDPN, max(age_at_af_dx) as age_At_Af_dx, max(ragender) as ragender, max(stroke_base) as stroke_base, 
	  max(race_eth) as race_eth, max(highschool_grad) as highschool_grad
from cohort_f1
group by HHIDPN; 
run;

data cohort_g (drop=first_itv_dt_after_AF last_int_dt_before_AF censor_dt grid); 
merge cohort_f1 (in=A drop=age_at_af_Dx ragender stroke_base race_eth highschool_grad NH_white NH_black hispanic) grid_1; 
by HHIDPN yr_time_from_AF;
if A then original_data=1; 
/*grid =.; */
run;

proc sort data=cohort_g; 
by HHIDPn yr_Time_From_AF; 
run;
proc sort data=time_inv_cov; by HHIDPN; run;

data cohort_g1 (drop=ragender lt_NH_flag next_BATh next_BED next_DRESS next_EAT next_TOILT next_WALK next_PHONE next_MONEY next_MEDS next_SHOP next_MEALS wave_no ); 
merge cohort_g time_inv_cov; 
by HHIDPN; 
female = ragender-1; 
if ever_stroke = . & original_data=1 then ever_stroke=0;
if age_at_outcome = . then age_at_outcome = age_at_af_dx +yr_time_from_Af;
run; 
	proc sql; select count(distinct HHIDPN) from cohort_g1;quit; 

proc export data=cohort_g1 dbms=dta
/*outfile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\08062020 grid.dta"*/
outfile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 grid.dta"
replace;
run;
