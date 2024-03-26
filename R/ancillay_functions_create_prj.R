# Project creation auxiliary functions


#' create_prj
#'
#' Function to create a GCAM project provided a database and a queries file
#' @param db_name name of the database. It will The extension will be automatically added if not present
#' @param desired_scen desired scenarios. If NULL, all the scenarios present in the database will be considered
#' @param prj_name name of the project. If NULL, it will be the defult option, i.e., the database name. Otherwise specify
#' @return create the specified project
create_prj <- function(db_name, desired_scen = NULL, prj_name = NULL) {
  db_path <- file.path(base_path,'output')
  query_path <- file.path(base_path, 'sdg_reporting', 'inst', 'extdata')
  
  ##############################################################################
  ##############################################################################
  # # 1. append all XML files into one
  # 
  # # read all available XMLs and remove special ones
  # xml_files <- list.files(query_path, full.names = TRUE, pattern = "\\.xml$")
  # xml_files <- xml_files[!basename(xml_files) %in% c("queries_all_sdg.xml", "queries_rfasst_nonCO2.xml")]
  # 
  # combined_xml <- xml2::xml_new_document()
  # 
  # # through each XML file, extract its root node and add it as a child to the combined XML document
  # for (xml_file in xml_files) {
  #   xml_data <- xml2::read_xml(xml_file)
  #   root_node <- xml2::xml_root(xml_data)
  #   xml2::xml_add_child(combined_xml, root_node)
  # }
  # 
  # # extract the root node from the combined XML document
  # root_node <- xml2::xml_root(combined_xml)
  # 
  # # find all query nodes in the combined XML document
  # query_nodes <- xml2::xml_find_all(root_node, "//aQuery")
  # 
  # # remove duplicated queries based on some criteria (e.g., query title)
  # unique_query_nodes <- unique(query_nodes)
  # 
  # # create a new XML document to hold the cleaned data
  # cleaned_xml <- xml2::xml_new_document()
  # cleaned_xml <- xml2::xml_add_child(cleaned_xml, "queries")
  # 
  # # add query nodes with unique titles to the cleaned XML document
  # for (node in unique_query_nodes) {
  #   xml2::xml_add_child(cleaned_xml, node)
  # }
  # 
  # # save the combined XML document
  # output_file <- file.path(query_path,"queries_all_sdg.xml")
  # xml2::write_xml(cleaned_xml, output_file)
  
  
  ##############################################################################
  ##############################################################################
  # 2. perform checks
  
  
  # prj name checks and/or definition
  if (!is.null(prj_name)) {
    assert_that(substr(prj_name, nchar(prj_name) - 3, nchar(prj_name)) == ".dat", msg = 'In `load_prj` function: The specified project name does not contain the extension (.dat)')
  } else {
    prj_name = paste0(db_name, '.dat')
  }
  
  # scenarios checks and/or definition
  conn <- rgcam::localDBConn(db_path, db_name)
  available_scen <- rgcam::listScenariosInDB(conn)$name
  if (!is.null(desired_scen)) {
    assert_that(all(desired_scen %in% available_scen))
  } else {
    desired_scen <- available_scen
  }
  
  
  ##############################################################################
  ##############################################################################
  # 3. create project
  
  print('create prj')
  # create/load prj
  if (!file.exists(file.path('output',prj_name))) {
    print('create prj')
    prj <- rgcam::addScenario(conn, prj_name, desired_scen,
                              file.path(query_path, 'queries_all_sdg.xml'),
                              clobber = FALSE, saveProj = FALSE)
  } else {
    print('load prj')
    prj <- rgcam::loadProject(file.path('output',prj_name))
  }
  
  # add detailed land query if necessary
  if (length(rgcam::listQueries(prj, anyscen = F)) != length(rgcam::listQueries(prj, anyscen = T))) {
    print('add detailed land query')
    prj_tmp <- rgcam::addScenario(conn, prj_name, desired_scen,
                                  file.path(query_path, 'queries_detailed_land.xml'),
                                  clobber = FALSE, saveProj = FALSE)
    prj <- rgcam::mergeProjects(prj_name, list(prj, prj_tmp), clobber = FALSE, saveProj = FALSE)
    rm(prj_tmp)
  }
  
  # add 'nonCO2' large query
  if (!"nonCO2 emissions by sector (excluding resource production)" %in% rgcam::listQueries(prj)) {
    print('nonCO2 emissions by sector ----------------------')
    dt_sec <- data_query("nonCO2 emissions by sector (excluding resource production)", db_path, db_name, prj_name, desired_scen)
    prj_tmp <- rgcam::addQueryTable(
      project = prj_name, qdata = dt_sec, saveProj = FALSE,
      queryname = "nonCO2 emissions by sector (excluding resource production)", clobber = FALSE
    )
    prj <- rgcam::mergeProjects(prj_name, list(prj, prj_tmp), clobber = FALSE, saveProj = TRUE)
  } else {
    saveProject(prj, file = file.path('output',prj_name))
  }
  
  print(rgcam::listQueries(prj))
  print(rgcam::listScenarios(prj))
  print(rgcam::listQueries(prj, anyscen = F))

}


