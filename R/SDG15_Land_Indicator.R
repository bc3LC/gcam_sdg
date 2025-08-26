library(dplyr)
library(tidyr)

#' @param prj uploaded project file
#' @param saveOutput save the produced output
#' @param makeFigures generate and save graphical representation/s of the output
get_sdg15_land_indicator <- function(prj, saveOutput = T, makeFigures = F){

  print('computing sdg15 - land indicator ...')
  
  # Create the directories if they do not exist:
  if (!dir.exists("gcam_sdg/output")) dir.create("gcam_sdg/output")
  if (!dir.exists("gcam_sdg/output/SDG15-Land")) dir.create("gcam_sdg/output/SDG15-Land")
  if (!dir.exists("gcam_sdg/output/SDG15-Land/figures")) dir.create("gcam_sdg/output/SDG15-Land/figures")
  
  # Create outputs folders 
  if (!dir.create("gcam_sdg/output/SDG15-Land/results")) dir.create("gcam_sdg/output/SDG15-Land/results/")
  if (!dir.create("gcam_sdg/output/SDG15-Land/results/QGIS-input-files")) dir.create("gcam_sdg/output/SDG15-Land/results/QGIS-input-files")
  if (!dir.create("gcam_sdg/output/SDG15-Land/results/Processed-Demeter-outputs")) dir.create("gcam_sdg/output/SDG15-Land/results/Processed-Demeter-outputs")
  if (!dir.create("gcam_sdg/output/SDG15-Land/results/Output-data-by-ecoregion")) dir.create("gcam_sdg/output/SDG15-Land/results/Output-data-by-ecoregion")
  if (!dir.create("gcam_sdg/output/SDG15-Land/results/PSL-results")) dir.create("gcam_sdg/output/SDG15-Land/results/PSL-results")
  if (!dir.create("gcam_sdg/output/SDG15-Land/results/PSL-prj-results")) dir.create("gcam_sdg/output/SDG15-Land/results/PSL-prj-results")
  
  # Set the dipc path for the GCAM folder
  dipc_path = "/scratch/bc3lc/GCAM_v7p1_plus/"
  
  # Set the name of the conda environment read by reticulate
  use_condaenv("/scratch/bc3lc/conda-env/dem-env-3", required=TRUE)
  py_config()
  
  # Create vector of all scenarios in the project
  scen_name <- listScenarios(prj)
  
  # Upload basin mapping
  basin.id <- read.csv("gcam_sdg/data_PSL/basin_to_country_mapping.csv")
  print("Creating Demeter inputs from GCAM land allocation query")
  
  # Format GCAM land use outputs to fit as Demeter inputs 
  det.LU <- rgcam::getQuery(prj, "detailed land allocation") %>% 
    # Need to comment out the four next lines if using GCAM 7.0 and previous versions
    dplyr::mutate(landleaf = gsub("Hardwood_Forest", "Forest", landleaf)) %>%
    dplyr::mutate(landleaf = gsub("Softwood_Forest", "Forest", landleaf)) %>%
    dplyr::group_by(Units, scenario, region, landleaf, year) %>%
    dplyr::summarize(value = sum(value)) %>% ungroup() %>%
    tidyr::separate(landleaf, into = c("landclass", "GLU_name", "irrtype", "hiORlo"), sep = "_") %>%
    dplyr::mutate(landclass = case_when (!is.na(irrtype) ~ paste0(landclass,irrtype, hiORlo),TRUE ~ landclass)) %>%
    merge(basin.id,by="GLU_name") %>% dplyr::select(region, landclass, GCAM_basin_ID, year, value, scenario)  %>%
    dplyr::rename("metric_id"="GCAM_basin_ID") %>% spread(year, value) %>% dplyr::select(-"1975")
  
  # Get unique scenario names
  scenario_names <- unique(det.LU$scenario)
  
  # Create path for specific scenario
  dir_demeter <- "/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/demeter-2.0/demeter/GCAM_demeter_protection_scenario/outputs"
  
  # Loop to create one file per scenario in "input/projected" demeter folder and configuration files
  for (scenario_name in scenario_names) {
    
    # Filter the dataframe for the current scenario
    filtered_df <- det.LU[det.LU$scenario == scenario_name, ]
    
    # Define the file paths for saving the filtered dataframe and the configuration file
    file_path <- paste0("/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/demeter-2.0/demeter/GCAM_demeter_protection_scenario/inputs/projected/Scenario_", scenario_name, ".csv")
    config_path <- paste0("/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/demeter-2.0/demeter/GCAM_demeter_protection_scenario/config_files/Scenario_", scenario_name, ".ini")
    
    # Config file parameters
    projected_file <- paste0("Scenario_", scenario_name, ".csv")
    
    # Create the content for the config file
    config_file <- paste0(
      "[STRUCTURE]\n",
      "run_dir =                       /scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/demeter-2.0/demeter/GCAM_demeter_protection_scenario\n",
      "in_dir =                        inputs\n",
      "out_dir =                       outputs\n\n",
      "[INPUTS]\n",
      "allocation_dir =                allocation\n",
      "observed_dir =                  observed\n",
      "constraints_dir =               constraints\n",
      "projected_dir =                 projected\n\n",
      "[[ALLOCATION]]\n",
      "spatial_allocation_file =       gcam_regbasin_moirai_v3_type5_5arcmin_observed_alloc.csv\n",
      "gcam_allocation_file =          gcam_regbasin_moirai_v3_type5_5arcmin_projected_alloc.csv\n",
      "kernel_allocation_file =        gcam_regbasin_moirai_v3_type5_5arcmin_kernel_weighting.csv\n",
      "transition_order_file =         gcam_regbasin_moirai_v3_type5_5arcmin_transition_alloc.csv\n",
      "treatment_order_file =          gcam_regbasin_moirai_v3_type5_5arcmin_order_alloc.csv\n",
      "constraints_file =              gcam_regbasin_moirai_v3_type5_5arcmin_constraint_alloc.csv\n\n",
      "[[OBSERVED]]\n",
      "observed_lu_file =              baselayer_GCAM6_WGS84_5arcmin_2022_HighProt.zip\n\n",
      "[[PROJECTED]]\n",
      "projected_lu_file =             ", projected_file, "\n\n",
      "[[MAPPING]]\n",
      "region_mapping_file =           gcam_regions_32.csv\n",
      "basin_mapping_file =            gcam_basin_lookup.csv\n\n",
      "[PARAMS]\n",
      "# scenario name\n",
      "scenario =                      ", scenario_name, "\n\n",
      "# run description\n",
      "run_desc =                      ", scenario_name, "\n\n",
      "# spatial base layer id field name\n",
      "observed_id_field =             fid\n\n",
      "# first year to process\n",
      "start_year =                    2020\n\n",
      "# last year to process\n",
      "end_year =                      2050\n\n",
      "# enter 1 to use non-kernel density constraints, 0 to ignore non-kernel density constraints\n",
      "use_constraints =               1\n\n",
      "# the spatial resolution of the observed spatial data layer in decimal degrees\n",
      "spatial_resolution =            0.0833333\n\n",
      "# error tolerance in km2 for PFT area change not completed\n",
      "errortol =                      0.001\n\n",
      "# time step in years\n",
      "timestep =                      30\n\n",
      "# factor to multiply the projected land allocation by\n",
      "proj_factor =                   1000\n\n",
      "# from 0 to 1; ideal fraction of LUC that will occur during intensification, the remainder will be expansion\n",
      "intensification_ratio =         0.8\n\n",
      "# activates the stochastic selection of grid cells for expansion of any PFT\n",
      "stochastic_expansion =          1\n\n",
      "# threshold above which grid cells are selected to receive a given land type expansion; between 0 and 1, where 0 is all\n",
      "#     land cells can receive expansion and set to 1 only the grid cell with the maximum likelihood will expand.  For\n",
      "#     a 0.75 setting, only grid cells with a likelihood >= 0.75 x max_likelihood are selected.\n",
      "selection_threshold =           0.75\n\n",
      "# radius in grid cells to use when computing the kernel density; larger is smoother but will increase run-time\n",
      "kernel_distance =               30\n\n",
      "# create kernel density maps; 1 is True\n",
      "map_kernels =                   1\n\n",
      "# create land change maps per time step per land class\n",
      "map_luc_pft =                   0\n\n",
      "# create land change maps for each intensification and expansion step\n",
      "map_luc_steps =                 0\n\n",
      "# creates maps of land transitions for each time step\n",
      "map_transitions =               0\n\n",
      "# years to save data for, default is all; otherwise a semicolon delimited string e.g, 2005;2050\n",
      "target_years_output =           all\n\n",
      "# save tabular spatial landcover as CSV; define tabular_units below (default sqkm)\n",
      "save_tabular =                  0\n\n",
      "# untis to output tabular data in (sqkm or fraction)\n",
      "tabular_units =                 sqkm\n\n",
      "# exports CSV files of land transitions for each time step in km2\n",
      "save_transitions =              0\n\n",
      "# create a NetCDF file of land cover percent for each year by grid cell containing each land class\n",
      "save_netcdf_yr =                1\n"
    )
    
    # Save the filtered dataframe to CSV as "projected" Demeter input 
    write.csv(filtered_df, file = file_path, row.names = FALSE)
    write(config_file, file = config_path)
    
    # Import Python module and Run Demeter (approx. 50 min per scenario)
    print(paste0("Importing and running Demeter for ", scenario_name))
    sys <- reticulate::import("sys")
    demeter <- reticulate::import("demeter")
    config_path = "gcam_sdg/demeter-2.0/demeter/GCAM_demeter_protection_scenario/config_files/"
    config_name = paste0("Scenario_", scenario_name, ".ini")
    # dipc_path = "/scratch/bc3lc/GCAM_v7p1_plus/"
    config_file = paste0("/scratch/bc3lc/GCAM_v7p1_plus/",config_path, config_name)
    demeter$run_model(config_file=config_file, write_outputs=TRUE)
    print(paste0("Demeter run for scenario ", scenario_name, " completed"))
    
  }
  print(paste0("Demeter runs completed for all scenarios of database ", db_name))
  
  # Extract surfaces by land use type from the netCDF files
  year <- c('2020','2050')
  output_year <- data.frame(year)
  areas_land_types <- read.csv("gcam_sdg/data_PSL/Coordinates.csv")

  # List and rename files 
  folders <- list.dirs(dir_demeter, full.names = FALSE, recursive = FALSE)
  
  # Filter folders using grep to match any of the scenario names as a substring
  scenario_folders <- folders[sapply(folders, function(folder) {
    any(grepl(paste(scenario_names, collapse = "|"), folder))
  })]

  # Loop through each file
  for (folder in scenario_folders) {
    # Full path of the original file
    old_folder_path <- file.path(dir_demeter, folder)
    # Use sub to extract the scenario name, everything before the first underscore
    new_name <- sub("_2024.+", "", folder)
    # Full path for the new file name
    new_folder_path <- file.path(dir_demeter, new_name)
    # Rename the file
    file.rename(old_folder_path, new_folder_path)
  }
  
  # Load & Process Ecoregions shp ---- 
  print("Loading and processing Ecoregion data")
  ecoregions_shp <- st_read("gcam_sdg/data_PSL/Ecoregions_shp/wwf_terr_ecos.shp")
  # Check the geometries
  ecoregions_valid <- st_is_valid(ecoregions_shp)
  # Identify invalid geometries
  invalid_ecoregions <- ecoregions_shp[!ecoregions_valid, ]
  # Fix the geometries 
  ecoregions_shp = st_make_valid(ecoregions_shp)
  # Simplify ecoregions
  ecoregions_id <- ecoregions_shp %>% 
    dplyr::select(all_of(c("OBJECTID", "eco_code")))
  length(unique(ecoregions_id$OBJECTID))
  # Read file with the Ecoregion names from Chaudhary and Brookes (2018)
  ecoregions_ID <- read.csv("gcam_sdg/data_PSL/Ecoregion ID.csv")
  # Create the final CSV that will receive the PSL results (one line per scenario)
  final_csv = read.csv("gcam_sdg/data_PSL/PSL_template.csv")
  
  print("Starting to create the dataframes from NetCDF files")
  # Create the NetCDF Files ----
  for (scenario_name in scenario_names) {
    for (j in 1:2) {
      
      # Initialize the receiving dataframe 
      merge_df = read.csv("gcam_sdg/data_PSL/lonlat_coord")
      merge_df = merge_df[,2:3]
      
      # Create path components 
      netcdffolder <- "spatial_landcover_netcdf"
      nc_file <- paste0("_demeter_",scenario_name,"_",output_year[j,1],".nc")
      NetCDFfiles_path <- file.path(dir_demeter,scenario_name,netcdffolder,nc_file)
      print(NetCDFfiles_path)
      # Read the nc file from Demeter outputs
      ncin <- nc_open(NetCDFfiles_path)
      
      # Set the list of variables 
      variables = names(ncin$var)
      
      # Get longitude and latitude
      lon <- ncvar_get(ncin,"longitude")
      nlon <- dim(lon)
      head(lon)
      lat <- ncvar_get(ncin,"latitude")
      nlat <- dim(lat)
      head(lat)
      lonlat <- as.matrix(expand.grid(lon, lat))
      dim(lonlat)
      
      # Function to create dataframes from the variables of the nc file
      for (i in 1:length(variables)) {
        
        # i = 5
        landuse_df <- na.omit(data.frame(cbind(lonlat, as.vector(ncvar_get(ncin, ncin$var[[i]])))))
        names(landuse_df) <- c("lon", "lat", paste(ncin$var[[i]]$longname)) # instead of landuse, the longname of the variable i
        # assign(paste(ncin$var[[i]]$longname, "df", sep="_"), landuse_df)
        merge_df = merge(merge_df, landuse_df)
        print(ncin$var[[i]]$longname)
        
      }
      
      # Now create a new column with the sum of the columns that finish by "irrigated" 
      merge_df$crop_irr = rowSums(merge_df[, grepl("irrigated", names(merge_df))])
      merge_df$crop_rfd = rowSums(merge_df[, grepl("rainfed|otherarableland", names(merge_df))])
      
      merge_df = merge_df %>% 
        dplyr::select(!contains("irrigated")) %>% 
        dplyr::select(!contains("rainfed")) %>% 
        dplyr::select(!contains("otherarableland")) %>%
        dplyr::select(!c(basin_id, region_id, water))
      
      # assign(paste(ncin$var[[i]]$longname, "df", sep="_"), merge_df)
      assign(paste("merge", j, "df", sep="_"), merge_df)
      
    }
    
    print(paste0("LUC dataframe for scenario ", scenario_name, " created from Demeter outputs"))
    
    # Merge 2020 and 2050 
    merge_df = merge(merge_1_df, merge_2_df, by = c("lon", "lat"))
    
    # Geography parameters 
    areas_land_types <- merge_df %>% rename ("longitude"="lon") %>% rename ("latitude"="lat")
    areas_land_types_shp <- areas_land_types
    coordinates(areas_land_types_shp)=~longitude+latitude
    proj4string(areas_land_types_shp)<- CRS("+proj=longlat +datum=WGS84")
    areas_land_types_shp = st_as_sf(areas_land_types_shp)
    
    # Unique geometries
    unique(st_geometry_type(areas_land_types_shp$geometry))
    
    # Check the classes
    class(areas_land_types_shp)
    crs(areas_land_types_shp)
    areas_land_types_shp = st_transform(areas_land_types_shp, crs=4326)
    
    # Check the geometries
    areas_land_types_valid <- st_is_valid(areas_land_types_shp)
    
    # Identify invalid geometries
    invalid_areas_land_types <- areas_land_types_shp[!areas_land_types_valid, ]
    
    # Join attributes by location 
    joined_shp_id = st_join(areas_land_types_shp, ecoregions_id, join = st_intersects) # way too long, need to simply both with index 
    
    # Aggregate per land use, dropping geometry
    joined_shp_agg <- joined_shp_id %>%
      st_drop_geometry() %>%
      group_by(OBJECTID) %>% 
      summarise(
                forest.x = sum(forest.x),
                pasture.x = sum(pasture.x),
                crop_irr.x = sum(crop_irr.x),
                crop_rfd.x = sum(crop_rfd.x),
                forest.y = sum(forest.y),
                pasture.y = sum(pasture.y),
                crop_irr.y = sum(crop_irr.y),
                crop_rfd.y = sum(crop_rfd.y),
                ) %>% 
      ungroup() %>% 
      full_join(ecoregions_shp[,c(1,18)]) %>%
      rename(ECOREGION_CODE = eco_code) %>%
      mutate_at(vars(-ECOREGION_CODE), ~replace(., is.na(.), 0))
    
    # Incorporate the ecoregions names from Chaudhary and Brookes (2018) to the Results matrix obtained from QGIS with data on land use type area changes over time
    # Conversion function from square km to square meters
    sqm <- function(x, na.rm = FALSE) (x*1000000)
    
    joined_shp_extended <- joined_shp_agg %>% 
      merge(ecoregions_ID,by="ECOREGION_CODE") %>%  
      relocate(ECO_NAME, .after=ECOREGION_CODE) %>%  
      group_by(ECOREGION_CODE,ECO_NAME) %>%
      summarise(across(where(is.numeric), sum)) %>% 
      dplyr::select(-OBJECTID) %>% 
      mutate_if(is.numeric, sqm, na.rm = FALSE) %>% 
      ungroup() %>% 
      as.data.frame() %>% 
      mutate(
             forest.diff = forest.y - forest.x,
             pasture.diff = pasture.y - pasture.x,
             crop_irr.diff = crop_irr.y - crop_irr.x,
             crop_rfd.diff = crop_rfd.y - crop_rfd.x,
        )
    
    # Estimate the final PSL number with CF file 
    CF = read.csv("gcam_sdg/data_PSL/CF.csv")
    
    final = merge(joined_shp_extended, CF, by = c("ECOREGION_CODE")) %>% 
      mutate(
             forest_PSL = forest.diff * Forest_CF,
             pasture_PSL = pasture.diff * Pasture_CF,
             crop_irr_PSL = crop_irr.diff * Irrigated_crop_CF,
             crop_rfd_PSL = crop_rfd.diff * Rainfed_crop_CF,
             ) %>% 
      mutate(final_PSL = rowSums(across(ends_with("_PSL"))))
    
    # Aggregate across the ecoregions and compute final PSL across land uses
    final_agg = final %>% 
      summarize(
                forest_PSL = sum(forest_PSL),
                pasture_PSL = sum(pasture_PSL),
                crop_irr_PSL = sum(crop_irr_PSL),
                crop_rfd_PSL = sum(crop_rfd_PSL),
                final_PSL = sum(final_PSL)
                ) %>% 
      mutate(scenario = scenario_name)
    
    # Delete the first column X
    final_agg = final_agg[,-1]
    
    # write.xlsx(final_agg,paste0(dipc_path,"results/PSL-results/",scenario_name,"_PSL_2020_2050.xlsx"), overwrite = TRUE, rowNames=TRUE, colNames=TRUE)          
    if (saveOutput) write.csv(final_agg,paste0("/scratch/bc3lc/GCAM_v7p1_plus/gcam_sdg/output/SDG15-Land/results/PSL-results/",scenario_name,"_PSL_2020_2050.csv"), row.names = F)       
    
    print(paste0("PSL dataframe for scenario ", scenario_name, " saved in results"))
    final_csv <- rbind(final_csv, final_agg)

  }
  
  # Write CSV
  if (saveOutput) write.csv(final_csv, file = file.path('gcam_sdg/output/SDG15-Land/results/PSL-prj-results/',paste0('PSL_',gsub("\\.dat$", "", prj_name, ".csv"))), row.names = F)
  print(paste0("PSL dataframe for all scenarios of the ", prj_name, " saved in results"))
  return(invisible(final_csv))
  
}

