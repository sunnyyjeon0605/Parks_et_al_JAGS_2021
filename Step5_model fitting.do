
use "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\cohort_19_10222020", clear 

rename *, lower

gen adl_indep = 1- next_adl
gen iadl_indep = 1-next_iadl

// gen yr_time_from_af = time_from_af_to_outcome/365.25
// gen yr_int = floor(yr_time_from_af)

replace ever_stroke=0 if ever_stroke==.
gen female = ragender-1

/**longitudinal analysis */
xtset hhidpn int_dt


/*--ADL */
xtlogit adl_indep i.ever_stroke##c.yr_time_from_af age_at_outcome female any_heartf any_hibpe any_diabe any_vasce any_cancre stroke_base ///
				married livealone  i.race_eth highschool_grad proxy,  /// 
				re or		
// estimate save 09232020_Adl, replace
estimate save 10222020_Adl, replace

xtlogit adl_indep i.ever_stroke##c.yr_time_from_af,  /// 
				re or		

			/* 08052020 John's comment: */
			/* To get pred prob, use logit; 
		// 	 margins is not goot at time-designed variables having spline patterns (check 'postrc' for details, 'margincountplot' )
		// 	 So solutions? : (1) Mr. Average (never had stroke and plot over time) vs. Mr.Average (who had a stroke at the average time (4.3))
		// 						 (2) Get everybody's prediction as it is vs. Get everybody's prediction as they didn't have stroke vs.
		// 						     (get those who had stroke at 4.3 yr?)
		// 						>> Let's do -- use the grand mean for covariates; replace ever_stroke=0 for all and get the pred. prob; 
		// 						Then replace ever_stroke */
								*/
			
		/*08/06/2020 John's solution (email on 08/05/2020)*/ 

		// import delimited "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\grid_id_time.csv", clear 
		// drop v1 
		// rename id_mx hhidpn
		// rename time yr_time_from_af
		// save "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\grid.id_time.dta", replace	
		//	
		// use "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\cohort_f0_08042020", clear 
		// rename *, lower
		// gen yr_time_from_af = time_from_af_to_outcome/365.25
		// sort hhidpn yr_time_from_af
		// merge m:m * hhidpn yr_time_from_af using "V:\Health and Retirement Study\Sun\Anna Park\SAS interim\grid.id_time.dta"
		//

/*--IADL */
xtlogit iadl_indep i.ever_stroke##c.yr_time_from_af age_at_outcome female any_heartf any_hibpe any_diabe any_vasce any_cancre stroke_base ///
				married livealone  i.race_eth highschool_grad proxy,  /// 
				or
// estimate save 08122020_iAdl, replace
estimate save 10222020_iAdl, replace
xtlogit iadl_indep i.ever_stroke##c.yr_time_from_af ,  /// 
				re or
