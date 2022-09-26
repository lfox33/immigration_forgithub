clear all
cd S:\Hamilton_Data\2022\Tara_immigration\immigration\data
use usa_00017
**#gen dummy
/*Please use well-commented do file 
 //WE'RE GOING TO USE THE 5 YEAR FILE.
PUMA using IPUMS-ACS for 2019: 
usa.ipums.org 
*/
//At Individual level, drop institutional/group quarters. Then calculate: 
//Count variable (=1 for everyone)
//drop inst/group quarters
drop if inrange(gqtype,1,9) 
drop if age==. 
tab age speakeng
//80000 to 99900 unknown/uninhabited birthplace dropping
drop if inrange(bpld, 80000,99900) 
//dropping unused to make run faster
drop hcovpriv hinsemp hinspur hinstri hcovpub hinscaid hinscare hinsva hinsihs hcovany2 hcovpriv2 hinsemp2 hinspur2 hinstri2 hcovpub2 hinscaid2 hinscare2 hinsva2 

drop inc* rac* pred*
//drop if inrange(empstatd,14,15) //drop armed forces?
//drop if labforce==0  //drop if laborforce status is NA?

//I had previously dropped laborforce==0 which was a mistake. It removes all of the children...when I do the collapse on the laborforce variable I need to just restrict to the age bins and ignore all else because the missing values are kids.


//drop if school==0   //same issue here.generate a school denominator instead of dropping
gen denom_school=0
replace denom_school=1 if school>0 

//LF comment: school = 1 if respondent is not in school, school = 2 if respondent is in school, so I belive that this code should be: replace denom_school = 1 if school == 2.

//generating a education denominator
gen denom_educd=0
replace denom_educd=1 if educd>1


///note labforce==0 is NA
gen ilf=0 
replace ilf=1 if labforce==2



tab age, m //double check
gen count=1  

//Dummy for Age 5-17 
gen age5to17=0
replace age5to17=1 if inrange(age,5,17)


//generating over 18
gen age18plus=0
replace age18plus=1 if age>18


//create new education and work variable for lauren.
///I neeed to redo this if we aren't dropping NAs 
gen inschool=0   
replace inschool=1 if school==2 

gen notinschool=0
replace notinschool=1 if school==1

//LF Comment: These dummies look good to go. 

//yrimmig when 0 is NA
//citizen 0 is NA, 1 is born abroad of american parents, 2 is naturalized citizen, 3 is not a citizen...please note that NA is not foreign born.
//foreign born via nativity is not available so I construct from birthplace (bpl) into a binary


tab bpl, m
gen foreign=.
replace foreign=0 if inrange(bpl, 1, 120)  //please note 100 to 120 are US territories
replace foreign=1 if inrange(bpl, 150, 999)

//LF comment: bpl == 999 is if birthplace is missing. I don't know if you want include these people here. 

tab foreign,m  //no missing should be ok.

gen native=0
replace native=1 if foreign==0 //note native would include us territories.

/*Dummy for foreign born 
Dummy for foreign born & entered since 2010  

Dummy for foreign born & entered since 2015 
Dummy for foreign born & does not speak English "very well" (define for age 5+)


 */
//SE: do we want to add a new dummmy for each group that has been in the US for more than 5 years/10 years now that we have the 5 year file?
//I can use multyear to do this for the 2015-2019 years using yrimmig  
**# year of immigration and citizenship dummy

tab yrimmig, nolab m //note that yimmig 0 is n/a, so what I've done should be ok.
tab multyear, nolab m //multyear ok
gen foreign5yr=0
gen foreign10yr=0

replace foreign5yr=1 if foreign==1 & yrimmig>2009 & multyear==2015
replace foreign5yr=1 if foreign==1 & yrimmig>2010 & multyear==2016
replace foreign5yr=1 if foreign==1 & yrimmig>2011 & multyear==2017
replace foreign5yr=1 if foreign==1 & yrimmig>2012 & multyear==2018
replace foreign5yr=1 if foreign==1 & yrimmig>2013 & multyear==2019


gen nohcov=0
replace nohcov=1 if hcovany==1


gen foreign5yr_nohcov=0
replace foreign5yr_nohcov=1 if foreign5yr==1 & nohcov==1

//generating 18 to 22 lessBA in school
gen dependent=0
replace dependent=1 if inrange(age, 18, 22) & inrange(educd,2,81) & inschool==1

//LF comment: The education variable on the IPUMS website specifies that a bachelor's degree is coded as 101, so it might be 2, 100.

gen nondep5yrnoba18plus=0 
replace nondep5yrnoba18plus=1 if age>18 & inrange(educd,2,81) & dependent!=1 & foreign5yr==1

//LF comment: same education comment as above. 

//keeping these because I think we might want to come back to this with different age groups.
/*
gen noedu_nowork=0
gen edu_work=0
gen edu_nowork=0
gen noedu_work=0

replace noedu_nowork=1 if ilf==0 & notinschool==1 & age18to34==1
replace edu_work=1 if ilf==1 & inschool==1 & age18to34==1
replace edu_nowork=1 if ilf==0 & inschool==1 & age18to34==1
replace noedu_work=1 if ilf==1 & notinschool==1 & age18to34==1


//please note that I restrict to the full range here, and then I collapse to one of the age groups later in the file.

gen edu_lfp=0
replace edu_lfp=1 if ilf==0 & notinschool==1 & age18to34==1
replace edu_lfp=2 if ilf==1 & inschool==1 & age18to34==1
replace edu_lfp=3 if ilf==0 & inschool==1 & age18to34==1
replace edu_lfp=4 if ilf==1 & notinschool==1 & age18to34==1
tab edu_lfp
# delimit ;
label define edulfpbinlbl
	0 "Not age 18-34"
	1 "Not in the labor force & not in school"
	2 "Both in the labor force & in school"
	3 "In school but not in the labor force"
	4 "In the labor force but not in school"
	;
# delimit cr
label values edu_lfp edulfpbinlbl




gen armedforces=0
replace armedforces=1 if inrange(empstatd,14,15)
*/


save clean_immigration_narrow, replace




**# generate GEOID and pumatotract
tostring puma, gen(strpuma) format(%05.0f)
gen str3 strstatefip = string(statefip,"%02.0f")
egen geoid=concat(strstatefip strpuma)
destring geoid, replace
gen str3 strcountyfip = string(countyfip, "%03.0f")
egen pumatotract=concat(strstatefip strcountyfip strpuma)
destring pumatotract,replace
save clean_immigration_narrow, replace
use clean_immigration_narrow


//LF comment: Looks good! 





**# gen shares 


foreach geo of varlist geoid {
foreach v of varlist nondep5yrnoba18plus {
use clean_immigration_narrow
preserve
//this time total will have everyone since I'm not worried about missings for these variables.
collapse (sum) `v' age18plus  [pw=perwt], by(`geo')
gen s_`v'=(`v'/age18plus)*100
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_AEI.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt

restore

}
}
