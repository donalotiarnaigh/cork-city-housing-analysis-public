# Restore Price Column for Airbnb Cork City Dataset
# This script adds the missing price column from airbnb_cleaned_corkCity.csv
# to the spatial dataset airbnb_corkCity.gpkg

# Load required libraries
library(sf)
library(dplyr)
library(readr)
library(here)

# Set paths
cleaned_csv_path <- here(here("data/processed/airbnb_cleaned_corkCity.csv"))
spatial_gpkg_path <- here(here("data/processed/final/airbnb_corkCity.gpkg"))
output_gpkg_path <- here(here("data/processed/final/airbnb_corkCity_with_price.gpkg"))
output_csv_path <- here(here("data/processed/final/airbnb_corkCity_with_price.csv"))

# Print status
cat("Restoring price column to Airbnb Cork City dataset\n")
cat("--------------------------------------------------\n")

# Load datasets
cat("Loading datasets...\n")

# Load the cleaned CSV data that contains the price column
cat("Loading cleaned CSV data with price information...\n")
airbnb_cleaned <- read_csv(cleaned_csv_path, show_col_types = FALSE)
cat(paste("Loaded", nrow(airbnb_cleaned), "records from cleaned CSV\n"))
cat(paste("Price column present:", "price" %in% names(airbnb_cleaned), "\n"))

# Check if price column exists
if (!("price" %in% names(airbnb_cleaned))) {
  stop("Price column not found in the source cleaned CSV file!")
}

# Load the spatial data
cat("Loading spatial data...\n")
airbnb_spatial <- st_read(spatial_gpkg_path, quiet = TRUE)
cat(paste("Loaded", nrow(airbnb_spatial), "records from spatial dataset\n"))

# Extract key identifiers - id and listing_id should be the same but we'll check both
cat("Preparing to merge datasets...\n")
if ("id" %in% names(airbnb_spatial) && "id" %in% names(airbnb_cleaned)) {
  cat("Using 'id' column for merging\n")
  key_col <- "id"
} else if ("listing_id" %in% names(airbnb_spatial) && "listing_id" %in% names(airbnb_cleaned)) {
  cat("Using 'listing_id' column for merging\n")
  key_col <- "listing_id"
} else {
  # If neither is available, we'll try to identify a suitable key column
  spatial_cols <- names(airbnb_spatial)
  cleaned_cols <- names(airbnb_cleaned)
  common_cols <- intersect(spatial_cols, cleaned_cols)
  
  # Look for columns that might be identifiers
  possible_keys <- common_cols[grepl("id", common_cols, ignore.case = TRUE)]
  
  if (length(possible_keys) > 0) {
    key_col <- possible_keys[1]
    cat(paste("Using", key_col, "column for merging\n"))
  } else {
    stop("No suitable ID column found for merging datasets!")
  }
}

# Extract just the columns we need from the cleaned data
price_data <- airbnb_cleaned %>%
  select(!!key_col, price)

# Convert price column to numeric if it's not already
price_data$price <- as.numeric(price_data$price)

# Log price stats from source data
cat("\nPrice statistics from source data:\n")
price_summary <- summary(price_data$price)
cat(paste("Min:", price_summary[1], "\n"))
cat(paste("Median:", price_summary[3], "\n"))
cat(paste("Mean:", mean(price_data$price, na.rm = TRUE), "\n"))
cat(paste("Max:", price_summary[6], "\n"))
cat(paste("Missing values:", sum(is.na(price_data$price)), "\n\n"))

# Merge the price data with the spatial data
cat("Merging price data with spatial data...\n")
airbnb_with_price <- left_join(airbnb_spatial, price_data, by = key_col)

# Check results
n_with_price <- sum(!is.na(airbnb_with_price$price))
cat(paste("Records with price data after merge:", n_with_price, "out of", nrow(airbnb_with_price), "\n"))
cat(paste("Percentage with price:", round(n_with_price/nrow(airbnb_with_price)*100, 1), "%\n"))

# Save the results
cat("\nSaving results...\n")

# Save as GeoPackage
st_write(airbnb_with_price, output_gpkg_path, delete_layer = TRUE)
cat(paste("Spatial data with price saved to:", output_gpkg_path, "\n"))

# Save as CSV (need to extract coordinates first)
airbnb_csv <- airbnb_with_price
coordinates <- st_coordinates(airbnb_csv)
airbnb_csv$longitude <- coordinates[, 1]  
airbnb_csv$latitude <- coordinates[, 2]
airbnb_csv <- st_drop_geometry(airbnb_csv)  # Remove geometry column

# Save CSV
write_csv(airbnb_csv, output_csv_path)
cat(paste("CSV data with price saved to:", output_csv_path, "\n"))

cat("\nProcess complete!\n")
cat("You can now update R/13_price_statistics.R to use the new dataset paths:\n")
cat("- airbnb_path <- \here(here("data/processed/final/airbnb_corkCity_with_price.gpkg\"))\n") 
