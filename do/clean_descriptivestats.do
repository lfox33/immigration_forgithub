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

//drop if speakeng==0  //Tara doesn't want to drop kids under 5 so I need to generate a school denominator instead of dropping.
gen denom_speakeng=0
replace denom_speakeng=1 if speakeng>0

//drop if school==0   //same issue here.generate a school denominator instead of dropping
gen denom_school=0
replace denom_school=1 if school>0

//generating a education denominator
gen denom_educd=0
replace denom_educd=1 if educd>1

//gen no education no school denominator for 25

gen denom_noednosch25=0
replace denom_noednosch25=1 if educd>1 & school>0 & age>24

//gen no education no english denom for 25
gen denom_noednoeng25=0
replace denom_noednoeng25=1 if educd>1 & speakeng>0 & age>24

gen denom_kidnoeng=0
replace denom_kidnoeng=1 if inrange(age, 5, 17) & speakeng>0

tab poverty age if age<5
//drop if poverty==0 // generate a poverty denominator instead of dropping
gen denom_poverty=0
replace denom_poverty=1 if poverty>0




*place of origin recode
gen pl_mexico=0
gen pl_china=0 //se I am pulling out china from east asia.
gen pl_asia_east_se_noch=0
gen pl_asia_india_sw=0
gen pl_oceania=0
gen pl_europe_inclRUS=0
gen pl_canada_otherNA=0
gen pl_caribbean=0
gen pl_america_central_nomex=0
gen pl_america_south=0
gen pl_mena=0
gen pl_africa_w=0
gen pl_africa_e=0
gen pl_africa_c=0
gen pl_africa_s=0
gen pl_unitedstates=0
gen pl_other=0

replace pl_unitedstates=1 if bpld<12000  
replace pl_canada_otherNA=1 if inrange(bpld,15000,19900)
replace pl_mexico=1 if bpld==20000
replace pl_america_central_nomex=1 if inrange(bpld,21000,21090)
replace pl_caribbean=1 if inrange(bpld,25000,26095) 
replace pl_america_south=1 if inrange(bpld,30000,30091) 
replace pl_europe_inclRUS=1 if inrange(bpld,40000,49900) 
replace pl_china=1 if inrange(bpld, 50000, 50040) //china incl hong kong,macau, mongolia, taiwan 
replace pl_asia_india_sw=1 if inrange(bpld,52100,52150) | inrange(bpld, 52300, 52400) //moving afghanistan and iran to MENA don't include india 
replace pl_asia_east_se_noch=1 if inrange(bpld,50100,50900)
replace pl_mena=1 if inrange(bpld,53000,54700)  | inrange(bpld,60010,60019)| bpld==52200 | bpld==52000
replace pl_africa_w=inrange(bpld,60020,60039)
replace pl_africa_e=inrange(bpld,60040,60066)
replace pl_africa_c=inrange(bpld,60070,60082)
replace pl_africa_s=inrange(bpld,60090,60096)
replace pl_oceania=1 if inrange(bpld,70000,71090) 
replace pl_other=1 if bpld==29900 | bpld==60099 |bpld==59900
//29900 Americas NS
//60099 Africa NA
//59900 Asia NA
//80000 to 99900 unknown/uninhabited.

gen bp_USborn=0
gen bp_otherNA=0
gen bp_CentralAmericaCarib=0
gen bp_SouthAmerica=0
gen bp_Europe=0
gen bp_EastAsia=0
gen bp_SouthAsia=0
gen bp_MiddleEast=0
gen bp_Africa=0
gen bp_Oceania=0
gen bp_Other=0


replace bp_USborn=1 if inrange(bpl,1,120)
replace bp_otherNA=1 if inrange(bpl,150,199)
replace bp_CentralAmericaCarib=1 if inrange(bpl,200,299)
replace bp_SouthAmerica=1 if inrange(bpl,300,300)
replace bp_Europe=1 if inrange(bpl,400,499)
replace bp_EastAsia=1 if inrange(bpl,500,509)
replace bp_SouthAsia=1 if inrange(bpl,510,524)
replace bp_MiddleEast=1 if inrange(bpl,530,547)
replace bp_Africa=1 if inrange(bpl,600,600)
replace bp_Oceania=1 if inrange(bpl,700,710)
replace bp_Other=1  if inrange(bpl,800,999)
 



