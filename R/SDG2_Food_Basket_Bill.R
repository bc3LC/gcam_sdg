library(dplyr)
library(tidyr)

#' @param prj uploaded project file
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
get_sdg2_food_basket_bill <- function(prj, saveOutput = T, makeFigures = F){

  print('computing sdg2 - food basket bill...')

  # Create the directories if they do not exist:
  if (!dir.exists("ougcam_sdg/outputtput")) dir.create("gcam_sdg/output")
  if (!dir.exists("gcam_sdg/output/SDG2-Poverty")) dir.create("gcam_sdg/output/SDG2-Poverty")
  if (!dir.exists("gcam_sdg/output/SDG2-Poverty/indiv_results")) dir.create("gcam_sdg/output/SDG2-Poverty/indiv_results")
  if (!dir.exists("gcam_sdg/output/SDG2-Poverty/figures")) dir.create("gcam_sdg/output/SDG2-Poverty/figures")

  # Perform computations
  food_subsector <- read.csv(file.path('gcam_sdg','inst','extdata','food_subsector.csv'))

  food_basket_bill_regional <- rgcam::getQuery(prj, "food consumption by type (specific)") %>%
    dplyr::group_by(Units, region, scenario, subsector...4, subsector...5, technology, year) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(nestingSector1 = subsector...4) %>%
    tidyr::separate(nestingSector1, into = c("nestingSector1", "rest"), sep = ",", extra = "merge") %>% dplyr::select(-rest) %>%
    dplyr::rename(nestingSector2 = subsector...5) %>%
    tidyr::separate(nestingSector2, into = c("nestingSector2", "rest"), sep = ",", extra = "merge") %>% dplyr::select(-rest) %>%
    dplyr::left_join(food_subsector %>%
                       dplyr::rename('technology' = 'subsector')) %>%
    # Pcal to kcal/capita/day
    dplyr::left_join(rgcam::getQuery(prj, "population by region") %>%
                       dplyr::mutate(value = value * 1000) %>% # Convert from thous ppl to total ppl
                       dplyr::select(-Units) %>%
                       dplyr::rename(population = value),
                     by = c("year", "scenario", "region")) %>%
    # convert from Pcal to kcal/day
    dplyr::mutate(value = (value * 1e12) / (population * 365),
                  Units = "kcal/capita/day") %>%
    # total staples and nonstaples kcal consumption
    dplyr::group_by(Units,region,scenario,year,supplysector) %>%
    dplyr::summarise(consumption = sum(value)) %>%
    # compute the expenditure by supplysector
    dplyr::left_join(rgcam::getQuery(prj, "food demand prices by income group") %>%
                       dplyr::group_by(Units, region, scenario, input, year) %>%
                       dplyr::summarise(value = sum(value)) %>%
                       dplyr::ungroup() %>%
                       dplyr::mutate(price = value / 1e3, # Mcal to kcal
                                     units_price = '2005$/kcal/day') %>%
                       dplyr::select(-c(Units,value)) %>%
                       dplyr::rename('supplysector' = 'input'),
                     by = c('region','year','supplysector','scenario')) %>%
    dplyr::mutate(expenditure = consumption * price,
                  units_expenditure = '2005$/capita/day') %>%
    # total expenditure (staples + nonstaples)
    dplyr::group_by(units_expenditure,region,scenario,year) %>%
    dplyr::summarise(expenditure = sum(expenditure)) %>%
    dplyr::ungroup()

  # report food basket expenditure as % of the GDP
  GDP <- get_sdg1_gdp(prj) %>%
    rename(GDP = value) %>%
    # take care of units
    mutate(GDP = GDP * 1e-6) %>% # million 1990$ to 1990$
    mutate(GDP = gcamdata::gdp_deflator(2005, 1990)) %>% # 1990$ to 2005$
    mutate(Units = '2005$/capita')

  food_basket_bill_percent_GDP <- food_basket_bill_regional %>%
    left_join(GDP,
              by = c('scenario','region','year')) %>%
    mutate(expenditure_percent_GDP = expenditure / GDP * 100) %>%
    select(region, year, scenario, expenditure_percent_GDP) %>%
    mutate(units = 'percentage')

  if (saveOutput) write.csv(food_basket_bill_percent_GDP, 
                            file = file.path('gcam_sdg/output/SDG2-Poverty/indiv_results',paste0('SDG2_fbbPerGDP_',gsub("\\.dat$", "", gsub("^database_basexdb_", "", prj_name)), ".csv")),
                            row.names = F)

  # compute GLOBAL food basket expenditure
  # consider the regional food basket bill with respect the GDP and weight it by the regional population
  pop_weights <- rgcam::getQuery(prj, "population by region") %>%
    dplyr::select(-Units) %>%
    dplyr::rename(population = value) %>%
    dplyr::group_by(year, scenario) %>%
    dplyr::mutate(total_population = sum(population)) %>%
    dplyr::ungroup() %>%
    dplyr::rowwise() %>%
    dplyr::mutate(w_pop = population / total_population) %>%
    dplyr::select(region, year, scenario, w_pop)

  food_basket_bill_percent_GDP_global <- food_basket_bill_percent_GDP %>%
    left_join(pop_weights, by = c('region', 'year', 'scenario')) %>%
    mutate(weighted_expenditure_percent_GDP = expenditure_percent_GDP * w_pop) %>%
    group_by(year, scenario, units) %>%
    summarise(expenditure_percent_GDP = sum(weighted_expenditure_percent_GDP)) %>%
    ungroup()

  if (saveOutput) write.csv(food_basket_bill_percent_GDP_global, 
                            file = file.path('gcam_sdg/output/SDG2-Poverty/indiv_results',paste0('SDG2_fbbPerGlobal_',gsub("\\.dat$", "", gsub("^database_basexdb_", "", prj_name)), ".csv")), 
                            row.names = F)

  return(food_basket_bill_percent_GDP_global)
}
