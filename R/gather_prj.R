# Main script to gather all GCAM projects in the DIPC given the folder path

## Set the working directory and load libraries
setwd('/scratch/bc3LC/gcam_bio_accounting')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3LC/R-libs/4.1"))

## List all prj files
sub_prj_names <- c(list.files('/scratch/bc3LC/gcam_bio_accounting/output/', pattern = '*.dat'))
for (it in sub_prj_names) {
  print(it)
  assign(gsub("\\.dat$", "", it),
         rgcam::loadProject(file.path('output',it)))
}

## Gather and save
prj_gathered <<- rgcam::mergeProjects(prjname = 'gath_all.dat', prjlist = sub_prj_names)
rgcam::saveProject(prj_gathered, file = 'gath_all.dat')
