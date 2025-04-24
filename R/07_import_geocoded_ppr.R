# Script to import geocoded PPR data from shapefile

# Load required libraries
library(tidyverse)
library(sf)

# Define base path
base_path <- "/Users/danieltierney/Documents/Cloud_FinalProject"

# Import shapefile
ppr_geocoded <- st_read(file.path(base_path, "data/processed/ppr_geocoded_features.shp"))

# Print summary of the data
cat("\nGeocoded PPR Data Summary:\n")
cat(sprintf("Number of records: %d\n", nrow(ppr_geocoded)))
cat(sprintf("Coordinate Reference System: %s\n", st_crs(ppr_geocoded)$input))
cat("\nAvailable columns:\n")
print(names(ppr_geocoded))

# Save as GeoPackage for future use
st_write(ppr_geocoded, 
         file.path(base_path, "data/processed/ppr_geocoded.gpkg"),
         delete_layer = TRUE)

# Save as CSV with coordinates
ppr_geocoded_csv <- ppr_geocoded %>%
  mutate(
    longitude = st_coordinates(.)[,1],
    latitude = st_coordinates(.)[,2]
  ) %>%
  st_drop_geometry()

write_csv(ppr_geocoded_csv, 
          file.path(base_path, "data/processed/ppr_geocoded.csv"))

# Print summary of saved files
cat("\nFiles saved:\n")
cat(sprintf("1. GeoPackage: %s\n", file.path(base_path, "data/processed/ppr_geocoded.gpkg")))
cat(sprintf("2. CSV with coordinates: %s\n", file.path(base_path, "data/processed/ppr_geocoded.csv"))) 