///note labforce==0 is NA
gen ilf=0 
replace ilf=1 if labforce==2



tab age, m //double check
gen count=1  
//Dummy for Age 5+ 
gen age5plus=0
replace age5plus=1 if inrange(age,5,99)
//Dummy for Age 5-17 
gen age5to17=0
replace age5to17=1 if inrange(age,5,17)
//Dummy for Age 25+ 
gen age25plus=0
replace age25plus=1 if inrange(age,25,99)
//Dummy for age 18 to 34, lauren and I discussed various ways to recode the age variable to see what's going on after 17, also considering that immigrants tend to be younger.

gen age18to34=0
replace age18to34=1 if inrange(age,18,34)

gen age25to34=0
replace age25to34=1 if inrange(age,25,34)

gen age18to24=0
replace age18to24=1 if inrange(age,18,24)


//create new education and work variable for lauren.
///I neeed to redo this if we aren't dropping NAs 
gen inschool=0   
replace inschool=1 if school==2 

gen notinschool=0
replace notinschool=1 if school==1

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

//yrimmig when 0 is NA
//citizen 0 is NA, 1 is born abroad of american parents, 2 is naturalized citizen, 3 is not a citizen...please note that NA is not foreign born.
//foreign born via nativity is not available so I construct from birthplace (bpl) into a binary


tab bpl, m
gen foreign=.
replace foreign=0 if inrange(bpl, 1, 120)  //please note 100 to 120 are US territories
replace foreign=1 if inrange(bpl, 150, 999)
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

replace foreign10yr=1 if foreign==1 & yrimmig>2005 & multyear==2015
replace foreign10yr=1 if foreign==1 & yrimmig>2006 & multyear==2016
replace foreign10yr=1 if foreign==1 & yrimmig>2007 & multyear==2017
replace foreign10yr=1 if foreign==1 & yrimmig>2008 & multyear==2018
replace foreign10yr=1 if foreign==1 & yrimmig>2009 & multyear==2019

gen nohcov=0
replace nohcov=1 if hcovany==1

gen foreign_nohcov=0
replace foreign_nohcov=1 if foreign==1 & nohcov==1

gen foreign5yr_nohcov=0
replace foreign5yr_nohcov=1 if foreign5yr==1 & nohcov==1

gen foreign10yr_nohcov=0
replace foreign10yr_nohcov=1 if foreign10yr==1 & nohcov==1


///fix year immigration var by checking tab w/ . is considered very large
/*tab citizen, nolab m  
gen foreign2010=.
replace foreign2010=0 if foreign==0 
replace foreign2010=1 if foreign==1 & yrimmig>2009 
*tab foreign2010

gen foreign2015=.
replace foreign2015=0 if foreign==0
replace foreign2015=1 if foreign==1 & yrimmig>2014

gen noncitizen=0
replace noncitizen=1 if citizen==3
*/

//summ noncitizen
//tab speakeng
//tab speakeng, nolab m 
//0 is missing values.
gen foreigneng=0 
replace foreigneng=1 if  age>4 & foreign==1 & speakeng==1 | inrange(speakeng,5,6)
///corrected speakeng range...1 is doesn't speake eng, 5 is well, 6 is not well. dont use: 3 only english, 4 sp eng very well.
gen anyloweng=0 
replace anyloweng=1 if age>4 & speakeng==1 | inrange(speakeng,5,6)  
///making this because we don't care if the kid is foreign born or native born, just if the family is.
/*
Dummy for no 4-year college degree (define for age 25+) 
Dummy for 4-year college degree (define for 25+) 
Dummy for foreign born & no college degree (define for 25+) 
Dummy for foreign born & entered since 2010 & no college degree (define for 25+) 
Dummy for foreign born & entered since 2015 & no college degree (define for 25+) 
Dummy for foreign born & does not speak English "very well" & no college degree (define for 25+) 
Dummy for Age 5-17 & does not speak English very well 
Dummy for Under 200% of poverty line 
SE: ADDING DUM FOR 200% and Foreign Born.
Dummy for Kid Age 5-17 & Under 200% of poverty line 
*/
//tab educd, nolab m
//tab educd
//for the educd variable n/a is 1 so the educ codes should be okay unless I should drop out those without an educ input?
gen tw5_lessBA=0 
replace tw5_lessBA=1 if age>24 & inrange(educd,2,81)

