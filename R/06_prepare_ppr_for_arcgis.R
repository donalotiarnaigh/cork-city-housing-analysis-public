# Script to prepare PPR data for ArcGIS Pro geocoding

# Load required libraries
library(tidyverse)
library(sf)

# Define base path
base_path <- "/Users/danieltierney/Documents/Cloud_FinalProject"

# Load cleaned PPR data
ppr_clean <- read_csv(file.path(base_path, "data/processed/ppr_cleaned.csv"), show_col_types = FALSE)

# Print column names to check
cat("Available columns:\n")
print(names(ppr_clean))

# Create address string for geocoding
ppr_for_arcgis <- ppr_clean %>%
  mutate(
    # Create a full address string
    full_address = paste(
      address,
      county,
      "Ireland",
      sep = ", "
    ),
    # Create a unique ID for each record
    arcgis_id = row_number()
  ) %>%
  # Select and rename columns for ArcGIS
  select(
    arcgis_id,
    address = full_address,
    price,
    property_description,
    not_full_market_price,
    vat_exclusive,
    property_size
  )

# Save as CSV for ArcGIS Pro
write_csv(ppr_for_arcgis, file.path(base_path, "data/processed/ppr_for_arcgis.csv"))

# Print summary
cat("\nData prepared for ArcGIS Pro geocoding:\n")
cat(sprintf("Total records: %d\n", nrow(ppr_for_arcgis)))
cat(sprintf("Output file: %s\n", file.path(base_path, "data/processed/ppr_for_arcgis.csv"))) 