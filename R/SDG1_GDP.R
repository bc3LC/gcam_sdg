library(dplyr)
library(tidyr)

#' @param prj uploaded project file
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
get_sdg1_gdp <- function(prj, saveOutput = T, makeFigures = F){

  print('computing sdg1 - food basket bill...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/SDG1-GDP")) dir.create("output/SDG1-GDP")
  if (!dir.exists("output/SDG1-GDP/figures")) dir.create("output/SDG1-GDP/figures")
  
  # Perform computations
  gdppc <- rgcam::getQuery(prj, "GDP per capita PPP by region")
  
  if (saveOutput) write.csv(gdppc, file = file.path('output/SDG1-GDP','gdppc.csv'), row.names = F)
  
  return(gdppc)
} 