gen tw5_BAplus=0 
replace tw5_BAplus=1 if age>24 & educd>100

gen tw5_lessBA_foreign=0 
replace tw5_lessBA_foreign=1 if tw5_lessBA==1 & foreign==1

gen tw5_lessBA_native=0 
replace tw5_lessBA_native=1 if tw5_lessBA==1 & native==1


gen tw5_lessBA_foreignnosch=0 
replace tw5_lessBA_foreignnosch=1 if tw5_lessBA==1 & foreign==1 & inschool==0

gen tw5_lessBA_nativenosch=0 
replace tw5_lessBA_nativenosch=1 if tw5_lessBA==1 & native==1 & inschool==0

gen tw5_BAplus_foreign=0 
replace tw5_BAplus_foreign=1 if tw5_BAplus==1 & foreign==1 

gen tw5_lessBA_foreign10yr=0 
replace tw5_lessBA_foreign10yr=1 if tw5_lessBA==1 & foreign10yr==1

gen tw5_lessBA_foreign5yr=0 
replace tw5_lessBA_foreign5yr=1 if tw5_lessBA==1 & foreign5yr==1

gen tw5_lessBA_noeng=0 
replace tw5_lessBA_noeng=1 if tw5_lessBA==1 & foreigneng==1

gen tw5_lessBA_10yr_nosch=0
replace tw5_lessBA_10yr_nosch=1 if tw5_lessBA_foreign10yr==1 & notinschool==1

gen tw5_lessBA_5yr_nosch=0
replace tw5_lessBA_5yr_nosch=1 if tw5_lessBA_foreign5yr==1 & notinschool==1

///poverty=0 is n/a 
gen pov200=.
replace pov200=0 if  poverty>199
replace pov200=1 if inrange(poverty,1,199)
//drop if pov200==.  //dont drop N/A... 

gen pov200foreign=0
replace pov200foreign=1 if pov200==1 & foreign==1

gen kid_pov200=0
replace kid_pov200=1 if pov200==1 & inrange(age,5,17)

**# houshold level calcs
/* 
Use egen to calculate at the household level: 
Any foreignborn person in hh 
Any foreignborn person arriving since 2010 in hh 
Any foreignborn person arriving since 2015 in hh 
Any person 25+ in hh 
*/
//duplicates report serial pernum
//whoever is FCing please double check my household identifier


sort serial
by serial: egen c_foreign=sum(foreign)
by serial: egen c_foreign10yr=sum(foreign10yr)
by serial: egen c_foreign5yr=sum(foreign5yr)
by serial: egen c_age25plus=sum(age25plus)
by serial: egen c_tw5_lessBA_foreign=sum(tw5_lessBA_foreign)

foreach v of varlist c_*{
by serial: gen hh_`v'=0 
by serial: replace hh_`v'=1 if `v'>0	

gen kid_hh_`v'=0
replace kid_hh_`v'=1 if age5to17==1 & hh_`v'==1  
//generates any kid foreign by hh characteristic
}



/*
Then calculate at individual level: 
Dummy for kid ages 5-17 w/ any foreign born person in hh 
Dummy for kid ages 5-17 w/ any foreign born person in hh arriving since 2010 se updated to 10 year
Dummy for kid ages 5-17 w/ any foreign born person in hh arriving since 2015 se update to 10year
Dummy for kid ages 5-17  who speaks English less than very well w/ any foreign born person in hh 
Dummy for kid ages 5-17 w/ any foreign born person and nobody 25+ with college degree in hh 
Dummy for Kid Age 5-17 & Under 200% of poverty line & and any foreign-born person in hh 
*/

gen kid_noeng_foreignhh=0
replace kid_noeng_foreignhh=1 if anyloweng==1 & kid_hh_c_foreign==1 //this should be fixed now with the anyloweng variabl


