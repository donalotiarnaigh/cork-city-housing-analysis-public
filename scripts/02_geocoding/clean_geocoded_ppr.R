# Script to clean and standardize geocoded PPR data

# Load required libraries
library(tidyverse)
library(sf)
library(here)

# Define base path
base_path <- "/Users/danieltierney/Documents/Cloud_FinalProject"

# Import geocoded data
ppr_geocoded <- st_read(file.path(base_path, here(here("data/processed/ppr_geocoded.gpkg"))))

# Print column names to debug
cat("\nAvailable columns:\n")
print(names(ppr_geocoded))

# Define Cork bounding box (roughly)
cork_bbox <- list(
  xmin = -9.00,  # Western extent
  xmax = -8.00,  # Eastern extent
  ymin = 51.75,  # Southern extent
  ymax = 52.25   # Northern extent
)

# Clean and standardize the data
ppr_clean <- ppr_geocoded %>%
  # Rename columns to be more intuitive
  rename(
    geocoding_score = Score,
    geocoding_match_type = Match_type,
    geocoding_match_address = Match_addr,
    longitude = X,
    latitude = Y,
    original_address = USER_addre,
    price = USER_price,
    property_description = USER_prope,
    not_full_market_price = USER_not_f,
    vat_exclusive = USER_vat_e,
    property_size = USER_pro_1
  ) %>%
  # Select only the columns we need
  select(
    geocoding_score,
    geocoding_match_type,
    geocoding_match_address,
    longitude,
    latitude,
    original_address,
    price,
    property_description,
    not_full_market_price,
    vat_exclusive,
    property_size,
    geom
  ) %>%
  # Add quality control flags
  mutate(
    geocoding_quality = case_when(
      st_is_empty(geom) ~ "failed",
      geocoding_score >= 90 ~ "high",
      geocoding_score >= 80 ~ "medium",
      TRUE ~ "low"
    ),
    in_cork_bounds = between(longitude, cork_bbox$xmin, cork_bbox$xmax) &
                     between(latitude, cork_bbox$ymin, cork_bbox$ymax),
    # Round coordinates to 6 decimal places (about 10cm precision)
    longitude = round(longitude, 6),
    latitude = round(latitude, 6)
  )

# Generate summary statistics
cat("\nGeocoding Quality Summary:\n")
print(table(ppr_clean$geocoding_quality))

cat("\nPoints within Cork bounds:\n")
print(table(ppr_clean$in_cork_bounds))

# Save cleaned data
st_write(ppr_clean, 
         file.path(base_path, here(here("data/processed/ppr_geocoded_clean.gpkg"))),
         delete_layer = TRUE)

# Save non-spatial version
ppr_clean_csv <- ppr_clean %>%
  st_drop_geometry() %>%
  write_csv(file.path(base_path, here(here("data/processed/ppr_geocoded_clean.csv"))))

# Print summary
cat("\nCleaned geocoded PPR data saved:\n")
cat(sprintf("1. GeoPackage: %s\n", file.path(base_path, here(here("data/processed/ppr_geocoded_clean.gpkg")))))
cat(sprintf("2. CSV: %s\n", file.path(base_path, here(here("data/processed/ppr_geocoded_clean.csv")))))

# Create a summary report
summary_report <- data.frame(
  metric = c(
    "Total records",
    "Failed geocoding",
    "High quality matches",
    "Medium quality matches",
    "Low quality matches",
    "Points within Cork bounds",
    "Points outside Cork bounds"
  ),
  value = c(
    nrow(ppr_clean),
    sum(ppr_clean$geocoding_quality == "failed"),
    sum(ppr_clean$geocoding_quality == "high"),
    sum(ppr_clean$geocoding_quality == "medium"),
    sum(ppr_clean$geocoding_quality == "low"),
    sum(ppr_clean$in_cork_bounds),
    sum(!ppr_clean$in_cork_bounds)
  )
)

# Save summary report
write_csv(summary_report, 
          file.path(base_path, here(here("data/processed/ppr_geocoding_summary.csv"))))

cat("\nSummary report saved to: ", 
    file.path(base_path, here(here("data/processed/ppr_geocoding_summary.csv"))), "\n") 
