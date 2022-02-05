
/** This code is to run bootstrapping to provide the confidence interval for the "drop" in Figure 1 
where fixedstroke and nostroke diverge. "bscohort_3" was created in SAS using the analytic dataset. The code is in Step7_bootstrap sample.sas**/

clear all

cd "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\logistic_new_cohort"


tempname nostrokeburden
postfile `nostrokeburden' adl iadl using nostroke_burden, replace
tempname popstrokeburden
postfile `popstrokeburden' adl iadl using popstroke_burden, replace

forvalue j=1/50{

use "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\10222020 bscohort_3.dta", clear 

rename *, lower

gen adl_indep = 1- next_adl
gen iadl_indep = 1-next_iadl

// gen yr_time_from_af = time_from_af_to_outcome/365.25
// gen yr_int = floor(yr_time_from_af)

replace ever_stroke=0 if ever_stroke==.
gen female = ragender-1

/**longitudinal analysis */
keep if sampnum==`j'
xtset boot_id int_dt

quietly xtlogit adl_indep i.ever_stroke##c.yr_time_from_af age_at_outcome female any_heartf any_hibpe any_diabe any_vasce any_cancre stroke_base ///
				married livealone  i.race_eth highschool_grad proxy,  /// 
				or		
estimate save adl, replace	

quietly xtlogit iadl_indep i.ever_stroke##c.yr_time_from_af age_at_outcome female any_heartf any_hibpe any_diabe any_vasce any_cancre stroke_base ///
				married livealone  i.race_eth highschool_grad proxy,  /// 
				or
estimate save iAdl, replace


use "\\vhasfcreap\sun\Anna Park\stroke_hrs\data\new_cohort\10222020 bs_GridNoStroke.dta", clear 
	keep if sampnum==`j'
	gen adl_indep = .
	gen iadl_indep=. 
// 	gen next_nh=.

	estimate use adl
	predict xb_adl, xb
	predict adl_error, stdp
	gen prob_adl = invlogit(xb_adl)
	gen adl_lb = invlogit(xb_adl-invnormal(0.975)*adl_error)
	gen adl_ub = invlogit(xb_adl+invnormal(0.975)*adl_error)


	estimate use iAdl
	predict xb_iadl, xb
	predict iadl_error, stdp
	gen prob_iadl = invlogit(xb_iadl)
	gen iadl_lb = invlogit(xb_iadl-invnormal(0.975)*iadl_error)
	gen iadl_ub = invlogit(xb_iadl+invnormal(0.975)*iadl_error)


	levelsof yr_time_from_af, local(levels)
	tempname output
	quietly{
	postfile `output' yr mean_adl adl_lb adl_ub mean_iadl iadl_lb iadl_ub using nostroke_`j', replace
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
	
		
		post `output' (year) (mean_adl) (mean_adl_lb) (mean_adl_ub) (mean_iadl) (mean_iadl_lb) (mean_iadl_ub)
		}	
	}
	postclose `output'
	
    quietly{
	gen adl_disability = (1- prob_adl)*0.2
	gen iadl_disability = (1- prob_iadl)*0.2
	
	collapse (sum) adl_disability iadl_disability (mean)raehsamp wtcrnh raestrat, by (boot_id)
	svyset raehsamp [pweight=wtcrnh], strata(raestrat)
	svy: mean adl_disability
	mat a = e(b)
	scalar adl_burden = a[1,1]
	
	svy: mean iadl_disability
	mat b = e(b)
	scalar iadl_burden =b[1,1]
	
	post `nostrokeburden' (adl_burden) (iadl_burden)
	}

/*** grid - fixed time stroke **/
use "\\vhasfcreap\sun\Anna Park\stroke_hrs\data\new_cohort\10222020 bs_GridFixedStroke.dta", clear 
	keep if sampnum==`j'
	replace ever_stroke=1 if yr_time_from_af>3.26 
	gen adl_indep = .
	gen iadl_indep=. 
// 	gen next_nh=.

	estimate use Adl
	predict xb_adl, xb
	predict adl_error, stdp
	gen prob_adl = invlogit(xb_adl)
	gen adl_lb = invlogit(xb_adl-invnormal(0.975)*adl_error)
	gen adl_ub = invlogit(xb_adl+invnormal(0.975)*adl_error)

	estimate use iAdl
	predict xb_iadl, xb
	predict iadl_error, stdp
	gen prob_iadl = invlogit(xb_iadl)
	gen iadl_lb = invlogit(xb_iadl-invnormal(0.975)*iadl_error)
	gen iadl_ub = invlogit(xb_iadl+invnormal(0.975)*iadl_error)

	levelsof yr_time_from_af, local(levels)
	tempname output
	quietly{
	postfile `output' yr mean_adl adl_lb adl_ub mean_iadl iadl_lb iadl_ub using fixedstroke_`j', replace
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
		
		post `output' (year) (mean_adl) (mean_adl_lb) (mean_adl_ub) (mean_iadl) (mean_iadl_lb) (mean_iadl_ub)
		}	
	}
	postclose `output'


/*** grid - pop stroke **/
use "\\vhasfcreap\sun\Anna Park\stroke_hrs\data\new_cohort\10222020 bs_GridPopStroke.dta", clear 

	keep if sampnum==`j'
	gen adl_indep = .
	gen iadl_indep=. 
// 	gen next_nh=.


	estimate use Adl
	predict xb_adl, xb
	predict adl_error, stdp
	gen prob_adl = invlogit(xb_adl)
	gen adl_lb = invlogit(xb_adl-invnormal(0.975)*adl_error)
	gen adl_ub = invlogit(xb_adl+invnormal(0.975)*adl_error)

	estimate use iAdl
	predict xb_iadl, xb
	predict iadl_error, stdp
	gen prob_iadl = invlogit(xb_iadl)
	gen iadl_lb = invlogit(xb_iadl-invnormal(0.975)*iadl_error)
	gen iadl_ub = invlogit(xb_iadl+invnormal(0.975)*iadl_error)

	levelsof yr_time_from_af, local(levels)
	tempname output
	quietly{
	postfile `output' yr mean_adl adl_lb adl_ub mean_iadl iadl_lb iadl_ub using popstroke_`j', replace
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
		
		post `output' (year) (mean_adl) (mean_adl_lb) (mean_adl_ub) (mean_iadl) (mean_iadl_lb) (mean_iadl_ub) 
		}	
	}
	postclose `output'

	quietly{
	gen adl_disability = (1- prob_adl)*0.2
	gen iadl_disability = (1- prob_iadl)*0.2
	
	collapse (sum) adl_disability iadl_disability (mean)raehsamp wtcrnh raestrat, by (boot_id)
	svyset raehsamp [pweight=wtcrnh], strata(raestrat)
	svy: mean adl_disability
	mat a = e(b)
	scalar adl_burden = a[1,1]
	
	svy: mean iadl_disability
	mat b = e(b)
	scalar iadl_burden =b[1,1]
	
	post `popstrokeburden' (adl_burden) (iadl_burden) 
	}

}
 
 postclose `popstrokeburden'
 postclose `nostrokeburden' 


/**** Confidence interval of delta (drop at 4.3 years) */

clear all 

tempname output
	postfile `output' num n_adl n_iadl f_adl f_iadl  using ci_delta, replace
	
	forvalue i=1/50{
	
	use nostroke_`i'.dta, clear
	keep if yr>2.5 & yr<2.75
	scalar n_num = `i'
	quietly sum mean_adl
	scalar n_adl = r(mean)
	quietly sum mean_iadl
	scalar n_iadl = r(mean)
	
	use fixedstroke_`i'.dta, clear
	keep if yr>2.7 & yr<2.95
	quietly sum mean_adl
	scalar f_adl = r(mean)
	quietly sum mean_iadl
	scalar f_iadl = r(mean)
	

	post `output' (n_num) (n_adl) (n_iadl)  (f_adl) (f_iadl) 
	}
	postclose `output'

	
use "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\logistic_new_cohort\ci_delta.dta", clear

gen delta_adl = n_adl- f_adl
gen delta_iadl = n_iadl- f_iadl

sum delta_adl 
sum delta_iadl 
