library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)

load_prj <- function(db_path = NULL, query_path = "./inst/extdata", db_name = NULL, prj_name,
                rdata_name = NULL, scen_name, queries = "queries_rfasst.xml", final_db_year = 2100, 
                ssp = "SSP2", recompute = F){
  
  print('loading project...')
  
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Assert that the parameters of the function are okay, or modify when necessary
  
  if (!endsWith(prj_name, '.dat')) prj_name = paste0(prj_name, '.dat')
  
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  
  # Load the rgcam project:
  if (!is.null(db_path) & !is.null(db_name)) {
    rlang::inform('Creating project ...')
    conn <- rgcam::localDBConn(db_path,
                               db_name,migabble = FALSE)
    prj <- rgcam::addScenario(conn,
                              prj_name,
                              scen_name,
                              paste0(query_path,"/",queries),
                              saveProj = F)
    prj <- fill_queries(prj, db_path, db_name, prj_name, scen_name)
    
    rgcam::saveProject(prj, file = file.path('output',prj_name))
    
    QUERY_LIST <- c(rgcam::listQueries(prj, c(scen_name)))
  } else if (is.null(rdata_name)){
    rlang::inform('Loading project ...')
    prj <- rgcam::loadProject(prj_name)
    
    QUERY_LIST <- c(rgcam::listQueries(prj, c(scen_name)))
  } else {
    rlang::inform('Loading RData ...')
    if (!exists('prj_rd')) {
      prj_rd = get(load(rdata_name))
      QUERY_LIST <- names(prj_rd)
    }
  }
  

} 
