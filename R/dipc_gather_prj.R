# Main script to gather all GCAM projects in the DIPC given the folder path

## Set the working directory and load libraries
setwd('/scratch/bc3lc/GCAM_v7p1_plus')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3lc/R-libs/4.1"))

## List all prj files
sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/prj_files', pattern = 'database_basexdb_SSP4'))
for (it in sub_prj_names) {
  print(it)
  prj <- rgcam::loadProject(file.path('prj_files',it))
  print(length(rgcam::listQueries(prj, anyscen = F)))
  print('------------------------------------------------')
}

  # assign(gsub("\\.dat$", "", it),
  #        rgcam::loadProject(file.path('prj_files',it)))
  # print(length(rgcam::listQueries(get(gsub("\\.dat$", "", it)), anyscen = F)))


## Gather and save
sub_prj_names <- paste0('prj_files/',sub_prj_names)
prj_gathered <- rgcam::mergeProjects(prjname = 'gath_SSP5.dat', prjlist = sub_prj_names, saveProj = T)
print(rgcam::listQueries(prj_gathered, anyscen = F))