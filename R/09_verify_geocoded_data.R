# Script to verify geocoded data for QGIS compatibility

# Load required libraries
library(tidyverse)
library(sf)

# Define base path
base_path <- "/Users/danieltierney/Documents/Cloud_FinalProject"

# Import cleaned data
ppr_clean <- st_read(file.path(base_path, "data/processed/ppr_geocoded_clean.gpkg"))

# Verify CRS
cat("\nCurrent CRS:\n")
print(st_crs(ppr_clean))

# Check for invalid geometries
invalid_geoms <- sum(!st_is_valid(ppr_clean))
cat("\nNumber of invalid geometries:", invalid_geoms, "\n")

# Check for empty geometries
empty_geoms <- sum(st_is_empty(ppr_clean))
cat("Number of empty geometries:", empty_geoms, "\n")

# Check coordinate ranges
coords <- st_coordinates(ppr_clean)
cat("\nCoordinate ranges:\n")
cat("Longitude range:", range(coords[,1]), "\n")
cat("Latitude range:", range(coords[,2]), "\n")

# Create a simplified version with only valid geometries
ppr_valid <- ppr_clean %>%
  filter(!st_is_empty(geom)) %>%
  filter(st_is_valid(geom))

# Save verified data
st_write(ppr_valid, 
         file.path(base_path, "data/processed/ppr_geocoded_verified.gpkg"),
         delete_layer = TRUE)

cat("\nVerified data saved to:", 
    file.path(base_path, "data/processed/ppr_geocoded_verified.gpkg"), "\n") 