gen kid_foreignhh_200pov=0
replace kid_foreignhh_200pov=1 if kid_hh_c_foreign==1 & kid_pov200==1

save clean_immigration, replace

**# kid number calcs for wendy
///add number of kids in addition to if there is one at all.

by serial: egen c_hhkids=sum(age5to17)
by serial: egen c_hhsize=sum(age5plus)
preserve
by serial: keep if c_hhkids>0
collapse (mean) c_hhkids [pw=perwt], by(foreign)
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\calcsforWELB", sheet(kidnumber_perwt, modify) firstrow(var) keepcellfmt
restore
preserve
by serial: keep if c_hhsize>0
collapse (mean) c_hhsize [pw=perwt], by(foreign)
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\calcsforWELB", sheet(hhsize, modify) firstrow(var) keepcellfmt
restore

**# multigen
//recodeing the multgen d variables
//
gen generations=0
replace generations=1 if multgend==10
replace generations=2 if multgend==21
replace generations=3 if multgend==22
replace generations=4 if multgend==23
replace generations=5 if inrange(multgend,31,32)
tab generations
# delimit ;
label define genbinlbl
	1 "1 generation"
	2 "2 generation: adult and kids"
	3 "2 generation: younger generation is married or 17+"
	4 "2 generation: householder and nonadjacent gen (grandchildren)"
	5 "3+ generations"
	;
# delimit cr
label values generations genbinlbl

preserve
gen total=1
collapse (count) total [pw=perwt], by(generations foreign)
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\calcsforWELB", sheet(generations, modify) firstrow(var) keepcellfmt
restore

**# education and in school
preserve
drop if age18to34!=1
drop if labforce==0
drop if school==0
gen total=1
collapse (count) total [pw=perwt], by(edu_lfp age18to24 armedforces foreign)
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\calcsforWELB", sheet(ilfedu, modify) firstrow(var) keepcellfmt
restore




**# Place of origin figures
//doing place of origin and working/notworking figs for Lauren

foreach pl of varlist pl_* {
gen fb_`pl'=0
replace fb_`pl'=1 if `pl'==1 & foreign==1

gen fb10_`pl'=0
replace fb10_`pl'=1 if `pl'==1 & foreign10yr==1

gen fb5_`pl'=0
replace fb5_`pl'=1 if `pl'==1 & foreign5yr==1



}

//doing same thing for less detailed cats
foreach bp of varlist bp_* {
gen for_`bp'=0
replace for_`bp'=1 if `bp'==1 & foreign==1

gen for10_`bp'=0
replace for10_`bp'=1 if `bp'==1 & foreign10yr==1

gen for5_`bp'=0
replace for5_`bp'=1 if `bp'==1 & foreign5yr==1



}

//Check to make sure you have all inputs needed for PUMA-level stats below.

save clean_immigration, replace


//collapsing place of origin for mondrian
preserve
use clean_immigration
collapse (sum) fb_pl_* foreign  [pw=perwt], by(year)
foreach s of varlist fb_pl_* {
	gen s_`s'=(`s'/foreign)*100
}
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\foreignorigin", sheet(all, modify) firstrow(var) keepcellfmt
restore

preserve
use clean_immigration
collapse (sum) fb10_pl_* foreign10yr  [pw=perwt], by(year)
foreach s of varlist fb10_pl_* {
	gen s_`s'=(`s'/foreign10yr)*100
}
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\foreignorigin", sheet(foreign10yr, modify) firstrow(var) keepcellfmt
restore

preserve
use clean_immigration
collapse (sum) fb5_pl_* foreign5yr  [pw=perwt], by(year)
foreach s of varlist fb5_pl_* {
	gen s_`s'=(`s'/foreign5yr)*100
}
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\foreignorigin", sheet(foreign5yr, modify) firstrow(var) keepcellfmt
restore


//now for less detailed cats
preserve
use clean_immigration
collapse (sum) for_bp_* foreign  [pw=perwt], by(year)
foreach s of varlist for_bp_* {
	gen s_`s'=(`s'/foreign)*100
}
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\lessdet_foreignorigin", sheet(all, modify) firstrow(var) keepcellfmt
restore

