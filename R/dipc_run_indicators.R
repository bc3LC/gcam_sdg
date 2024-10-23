## Set the working directory and load libraries
setwd('/scratch/bc3lc/GCAM_v7p1_plus')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3lc/R-libs/4.1"))

library(dplyr)
library(tidyr)
library(rgcam)

base_path <<- getwd()
ssps <- c('SSP1','SSP2','SSP3','SSP4','SSP5')

#### To run all indicators
source(file.path('gcam_sdg','R','run_SDG_indicators.R'))
prj_base <- rgcam::loadProject(file.path('prj_files','database_basexdb_sdgstudy_base.dat'))
for (ssp in ssps) {
    sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/prj_files', pattern = paste0('database_basexdb_',ssp)))
    for (prj_name in sub_prj_names) {
        print(paste0('Start indicators computation for prj ', prj_name))
        run_indiv(prj_name, ssp = ssp)
        print('------------------------------------------------')
    }
}
run_indiv('database_basexdb_sdgstudy_base.dat', ssp = 'base')

#### To gather all indicators by SSP/REF
source(file.path('gcam_sdg','R','gather_SDGs.R'))
for (ssp in ssps) {
    gather_indicators(ssp)
}
gather_indicators_ref()

#### To compute final output (SSP vs REF)
source(file.path('gcam_sdg','R','run_SDG_indicators.R'))
gdp_final = data.frame()
expenditure_final = data.frame()
poverty_final = data.frame()
health_final = data.frame()
water_final = data.frame()

add_data <- function(base_data, new_data) {
    base_data <- as.data.frame(base_data)
    if (nrow(base_data) == 0) {
        base_data = new_data
    } else {
        base_data = as.data.frame(merge(base_data, new_data[[1]], by = c('unit', 'sdg', 'Gt_CO2_reduction')))
    }
    return(base_data)
}

for (ssp in ssps) {
    print(ssp)
    output <- run_comparisson(ssp)
    gdp_final <- add_data(gdp_final, output[1])
    expenditure_final <- add_data(expenditure_final, output[2])
    poverty_final <- add_data(poverty_final, output[3])
    health_final <- add_data(health_final, output[4])
    water_final <- add_data(water_final, output[5])
}

sdg <- bind_rows(
    as.data.frame(gdp_final),
    as.data.frame(expenditure_final),
    as.data.frame(poverty_final),
    as.data.frame(health_final),
    as.data.frame(water_final),
) %>%
arrange(sdg, as.numeric(Gt_CO2_reduction))

# reorder columns
manual_cols <- c("Gt_CO2_reduction","unit","sdg")
afolu_cols <- grep("^afolu", names(sdg), value = TRUE)
bld_cols <- grep("^bld", names(sdg), value = TRUE)
dac_cols <- grep("^dac", names(sdg), value = TRUE)
ind_cols <- grep("^ind", names(sdg), value = TRUE)
sup_cols <- grep("^sup", names(sdg), value = TRUE)
trn_cols <- grep("^trn", names(sdg), value = TRUE)
final_col_order <- c(manual_cols, afolu_cols, bld_cols, dac_cols, ind_cols, sup_cols, trn_cols)
sdg_ordered <- sdg[, final_col_order]

write.csv(sdg_ordered, file = file.path("gcam_sdg/output","sdg_v4.csv"), row.names = F)


