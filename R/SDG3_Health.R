library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)

get_sdg3_health <- function(db_path = NULL, query_path = "./inst/extdata", db_name = NULL, prj_name,
                rdata_name = NULL, scen_name, queries = "queries_rfasst.xml", final_db_year = 2100, 
                health_model = "GBD", ssp = "SSP2", recompute = F){
  
  print('computing...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/SDG3-Health")) dir.create("output/SDG3-Health")
  if (!dir.exists("output/SDG3-Health/figures")) dir.create("output/SDG3-Health/figures")
  if (!dir.exists("output/SDG3-Health/maps")) dir.create("output/SDG3-Health/maps")
  
  mort <- rfasst::m3_get_mort_pm25(db_path = db_path, db_name = db_name, prj_name = prj_name, scen_name = scen_name, rdata_name = rdata_name, query_path = query_path,
                                        queries = queries, ssp = ssp, saveOutput = F, final_db_year = final_db_year, recompute = recompute)
  

  
} 