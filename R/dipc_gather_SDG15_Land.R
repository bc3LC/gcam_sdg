# Main script to gather all GCAM projects in the DIPC given the folder path

## Set the working directory and load libraries
setwd('/scratch/bc3lc/GCAM_v7p1_plus')
libP <- .libPaths()
.libPaths(c(libP,"/scratch/bc3lc/R-libs/4.1"))

## List all RData files and gather in one list
sub_prj_names <- c(list.files('/scratch/bc3lc/GCAM_v7p1_plus/output/SDG15-Land/results/PSL-prj-results', pattern = '.csv'))
base_path <- '/scratch/bc3lc/GCAM_v7p1_plus/output/SDG15-Land/results/PSL-prj-results'
PSL.fin.list <- list()

# Loop through each file in sub_prj_names
for (it in sub_prj_names) {
  print(it)
  
  file_path <- file.path(base_path, it)  # Full path to the file
  
  # Check file extension to determine how to load it
  if (grepl("\\.RData$", it)) {  # If it's an RData file
    tmp <- get(load(file_path))  # Load the RData file
  } else if (grepl("\\.csv$", it)) {  # If it's a CSV file
    tmp <- read.csv(file_path)  # Read the CSV file
  } else {
    warning(paste("Skipping unsupported file type:", it))
    next
  }
  
  PSL_fin <- dplyr::bind_rows(tmp)  # Bind rows if needed (for multiple data frames)
  PSL.fin.list[[it]] <- PSL_fin  # Store in the list
}

## Gather and save
PSL_fin <- dplyr::bind_rows(PSL.fin.list)
# save(PSL_fin, file = 'output/SDG3-Health/mort.fin/mort.fin_ALL.RData')
write.csv(PSL_fin, file = file.path('output/SDG15-Land/results/','PSL_final_ALL.csv'), row.names = F)




