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
  
  mort.list <- NULL
  
  for(i in scen_name) {
    
    mort_pre <- rfasst::m3_get_mort_pm25(prj_name = prj,
                                     scen_name = i,
                                     final_db_year = final_db_year,
                                     saveOutput = F) %>%
      # select the only one model (GBD)
      dplyr::select(region, year, age, disease, mort = GBD) %>%
      # Aggregate to region-level
      dplyr::group_by(region, year) %>%
      dplyr::summarise(mort = sum(mort)) %>%
      dplyr::ungroup() 
    
    # Add-uo RUS and RUE
    mort_adj <- mort_pre %>%
      dplyr::filter(region == "RUE") %>%
      dplyr::mutate(region = "RUS") %>%
      dplyr::bind_rows(
        mort_pre %>% dplyr::filter(region != "RUE")
      ) %>%
      dplyr::group_by(region, year) %>%
      dplyr::summarise(mort = sum(mort)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(year = as.numeric(year))
      
    
    # Downscale to country-level based on population
    country_shares <- rfasst::raw.ssp.data %>%
      dplyr::filter(grepl("SSP2", SCENARIO),
                    VARIABLE == "Population") %>%
      tidyr::pivot_longer(cols = starts_with("X"),
                          names_to = "year",
                          values_to = "pop") %>%
      dplyr::filter(complete.cases(.)) %>%
      dplyr::mutate(year = gsub("X", "", year)) %>%
      dplyr::select(country = REGION, year, pop) %>%
      gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(country = subRegionAlt ), by = dplyr::join_by(country)) %>%
      dplyr::group_by(fasst_region, year) %>%
      dplyr::mutate(pop_fasst_reg = sum(pop)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(share = pop / pop_fasst_reg) %>%
      dplyr::select(fasst_region, country, year, share) %>%
      dplyr::mutate(year = as.numeric(year))
    
    # add TWN
    twn_share <- country_shares %>%
      dplyr::filter(country == "CHN") %>%
      dplyr::mutate(fasst_region = "TWN",
                    country = "TWN",
                    share = 1)
    
    mort.pm25_country<- dplyr::bind_rows(country_shares, twn_share) %>%
      dplyr::rename(region = fasst_region) %>%
      dplyr::left_join(mort_adj, by = dplyr::join_by(region, year)) %>%
      dplyr::filter(complete.cases(.)) %>%
      dplyr::mutate(mort = round(mort * share, 0)) %>%
      dplyr::select(country, year, mort)
    
    mort.pm25 <- mort.pm25_country %>%
      gcamdata::left_join_error_no_match(rfasst::GCAM_reg %>% dplyr::rename(country = `ISO 3`), by = dplyr::join_by(country)) %>%
      dplyr::select(GCAM_region = `GCAM Region`, year, mort) %>%
      dplyr::group_by(GCAM_region, year) %>%
      dplyr::summarise(mort = sum(mort)) %>%
      dplyr::ungroup()
      
    #--------------------
      # ADD O3
    o3_mort_pre <- rfasst::m3_get_mort_o3(prj_name = prj,
                                         scen_name = i,
                                         final_db_year = final_db_year,
                                         saveOutput = F) %>%
      # select the only one model (GBD)
      dplyr::select(region, year, disease, mort = Jerret2009) %>%
      # Aggregate to region-level
      dplyr::group_by(region, year) %>%
      dplyr::summarise(mort = sum(mort)) %>%
      dplyr::ungroup() 
    
    # Add-uo RUS and RUE
    o3_mort_adj <- o3_mort_pre %>%
      dplyr::filter(region == "RUE") %>%
      dplyr::mutate(region = "RUS") %>%
      dplyr::bind_rows(
        o3_mort_pre %>% dplyr::filter(region != "RUE")
      ) %>%
      dplyr::group_by(region, year) %>%
      dplyr::summarise(mort = sum(mort)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(year = as.numeric(year))
    
    mort.o3_country<- dplyr::bind_rows(country_shares, twn_share) %>%
      dplyr::rename(region = fasst_region) %>%
      dplyr::left_join(o3_mort_adj, by = dplyr::join_by(region, year)) %>%
      dplyr::filter(complete.cases(.)) %>%
      dplyr::mutate(mort = round(mort * share, 0)) %>%
      dplyr::select(country, year, mort)
    
    mort.o3 <- mort.o3_country %>%
      gcamdata::left_join_error_no_match(rfasst::GCAM_reg %>% dplyr::rename(country = `ISO 3`), by = dplyr::join_by(country)) %>%
      dplyr::select(GCAM_region = `GCAM Region`, year, mort) %>%
      dplyr::group_by(GCAM_region, year) %>%
      dplyr::summarise(mort = sum(mort)) %>%
      dplyr::ungroup()
    
    #--------------------
    # Sum PM2.5 and O3
    mort <- dplyr::bind_rows(
      mort.pm25,
      mort.o3
    ) %>%
      dplyr::group_by(GCAM_region, year) %>%
      dplyr::summarise(mort = sum(mort)) %>%
      dplyr::ungroup()
    
  }
  
  mort_fin <- dplyr::bind_rows(mort.list)
  

  return(invisible(mort))
  
} 
