# Main script to create a GCAM project in the DIPC given the database name

#### INPUTS
# queries file

## Read the db name
args <- commandArgs(trailingOnly=TRUE)
print(args)

## Set the working directory and load libraries
setwd('/scratch/bc3LC/gcam_bio_accounting')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3LC/R-libs/4.1"))

library(dplyr)
library(tidyr)
library(rgcam)
library(rfasst)

base_path <<- getwd()
source(file.path('sdg_reporting','R','SDG3_Health.R'))

## Extract the db name
db_name <- args[1]
db_name <- paste0('database_basexdb_',db_name)
prj_name <- paste0(db_name, '.dat')
print(paste0('Start SDG3 Health analysis for prj ', prj_name))

## Load prj
prj <- rgcam::loadProject(file.path('output',prj_name))

## Run SDG3 Health
get_sdg3_health(prj, saveOutput = T, makeFigures = F, final_db_year = 2050, prj_name = prj_name)
