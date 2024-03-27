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

base_path <<- getwd()
source(file.path('sdg_reporting','R','ancillay_functions_create_prj.R'))

## Extract the db name
db_name <- args[1]
db_name = paste0('database_basexdb_',db_name)
print(paste0('Start prj creation for db ', db_name))

## Create the prj
create_prj(db_name)