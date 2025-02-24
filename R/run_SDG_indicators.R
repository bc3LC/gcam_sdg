library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)
library(rfasst)

run_indiv <- function(prj_name, ssp = NULL, saveOutput = T, makeFigures = F, final_db_year = 2050){

  prj <- rgcam::loadProject(file.path('prj_files',paste0(prj_name)))
  prj_name <<- prj_name

  # load SDG reporting scripts
  source('gcam_sdg/R/SDG1_GDP.R')
  source('gcam_sdg/R/SDG1_Expenditure.R')
  source('gcam_sdg/R/SDG2_Food_Basket_Bill.R')
  source('gcam_sdg/R/SDG3_Health.R')
  source('gcam_sdg/R/SDG6_Water_Scarcity.R')
  source('gcam_sdg/R/SDG0_Population.R')
  
  first_model_year <- 2020

  # SDG 1: GDP
  gdp_output <- get_sdg1_gdp(prj, saveOutput = T)

  # SDG 1: Expenditure
  expenditure_output <- get_sdg1_expenditure(prj, ssp, saveOutput = T)

  # SDG 2: GDP
  poverty_output <- get_sdg2_food_basket_bill(prj, saveOutput = T)

  # SDG 3: Health
  health <- get_sdg3_health(prj, saveOutput = T)

  # SDG 6
  water_output <- get_sdg6_water_scarcity(prj, saveOutput = T)

  # basics
  pop_by_reg <- get_sdg0_pop(prj, saveOutput = T)
}


# function to extract and bind all data of a given list of RData items
extract_data <- function(dat_list, pre_path) {
  dt <- data.frame()
  for (it in dat_list) {
    if (grepl('.csv',it)) {
      tmp <- read.csv(file.path(pre_path, it))
    } else {
      tmp <- get(load(file.path(pre_path, it)))
    }
    dt <- rbind(dt, tmp)
  }
  return(dt)
}


