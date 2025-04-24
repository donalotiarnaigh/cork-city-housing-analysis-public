# Script to standardize property types in PPR data

# Load required libraries
library(tidyverse)
library(sf)

# Define base path
base_path <- "/Users/danieltierney/Documents/Cloud_FinalProject"

# Import PPR data
ppr_data <- read_csv(file.path(base_path, "data/processed/ppr_corkCity.csv"))

# 1. Analyze current property descriptions
cat("\nCurrent property description distribution:\n")
property_dist <- ppr_data %>%
  count(property_description) %>%
  arrange(desc(n)) %>%
  mutate(percentage = round(n / sum(n) * 100, 2))

print(property_dist)

# 2. Create standardized categories
ppr_standardized <- ppr_data %>%
  mutate(
    # Create standardized property type
    property_type = case_when(
      str_detect(property_description, "New Dwelling house /Apartment") ~ "New Dwelling",
      str_detect(property_description, "Second-Hand Dwelling house /Apartment") ~ "Second-Hand Dwelling",
      str_detect(property_description, "Teach/Árasán") ~ "Other",
      TRUE ~ "Other"
    ),
    # Create market status
    market_status = case_when(
      not_full_market_price == TRUE ~ "Non-Market",
      vat_exclusive == TRUE ~ "VAT Exclusive",
      TRUE ~ "Full Market"
    )
  )

# 3. Verify the standardization
cat("\nStandardized property type distribution:\n")
type_dist <- ppr_standardized %>%
  count(property_type) %>%
  arrange(desc(n)) %>%
  mutate(percentage = round(n / sum(n) * 100, 2))

print(type_dist)

cat("\nMarket status distribution:\n")
market_dist <- ppr_standardized %>%
  count(market_status) %>%
  arrange(desc(n)) %>%
  mutate(percentage = round(n / sum(n) * 100, 2))

print(market_dist)

# 4. Save standardized data
write_csv(ppr_standardized, 
          file.path(base_path, "data/processed/ppr_corkCity_standardized.csv"))

cat("\nStandardized data saved to:", 
    file.path(base_path, "data/processed/ppr_corkCity_standardized.csv"), "\n")

# 5. Generate summary statistics by property type
cat("\nSummary statistics by property type:\n")
summary_stats <- ppr_standardized %>%
  group_by(property_type) %>%
  summarise(
    count = n(),
    avg_price = mean(price, na.rm = TRUE),
    median_price = median(price, na.rm = TRUE),
    min_price = min(price, na.rm = TRUE),
    max_price = max(price, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(across(where(is.numeric), ~round(., 2)))

print(summary_stats) 