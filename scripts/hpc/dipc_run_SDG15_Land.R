# Main script to run the SDG15 (Life on Land) indicator in the DIPC for a
# single GCAM project

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
library(reticulate)
library(rgcam)
library(dplyr)
library(tidyr)
library(ncdf4)
library(sf)
library(sp)
library(shapefiles)
library(raster)
devtools::load_all(file.path(base_path, "gcamsdg"))

## Extract the db name
db_name <- args[1]
ssp <- args[2]
db_name = paste0('database_basexdb_',toupper(ssp),'_',db_name)
prj_name <- paste0(db_name, '.dat')
print(paste0('Start SDG15 Land analysis for prj ', prj_name))

## Load prj
prj <- rgcam::loadProject(file.path('prj_files',prj_name))

## Run SDG15 Land
get_sdg15_land_indicator(prj, prj_name, saveOutput = T, makeFigures = F)
