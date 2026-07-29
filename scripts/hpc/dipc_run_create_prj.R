# Main script to create a GCAM project in the DIPC given the database name

#### INPUTS
# queries file

## Read the db name
args <- commandArgs(trailingOnly=TRUE)
print(args)

## Set the working directory and load the gcam_sdg package
## Defaults to the BC3 "DIPC" cluster paths; override via the
## GCAM_SDG_BASE_PATH / GCAM_SDG_RLIB_PATH environment variables to run
## on a different machine.
base_path <- Sys.getenv("GCAM_SDG_BASE_PATH", unset = "/scratch/bc3lc/GCAM_v7p1_plus")
setwd(base_path)
.libPaths(c(.libPaths(), Sys.getenv("GCAM_SDG_RLIB_PATH", unset = "/scratch/bc3lc/R-libs/4.1")))

library(dplyr)
library(tidyr)
library(rgcam)
devtools::load_all(file.path(base_path, "gcam_sdg"))

## Extract the db name
db_name <- args[1]
ssp <- args[2]
if (ssp != 'base') {
    db_name = paste0('database_basexdb_',toupper(ssp),'_',db_name)
} else {
    db_name = paste0('database_basexdb_',db_name,'_',ssp)
}
print(paste0('Start prj creation for db ', db_name))

## Create the prj
create_prj(db_name, base_path)
