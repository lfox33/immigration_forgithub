cd S:\Hamilton_Data\2022\Tara_immigration\immigration\data\maps
/*ssc install spmap
ssc install shp2dta
ssc install mif2dta
*/

shp2dta using ipums_puma_2010, database(usdb) coordinates(uscoord) genid(idvar) //ipums_cpuma0010,
use usdb, clear
describe
destring GEOID, gen(geoid)
save usdb, replace

foreach v in foreign foreign10yr foreign5yr foreign_nohcov foreign5yr_nohcov foreign10yr_nohcov pov200 pov200foreign tw5_lessBA_foreign tw5_lessBA_native tw5_lessBA_5yr_nosch tw5_lessBA_10yr_nosch tw5_lessBA_foreignnosch tw5_lessBA_nativenosch tw5_lessBA_noeng kid_noeng_foreignhh {
import excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesbygeoid_5yr.xlsx", sheet("`v'") firstrow clear
save `v', replace
use `v'

merge 1:1 geoid using usdb
drop if _merge!=3

colorpalette  	#e4ffdb #427730, ipolate(5)    
local colors `r(p)'
replace s_`v' = s_`v'*100
format s_`v' %4.2f
spmap s_`v' using uscoord, id(idvar) fcolor("`colors'") ocolor(none ..) title(`v') legstyle(2) clm(quantile) cln(5)  //note here I am using standard dev instead of quantile and for some reason it wont let me break into 5 bins?
graph export "S:\Hamilton_Data\2022\Tara_immigration\immigration\data\maps\export\geoid_`v'.pdf", replace
}
//
foreach v in kid_foreignhh_200pov{
import excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesbygeoid_5yr.xlsx", sheet("`v'_200") firstrow clear
save `v', replace
use `v'
merge 1:1 geoid using usdb
drop if _merge!=3
colorpalette  	#e4ffdb #427730, ipolate(5)    
local colors `r(p)'
replace s_`v' = s_`v'*100
format s_`v' %4.2f
spmap s_`v' using uscoord, id(idvar) fcolor("`colors'") ocolor(none ..) title(Kid foreignHH poverty over 5to17pov200) legstyle(2) clm(quantile) cln(5)  //note here I am using standard dev instead of quantile and for some reason it wont let me break into 5 bins?
graph export "V:\sestep\mapexports\geoid_`v'_200.pdf", replace
}

foreach v in kid_foreignhh_200pov{
import excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesbygeoid_5yr.xlsx", sheet("`v'_5to17") firstrow clear
save `v', replace
use `v'
merge 1:1 geoid using usdb
drop if _merge!=3
colorpalette  	#e4ffdb #427730, ipolate(5)    
local colors `r(p)'
replace s_`v' = s_`v'*100
format s_`v' %4.2f
spmap s_`v' using uscoord, id(idvar) fcolor("`colors'") ocolor(none ..) title(Kid foreignHH poverty over 5to17) legstyle(2) clm(quantile) cln(5)  //note here I am using standard dev instead of quantile and for some reason it wont let me break into 5 bins?
graph export "V:\sestep\mapexports\geoid_`v'_5to17.pdf", replace
}

/*foreign10yr foreign5yr pov200 pov200foreign kid_pov200 kid_foreignhh_200pov kid_foreignhh_200pov_200 kid_noeng_foreignhh tw5_BAplus tw5_BAplus_foreign tw5_lessBA tw5_lessBA_foreign tw5_lessBA_foreign10yr tw5_lessBA_foreign5yr tw5_lessBA_noeng*/

//colorpalette HSV purplegreen, ipolate(3) nograph reverse 
//local colors `r(p)'
/*
shp2dta using states_simp, database(statedb) coordinates(statecoord) genid(puma)
use usdb, clear
describe


foreach v in foreign /*foreign2010 foreign2015 noncitizen noncitizen2010 noncitizen2015 pov200 pov200foreign kid_pov200 kid_foreignhh_noba kid_foreignhh_200pov kid_noeng_foreignhh kid_hh_c_foreign tw5_BAplus tw5_BAplus_foreign tw5_lessthanBA tw5_lessthanBA_foreign tw5_lessthanBA_foreign2010 tw5_lessthanBA_foreign2015 tw5_lessthanBA_noeng*/{
import excel "S:\Hamilton_Data\2022\Tara_immigration\immigration\sharesbystatefip.xlsx", sheet("`v'") firstrow clear
save `v', replace
use `v'
merge 1:1 puma using usdb
drop if _merge!=3
replace s_`v' = s_`v'*100
format s_`v' %4.2f
spmap s_`v' using uscoord , id(puma) fcolor(Blues)

}