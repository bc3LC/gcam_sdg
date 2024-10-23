# ## Set the working directory and load libraries
# setwd('/scratch/bc3lc/GCAM_v7p1_plus')
# libP <- .libPaths()
# .libPaths(c(libP,"/scratch/bc3lc/R-libs/4.1"))

## SSPs
gather_indicators <- function(ssp) {
  #################################### SDG1 ####################################
  ## List all RData files and gather in one list
  sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG1-GDP/indiv_results', pattern = ssp))
  base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG1-GDP/indiv_results'
  fin.list <- list()
  for (it in sub_prj_names) {
    print(it)
    tmp <- read.csv(file.path(base_path, it))
    dat_fin <- dplyr::bind_rows(tmp)
    fin.list[[it]] <- dat_fin
  }
  ## Gather and save
  dat_fin <- dplyr::bind_rows(fin.list)
  save(dat_fin, file = file.path('gcam_sdg/output/SDG1-GDP/', paste0('SDG1-GDP_',ssp,'.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG1-GDP/', paste0('SDG1-GDP_',ssp,'.csv')), row.names = F)

  #################################### SDG1 ####################################
  ## List all RData files and gather in one list
  sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG1-Expenditure/indiv_results', 
                     pattern = paste0('^SDG1_totalWorldExpPer.*', ssp)))
  base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG1-Expenditure/indiv_results'
  fin.list <- list()
  for (it in sub_prj_names) {
    print(it)
    tmp <- read.csv(file.path(base_path, it)) %>%
           dplyr::select(scenario, year, total_expenditure_per_world) %>%
           dplyr::distinct()
    dat_fin <- dplyr::bind_rows(tmp)
    fin.list[[it]] <- dat_fin
  }
  ## Gather and save
  dat_fin <- dplyr::bind_rows(fin.list)
  save(dat_fin, file = file.path('gcam_sdg/output/SDG1-Expenditure/', paste0('SDG1-Expenditure_',ssp,'.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG1-Expenditure/', paste0('SDG1-Expenditure_',ssp,'.csv')), row.names = F)

  #################################### SDG2 ####################################
  ## List all RData files and gather in one list
  sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG2-Poverty/indiv_results', pattern = paste0('fbbPerGlobal_',ssp)))
  base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG2-Poverty/indiv_results'
  fin.list <- list()
  for (it in sub_prj_names) {
    print(it)
    tmp <- read.csv(file.path(base_path, it))
    dat_fin <- dplyr::bind_rows(tmp)
    fin.list[[it]] <- dat_fin
  }
  ## Gather and save
  dat_fin <- dplyr::bind_rows(fin.list)
  save(dat_fin, file = file.path('gcam_sdg/output/SDG2-Poverty/', paste0('SDG2-Poverty_',ssp,'.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG2-Poverty/', paste0('SDG2-Poverty_',ssp,'.csv')), row.names = F)

  #################################### SDG3 ####################################
  ## List all RData files and gather in one list
  sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG3-Health/mort.fin', pattern = ssp))
  base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG3-Health/mort.fin'
  fin.list <- list()
  for (it in sub_prj_names) {
    print(it)
    tmp <- read.csv(file.path(base_path, it))
    dat_fin <- dplyr::bind_rows(tmp)
    fin.list[[it]] <- dat_fin
  }
  ## Gather and save
  dat_fin <- dplyr::bind_rows(fin.list)
  save(dat_fin, file = file.path('gcam_sdg/output/SDG3-Health/', paste0('SDG3-mort_',ssp,'.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG3-Health/', paste0('SDG3-mort_',ssp,'.csv')), row.names = F)

  #################################### SDG6 ####################################
  ## List all RData files and gather in one list
  sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG6-Water/indiv_results', pattern = paste0('wscarIndex_',ssp)))
  base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG6-Water/indiv_results'
  fin.list <- list()
  for (it in sub_prj_names) {
    print(it)
    tmp <- read.csv(file.path(base_path, it))
    dat_fin <- dplyr::bind_rows(tmp)
    fin.list[[it]] <- dat_fin
  }
  ## Gather and save
  dat_fin <- dplyr::bind_rows(fin.list)
  save(dat_fin, file = file.path('gcam_sdg/output/SDG6-Water/', paste0('SDG6-Water_',ssp,'.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG6-Water/', paste0('SDG6-Water_',ssp,'.csv')), row.names = F)

  #################################### SDG0 ####################################
  ## List all RData files and gather in one list
  sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG0-POP/indiv_results', pattern = paste0('pop_',ssp)))
  base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG0-POP/indiv_results'
  fin.list <- list()
  for (it in sub_prj_names) {
    print(it)
    tmp <- read.csv(file.path(base_path, it))
    dat_fin <- dplyr::bind_rows(tmp)
    fin.list[[it]] <- dat_fin
  }
  ## Gather and save
  dat_fin <- dplyr::bind_rows(fin.list)
  save(dat_fin, file = file.path('gcam_sdg/output/SDG0-POP/', paste0('SDG0-POP_',ssp,'.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG0-POP/', paste0('SDG0-POP_',ssp,'.csv')), row.names = F)

}

gather_indicators_ref <- function() {
  #################################### REF ####################################
  base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output'

  tag = 'SDG1-GDP/indiv_results'
  dat_fin <- read.csv(file.path(base_path, tag, c(list.files(file.path(base_path, tag), pattern = paste0('sdgstudy_base')))[1]))
  save(dat_fin, file = file.path('gcam_sdg/output/SDG1-GDP/', paste0('SDG1-GDP_','REF','.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG1-GDP/', paste0('SDG1-GDP_','REF','.csv')), row.names = F)

  tag = 'SDG1-Expenditure/indiv_results'
  dat_fin <- read.csv(file.path(base_path, tag, c(list.files(file.path(base_path, tag), pattern = paste0('totalWorldExpPer_sdgstudy_base')))[1])) %>%
           dplyr::select(scenario, year, total_expenditure_per_world) %>%
           dplyr::distinct()
  save(dat_fin, file = file.path('gcam_sdg/output/SDG1-Expenditure/', paste0('SDG1-Expenditure_','REF','.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG1-Expenditure/', paste0('SDG1-Expenditure_','REF','.csv')), row.names = F)

  tag = 'SDG2-Poverty/indiv_results'
  dat_fin <- read.csv(file.path(base_path, tag, c(list.files(file.path(base_path, tag), pattern = paste0('fbbPerGlobal_sdgstudy_base')))[1]))
  save(dat_fin, file = file.path('gcam_sdg/output/SDG2-Poverty/', paste0('SDG2-Poverty_','REF','.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG2-Poverty/', paste0('SDG2-Poverty_','REF','.csv')), row.names = F)

  tag = 'SDG3-Health/mort.fin'
  dat_fin <- read.csv(file.path(base_path, tag, c(list.files(file.path(base_path, tag), pattern = paste0('sdgstudy_base')))[1]))
  save(dat_fin, file = file.path('gcam_sdg/output/SDG3-Health/', paste0('SDG3-Health_','REF','.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG3-Health/', paste0('SDG3-Health_','REF','.csv')), row.names = F)

  tag = 'SDG6-Water/indiv_results'
  dat_fin <- read.csv(file.path(base_path, tag, c(list.files(file.path(base_path, tag), pattern = paste0('wscarIndex_sdgstudy_base')))[1]))
  save(dat_fin, file = file.path('gcam_sdg/output/SDG6-Water/', paste0('SDG6-Water_','REF','.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG6-Water/', paste0('SDG6-Water_','REF','.csv')), row.names = F)

  tag = 'SDG0-POP/indiv_results'
  dat_fin <- read.csv(file.path(base_path, tag, c(list.files(file.path(base_path, tag), pattern = paste0('pop_sdgstudy_base')))[1])) 
  save(dat_fin, file = file.path('gcam_sdg/output/SDG0-POP/', paste0('SDG0-POP_','REF','.RData')))
  write.csv(dat_fin, file = file.path('gcam_sdg/output/SDG0-POP/', paste0('SDG0-POP_','REF','.csv')), row.names = F)
}