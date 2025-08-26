# Main script to create a GCAM project in the DIPC given the database name

#### INPUTS
# queries file

## Read the db name
args <- commandArgs(trailingOnly=TRUE)
print(args)

## Set the working directory and load libraries
setwd('/scratch/bc3lc/GCAM_v7p1_plus')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3lc/R-libs/4.1"))
library(reticulate)
library(rgcam)
library(dplyr)
library(tidyr)
# library(xlsx)
# library(readxl)
library(ncdf4)
library(sf)
library(sp)
# library(openxlsx)
library(shapefiles)
library(raster)

# prj = loadProject(paste0("prj_files/database_basexdb_SSP1_sdgstudy_afolu2.dat"))
# listScenarios(prj)
# scenario_names = c("SDGstudy_incr_base_SSP1", "SDGstudy_incr_base_SSP2")

base_path <<- getwd()
source(file.path('gcam_sdg','R','SDG15_Land.R'))

## Extract the db name
db_name <- args[1]
ssp <- args[2]
db_name = paste0('database_basexdb_',toupper(ssp),'_',db_name)
prj_name <- paste0(db_name, '.dat')
print(paste0('Start SDG15 Land analysis for prj ', prj_name))

## Load prj
prj <- rgcam::loadProject(file.path('prj_files',prj_name))

## Run SDG15 Land
get_sdg15_land_indicator(prj, saveOutput = T, makeFigures = F)

