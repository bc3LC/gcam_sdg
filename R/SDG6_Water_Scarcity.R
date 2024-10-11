library(dplyr)
library(tidyr)

#' @param prj uploaded project file
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
get_sdg6_water_scarcity <- function(prj, saveOutput = T, makeFigures = F){

  print('computing sdg6 - water scarcity ...')

  # Create the directories if they do not exist:
  if (!dir.exists("gcam_sdg/output")) dir.create("gcam_sdg/output")
  if (!dir.exists("gcam_sdg/output/SDG6-Water")) dir.create("gcam_sdg/output/SDG6-Water")
  if (!dir.exists("gcam_sdg/output/SDG6-Water/indiv_results")) dir.create("gcam_sdg/output/SDG6-Water/indiv_results")
  if (!dir.exists("gcam_sdg/output/SDG6-Water/figures")) dir.create("gcam_sdg/output/SDG6-Water/figures")

  # Get Water Supply Data
  water_supply = rgcam::getQuery(prj, "Basin level available runoff") %>%
      select(-region) %>%
      filter(year < 2055) %>%
      bind_rows(
        rgcam::getQuery(prj, "resource supply curves") %>%
          filter(stringr::str_detect(subresource, "groundwater")) %>%
          mutate(subresource = "groundwater") %>%
          group_by(scenario, year, resource, subresource, Units) %>%
          summarize(value = sum(value)) %>%
          ungroup() %>%
          rename(basin = resource)) %>%
      rename(value_sup = value)

  # Get Water Withdrawal Data
  water_withdrawal = rgcam::getQuery(prj, "Water Withdrawals by Basin (Runoff)") %>%
    select(-region) %>%
    rename(basin = "runoff water") %>%
    filter(year < 2055) %>%
    bind_rows(
      rgcam::getQuery(prj, "Water Withdrawals by Basin (Groundwater)") %>%
        filter(stringr::str_detect(subresource, "groundwater")) %>%
        mutate(subresource = "groundwater") %>%
        group_by(scenario, year, groundwater, subresource, Units) %>%
        summarize(value = sum(value)) %>%
        ungroup() %>%
        rename(basin = groundwater)) %>%
    rename(value_wd = value)

  # Extract values of baseline 
  water_withdrawal_2015 = water_withdrawal %>% filter(year == 2015) %>% rename(value_wd_2015 = value_wd)
  water_supply_2015 = water_supply %>% filter(year == 2015) %>% rename(value_sup_2015 = value_sup)
  
  # Compute the Weighted Water Scarcity Index (Weighted per Basin both by Supply & by Withdrawal)
  water_scarcity_index = water_supply %>%
    left_join(water_withdrawal) %>%
    mutate(index = value_wd / value_sup) 
  water_scarcity_index = merge(water_scarcity_index, water_withdrawal_2015, by = c("basin", "scenario", "subresource"))
  water_scarcity_index = merge(water_scarcity_index, water_supply_2015, by = c("basin", "scenario", "subresource"))
  water_scarcity_index = water_scarcity_index %>% 
    # group_by(scenario, basin, subresource, year) %>% 
    # summarize(value_sup = mean(value_sup),
    #           value_wd = mean(value_wd),
    #           index = mean(index)) %>% 
    # ungroup() %>% 
  # %>% filter(!index > 1)
    mutate(weighted_sup = index * value_sup_2015,
           weighted_wd = index * value_wd_2015) %>%
    select(-year, -year.y) %>% 
    rename(year = year.x) %>% 
    group_by(scenario, year, resource = if_else(subresource == "runoff", "runoff", "groundwater")) %>%
    summarize(index_sup = sum(weighted_sup) / sum(value_sup_2015),
              index_wd = sum(weighted_wd) / sum(value_wd_2015)) %>%
    ungroup() 

    # Filter out groundwater and index weighted by water supply
  water_scarcity_index_runoff_wd = water_scarcity_index %>%
    select(-index_sup) %>%
    filter(resource == "runoff")

  if (saveOutput) write.csv(water_scarcity_index, 
                            file = file.path('gcam_sdg/output/SDG6-Water/indiv_results',paste0('SDG6_wscarIndex_',gsub("\\.dat$", "", gsub("^database_basexdb_", "", prj_name)), ".csv")), 
                            row.names = F)
  if (saveOutput) write.csv(water_scarcity_index_runoff_wd, 
                            file = file.path('gcam_sdg/output/SDG6-Water/indiv_results',paste0('SDG6_wscarIndexRunOff_',gsub("\\.dat$", "", gsub("^database_basexdb_", "", prj_name)), ".csv")), 
                            row.names = F)

  if (makeFigures) {
    pl_water_scarcity_index_sup = ggplot(data = water_scarcity_index) +
      geom_line(aes(x = year, y = index_sup, color = scenario)) +
      facet_wrap(. ~ resource, scales= "free_y") +
      labs(y = 'Index', x = 'Year', title = 'Water Scarcity Index (dimensionless) - Supply Weigth') +
      theme_light() +
      theme(legend.key.size = unit(2, "cm"), legend.position = 'bottom', legend.direction = 'horizontal',
            strip.background = element_blank(),
            strip.text = element_text(color = 'black', size = 40),
            strip.text.y = element_text(angle = 0),
            axis.text.x = element_text(size=30),
            axis.text.y = element_text(size=30),
            legend.text = element_text(size = 35),
            legend.title = element_text(size = 40),
            title = element_text(size = 40))
    # print(pl_water_scarcity_index_sup)
    ggsave(pl_water_scarcity_index_sup, file = file.path('gcam_sdg/output/SDG6-Water/figures', paste0('sdg6_water_scarcity_index_sup.png')),
           width = 1000, height = 1000, units = 'mm', limitsize = FALSE)

    pl_water_scarcity_index_wd = ggplot(data = water_scarcity_index) +
      geom_line(aes(x = year, y = index_wd, color = scenario)) +
      facet_wrap(. ~ resource, scales= "free_y") +
      labs(y = 'Index', x = 'Year', title = 'Water Scarcity Index (dimensionless) - Withdrawal Weight') +
      theme_light() +
      theme(legend.key.size = unit(2, "cm"), legend.position = 'bottom', legend.direction = 'horizontal',
            strip.background = element_blank(),
            strip.text = element_text(color = 'black', size = 40),
            strip.text.y = element_text(angle = 0),
            axis.text.x = element_text(size=30),
            axis.text.y = element_text(size=30),
            legend.text = element_text(size = 35),
            legend.title = element_text(size = 40),
            title = element_text(size = 40))
    # print(pl_water_scarcity_index_wd)
    ggsave(pl_water_scarcity_index_wd, file = file.path('gcam_sdg/output/SDG6-Water/figures', paste0('sdg6_water_scarcity_index_wd.png')),
           width = 1000, height = 1000, units = 'mm', limitsize = FALSE)
  }

  return(water_scarcity_index)

  }