#' data_query
#'
#' Aux. function to load heavy queries
#' @param type query name
#' @param db_path database path
#' @param db_name database name
#' @param prj_name project name
#' @param scenarios scenarios to be considered
#' @return dataframe with the specified query information
data_query = function(type, db_path, db_name, prj_name, scenarios) {
  dt = data.frame()
  xml <- xml2::read_xml(file.path(base_path, 'sdg_reporting', 'inst', 'extdata', 'queries_rfasst_nonCO2.xml'))
  qq <- xml2::xml_find_first(xml, paste0("//*[@title='", type, "']"))
  
  full_nonCO2_emissions_list = c('BC','BC_AWB','C2F6','CF4','CH4','CH4_AGR','CH4_AWB','CO','CO_AWB','H2',
                                 'H2_AWB','HFC125','HFC134a','HFC143a','HFC152a','HFC227ea','HFC23','HFC236fa',
                                 'HFC245fa','HFC32','HFC365mfc','HFC43','N2O','N2O_AGR','N2O_AWB','NH3','NH3_AGR',
                                 'NH3_AWB','NMVOC','NMVOC_AGR','NMVOC_AWB','NOx','NOx_AGR','NOx_AWB','OC','OC_AWB',
                                 'PM10','PM2.5','SF6','SO2_1','SO2_1_AWB','SO2_2','SO2_2_AWB','SO2_3','SO2_3_AWB',
                                 'SO2_4','SO2_4_AWB')
  
  for (sc in scenarios) {
    emiss_list = unique(full_nonCO2_emissions_list)
    while (length(emiss_list) > 0) {
      current_emis = emiss_list[1:min(21,length(emiss_list))]
      qq_sec = gsub("current_emis", paste0("(@name = '", paste(current_emis, collapse = "' or @name = '"), "')"), qq)
      
      prj_tmp = rgcam::addSingleQuery(
        conn = rgcam::localDBConn(db_path,
                                  db_name,migabble = FALSE),
        proj = prj_name,
        qn = type,
        query = qq_sec,
        scenario = sc,
        regions = NULL,
        clobber = TRUE,
        transformations = NULL,
        saveProj = FALSE,
        warn.empty = FALSE
      )
      
      tmp = data.frame(prj_tmp[[sc]][type])
      if (nrow(tmp) > 0) {
        dt = dplyr::bind_rows(dt,tmp)
      }
      rm(prj_tmp)
      
      if (length(emiss_list) > 21) {
        emiss_list <- emiss_list[(21 + 1):length(emiss_list)]
      } else {
        emiss_list = c()
      }
    }
  }
  # Rename columns
  new_colnames <- sub(".*\\.(.*)", "\\1", names(dt))
  names(dt) <- new_colnames
  
  return(dt)
}

