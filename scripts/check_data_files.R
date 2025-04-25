# Data file inventory script for Cork City Property Analysis
# This script checks if required data files exist in the expected locations

# Load required packages
if (!require("here")) {
  install.packages("here", repos = "https://cloud.r-project.org")
}
library(here)

# Function to log message with timestamp
log_message <- function(message) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(paste0("[", timestamp, "] ", message, "\n"))
}

log_message("Starting data file inventory...")

# List of expected data files and their locations
expected_files <- list(
  # Raw data
  list(
    path = here("data/raw/airbnb/listings.csv"),
    description = "Airbnb listings raw data",
    required_by = "scripts/01_data_cleaning/airbnb_data_cleaning.R"
  ),
  list(
    path = here("data/raw/property_sales/PPR-2024-Cork.csv"),
    description = "Property Price Register raw data",
    required_by = "scripts/01_data_cleaning/ppr_data_cleaning.R"
  ),
  
  # Processed data
  list(
    path = here("data/processed/ppr_cleaned.csv"),
    description = "Cleaned PPR data",
    required_by = "scripts/02_geocoding/ppr_geocoding.R"
  ),
  list(
    path = here("data/processed/airbnb_cleaned_corkCity.csv"),
    description = "Cleaned Airbnb data",
    required_by = "scripts/01_data_cleaning/create_complete_dataset.R"
  ),
  
  # Final data
  list(
    path = here("data/processed/final/ppr_corkCity.csv"),
    description = "Final PPR data for Cork City",
    required_by = "app/app.R"
  ),
  list(
    path = here("data/processed/final/airbnb_corkCity.gpkg"),
    description = "Final Airbnb data for Cork City",
    required_by = "app/app.R"
  ),
  list(
    path = here("data/processed/final/ppr_corkCity_with_dates.gpkg"),
    description = "Final PPR data with dates",
    required_by = "app/app.R"
  ),
  list(
    path = here("data/processed/final/airbnb_corkCity_with_dates.gpkg"),
    description = "Final Airbnb data with dates",
    required_by = "app/app.R"
  ),
  
  # Boundaries
  list(
    path = here("data/boundaries/cork_city_boundary.gpkg"),
    description = "Cork City boundary data",
    required_by = "app/app.R"
  )
)

# Check each file and report status
missing_files <- list()
for (file_info in expected_files) {
  file_path <- here(file_info$path)
  if (file.exists(file_path)) {
    log_message(paste("✓ FOUND:", file_info$path))
  } else {
    log_message(paste("✗ MISSING:", file_info$path))
    missing_files[[length(missing_files) + 1]] <- file_info
  }
}

# Print summary
cat("\n===========================================================\n")
cat("DATA FILE INVENTORY SUMMARY\n")
cat("===========================================================\n")
cat("Total files checked:", length(expected_files), "\n")
cat("Files found:", length(expected_files) - length(missing_files), "\n")
cat("Files missing:", length(missing_files), "\n")

# Report missing files
if (length(missing_files) > 0) {
  cat("\n===========================================================\n")
  cat("MISSING FILES DETAILS\n")
  cat("===========================================================\n")
  for (i in seq_along(missing_files)) {
    file_info <- missing_files[[i]]
    cat(i, ". ", file_info$path, "\n", sep = "")
    cat("   Description: ", file_info$description, "\n", sep = "")
    cat("   Required by: ", file_info$required_by, "\n", sep = "")
    cat("\n")
  }
  
  # Suggest actions
  cat("===========================================================\n")
  cat("ACTION PLAN\n")
  cat("===========================================================\n")
  cat("1. Check if raw data is available and placed in the correct locations\n")
  cat("2. Run the data processing scripts in order to generate missing files\n")
  cat("3. If raw data is missing, obtain it from the original sources and place in:\n")
  cat("   - Airbnb data: data/raw/airbnb/\n")
  cat("   - Property data: data/raw/property_sales/\n")
}

cat("\n===========================================================\n") 
