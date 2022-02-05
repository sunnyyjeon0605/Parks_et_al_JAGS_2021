
/** AFIB patients functional outcome after stroke **/ 
/** Data: Health and Retirement Survey/ Medicare  **/
/** Written by Sun Jeon **/

/*This code is to create bootstarpping sample to get confidence intervals for our population rate measures
*/

libname mdcr 'V:\Health and Retirement Study\DATAinSAS2018\HRS_Provider_Distribution HRS018 - NCIRE 51424';
libname trk 'V:\Health and Retirement Study\Grisell\HRS_data\trk2016earlyv3'; 
libname doi 'V:\Health and Retirement Study\DATAinSAS\doi_gdr';
libname dod 'V:\Health and Retirement Study\DATAinSAS\dod_gdr';
libname randp 'V:\Health and Retirement Study\Grisell\HRS_data\rand\randhrs1992_2016v1';
proc format cntlin=randp.sasfmts;run;
libname fat 'V:\Health and Retirement Study\Grisell\HRS_data\rand\fatfiles';
libname AF 'V:\Health and Retirement Study\Sun\Anna Park\SAS interim'; 

proc sort data=af.cohort_19_10222020 ; by HHIDPN int_dt; run; 
data bscohort_1 ; 
set af.cohort_19_10222020 ; 
by HHIDPN; 
retain id 0; 
if first.HHIDPN then id = id+1; 
run; 

data bscohort_id (keep=id HHIDPN raestrat raehsamp wtcrnh); 
set bscohort_1; 
by HHIDPN;
if first.HHIDPN; 
run; 

/*** BOOTSTARPPED IDs for 50 bootstrapped dataset ***/
data bootcohort_0 (drop=i); 
	do sampnum=1 to 50; 
		do i=1 to nobs; 
			x=round(ranuni(10)*nobs); 
			set bscohort_id
				nobs=nobs
				point=x; 
			output;
		end; 
	end; 
	stop;
run;

proc sort data=bootcohort_0; by sampnum HHIDPN; run; 
data bootcohort_1; 
	set bootcohort_0; 
	by sampnum HHIDPN; 
	if first.HHIDPN then seq_id = 1; 
	else seq_id+1; 
run;

proc sort data=bootcohort_1; by sampnum id; run;
proc sort data=bscohort_1; by id int_dt; run;
proc freq data=bootcohort_1; tables seq_id; run;

/** FULL DATASET TO FEED FOR MODEL FITTING **/
proc sql; 
create table bscohort_2 as
select *
from bootcohort_1 as t1 left join bscohort_1 as t2 on t1.HHIDPN = t2.HHIDPN; 
quit; 

proc freq data=bscohort_2; tables seq_id; run;
proc freq data=bscohort_2; tables sampnum; run;

proc sort data=bscohort_2; by sampnum id; run;

data bscohort_3; 
set bscohort_2; 
boot_id = HHIDPN *10000 +sampnum*100 + seq_id; 
run;
proc contents data=bscohort_3;
run;

proc export data=bscohort_3 outfile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 bscohort_3.dta"
dbms=dta replace; run;


/*** GRID ****/
proc import out=gridNoStroke datafile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 gridNoStroke.csv"
dbms=csv replace; run;
proc import out=gridFixedStroke datafile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 gridFixedStroke.csv"
dbms=csv replace; run;
proc import out=gridPopStroke datafile="V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 gridPopStroke.csv"
dbms=csv replace; run;

proc sql; 
create table bs_gridNoStroke as
select *, t1.HHIDPN *10000 +sampnum*100 + seq_id as boot_id 
from bootcohort_1 as t1 left join gridNoStroke as t2 on t1.HHIDPN = t2.HHIDPN
where t2.original_data~=1; 
quit; 

proc sort data=bs_gridnostroke; by sampnum id yr_time_from_Af; run;

proc sql; 
create table bs_gridFixedStroke as
select *, t1.HHIDPN *10000 +sampnum*100 + seq_id as boot_id 
from bootcohort_1 as t1 left join gridFixedStroke as t2 on t1.HHIDPN = t2.HHIDPN 
where t2.original_data~=1; 
quit; 


proc sort data=bs_gridFixedstroke; by sampnum id yr_time_from_Af; run;

proc sql; 
create table bs_gridPopStroke as
select *,  t1.HHIDPN *10000 +sampnum*100 + seq_id as boot_id 
from bootcohort_1 as t1 left join gridPopStroke as t2 on t1.HHIDPN = t2.HHIDPN 
where t2.original_data~=1; 
quit; 

proc sort data=bs_gridPopstroke; by sampnum id yr_time_from_Af; run;

proc export data=bs_gridNoStroke outfile="\\vhasfcreap\sun\Anna Park\stroke_hrs\data\new_cohort\10222020 bs_GridNoStroke.dta"
dbms=dta replace; run;
proc export data=bs_gridFixedStroke outfile="\\vhasfcreap\sun\Anna Park\stroke_hrs\data\new_cohort\10222020 bs_GridFixedStroke.dta"
dbms=dta replace; run;
proc export data=bs_gridPopStroke outfile="\\vhasfcreap\sun\Anna Park\stroke_hrs\data\new_cohort\10222020 bs_GridPopStroke.dta"
dbms=dta replace; run;

data test; set bs_gridPopStroke; if sampnum=1; run;
proc sort data=test; by HHIDPN boot_id; run; 
proc sql; 
select count(distinct boot_id) from bs_gridPopStroke
where sampnum=1; quit; 
