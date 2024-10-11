library(dplyr)
library(tidyr)

#' @param prj uploaded project file
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
get_sdg1_gdp <- function(prj, saveOutput = T, makeFigures = F){

  print('computing sdg1 - GDP...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("gcam_sdg/output")) dir.create("gcam_sdg/output")
  if (!dir.exists("gcam_sdg/output/SDG1-GDP")) dir.create("gcam_sdg/output/SDG1-GDP")
  if (!dir.exists("gcam_sdg/output/SDG1-GDP/indiv_results")) dir.create("gcam_sdg/output/SDG1-GDP/indiv_results")
  if (!dir.exists("gcam_sdg/output/SDG1-GDP/figures")) dir.create("gcam_sdg/output/SDG1-GDP/figures")
  
  # Perform computations
  gdppc <- rgcam::getQuery(prj, "GDP per capita PPP by region")
  
  if (saveOutput) write.csv(gdppc, 
                            file = file.path('gcam_sdg/output/SDG1-GDP/indiv_results',paste0('SDG1_gdppc_',gsub("\\.dat$", "", gsub("^database_basexdb_", "", prj_name)), ".csv")), 
                            row.names = F)
  
  return(gdppc)
} 