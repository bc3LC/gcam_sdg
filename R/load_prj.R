library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)

load_prj <- function(db_path = NULL, query_path = "./inst/extdata", db_name = NULL, prj_name,
                rdata_name = NULL, scen_name, final_db_year = 2100, recompute = F){
  
  print('loading project...')
  
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Assert that the parameters of the function are okay, or modify when necessary
  
  # if (!endsWith(prj_name, '.dat')) prj_name = paste0(prj_name, '.dat')
  
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Load project file for SDG1
  # prj_sdg1 <- 
  
  #----------------------------------------------------------------------
  # Load project file for SDG2
  # prj_sdg2 <- 
  
  #----------------------------------------------------------------------
  # Load project file for SDG3: Requires some changes for nonCO2 emissions (already solved in rfasst package)

    # Load the rgcam project:
  if (!is.null(db_path) & !is.null(db_name)) {
    rlang::inform('Creating project ...')
    conn <- rgcam::localDBConn(db_path,
                               db_name,migabble = FALSE)
    prj_sdg3 <- rgcam::addScenario(conn,
                              prj_name,
                              scen_name,
                              paste0(query_path,"/",queries),
                              saveProj = F)
    prj_sdg3 <- fill_queries(prj_sdg3, db_path, db_name, prj_name, scen_name)
    
    rgcam::saveProject(prj_sdg3, file = file.path('output',prj_name))
    
    QUERY_LIST <- c(rgcam::listQueries(prj_sdg3, c(scen_name)))
  } else if (is.null(rdata_name)){
    rlang::inform('Loading project ...')
    prj_sdg3 <- rgcam::loadProject(prj_name)
    
    QUERY_LIST <- c(rgcam::listQueries(prj, c(scen_name)))
  } else {
    rlang::inform('Loading RData ...')
    if (!exists('prj_rd')) {
      prj_rd = get(load(rdata_name))
      QUERY_LIST <- names(prj_rd)
    }
  }
  
  #----------------------------------------------------------------------
  # Load project file for SDGK
  # prj_sdg_k <- 

  
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Merge projects!
  # prj <- rgcam::mergeProjects()
  
  
} 
