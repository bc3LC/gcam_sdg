library(dplyr)
library(tidyr)
library(rgcam)
library(gcamdata)
library(rfasst)

run <- function(prj, saveOutput = T, makeFigures = F, final_db_year = 2050){

  prj <- rgcam::loadProject("gath_all_base.dat")
  final_db_year <- 2050
  saveOutput <- T

  baseline_scen <- "SDGstudy_incr_base"
  first_model_year <- 2020

  # SDG 1: GDP
  gdp_output <- get_sdg1_gdp(prj, saveOutput = F)

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
    group_by(scenario, unit) %>%
    summarise(diff = mean(diff)) %>%
    ungroup() %>%
    filter(scenario != baseline_scen) %>%
    mutate(sdg = "Economy",
           sector = if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = if_else(grepl("ind", scenario), "ind", sector),
           sector = if_else(grepl("bld", scenario), "bld", sector),
           sector = if_else(grepl("trn", scenario), "trn", sector),
           sector = if_else(grepl("sup", scenario), "sup", sector)) %>%
    mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "scenario"), sep = "_split_", extra = "merge", fill = "right") %>%
    select(-adj) %>%
    rename(Gt_CO2_reduction = scenario) %>%
    pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 2: GDP
  poverty_output <- get_sdg2_food_basket_bill(prj, saveOutput = F)

  poverty <- poverty_output %>%
    left_join_error_no_match(poverty_output %>%
                               filter(scenario == baseline_scen) %>%
                               rename(expenditure_percent_GDP_base = expenditure_percent_GDP) %>%
                               select(-scenario), by = join_by(year, units)) %>%
    mutate(units = "perc_GDP") %>%
    filter(year <= final_db_year,
           year >= first_model_year) %>%
    mutate(diff = expenditure_percent_GDP - expenditure_percent_GDP_base) %>%
    group_by(scenario, unit = units) %>%
    summarise(diff = mean(diff)) %>%
    ungroup() %>%
    filter(scenario != baseline_scen) %>%
    mutate(sdg = "Poverty",
           sector = if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = if_else(grepl("ind", scenario), "ind", sector),
           sector = if_else(grepl("bld", scenario), "bld", sector),
           sector = if_else(grepl("trn", scenario), "trn", sector),
           sector = if_else(grepl("sup", scenario), "sup", sector)) %>%
    mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "scenario"), sep = "_split_", extra = "merge", fill = "right") %>%
    select(-adj) %>%
    rename(Gt_CO2_reduction = scenario) %>%
    pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 3: Health
  # health <- get_sdg3_health(prj, final_db_year = 2050)

  # reading it exogenously for the number of scenarios
  health_pre <- read.csv("C:/GCAM_working_group/IAM COMPACT/gcam_bio_accounting/output/SDG3-Health/mort.fin/mort.fin_ALL.csv") %>%
    group_by(scenario, year) %>%
    summarise(mort = sum(mort)) %>%
    ungroup()

  health_base <- read.csv("C:/GCAM_working_group/IAM COMPACT/gcam_bio_accounting/output/SDG3-Health/mort.fin/mort.fin_ALL.csv") %>%
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
    mutate(diff = mort - mort_base) %>%
    mutate(unit = "Mortalities") %>%
    group_by(scenario, unit) %>%
    summarise(diff = mean(diff)) %>%
    ungroup() %>%
    filter(scenario != baseline_scen) %>%
    mutate(sdg = "Health",
           sector = if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = if_else(grepl("ind", scenario), "ind", sector),
           sector = if_else(grepl("bld", scenario), "bld", sector),
           sector = if_else(grepl("trn", scenario), "trn", sector),
           sector = if_else(grepl("sup", scenario), "sup", sector)) %>%
    mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "scenario"), sep = "_split_", extra = "merge", fill = "right") %>%
    select(-adj) %>%
    rename(Gt_CO2_reduction = scenario) %>%
    pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 6
  water_output <- get_sdg6_water_scarcity(prj,saveOutput = F)

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
    mutate(diff = index - index_base) %>%
    group_by(scenario, unit = Units) %>%
    summarise(diff = mean(diff)) %>%
    ungroup() %>%
    filter(scenario != baseline_scen) %>%
    mutate(sdg = "Water",
           sector = if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = if_else(grepl("ind", scenario), "ind", sector),
           sector = if_else(grepl("bld", scenario), "bld", sector),
           sector = if_else(grepl("trn", scenario), "trn", sector),
           sector = if_else(grepl("sup", scenario), "sup", sector)) %>%
    mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "scenario"), sep = "_split_", extra = "merge", fill = "right") %>%
    select(-adj) %>%
    rename(Gt_CO2_reduction = scenario) %>%
    pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))

  # SDG 15: Land

  # Test new proj file with detailed land allocation in all scens
  land_output <- get_sdg15_land_indicator(prj, saveOutput = F)

  land <- land_output %>%
    filter(year <= final_db_year,
           year >= first_model_year) %>%
    left_join_error_no_match(land_output %>%
                               filter(scenario == baseline_scen) %>%
                               select(year, percent_unmanaged_base = percent_unmanaged) %>%
                               filter(year <= final_db_year,
                                      year >= first_model_year), by = join_by(year)) %>%
    mutate(Units = "%") %>%
    mutate(diff = percent_unmanaged - percent_unmanaged_base) %>%
    group_by(scenario, unit = Units) %>%
    summarise(diff = mean(diff)) %>%
    ungroup() %>%
    filter(scenario != baseline_scen) %>%
    mutate(sdg = "Land",
           sector = if_else(grepl("afolu", scenario), "afolu", "a"),
           sector = if_else(grepl("ind", scenario), "ind", sector),
           sector = if_else(grepl("bld", scenario), "bld", sector),
           sector = if_else(grepl("trn", scenario), "trn", sector),
           sector = if_else(grepl("sup", scenario), "sup", sector)) %>%
    mutate(scenario = sub("_([^_]*)$", "_split_\\1", scenario)) %>%
    tidyr::separate(scenario, into = c("adj", "scenario"), sep = "_split_", extra = "merge", fill = "right") %>%
    select(-adj) %>%
    rename(Gt_CO2_reduction = scenario) %>%
    pivot_wider(names_from = sector,
                values_from = diff) %>%
    arrange(as.numeric(Gt_CO2_reduction))



  sdg <- bind_rows(
    gdp,
    poverty,
    health,
    water,
    land
  )

   write.csv(sdg, file = file.path("output","sdg_Deliverable.csv"), row.names = F)

}
