library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)

run <- function(db_path = NULL, query_path = "./inst/extdata", db_name = NULL, prj_name,
                rdata_name = NULL, scen_name, queries = "queries_xxx.xml", final_db_year = 2100){
  
  
  # Load the rgcam project:
  if (!is.null(db_path) & !is.null(db_name)) {
    print('creating prj')
    conn <- rgcam::localDBConn(db_path,
                               db_name,migabble = FALSE)
    prj <- rgcam::addScenario(conn,
                              prj_name,
                              scen_name,
                              paste0(query_path,"/",queries))
    prj <- fill_queries(prj, db_path, db_name, prj_name, scen_name)
    
    QUERY_LIST <- c(rgcam::listQueries(prj, c(scen_name)))
  } else if (is.null(rdata_name)){
    print('loading prj')
    prj <- rgcam::loadProject(prj_name)
    
    QUERY_LIST <- c(rgcam::listQueries(prj, c(scen_name)))
  } else {
    print('loading RData')
    if (!exists('prj_rd')) {
      prj_rd = get(load(rdata_name))
      QUERY_LIST <- names(prj_rd)
    }
  }
  print('computing...')
  
  
  
} 