# PPR Data Geocoding Script
# This script geocodes the cleaned PPR data using tidygeocoder

# Load required libraries
library(tidyverse)
library(tidygeocoder)
library(sf)
library(here)

# Set working directory
setwd("..")

# Function to geocode with retries
geocode_with_retry <- function(address, max_retries = 3, timeout = 30) {
  for (i in 1:max_retries) {
    tryCatch({
      result <- geocode(
        tibble(address = address),
        address = address,
        method = "osm",
        quiet = TRUE,
        timeout = timeout
      )
      return(result)
    }, error = function(e) {
      if (i == max_retries) {
        cat(sprintf("Failed to geocode address after %d retries: %s\n", max_retries, address))
        return(tibble(address = address, lat = NA, long = NA))
      }
      cat(sprintf("Retry %d for address: %s\n", i, address))
      Sys.sleep(5) # Wait 5 seconds before retrying
    })
  }
}

# Load cleaned PPR data
ppr_clean <- read_csv(here(here("data/processed/ppr_cleaned.csv")), show_col_types = FALSE)

# Create address string for geocoding
# We'll combine address components to create a full address
ppr_clean <- ppr_clean %>%
  mutate(
    full_address = paste(
      address,
      county,
      "Ireland",
      sep = ", "
    )
  )

# Check if we have a progress file
progress_file <- here(here("output/ppr_geocoded_progress.csv"))
if (file.exists(progress_file)) {
  geocoded_results <- read_csv(progress_file, show_col_types = FALSE)
  processed_addresses <- geocoded_results$full_address
  ppr_clean <- ppr_clean %>%
    filter(!full_address %in% processed_addresses)
  cat(sprintf("Resuming from %d processed addresses\n", length(processed_addresses)))
} else {
  geocoded_results <- tibble()
}

# Process in smaller batches with longer delays
batch_size <- 50  # Reduced batch size
total_rows <- nrow(ppr_clean)
num_batches <- ceiling(total_rows / batch_size)

# Process remaining addresses
for (i in 1:num_batches) {
  start_row <- ((i - 1) * batch_size) + 1
  end_row <- min(i * batch_size, total_rows)
  
  cat(sprintf("Processing batch %d of %d (rows %d to %d)\n", 
              i, num_batches, start_row, end_row))
  
  batch <- ppr_clean[start_row:end_row, ]
  
  # Geocode each address in the batch
  batch_results <- tibble()
  for (j in 1:nrow(batch)) {
    address <- batch$full_address[j]
    result <- geocode_with_retry(address)
    batch_results <- bind_rows(batch_results, result)
    
    # Save progress after each address
    if (nrow(batch_results) > 0) {
      if (nrow(geocoded_results) > 0) {
        write_csv(bind_rows(geocoded_results, batch_results), progress_file)
      } else {
        write_csv(batch_results, progress_file)
      }
    }
    
    # Add a small delay between addresses
    Sys.sleep(2)
  }
  
  # Add batch results to main results
  geocoded_results <- bind_rows(geocoded_results, batch_results)
  
  # Save progress after each batch
  write_csv(geocoded_results, progress_file)
  
  # Longer delay between batches
  Sys.sleep(10)
}

# Convert to spatial object
ppr_sf <- st_as_sf(
  geocoded_results,
  coords = c("long", "lat"),
  crs = 4326
)

# Save final results
write_csv(geocoded_results, here(here("output/ppr_geocoded.csv")))
st_write(ppr_sf, here(here("output/ppr_geocoded.gpkg")))

# Print summary
cat("\nGeocoding Summary:\n")
cat(sprintf("Total addresses processed: %d\n", nrow(geocoded_results)))
cat(sprintf("Successfully geocoded: %d\n", sum(!is.na(geocoded_results$lat))))
cat(sprintf("Failed to geocode: %d\n", sum(is.na(geocoded_results$lat)))) 
