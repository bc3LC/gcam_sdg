library(dplyr)
library(tidyr)

#' @param prj uploaded project file
get_sdg2_food_basket_bill <- function(prj){
  
  print('computing sdg1 - food basket bill...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/SDG2-Poverty")) dir.create("output/SDG2-Poverty")
  if (!dir.exists("output/SDG2-Poverty/figures")) dir.create("output/SDG2-Poverty/figures")

  food_subsector <- read.csv('inputs/nutrition/food_subsector.csv')
  
  food_basket_bill_regional = rgcam::getQuery(prj, "food consumption by type (specific)") %>%
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
    dplyr::left_join(getQuery(prj, "population by region") %>%
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
    dplyr::left_join(rgcam::getQuery(prj, "food demand prices") %>%
                       dplyr::group_by(Units, region, scenario, input, year) %>%
                       dplyr::summarise(value = sum(value)) %>%
                       dplyr::ungroup() %>%
                       dplyr::mutate(price = value * 1e3,
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
  
  write.csv(food_basket_bill_regional, file = file.path('output/SDG2-Poverty','food_basket_bill_regional.csv'), row.names = F)
  
  for (yy in unique(food_basket_bill_regional$year)) {
    pl_food_basket_bill_regional = ggplot(data = food_basket_bill_regional %>%
                                            dplyr::filter(year == yy) %>% 
                                            dplyr::group_by(year,region,scenario) %>%
                                            dplyr::summarise(median_value = median(expenditure),
                                                             min_value = min(expenditure),
                                                             max_value = max(expenditure))) +
      geom_bar(aes(x = scenario, y = median_value, fill = scenario), stat = 'identity', alpha = 0.3) +
      geom_errorbar(aes(x = scenario, ymin = min_value, ymax = max_value), width=0.3, colour="#757575", alpha=1, linewidth=1.2) +
      # facet
      facet_wrap(. ~ region, scales = 'fixed') +
      # labs
      labs(y = '2005$/capita/day', x = '', title = 'Annual regional median food basket expenditure (fixed scales)') +
      # theme
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
    ggsave(pl_food_basket_bill_regional, file = file.path('output/SDG2-Poverty/figures', paste0('sgd2_food_basket_bill_regional_',yy,'.png')),
           width = 1000, height = 1000, units = 'mm', limitsize = FALSE)
  }
  
  
  return(food_basket_bill_regional)
} 