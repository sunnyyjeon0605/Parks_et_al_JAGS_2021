
/** Here, we are trying to get predictied probability of ADL/IADL impairement
at each time point using the grid we created.  We do this for two scenarios.
(1) When there was no stroke in this popoulation
(2) When there was stroke at a fixed time (median of time_to_stroke) 
This is what they call "recycling" prediction that can be done using margins command;
there was no established command we could use for our data where everyone had different time increment and
we want to have probabilities per 0.2 year. So we came up with this method to manually create the grid
and compute the probability for every 0.2 year*/

/***********************************************************************/
/********************08/12/2020 GRID prediction ************************/
/***********************************************************************/

/************************************/
/*** (1) grid - assuming no stroke **/
/************************************/

/** This create the green line in Figure 1 **/
use "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 gridNoStroke.dta", clear 

drop if original_data==1

// gen adl_indep = .
// gen iadl_indep=. 
// gen next_nh=.

estimate use 10222020_Adl
predict xb_adl, xb
predict adl_error, stdp
gen prob_adl = invlogit(xb_adl)
gen adl_lb = invlogit(xb_adl-invnormal(0.975)*adl_error)
gen adl_ub = invlogit(xb_adl+invnormal(0.975)*adl_error)

estimate use 10222020_iAdl.ster
predict xb_iadl, xb
predict iadl_error, stdp
gen prob_iadl = invlogit(xb_iadl)
gen iadl_lb = invlogit(xb_iadl-invnormal(0.975)*iadl_error)
gen iadl_ub = invlogit(xb_iadl+invnormal(0.975)*iadl_error)


levelsof yr_time_from_af, local(levels)
tempname output
quietly{
postfile `output' yr mean_adl adl_lb adl_ub mean_iadl iadl_lb iadl_ub using results_nostroke, replace
foreach i of local levels {

	sum prob_adl if yr_time_from_af ==`i'
		scalar year = `i'
		scalar mean_adl = r(mean)
	sum adl_lb if yr_time_from_af ==`i'
		scalar mean_adl_lb = r(mean)
	sum adl_ub if yr_time_from_af ==`i'
		scalar mean_adl_ub = r(mean)
	
	sum prob_iadl if yr_time_from_af ==`i'
		scalar mean_iadl = r(mean)
	sum iadl_lb if yr_time_from_af ==`i'
		scalar mean_iadl_lb = r(mean)
	sum iadl_ub if yr_time_from_af ==`i'
		scalar mean_iadl_ub = r(mean)
	
	sum prob_nh if yr_time_from_af ==`i'
		scalar mean_nh = r(mean)
	sum nh_lb if yr_time_from_af ==`i'
		scalar mean_nh_lb = r(mean)
	sum nh_ub if yr_time_from_af ==`i' 
		scalar mean_nh_ub = r(mean)
	
	post `output' (year) (mean_adl) (mean_adl_lb) (mean_adl_ub) (mean_iadl) (mean_iadl_lb) (mean_iadl_ub) 
	}	
}
postclose `output'

/** burden of disabilility **/
sort hhidpn 

gen adl_disability = 1- prob_adl
gen iadl_disability = 1- prob_iadl

collapse (sum) adl_disability, by (hhidpn)
gen burden_adl = adl_disability*0.2
sum burden_adl 
// 	use "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 weights.dta", clear
// 	rename *, lower
//  	save "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 weights.dta", replace
	merge 1:1 hhidpn using "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 weights.dta"
	mean burden_adl 
	svyset raehsamp [pweight=wtcrnh], strata(raestrat)
	svy: mean burden_adl  /*5.0*/

collapse (sum) iadl_disability, by (hhidpn)
sum iadl_disability  /*26.05221 is the mean; 26.05221*0.2 = 5.210442*/
gen burden_iadl = iadl_disability*0.2
	merge 1:1 hhidpn using "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 weights.dta"
	mean burden_iadl 
	svyset raehsamp [pweight=wtcrnh], strata(raestrat)
	svy: mean burden_iadl /*5.5*/



/**********************************************/
/*** (2) grid - assuming stroke at fixed time**/
/**********************************************/

/* This creates red lines Figure 1 */
use "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 gridFixedStroke.dta", clear 

drop if original_data==1
// gen adl_indep = .
// gen iadl_indep=. 
// gen next_nh=.

estimate use 10222020_Adl
predict xb_adl, xb
predict adl_error, stdp
gen prob_adl = invlogit(xb_adl)
gen adl_lb = invlogit(xb_adl-invnormal(0.975)*adl_error)
gen adl_ub = invlogit(xb_adl+invnormal(0.975)*adl_error)

estimate use 10222020_iAdl
predict xb_iadl, xb
predict iadl_error, stdp
gen prob_iadl = invlogit(xb_iadl)
gen iadl_lb = invlogit(xb_iadl-invnormal(0.975)*iadl_error)
gen iadl_ub = invlogit(xb_iadl+invnormal(0.975)*iadl_error)

levelsof yr_time_from_af, local(levels)
tempname output
quietly{
postfile `output' yr mean_adl adl_lb adl_ub mean_iadl iadl_lb iadl_ub using results_fixedstroke, replace
foreach i of local levels {

	sum prob_adl if yr_time_from_af ==`i'
		scalar year = `i'
		scalar mean_adl = r(mean)
	sum adl_lb if yr_time_from_af ==`i'
		scalar mean_adl_lb = r(mean)
	sum adl_ub if yr_time_from_af ==`i'
		scalar mean_adl_ub = r(mean)
	
	sum prob_iadl if yr_time_from_af ==`i'
		scalar mean_iadl = r(mean)
	sum iadl_lb if yr_time_from_af ==`i'
		scalar mean_iadl_lb = r(mean)
	sum iadl_ub if yr_time_from_af ==`i'
		scalar mean_iadl_ub = r(mean)
	
	sum prob_nh if yr_time_from_af ==`i'
		scalar mean_nh = r(mean)
	sum nh_lb if yr_time_from_af ==`i'
		scalar mean_nh_lb = r(mean)
	sum nh_ub if yr_time_from_af ==`i' 
		scalar mean_nh_ub = r(mean)
	
	post `output' (year) (mean_adl) (mean_adl_lb) (mean_adl_ub) (mean_iadl) (mean_iadl_lb) (mean_iadl_ub) 
	}	
}
postclose `output'


