library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)

load_prj <- function(prj_path, prj_name){
  
  print('loading project...')
  
prj <- rgcam::loadProject(paste0(prj_path, "/", prj_name))

return(invisible(prj))
  
  
} 
