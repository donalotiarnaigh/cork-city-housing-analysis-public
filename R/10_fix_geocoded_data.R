# Script to fix geocoded data issues

# Load required libraries
library(tidyverse)
library(sf)

# Define base path
base_path <- "/Users/danieltierney/Documents/Cloud_FinalProject"

# Define Cork bounding box (roughly)
cork_bbox <- list(
  xmin = -9.00,  # Western extent
  xmax = -8.00,  # Eastern extent
  ymin = 51.75,  # Southern extent
  ymax = 52.25   # Northern extent
)

# Import cleaned data
ppr_clean <- st_read(file.path(base_path, "data/processed/ppr_geocoded_clean.gpkg"))

# Fix coordinate issues
ppr_fixed <- ppr_clean %>%
  # Remove empty geometries
  filter(!st_is_empty(geom)) %>%
  # Extract coordinates
  mutate(
    coords = st_coordinates(geom),
    longitude = coords[,1],
    latitude = coords[,2]
  ) %>%
  # Filter out invalid coordinates
  filter(
    !is.na(longitude),
    !is.na(latitude),
    between(longitude, -180, 180),
    between(latitude, -90, 90)
  ) %>%
  # Filter to Cork bounds
  filter(
    between(longitude, cork_bbox$xmin, cork_bbox$xmax),
    between(latitude, cork_bbox$ymin, cork_bbox$ymax)
  ) %>%
  # Round coordinates to 6 decimal places
  mutate(
    longitude = round(longitude, 6),
    latitude = round(latitude, 6)
  ) %>%
  # Recreate geometry from fixed coordinates
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  # Remove temporary coordinate columns
  select(-coords, -longitude, -latitude)

# Print summary
cat("\nData summary after fixing:\n")
cat("Total features:", nrow(ppr_fixed), "\n")
cat("CRS:", st_crs(ppr_fixed)$input, "\n")

# Check coordinate ranges
coords <- st_coordinates(ppr_fixed)
cat("\nCoordinate ranges:\n")
cat("Longitude range:", range(coords[,1]), "\n")
cat("Latitude range:", range(coords[,2]), "\n")

# Save fixed data
st_write(ppr_fixed, 
         file.path(base_path, "data/processed/ppr_geocoded_fixed.gpkg"),
         delete_layer = TRUE)

cat("\nFixed data saved to:", 
    file.path(base_path, "data/processed/ppr_geocoded_fixed.gpkg"), "\n") 