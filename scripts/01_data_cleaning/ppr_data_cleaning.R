# PPR Data Cleaning Script
# This script performs initial cleaning and standardization of the Property Price Register data

# Load required packages
library(maps)
library(leaflet)
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
ppr_raw <- readr::read_csv(here(here("data/raw/property_sales/PPR-2024-Cork.csv")), 
                          locale = locale(encoding = "latin1"),
                          show_col_types = FALSE)

# Print column names for debugging
cat("Column names in raw data:\n")
print(names(ppr_raw))
cat("\n")

# Get the price column name
price_col <- names(ppr_raw)[5]

# Clean and standardize columns
ppr_clean <- ppr_raw %>%
  # Rename columns to remove spaces and special characters
  dplyr::rename(
    date_of_sale = `Date of Sale (dd/mm/yyyy)`,
    address = Address,
    county = County,
    eircode = Eircode,
    price = !!rlang::sym(price_col),
    not_full_market_price = `Not Full Market Price`,
    vat_exclusive = `VAT Exclusive`,
    property_description = `Description of Property`,
    property_size = `Property Size Description`
  ) %>%
  # Convert price to numeric (remove € symbol and commas)
  dplyr::mutate(
    # First remove any non-numeric characters except decimal point and comma
    price = stringr::str_replace_all(price, "[^0-9,.]", ""),
    # Then remove commas and convert to numeric
    price = as.numeric(stringr::str_replace_all(price, ",", ""))
  ) %>%
  # Convert date to proper date format
  dplyr::mutate(
    date_of_sale = lubridate::dmy(date_of_sale)
  ) %>%
  # Convert Yes/No to Boolean
  dplyr::mutate(
    not_full_market_price = ifelse(not_full_market_price == "Yes", TRUE, FALSE),
    vat_exclusive = ifelse(vat_exclusive == "Yes", TRUE, FALSE)
  ) %>%
  # Standardize address format
  dplyr::mutate(
    # Clean up whitespace
    address = stringr::str_trim(address),
    address = stringr::str_squish(address)
  ) %>%
  # Add unique identifier
  dplyr::mutate(
    id = row_number()
  )

############################################################################################################
## Data Validation ##

# Data validation checks
cat("Data Validation Checks:\n")
cat("----------------------\n")
cat("Number of rows:", nrow(ppr_clean), "\n")
cat("Number of columns:", ncol(ppr_clean), "\n")
cat("Missing values by column:\n")
print(colSums(is.na(ppr_clean)))
cat("\nPrice range:", range(ppr_clean$price, na.rm = TRUE), "\n")
cat("Date range:", range(ppr_clean$date_of_sale, na.rm = TRUE), "\n")

############################################################################################################
## Save and Summarize Data ##

# Save cleaned data
write.csv(ppr_clean, 
          here(here("data/processed/ppr_cleaned.csv")), 
          row.names = FALSE,
          fileEncoding = "UTF-8")

# Print summary of cleaned data
cat("\nSummary of cleaned data:\n")
cat("------------------------\n")
summary(ppr_clean) 
