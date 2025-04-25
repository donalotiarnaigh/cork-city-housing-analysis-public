# Airbnb Data Cleaning Script
# This script performs initial cleaning and standardization of the Airbnb listings data

# Load required packages
library(dplyr)
library(stringr)
library(lubridate)
library(readr)
library(stringi)
library(here)

# Set working directory (adjust as needed)
# setwd("path/to/your/project")

############################################################################################################
## Data Import and Cleaning ##

# Import raw CSV data with proper encoding
airbnb_raw <- readr::read_csv(here(here("data/raw/airbnb/listings.csv")), 
                             locale = locale(encoding = "UTF-8"),
                             show_col_types = FALSE)

# Print column names for debugging
cat("Column names in raw data:\n")
print(names(airbnb_raw))
cat("\n")

# Clean and standardize columns
airbnb_clean <- airbnb_raw %>%
  # Select and rename relevant columns
  dplyr::select(
    id,
    listing_url,
    name,
    description,
    neighborhood_overview,
    host_id,
    host_name,
    host_since,
    host_location,
    host_response_time,
    host_response_rate,
    host_acceptance_rate,
    host_is_superhost,
    host_listings_count,
    host_total_listings_count,
    host_verifications,
    host_has_profile_pic,
    host_identity_verified,
    neighbourhood,
    latitude,
    longitude,
    property_type,
    room_type,
    accommodates,
    bathrooms,
    bathrooms_text,
    bedrooms,
    beds,
    amenities,
    price,
    minimum_nights,
    maximum_nights,
    has_availability,
    availability_30,
    availability_60,
    availability_90,
    availability_365,
    calendar_last_scraped,
    number_of_reviews,
    number_of_reviews_ltm,
    number_of_reviews_l30d,
    first_review,
    last_review,
    review_scores_rating,
    review_scores_accuracy,
    review_scores_cleanliness,
    review_scores_checkin,
    review_scores_communication,
    review_scores_location,
    review_scores_value,
    instant_bookable,
    calculated_host_listings_count,
    calculated_host_listings_count_entire_homes,
    calculated_host_listings_count_private_rooms,
    calculated_host_listings_count_shared_rooms,
    reviews_per_month
  ) %>%
  # Convert price to numeric (remove $ symbol and commas)
  dplyr::mutate(
    price = as.numeric(stringr::str_replace_all(stringr::str_replace_all(price, "\\$", ""), ",", ""))
  ) %>%
  # Convert dates to proper date format
  dplyr::mutate(
    host_since = lubridate::ymd(host_since),
    first_review = lubridate::ymd(first_review),
    last_review = lubridate::ymd(last_review),
    calendar_last_scraped = lubridate::ymd(calendar_last_scraped)
  ) %>%
  # Convert percentages to numeric
  dplyr::mutate(
    host_response_rate = as.numeric(stringr::str_replace_all(host_response_rate, "%", "")) / 100,
    host_acceptance_rate = as.numeric(stringr::str_replace_all(host_acceptance_rate, "%", "")) / 100
  ) %>%
  # Convert Boolean columns
  dplyr::mutate(
    host_is_superhost = ifelse(host_is_superhost == "t", TRUE, FALSE),
    host_has_profile_pic = ifelse(host_has_profile_pic == "t", TRUE, FALSE),
    host_identity_verified = ifelse(host_identity_verified == "t", TRUE, FALSE),
    has_availability = ifelse(has_availability == "t", TRUE, FALSE),
    instant_bookable = ifelse(instant_bookable == "t", TRUE, FALSE)
  ) %>%
  # Clean text fields
  dplyr::mutate(
    name = stringr::str_trim(name),
    description = stringr::str_trim(description),
    neighborhood_overview = stringr::str_trim(neighborhood_overview)
  ) %>%
  # Add unique identifier (though id column already exists)
  dplyr::mutate(
    listing_id = id
  )

############################################################################################################
## Data Validation ##

# Data validation checks
cat("Data Validation Checks:\n")
cat("----------------------\n")
cat("Number of rows:", nrow(airbnb_clean), "\n")
cat("Number of columns:", ncol(airbnb_clean), "\n")
cat("Missing values by column:\n")
print(colSums(is.na(airbnb_clean)))
cat("\nPrice range:", range(airbnb_clean$price, na.rm = TRUE), "\n")
cat("Date range (host_since):", range(airbnb_clean$host_since, na.rm = TRUE), "\n")

############################################################################################################
## Save and Summarize Data ##

# Save cleaned data
write.csv(airbnb_clean, 
          here(here("data/processed/airbnb_cleaned.csv")), 
          row.names = FALSE,
          fileEncoding = "UTF-8")

# Print summary of cleaned data
cat("\nSummary of cleaned data:\n")
cat("------------------------\n")
summary(airbnb_clean) 
