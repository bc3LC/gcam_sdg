library(dplyr)
library(tidyr)

#' @param prj uploaded project file
get_sdg1_gdp <- function(prj){
  
  print('computing sdg1 - food basket bill...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/SDG1-GDP")) dir.create("output/SDG1-GDP")
  if (!dir.exists("output/SDG1-GDP/figures")) dir.create("output/SDG1-GDP/figures")
  
  # Perform computations
  gdppc <- rgcam::getQuery(prj, "GDP per capita PPP by region")
  
  write.csv(gdppc, file = file.path('output/SDG1-GDP','gdppc.csv'), row.names = F)
  
  return(gdppc)
} 