preserve
use clean_immigration
collapse (sum) for10_bp_* foreign10yr  [pw=perwt], by(year)
foreach s of varlist for10_bp_* {
	gen s_`s'=(`s'/foreign10yr)*100
}
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\lessdet_foreignorigin", sheet(foreign10yr, modify) firstrow(var) keepcellfmt
restore

preserve
use clean_immigration
collapse (sum) for5_bp_* foreign5yr [pw=perwt], by(year)
foreach s of varlist for5_bp_* {
	gen s_`s'=(`s'/foreign5yr)*100
}
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\lessdet_foreignorigin", sheet(foreign5yr, modify) firstrow(var) keepcellfmt
restore


**# generate GEOID and pumatotract
tostring puma, gen(strpuma) format(%05.0f)
gen str3 strstatefip = string(statefip,"%02.0f")
egen geoid=concat(strstatefip strpuma)
destring geoid, replace
gen str3 strcountyfip = string(countyfip, "%03.0f")
egen pumatotract=concat(strstatefip strcountyfip strpuma)
destring pumatotract,replace
save clean_immigration, replace
use clean_immigration






**# gen shares 
//Use the collapse command with person weights to calculate by PUMA: 
*total pop 
*Share of Pop that is foreign-born 
*Share of Pop that is foreign-born and entered since 2010 
*Share of Pop that is foreign-born and entered since 2015 
*Share of Pop (age 5+) that speaks English less than "very well" & foreign born 
*Share of Pop (age 25+) that is foreign-born 
*Share of Pop (age 25+) that is foreign-born & no 4-year college degree 
*Share of Pop (age 25+) that is foreign-born and entered since 2010 & no 4-year college degree 
*Share of Pop (age 25+) that is foreign-born and entered since 2015 & no 4-year college degree 
*Share of Pop (age 25+) that speaks English less than "very well" & no 4-year college degree 
*Share of Kids ages 5-17 with any foreign-born person in HH 
*Share of Kids ages 5-17 with any person in HH who is foreign-born and entered since 2010 (check arrival date info) 
*Share of Kids ages 5-17 with any person in HH who is foreign-born and entered since 2015 (check arrival date info) 
*Share of kids ages 5-17 that speak English less than "very well" with any person in HH who is foreign-born 
*Share of Kids ages 5-17 with any foreign-born person in HH & and nobody with college degree in HH 
*Share of pop <200% poverty 
*Share of pop <200% poverty & foreign-born 
*Share of kids 5-17 <200% poverty & living with any foreign-born person in HH 
//I'm removing state fips since we haven't been using them

foreach geo of varlist geoid {
foreach v of varlist foreign foreign10yr foreign5yr foreign_nohcov foreign5yr_nohcov foreign10yr_nohcov {
use clean_immigration
preserve
gen total=1  
//this time total will have everyone since I'm not worried about missings for these variables.
collapse (sum) `v' total  [pw=perwt], by(`geo')
gen s_`v'=`v'/total
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt
//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'.pdf", replace

restore

}
}
//just doing poverty variables to handle missings
foreach geo of varlist geoid {
foreach v of varlist pov200 pov200foreign {
use clean_immigration
preserve
gen total=1
drop if pov200==.  
//I think I have to drop the N/A otherwise it's going to do something weird when I sum the na's in pov200....
collapse (sum) `v' total  [pw=perwt], by(`geo')
gen s_`v'=`v'/total
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt
//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'.pdf", replace

restore

}
}
//SE redo age restricted collapses. 
/*
foreach geo of varlist GEOID {
foreach v of varlist tw5* {
use clean_immigration
preserve
collapse (sum) `v' age25plus  [pw=perwt], by(`geo')
gen s_`v'=`v'/age25plus
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt
histogram s_`v'
graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'.pdf", replace

restore

}
}*/

//redo tw5 collapses to make sure not dividing by N/As



