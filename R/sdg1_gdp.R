library(dplyr)
library(tidyr)

#' get_sdg1_gdp
#'
#' Extract GDP per capita (PPP) by region, used as the SDG 1 (Poverty) economy
#' metric and as an input to SDG2's food-basket-bill-as-%-of-GDP calculation.
#' @param prj uploaded project file
#' @param prj_name project file name, used to tag the saved output file
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
#' @return data frame with GDP per capita (PPP) by region, scenario and year
#' @export
get_sdg1_gdp <- function(prj, prj_name, saveOutput = T, makeFigures = F){

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