# function to compute the final indicators of the SDGs (SSP vs REF)
run_comparisson <- function(ssp, final_db_year = 2050){

  # base_path <- file.path(base_path, 'gcam_sdg/output')
  first_model_year <- 2020

  # SDG 1: GDP
  dat_list <- c(list.files(file.path(base_path, 'SDG1-GDP'), pattern = paste0('.RData')))
  gdp_output <- extract_data(dat_list, file.path(base_path, 'SDG1-GDP')) %>%
    dplyr::filter(grepl(ssp, scenario))

  dat_list <- c(list.files(file.path(base_path, 'SDG0-POP'), pattern = paste0('.RData')))
  pop_by_reg <- extract_data(dat_list, file.path(base_path, 'SDG0-POP')) %>%
    dplyr::filter(grepl(ssp, scenario)) %>%
    dplyr::distinct()

  gdp_pre <- tibble::as_tibble(gdp_output) %>%
    dplyr::mutate(Units = "Thous$/pers") %>%
    gcamdata::left_join_error_no_match(tibble::as_tibble(pop_by_reg), 
           by = c('scenario', 'region', 'year')) %>%
    dplyr::mutate(pop = value.y * 1E3,
           gdp = value.x * 1E3 * pop) %>%
    dplyr::group_by(scenario, year) %>%
    dplyr::summarise(gdp = sum(gdp),
              pop = sum(pop)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(GDPpc_thous = gdp / pop / 1E3) %>%
    dplyr::select(scenario, year, GDPpc_thous) %>%
    dplyr::mutate(unit = "Thous$/pers")

  gdp_base <- gdp_pre %>%
    dplyr::filter(grepl('base', scenario)) %>%
    dplyr::rename(GDPpc_thous_base = GDPpc_thous) %>%
    dplyr::select(-scenario)

  gdp <- gdp_pre %>%
    gcamdata::left_join_error_no_match(gdp_base, by = c('year', 'unit')) %>%
    dplyr::filter(year <= final_db_year,
           year >= first_model_year) %>%
    dplyr::mutate(diff = (GDPpc_thous - GDPpc_thous_base)/GDPpc_thous_base) %>%
    dplyr::group_by(scenario, unit) %>%
    dplyr::summarise(diff = mean(diff)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!grepl('base', scenario)) %>%
    dplyr::mutate(sdg = "Economy",
           sector = dplyr::if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = dplyr::if_else(grepl("ind", scenario), "ind", sector),
           sector = dplyr::if_else(grepl("bld", scenario), "bld", sector),
           sector = dplyr::if_else(grepl("trn", scenario), "trn", sector),
           sector = dplyr::if_else(grepl("dac", scenario), "dac", sector),
           sector = dplyr::if_else(grepl("sup", scenario), "sup", sector)) %>%
    dplyr::mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "ssp"), sep = "_split_", extra = "merge", fill = "right") %>%
    dplyr::mutate(Gt_CO2_reduction = as.numeric(unlist(stringr::str_extract_all(adj, "\\d+")))) %>%
    dplyr::mutate(sector = paste0(sector, '_', tolower(ssp))) %>%
    dplyr::select(-adj, -ssp) %>%
    tidyr::pivot_wider(names_from = sector,
                      values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 1: Expenditure
  dat_list <- c(list.files(file.path(base_path, 'SDG1-Expenditure'), pattern = paste0('.*',ssp,'.RData')))
  dat_list <- c(dat_list, list.files(file.path(base_path, 'SDG1-Expenditure'), pattern = paste0('.*','REF','.RData')))
  expenditure_output <- extract_data(dat_list, file.path(base_path, 'SDG1-Expenditure')) %>%
    dplyr::filter(grepl(ssp, scenario))

  expenditure <- tibble::as_tibble(expenditure_output) %>%
    gcamdata::left_join_error_no_match(tibble::as_tibble(expenditure_output) %>%
                               dplyr::filter(grepl('base', scenario)) %>%
                               dplyr::rename(total_expenditure_per_world_base = total_expenditure_per_world) %>%
                               dplyr::select(-scenario), by = c('year')) %>%
    dplyr::mutate(unit = "perc_income") %>%
    dplyr::filter(year <= final_db_year,
           year >= first_model_year) %>%
    dplyr::mutate(diff = total_expenditure_per_world - total_expenditure_per_world_base) %>%
    dplyr::group_by(scenario, unit) %>%
    dplyr::summarise(diff = mean(diff)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!grepl('base', scenario)) %>%
    dplyr::mutate(sdg = "Poverty",
           sector = dplyr::if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = dplyr::if_else(grepl("ind", scenario), "ind", sector),
           sector = dplyr::if_else(grepl("bld", scenario), "bld", sector),
           sector = dplyr::if_else(grepl("trn", scenario), "trn", sector),
           sector = dplyr::if_else(grepl("dac", scenario), "dac", sector),
           sector = dplyr::if_else(grepl("sup", scenario), "sup", sector)) %>%
    dplyr::mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "ssp"), sep = "_split_", extra = "merge", fill = "right") %>%
    dplyr::mutate(Gt_CO2_reduction = as.numeric(unlist(stringr::str_extract_all(adj, "\\d+")))) %>%
    dplyr::mutate(sector = paste0(sector, '_', tolower(ssp))) %>%
    dplyr::select(-adj, -ssp) %>%
    tidyr::pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 2: Food exp
  dat_list <- c(list.files(file.path(base_path, 'SDG2-Poverty'), pattern = paste0('.RData')))
  poverty_output <- extract_data(dat_list, file.path(base_path, 'SDG2-Poverty')) %>%
    dplyr::filter(grepl(ssp, scenario))

  poverty <- tibble::as_tibble(poverty_output) %>%
    gcamdata::left_join_error_no_match(tibble::as_tibble(poverty_output) %>%
                               dplyr::filter(grepl('base', scenario)) %>%
                               dplyr::rename(expenditure_percent_GDP_base = expenditure_percent_GDP) %>%
                               dplyr::select(-scenario), by = c('year', 'units')) %>%
    dplyr::mutate(units = "perc_GDP") %>%
    dplyr::filter(year <= final_db_year,
           year >= first_model_year) %>%
    dplyr::mutate(diff = expenditure_percent_GDP - expenditure_percent_GDP_base) %>%
    dplyr::group_by(scenario, unit = units) %>%
    dplyr::summarise(diff = mean(diff)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!grepl('base', scenario)) %>%
    dplyr::mutate(sdg = "Hunger",
           sector = dplyr::if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = dplyr::if_else(grepl("ind", scenario), "ind", sector),
           sector = dplyr::if_else(grepl("bld", scenario), "bld", sector),
           sector = dplyr::if_else(grepl("trn", scenario), "trn", sector),
           sector = dplyr::if_else(grepl("dac", scenario), "dac", sector),
           sector = dplyr::if_else(grepl("sup", scenario), "sup", sector)) %>%
    dplyr::mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "ssp"), sep = "_split_", extra = "merge", fill = "right") %>%
    dplyr::mutate(Gt_CO2_reduction = as.numeric(unlist(stringr::str_extract_all(adj, "\\d+")))) %>%
    dplyr::mutate(sector = paste0(sector, '_', tolower(ssp))) %>%
    dplyr::select(-adj, -ssp) %>%
    tidyr::pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 3: Health
  dat_list <- c(list.files(file.path(base_path, 'SDG3-Health'), pattern = paste0('.RData')))
  health_output <- extract_data(dat_list, file.path(base_path, 'SDG3-Health')) %>%
    dplyr::filter(grepl(ssp, scenario))

  health_pre <- health_output %>%
    dplyr::group_by(scenario, year) %>%
    dplyr::summarise(mort = sum(mort)) %>%
    dplyr::ungroup()

  health_base <- health_pre %>%
    dplyr::filter(grepl('base', scenario)) %>%
    dplyr::rename(mort_base = mort) %>%
    dplyr::select(-scenario)

  health <- health_pre %>%
    gcamdata::left_join_error_no_match(health_base, by = "year") %>%
    dplyr::filter(year <= final_db_year,
           year >= first_model_year) %>%
    dplyr::mutate(diff = mort - mort_base) %>%
    dplyr::mutate(unit = "Mortalities") %>%
    dplyr::group_by(scenario, unit) %>%
    dplyr::summarise(diff = mean(diff)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!grepl('base', scenario)) %>%
    dplyr::mutate(sdg = "Health",
           sector = dplyr::if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = dplyr::if_else(grepl("ind", scenario), "ind", sector),
           sector = dplyr::if_else(grepl("bld", scenario), "bld", sector),
           sector = dplyr::if_else(grepl("trn", scenario), "trn", sector),
           sector = dplyr::if_else(grepl("dac", scenario), "dac", sector),
           sector = dplyr::if_else(grepl("sup", scenario), "sup", sector)) %>%
    dplyr::mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "ssp"), sep = "_split_", extra = "merge", fill = "right") %>%
    dplyr::mutate(Gt_CO2_reduction = as.numeric(unlist(stringr::str_extract_all(adj, "\\d+")))) %>%
    dplyr::mutate(sector = paste0(sector, '_', tolower(ssp))) %>%
    dplyr::select(-adj, -ssp) %>%
    tidyr::pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 6
  dat_list <- c(list.files(file.path(base_path, 'SDG6-Water'), pattern = paste0('.RData')))
  water_output <- extract_data(dat_list, file.path(base_path, 'SDG6-Water')) %>%
    dplyr::filter(grepl(ssp, scenario))

  water <- tibble::as_tibble(water_output) %>%
    dplyr::filter(resource == "runoff") %>%
    dplyr::select(scenario, year, index = index_wd) %>%
    gcamdata::left_join_error_no_match(tibble::as_tibble(water_output) %>%
                               dplyr::filter(resource == "runoff",
                                      grepl('base', scenario)) %>%
                               dplyr::select(year, index_base = index_wd), by = c('year')) %>%
    dplyr::mutate(Units = "Index") %>%
    dplyr::filter(year <= final_db_year,
           year >= first_model_year) %>%
    dplyr::mutate(diff = index - index_base) %>%
    dplyr::group_by(scenario, unit = Units) %>%
    dplyr::summarise(diff = mean(diff)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!grepl('base', scenario)) %>%
    dplyr::mutate(sdg = "Water",
           sector = dplyr::if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = dplyr::if_else(grepl("ind", scenario), "ind", sector),
           sector = dplyr::if_else(grepl("bld", scenario), "bld", sector),
           sector = dplyr::if_else(grepl("trn", scenario), "trn", sector),
           sector = dplyr::if_else(grepl("dac", scenario), "dac", sector),
           sector = dplyr::if_else(grepl("sup", scenario), "sup", sector)) %>%
    dplyr::mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "ssp"), sep = "_split_", extra = "merge", fill = "right") %>%
    dplyr::mutate(Gt_CO2_reduction = as.numeric(unlist(stringr::str_extract_all(adj, "\\d+")))) %>%
    dplyr::mutate(sector = paste0(sector, '_', tolower(ssp))) %>%
    dplyr::select(-adj, -ssp) %>%
    tidyr::pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))


  # SDG 15
  dat_list <- c(list.files(file.path(base_path, 'SDG15-Land'), pattern = paste0('.RData')))
  land_output <- extract_data(dat_list, file.path(base_path, 'SDG15-Land')) %>%
    dplyr::filter(grepl(ssp, scenario))

  land <- tibble::as_tibble(land_output) %>%
    dplyr::mutate(value_base = tibble::as_tibble(land_output) %>%
                               dplyr::filter(grepl('base', scenario)) %>%
                               dplyr::pull(value)) %>%
    dplyr::mutate(diff = value - value_base) %>%
    dplyr::group_by(scenario, unit = Units) %>%
    dplyr::summarise(diff = mean(diff)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!grepl('base', scenario)) %>%
    dplyr::mutate(sdg = "PSL",
           sector = dplyr::if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = dplyr::if_else(grepl("ind", scenario), "ind", sector),
           sector = dplyr::if_else(grepl("bld", scenario), "bld", sector),
           sector = dplyr::if_else(grepl("trn", scenario), "trn", sector),
           sector = dplyr::if_else(grepl("dac", scenario), "dac", sector),
           sector = dplyr::if_else(grepl("sup", scenario), "sup", sector)) %>%
    dplyr::mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "ssp"), sep = "_split_", extra = "merge", fill = "right") %>%
    dplyr::mutate(Gt_CO2_reduction = as.numeric(unlist(stringr::str_extract_all(adj, "\\d+")))) %>%
    dplyr::mutate(sector = paste0(sector, '_', tolower(ssp))) %>%
    dplyr::select(-adj, -ssp) %>%
    tidyr::pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  output <- list(gdp, expenditure, poverty, health, water, land)
  return(output)
}

