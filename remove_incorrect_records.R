library(readr)
library(dplyr)
library(sf)

# Load the potentially incorrect records
potentially_incorrect <- read_csv("potentially_incorrect_records.csv")

# Load the current app datasets
ppr_data_gpkg <- st_read("data/processed/final/ppr_corkCity_with_dates.gpkg", quiet = TRUE)
ppr_data_csv <- read_csv("data/processed/final/ppr_corkCity.csv")

# Print initial summary
cat("Initial datasets:\n")
cat("- GPKG dataset:", nrow(ppr_data_gpkg), "records\n")
cat("- CSV dataset:", nrow(ppr_data_csv), "records\n")
cat("- Potentially incorrect records:", nrow(potentially_incorrect), "records\n\n")

# Create match keys to identify records to remove based on address and coordinates
incorrect_keys <- potentially_incorrect %>%
  mutate(
    match_key = paste(original_address, longitude, latitude, sep = "||")
  ) %>%
  pull(match_key)

# Clean GPKG dataset
ppr_data_gpkg_clean <- ppr_data_gpkg %>%
  mutate(
    match_key = paste(original_address, st_coordinates(.)[,1], st_coordinates(.)[,2], sep = "||")
  ) %>%
  filter(!match_key %in% incorrect_keys) %>%
  select(-match_key)

# Clean CSV dataset
ppr_data_csv_clean <- ppr_data_csv %>%
  mutate(
    match_key = paste(original_address, longitude, latitude, sep = "||")
  ) %>%
  filter(!match_key %in% incorrect_keys) %>%
  select(-match_key)

# Print summary of removed records
cat("After cleaning:\n")
cat("- GPKG dataset:", nrow(ppr_data_gpkg_clean), "records\n")
cat("- CSV dataset:", nrow(ppr_data_csv_clean), "records\n")
cat("- Records removed:", nrow(ppr_data_gpkg) - nrow(ppr_data_gpkg_clean), "records\n\n")

# Create backup of the original files
file.copy("data/processed/final/ppr_corkCity_with_dates.gpkg", 
          "data/processed/final/ppr_corkCity_with_dates.gpkg.bak", 
          overwrite = TRUE)
file.copy("data/processed/final/ppr_corkCity.csv", 
          "data/processed/final/ppr_corkCity.csv.bak", 
          overwrite = TRUE)

# Save the cleaned datasets
st_write(ppr_data_gpkg_clean, "data/processed/final/ppr_corkCity_with_dates.gpkg", 
         delete_layer = TRUE, quiet = TRUE)
write_csv(ppr_data_csv_clean, "data/processed/final/ppr_corkCity.csv")

cat("Files have been cleaned and saved.\n")
cat("Backups of the original files were created with the .bak extension.\n") 