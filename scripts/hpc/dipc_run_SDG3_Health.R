# Main script to run the SDG3 (Health) indicator in the DIPC for a single
# GCAM project

#### INPUTS
# queries file

## Read the db name
args <- commandArgs(trailingOnly=TRUE)
print(args)

## Set the working directory and load the gcamsdg package
## Defaults to the BC3 "DIPC" cluster paths; override via the
## GCAMSDG_BASE_PATH / GCAMSDG_RLIB_PATH environment variables to run
## on a different machine.
base_path <- Sys.getenv("GCAMSDG_BASE_PATH", unset = "/scratch/bc3lc/GCAM_v7p1_plus")
setwd(base_path)
.libPaths(c(.libPaths(), Sys.getenv("GCAMSDG_RLIB_PATH", unset = "/scratch/bc3lc/R-libs/4.1")))

library(dplyr)
library(tidyr)
library(rgcam)
library(rfasst)
devtools::load_all(file.path(base_path, "gcamsdg"))

## Extract the db name
db_name <- args[1]
ssp <- args[2]
db_name = paste0('database_basexdb_',toupper(ssp),'_',db_name)
prj_name <- paste0(db_name, '.dat')
print(paste0('Start SDG3 Health analysis for prj ', prj_name))

## Load prj
prj <- rgcam::loadProject(file.path('prj_files',prj_name))

## Run SDG3 Health
get_sdg3_health(prj, prj_name, saveOutput = T, makeFigures = F, final_db_year = 2050)
