library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)
library(rfasst)

get_sdg3_health <- function(prj, final_db_year = 2050){
  
  print('computing sdg3 - health impacts......')
  
  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/SDG3-Health")) dir.create("output/SDG3-Health")
  if (!dir.exists("output/SDG3-Health/figures")) dir.create("output/SDG3-Health/figures")
  if (!dir.exists("output/SDG3-Health/maps")) dir.create("output/SDG3-Health/maps")
  
  scen_name <- rgcam::listScenarios(prj)
  
  mort <- NULL
  
  for(i in scen_name) {
    
    mort <- rfasst::m3_get_mort_pm25(prj_name = prj,
                                     scen_name = i,
                                     final_db_year = final_db_year,
                                     saveOutput = F)
  }
  
  mort_fin <- dplyr::bind_rows(mort)
  

  return(invisible(mort))
  
} 
