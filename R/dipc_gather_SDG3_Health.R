# Main script to gather all GCAM projects in the DIPC given the folder path

## Set the working directory and load libraries
setwd('/scratch/bc3LC/gcam_bio_accounting')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3LC/R-libs/4.1"))

## List all RData files and gather in one list
sub_prj_names <- c(list.files('/scratch/bc3LC/gcam_bio_accounting/output/SDG3-Health/mort.list', pattern = '*.RData'))
base_path <- '/scratch/bc3LC/gcam_bio_accounting/output/SDG3-Health/mort.list'
mort.fin.list <- list()
for (it in sub_prj_names) {
  print(it)
  tmp <- get(load(file.path(base_path, it)))
  mort_fin <- dplyr::bind_rows(tmp)
  mort.fin.list[[it]] <- mort_fin
}

## Gather and save
mort_fin <- dplyr::bind_rows(mort.fin.list)
save(mort_fin, file = 'output/SDG3-Health/mort.fin/mort.fin_ALL.RData')
write.csv(mort_fin, file = file.path('output/SDG3-Health/mort.fin','mort.fin_ALL.csv'), row.names = F)