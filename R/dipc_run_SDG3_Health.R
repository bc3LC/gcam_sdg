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

library(dplyr)
library(tidyr)
library(rgcam)
library(rfasst)

base_path <<- getwd()
source(file.path('gcam_sdg','R','SDG3_Health.R'))

## Extract the db name
db_name <- args[1]
ssp <- args[2]
db_name = paste0('database_basexdb_',toupper(ssp),'_',db_name)
prj_name <- paste0(db_name, '.dat')
print(paste0('Start SDG3 Health analysis for prj ', prj_name))

## Load prj
prj <- rgcam::loadProject(file.path('prj_files',prj_name))

## Run SDG3 Health
get_sdg3_health(prj, saveOutput = T, makeFigures = F, final_db_year = 2050)
