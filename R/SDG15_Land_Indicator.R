library(dplyr)
library(tidyr)

#' @param prj uploaded project file
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
get_sdg15_land_indicator <- function(prj, saveOutput = T, makeFigures = F){

  print('computing sdg15 - land indicator ...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/SDG15-Land")) dir.create("output/SDG15-Land")
  if (!dir.exists("output/SDG15-Land/figures")) dir.create("output/SDG15-Land/figures")
  
  # Compute the Land Indicator (Percent of Unmanaged Land)
  land_indicator = rgcam::getQuery(prj_land, "detailed land allocation") %>% 
    mutate(value = value * 0.1) %>% # Convert to Mha
    mutate(management = case_when(
      grepl("ProtectedUnmanagedForest|UnmanagedForest|Shrubland|ProtectedShrubland|Grassland|ProtectedGrassland|UnmanagedPasture|ProtectedUnmanagedPasture|Tundra|RockIceDesert", land_indicator$landleaf) ~ "Unmanaged",
      TRUE ~ "Managed")) %>% 
    group_by(scenario, region, year, management) %>% 
    summarize(value = sum(value)) %>% 
    ungroup() %>% 
    group_by(scenario, region, year) %>%
    summarize(percent_unmanaged = 100 * sum(value[management == "Unmanaged"]) / sum(value[management %in% c("Unmanaged", "Managed")]),
              total_land = sum(value[management %in% c("Unmanaged", "Managed")])) %>%
    ungroup() 
  
  # Aggregate Global Value with Weighted Average
  land_indicator_global = land_indicator %>%
    mutate(weight = percent_unmanaged * total_land) %>% 
    group_by(scenario, year) %>%
    summarize(percent_unmanaged = sum(weight) / sum(total_land)) %>%
    ungroup()

  # Write CSV
  if (saveOutput) write.csv(land_indicator, file = file.path('output/SDG15-Land','land_indicator_regional.csv'), row.names = F)
  if (saveOutput) write.csv(land_indicator_global, file = file.path('output/SDG15-Land','land_indicator_global.csv'), row.names = F)
      
  if (makeFigures) {
    # Regional plot (facet)
    pl_land_regional = ggplot(data = land_indicator) + 
      geom_line(aes(x = year, y = percent_unmanaged, color = scenario)) +     
      facet_wrap(. ~ region, scales= "free_y") +
      labs(y = 'Percent (%)', x = 'Year', title = 'Percentage of Unmanaged Land per GCAM Region') +
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
    print(pl_land_regional)
    ggsave(pl_land_regional, file = file.path('output/SDG15-Land/figures', paste0('sdg15-land_indicator_regional.png')),
           width = 1000, height = 1000, units = 'mm', limitsize = FALSE)
    
    # Global plot
    pl_land_global = ggplot(data = land_indicator_global) + 
      geom_line(aes(x = year, y = percent_unmanaged, color = scenario)) +     
      # facet_wrap(. ~ region, scales= "free_y") +
      labs(y = 'Percent (%)', x = 'Year', title = 'Percentage of Unmanaged Land') +
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
    print(pl_land_global)
    ggsave(pl_land_global, file = file.path('output/SDG15-Land/figures', paste0('sdg15-land_indicator_global.png')),
           width = 1000, height = 1000, units = 'mm', limitsize = FALSE)
  }
  
  
  return(land_indicator)
  
}  
  