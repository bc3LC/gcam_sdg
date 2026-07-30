library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)
library(rfasst)

#' run
#'
#' Interactive/one-off entry point: compute all SDG indicators for the
#' scenarios in the fixed "sdgstudy_base" GCAM database and write the
#' combined SDG deliverable table. Requires `baseline_scen` to already be
#' set in the calling environment (the name of the baseline scenario to
#' diff every other scenario against).
#' @param prj unused - the project is loaded internally from a fixed
#'   database name; kept for interface compatibility
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
#' @param final_db_year last model year to consider
#' @return invisibly writes output/sdg_Deliverable.csv
#' @export
run <- function(prj, saveOutput = T, makeFigures = F, final_db_year = 2050){

  prj_name <- "database_basexdb_sdgstudy_base.dat"
  prj <- rgcam::loadProject(prj_name)
  final_db_year <- 2050
  saveOutput <- T

#   baseline_scen <- "SDGstudy_incr_base"
  first_model_year <- 2020

  # SDG 1: GDP
  gdp_output <- get_sdg1_gdp(prj, prj_name, saveOutput = F)

  gdp_pre <- gdp_output %>%
    mutate(Units = "Thous$/pers") %>%
    left_join_error_no_match(getQuery(prj,"population by region"), by = join_by(scenario, region, year)) %>%
    mutate(pop = value.y * 1E3,
           gdp = value.x * 1E3 * pop) %>%
    group_by(scenario, year) %>%
    summarise(gdp = sum(gdp),
              pop = sum(pop)) %>%
    ungroup() %>%
    mutate(GDPpc_thous = gdp / pop / 1E3) %>%
    select(scenario, year, GDPpc_thous) %>%
    mutate(unit = "Thous$/pers")

  gdp_base <- gdp_output %>%
    mutate(Units = "Thous$/pers") %>%
    left_join_error_no_match(getQuery(prj,"population by region"), by = join_by(scenario, region, year)) %>%
    mutate(pop = value.y * 1E3,
           gdp = value.x * 1E3 * pop) %>%
    group_by(scenario, year) %>%
    summarise(gdp = sum(gdp),
              pop = sum(pop)) %>%
    ungroup() %>%
    mutate(GDPpc_thous = gdp / pop / 1E3) %>%
    select(scenario, year, GDPpc_thous) %>%
    mutate(unit = "Thous$/pers") %>%
    filter(scenario == baseline_scen) %>%
    rename(GDPpc_thous_base = GDPpc_thous) %>%
    select(-scenario)

  gdp <- gdp_pre %>%
    left_join_error_no_match(gdp_base, by = join_by(year, unit)) %>%
    filter(year <= final_db_year,
           year >= first_model_year) %>%
    mutate(diff = GDPpc_thous - GDPpc_thous_base) %>%
    postprocess_sdg_diff("Economy", baseline_scen, match = "exact")

  # SDG 2: GDP
  poverty_output <- get_sdg2_food_basket_bill(prj, prj_name, saveOutput = F)

  poverty <- poverty_output %>%
    left_join_error_no_match(poverty_output %>%
                               filter(scenario == baseline_scen) %>%
                               rename(expenditure_percent_GDP_base = expenditure_percent_GDP) %>%
                               select(-scenario), by = join_by(year, units)) %>%
    mutate(units = "perc_GDP") %>%
    filter(year <= final_db_year,
           year >= first_model_year) %>%
    mutate(diff = expenditure_percent_GDP - expenditure_percent_GDP_base,
           unit = units) %>%
    postprocess_sdg_diff("Poverty", baseline_scen, match = "exact")

  # SDG 3: Health
  # health <- get_sdg3_health(prj, prj_name, final_db_year = 2050)

  # reading it exogenously for the number of scenarios
  # (set options(gcamsdg.base_path = ...) or GCAMSDG_BASE_PATH to point this
  # at a local run directory instead of the BC3 cluster default)
  mort_fin_path <- file.path(gcamsdg_base_path(), "output", "SDG3-Health", "mort.fin", "mort.fin_ALL.csv")

  health_pre <- read.csv(mort_fin_path) %>%
    group_by(scenario, year) %>%
    summarise(mort = sum(mort)) %>%
    ungroup()

  health_base <- read.csv(mort_fin_path) %>%
    group_by(scenario, year) %>%
    summarise(mort = sum(mort)) %>%
    ungroup() %>%
    filter(scenario == baseline_scen) %>%
    rename(mort_base = mort) %>%
    select(-scenario)

  health <- health_pre %>%
    left_join_error_no_match(health_base, by = "year") %>%
    filter(year <= final_db_year,
           year >= first_model_year) %>%
    mutate(diff = mort - mort_base,
           unit = "Mortalities") %>%
    postprocess_sdg_diff("Health", baseline_scen, match = "exact")

  # SDG 6
  water_output <- get_sdg6_water_scarcity(prj, prj_name, saveOutput = F)

  water <- water_output %>%
    filter(resource == "runoff") %>%
    select(scenario, year, index = index_wd) %>%
    left_join_error_no_match(water_output %>%
                               filter(resource == "runoff",
                                      scenario == baseline_scen) %>%
                               select(year, index_base = index_wd), by = join_by(year)) %>%
    mutate(Units = "Index") %>%
    filter(year <= final_db_year,
           year >= first_model_year) %>%
    mutate(diff = index - index_base,
           unit = Units) %>%
    postprocess_sdg_diff("Water", baseline_scen, match = "exact")

  
  # SDG 15: Land
  # Test new proj file with detailed land allocation in all scens
  land_output <- get_sdg15_land_indicator(prj, prj_name, saveOutput = F)

  land <- land_output %>%
    filter(year <= final_db_year,
           year >= first_model_year) %>%
    left_join_error_no_match(land_output %>%
                               filter(scenario == baseline_scen) %>%
                               select(year, percent_unmanaged_base = percent_unmanaged) %>%
                               filter(year <= final_db_year,
                                      year >= first_model_year), by = join_by(year)) %>%
    mutate(Units = "%") %>%
    mutate(diff = percent_unmanaged - percent_unmanaged_base,
           unit = Units) %>%
    postprocess_sdg_diff("Land", baseline_scen, match = "exact")



  sdg <- bind_rows(
    gdp,
    poverty,
    health,
    water,
    land
  )

   write.csv(sdg, file = file.path("output","sdg_Deliverable.csv"), row.names = F)

}
