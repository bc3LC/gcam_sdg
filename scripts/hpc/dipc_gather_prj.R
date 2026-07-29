# Main script to gather all GCAM projects in the DIPC given the folder path

## Set the working directory
## Defaults to the BC3 "DIPC" cluster paths; override via the
## GCAM_SDG_BASE_PATH / GCAM_SDG_RLIB_PATH environment variables to run
## on a different machine.
base_path <- Sys.getenv("GCAM_SDG_BASE_PATH", unset = "/scratch/bc3lc/GCAM_v7p1_plus")
setwd(base_path)
.libPaths(c(.libPaths(), Sys.getenv("GCAM_SDG_RLIB_PATH", unset = "/scratch/bc3lc/R-libs/4.1")))

## List all prj files
sub_prj_names <- c(list.files(file.path(base_path, 'prj_files'), pattern = 'database_basexdb_SSP4'))
for (it in sub_prj_names) {
  print(it)
  prj <- rgcam::loadProject(file.path('prj_files',it))
  print(length(rgcam::listQueries(prj, anyscen = F)))
  print('------------------------------------------------')
}

## Gather and save
sub_prj_names <- paste0('prj_files/',sub_prj_names)
prj_gathered <- rgcam::mergeProjects(prjname = 'gath_SSP5.dat', prjlist = sub_prj_names, saveProj = T)
print(rgcam::listQueries(prj_gathered, anyscen = F))
