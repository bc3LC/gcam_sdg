###############################################################################
# Date: January 2026
# Description: Main script to generate the SUSMIP GCAM reporting
# Details:
#     - 1. If GCAM prj exists: load it
#     -    If GCAM prj does not exist: create query file with all the necessary queries to run the rest of the script
#     - 2. Run gcamreport
#          - Note: if needed, the prj creation will be done at this stage
#     - 3. Run gcam-sdg
#     - 4. Aggregate, standardize, and save the results
###############################################################################

library(dplyr)
library(tidyr)
library(rgcam)
library(gcamreport)
## NOTE: script to be run in the gcam-sdg main folder

## INPUTS
db_path <- "C:/GCAM_working_group/SUSMIP/gcam-cgs/output"
db_name <- "database_basexdb_SUSMIP"
# prj_name <- "../gcam-cgs/output/database_basexdb_SUSMIP_susmip_15Jan2026.dat"
prj_name <- "../database_basexdb_SUSMIP_susmip_15Jan2026.dat"
scenarios <- c('SUSMIP_SUSTAINABLE','Baseline')
final_year = 2100
GCAM_version = 'vScenarioMIPCMIP7'
launch_ui = F
GWP_version = 'AR6'

####################
## STEP 1
####################

# Case A: prj exists -> load it
if (file.exists(prj_name)) {
  case <- 'A'
  prj <- rgcam::loadProject(prj_name)
  
  
# Case B: prj does not exit -> create query file
} else {
  case <- 'B'
  queries_gcamreport <- gcamreport::queries_general_vScenarioMIPCMIP7
  queries_gcamsdg <- rgcam::parse_batch_query('inst/extdata/queries_all_sdg.xml')
  
  queries_all <- modifyList(queries_gcamreport, queries_gcamsdg)
  queries_all_clean <- queries_all[!duplicated(queries_all)]
}


####################
## STEP 2
####################
if (!dir.exists('output')) dir.create('output')
prj_name_raw <- gsub("^\\.\\./|\\.dat$", "", prj_name)

# Case 0: load gcamreport standardized output
if (file.exists(paste0('output/',prj_name_raw,'.csv'))) {
  out_gcamreport <- read.csv((paste0('output/',prj_name_raw,'.csv')))

# Case A: run gcamreport with the loaded project
} else if (case == 'A') {
  generate_report(db_path = NULL, db_name = NULL, prj_name = prj_name, scenarios = scenarios,
                  final_year = final_year, GWP_version = GWP_version, GCAM_version = GCAM_version,
                  output_file = paste0('output/',prj_name_raw), launch_ui = launch_ui)

  
# Case B: run gcamreport creating the project
} else {
  generate_report(db_path = db_path, db_name = db_name, prj_name = prj_name, scenarios = scenarios,
                  final_year = final_year, GWP_version = GWP_version, GCAM_version = GCAM_version,
                  output_file = paste0('output/',prj_name_raw), launch_ui = launch_ui)
  
  
}


####################
## STEP 3
####################

# Case 0: load gcam-sdg standardized output
if (file.exists(paste0('output/',prj_name_raw,'_sdg.csv'))) {
  out_gcamreport <- read.csv((paste0('output/',prj_name_raw,'_sdg.csv')))
  
# Else: run gcam-sdg
} else {
  # TODO
  
}


####################
## STEP 4
####################

# TODO




