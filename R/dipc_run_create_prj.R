# Main script to create a GCAM project in the DIPC given the database name

#### INPUTS
# queries file

## Read the db name
args <- commandArgs(trailingOnly=TRUE)
print(args)

## Set the working directory and load libraries
setwd('C:/GCAM_working_group/IAM COMPACT/GCAM_v7p1_plus')
libP <- .libPaths()
.libPaths(c(libP,"C:/GCAM_working_group/R_libs"))
setwd('/scratch/bc3lc/GCAM_v7p1_plus')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3lc/R-libs/4.1"))

library(dplyr)
library(tidyr)
library(rgcam)

base_path <<- getwd()
source(file.path('gcam_sdg','R','ancillary_functions_create_prj.R'))

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
create_prj(db_name)