foreach geo of varlist geoid {
foreach v of varlist tw5_lessBA_foreign tw5_lessBA_native tw5_lessBA_5yr_nosch tw5_lessBA_10yr_nosch tw5_lessBA_foreignnosch tw5_lessBA_nativenosch {
use clean_immigration
preserve
collapse (sum) `v' denom_noednosch25 [pw=perwt], by(`geo')
gen s_`v'=`v'/denom_noednosch25
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt
//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'.pdf", replace

restore

}
}

foreach geo of varlist geoid {
foreach v of varlist tw5_lessBA_noeng {
use clean_immigration
preserve
collapse (sum) `v' denom_noednoeng25 [pw=perwt], by(`geo')
gen s_`v'=`v'/denom_noednoeng25
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt
//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'.pdf", replace

restore

}
}


**# kid collapses by puma


foreach geo of varlist geoid {
foreach v of varlist kid_noeng_foreignhh {
use clean_immigration
preserve
collapse (sum) `v' denom_kidnoeng  [pw=perwt], by(`geo')
gen s_`v'=`v'/denom_kidnoeng
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt

//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'.pdf", replace
restore

}
}

///doing this variable both ways as instructed 5-17 and 5-17pov200
foreach geo of varlist geoid {
foreach v of varlist kid_foreignhh_200pov {
use clean_immigration
preserve
drop if pov200==.
collapse (sum) `v' kid_pov200  [pw=perwt], by(`geo')
gen s_`v'=`v'/kid_pov200
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v'_200, modify) firstrow(var) keepcellfmt

//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'_200.pdf", replace
restore

}
}
foreach geo of varlist geoid {
foreach v of varlist kid_foreignhh_200pov {
use clean_immigration
preserve
drop if pov200==.
collapse (sum) `v' age5to17 [pw=perwt], by(`geo')
gen s_`v'=`v'/age5to17
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v'_5to17, modify) firstrow(var) keepcellfmt

//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'_200.pdf", replace
restore

}
}

**# kid collapses by pumatotract
foreach geo of varlist pumatotract {
foreach v of varlist kid_noeng_foreignhh {
use clean_immigration
preserve
//county not identifiable from public use data is 0
drop if countyfip==0  

collapse (sum) `v' denom_kidnoeng  [pw=perwt], by(`geo')
gen s_`v'=`v'/denom_kidnoeng
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v', modify) firstrow(var) keepcellfmt

//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'.pdf", replace
restore

}
}

///doing this variable both ways as instructed 5-17 and 5-17pov200
foreach geo of varlist pumatotract {
foreach v of varlist kid_foreignhh_200pov {
use clean_immigration
preserve
//county not identifiable from public use data is 0
drop if countyfip==0  
drop if pov200==.
collapse (sum) `v' kid_pov200  [pw=perwt], by(`geo')
gen s_`v'=`v'/kid_pov200
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v'_200, modify) firstrow(var) keepcellfmt

//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'_200.pdf", replace
restore

}
}
foreach geo of varlist pumatotract {
foreach v of varlist kid_foreignhh_200pov {
use clean_immigration
preserve
//county not identifiable from public use data is 0
drop if countyfip==0  
drop if pov200==.
collapse (sum) `v' age5to17 [pw=perwt], by(`geo')
gen s_`v'=`v'/age5to17
export excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesby`geo'_5yr.xlsx", sheet(`v'_5to17, modify) firstrow(var) keepcellfmt

//histogram s_`v'
//graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\histograms\`geo'_`v'_200.pdf", replace
restore

}
}

**# summary stats

use clean_immigration

foreach v in {
import excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesbygeoid_5yr.xlsx", sheet("`v'") firstrow clear
summ s*,detail
}

///estout is good for summ tabs.

/*
**# Bookmark #2
twoway histogram s_`v'
graph export `geo'_`v'.pdf
**# Bookmark #1
*/
/* 
Then: 


Please make histogram distributions of each of these variables across PUMAs  
Please make table of summary stats across Pumas using summ command. 
 
Then use saved individual-level dataset to make state-level version. 


Make Excel table of all outcomes showing each state
/*

**# merge with tract
import excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\2010_Census_Tract_to_2010_PUMA.xlsx", firstrow clear
save tracttopuma
use tracttopuma
merge 1:m statefip countyfip puma using clean_immigration
//drop if _merge!=3
save pumatractmerge