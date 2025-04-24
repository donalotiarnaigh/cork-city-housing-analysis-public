library(readr)
library(dplyr)
library(sf)

# Load the false positive records that need to be restored
false_positives <- read_csv("fales_pos_incorrect_geocoded.csv")
cat("False positives dataset:", nrow(false_positives), "records\n")
cat("Columns in false positives:\n")
print(names(false_positives))

# Load the current app datasets
ppr_data_gpkg <- st_read("data/processed/final/ppr_corkCity_with_dates.gpkg", quiet = TRUE)
ppr_data_csv <- read_csv("data/processed/final/ppr_corkCity.csv")

cat("\nGPKG dataset:", nrow(ppr_data_gpkg), "records\n")
cat("Columns in GPKG dataset:\n")
print(names(ppr_data_gpkg))

cat("\nCSV dataset:", nrow(ppr_data_csv), "records\n")
cat("Columns in CSV dataset:\n")
print(names(ppr_data_csv))

# Check for column differences
cat("\nColumns only in GPKG dataset:\n")
print(setdiff(names(ppr_data_gpkg), names(false_positives)))

cat("\nColumns only in false positives dataset:\n")
print(setdiff(names(false_positives), names(ppr_data_gpkg)))

# Print sample data structures for debugging
cat("\nSample GPKG record structure:\n")
str(ppr_data_gpkg[1,])

cat("\nSample false positives structure:\n")
str(false_positives[1,]) 