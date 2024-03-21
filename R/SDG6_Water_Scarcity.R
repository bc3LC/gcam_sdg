library(dplyr)
library(tidyr)

#' @param prj uploaded project file
get_sdg6_water_scarcity <- function(prj) {
  
  print('computing sdg6 - water scarcity ...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/SDG6-Water")) dir.create("output/SDG6-Water")
  if (!dir.exists("output/SDG6-Water/figures")) dir.create("output/SDG6-Water/figures")
  
  # Get Water Supply Data
  water_supply = rgcam::getQuery(prj, "Basin level available runoff") %>%
      select(-region) %>%
      bind_rows(
        getQuery(prj_water, "resource supply curves") %>%
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
    bind_rows(
      getQuery(prj_water, "Water Withdrawals by Basin (Groundwater)") %>%
        filter(stringr::str_detect(subresource, "groundwater")) %>%
        mutate(subresource = "groundwater") %>%
        group_by(scenario, year, groundwater, subresource, Units) %>%
        summarize(value = sum(value)) %>%
        ungroup() %>%
        rename(basin = groundwater)) %>% 
    rename(value_wd = value)
  
  # Compute the Weighted Water Scarcity Index (Weighted per Basin both by Supply & by Withdrawal)
  water_scarcity_index = water_supply %>% 
    left_join(water_withdrawal) %>% 
    mutate(index = value_wd / value_sup) %>% 
    group_by(scenario, basin, subresource, year) %>% 
    summarize(value_sup = mean(value_sup),
              value_wd = mean(value_wd),
              index = mean(index)) %>% 
    ungroup() %>% 
  # %>% filter(!index > 1)
    mutate(weighted_sup = index * value_sup,
           weighted_wd = index * value_wd) %>%
    group_by(scenario, year, resource = if_else(subresource == "runoff", "runoff", "groundwater")) %>%
    summarize(index_sup = sum(weighted_sup) / sum(value_sup),
              index_wd = sum(weighted_wd) / sum(value_wd)) %>%
    ungroup()

  write.csv(water_scarcity_index, file = file.path('output/SDG6-Water','water_scarcity_index.csv'), row.names = F)
      
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
  ggsave(pl_water_scarcity_index_sup, file = file.path('output/SDG6-Water/figures', paste0('sdg6_water_scarcity_index_sup.png')),
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
  ggsave(pl_water_scarcity_index_wd, file = file.path('output/SDG6-Water/figures', paste0('sdg6_water_scarcity_index_wd.png')),
         width = 1000, height = 1000, units = 'mm', limitsize = FALSE)  
  
  return(water_scarcity_index)
  
  }  
  
