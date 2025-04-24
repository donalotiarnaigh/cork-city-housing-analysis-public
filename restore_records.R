library(readr)
library(dplyr)
library(sf)
library(lubridate)

# Load the false positive records that need to be restored
false_positives <- read_csv("fales_pos_incorrect_geocoded.csv")
cat("Loaded", nrow(false_positives), "records to restore\n")

# Load the current app datasets
ppr_data_gpkg <- st_read("data/processed/final/ppr_corkCity_with_dates.gpkg", quiet = TRUE)
ppr_data_csv <- read_csv("data/processed/final/ppr_corkCity.csv")

# Print initial summary
cat("Initial datasets:\n")
cat("- GPKG dataset:", nrow(ppr_data_gpkg), "records\n")
cat("- CSV dataset:", nrow(ppr_data_csv), "records\n\n")

# Print column names for debugging
cat("Column names in GPKG dataset:\n")
print(names(ppr_data_gpkg))

# Check for duplicate records to avoid adding the same record twice
# Create match keys based on address and coordinates
fp_keys <- false_positives %>%
  mutate(
    match_key = paste(original_address, longitude, latitude, sep = "||")
  ) %>%
  pull(match_key)

ppr_data_gpkg_keys <- ppr_data_gpkg %>%
  mutate(
    match_key = paste(original_address, longitude, latitude, sep = "||")
  ) %>%
  pull(match_key)

# Identify which records need to be added (not already in the dataset)
new_record_indices <- which(!fp_keys %in% ppr_data_gpkg_keys)
cat("Records to add:", length(new_record_indices), "\n")

if (length(new_record_indices) > 0) {
  # Get the records to add
  records_to_add <- false_positives[new_record_indices, ]
  
  # Create backup of the original files
  file.copy("data/processed/final/ppr_corkCity_with_dates.gpkg", 
            "data/processed/final/ppr_corkCity_with_dates.gpkg.before_restore", 
            overwrite = TRUE)
  file.copy("data/processed/final/ppr_corkCity.csv", 
            "data/processed/final/ppr_corkCity.csv.before_restore", 
            overwrite = TRUE)
  
  # For CSV first (simpler case)
  # Add records to CSV dataset
  ppr_data_csv_restored <- rbind(ppr_data_csv, records_to_add)
  
  # For GPKG, we need a more careful approach
  cat("Creating spatial objects from false positive records...\n")
  
  # Convert to sf object
  records_to_add_sf <- st_as_sf(
    records_to_add,
    coords = c("longitude", "latitude"),
    crs = st_crs(ppr_data_gpkg)
  )
  
  # Store the coordinates separately (they'll be lost in the conversion)
  coords_temp <- data.frame(
    longitude = records_to_add$longitude,
    latitude = records_to_add$latitude
  )
  
  # Add missing date_of_sale column
  records_to_add_sf$date_of_sale <- as.Date(Sys.Date())
  
  # Get the geometry column name from the original data
  geom_col_name <- attr(ppr_data_gpkg, "sf_column")
  cat("Geometry column name in original data:", geom_col_name, "\n")
  
  # Rename the geometry column to match
  sf::st_geometry(records_to_add_sf) <- geom_col_name
  
  # Add back the coordinates
  records_to_add_sf$longitude <- coords_temp$longitude
  records_to_add_sf$latitude <- coords_temp$latitude
  
  # Make a complete copy of the GPKG dataset
  ppr_data_gpkg_restored <- ppr_data_gpkg
  
  # Add new records one by one
  for (i in 1:nrow(records_to_add_sf)) {
    # Ensure all columns match
    new_row <- records_to_add_sf[i, ]
    new_row <- new_row[, names(ppr_data_gpkg_restored)]
    
    # Bind the row
    ppr_data_gpkg_restored <- rbind(ppr_data_gpkg_restored, new_row)
  }
  
  # Print summary of added records
  cat("After restoration:\n")
  cat("- GPKG dataset:", nrow(ppr_data_gpkg_restored), "records\n")
  cat("- CSV dataset:", nrow(ppr_data_csv_restored), "records\n")
  cat("- Records added:", length(new_record_indices), "records\n\n")
  
  # Save the restored datasets
  st_write(ppr_data_gpkg_restored, "data/processed/final/ppr_corkCity_with_dates.gpkg", 
           delete_layer = TRUE, quiet = TRUE)
  write_csv(ppr_data_csv_restored, "data/processed/final/ppr_corkCity.csv")
  
  cat("Files have been restored with the previously removed records.\n")
  cat("Backups of the files before restoration were created with the .before_restore extension.\n")
} else {
  cat("No new records to add. All false positive records are already in the dataset.\n")
} 