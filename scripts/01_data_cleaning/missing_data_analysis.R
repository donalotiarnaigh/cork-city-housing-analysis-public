# Missing Data Analysis Script
# This script analyzes patterns in missing data for the Cork City Airbnb dataset

# Load required packages
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(readr)
library(here)

# Import the Cork City filtered dataset
airbnb_cork <- readr::read_csv(here(here("data/processed/airbnb_cleaned_corkCity.csv")),
                              show_col_types = FALSE)

# Print basic information about the dataset
cat("Dataset Information:\n")
cat("-------------------\n")
cat("Number of listings:", nrow(airbnb_cork), "\n")
cat("Number of columns:", ncol(airbnb_cork), "\n\n")

# 1. Overall Missing Data Summary
cat("Missing Data Summary:\n")
cat("--------------------\n")

# Calculate missing data percentages
missing_summary <- airbnb_cork %>%
  summarise(across(everything(), ~sum(is.na(.))/n() * 100)) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_percentage") %>%
  arrange(desc(missing_percentage))

# Print columns with missing data
print(missing_summary %>% filter(missing_percentage > 0))

# Create visualization of missing data
missing_plot <- missing_summary %>%
  filter(missing_percentage > 0) %>%
  ggplot(aes(x = reorder(column, missing_percentage), y = missing_percentage)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Percentage of Missing Data by Column",
       x = "Column",
       y = "Percentage Missing") +
  theme_minimal()

# Save the plot
ggsave(here(here("output/missing_data_summary.png")), missing_plot, width = 10, height = 8)

# 2. Temporal Patterns
cat("\nTemporal Patterns in Missing Data:\n")
cat("--------------------------------\n")

# Create year and month columns from host_since
airbnb_cork <- airbnb_cork %>%
  mutate(
    host_since_year = year(host_since),
    host_since_month = month(host_since)
  )

# Analyze missing data by year
missing_by_year <- airbnb_cork %>%
  group_by(host_since_year) %>%
  summarise(
    n_listings = n(),
    missing_price = sum(is.na(price))/n() * 100,
    missing_bathrooms = sum(is.na(bathrooms))/n() * 100,
    missing_bedrooms = sum(is.na(bedrooms))/n() * 100,
    missing_neighborhood = sum(is.na(neighbourhood))/n() * 100
  )

print(missing_by_year)

# 3. Property Type Patterns
cat("\nMissing Data by Property Type:\n")
cat("----------------------------\n")

missing_by_property_type <- airbnb_cork %>%
  group_by(property_type) %>%
  summarise(
    n_listings = n(),
    missing_price = sum(is.na(price))/n() * 100,
    missing_bathrooms = sum(is.na(bathrooms))/n() * 100,
    missing_bedrooms = sum(is.na(bedrooms))/n() * 100,
    missing_neighborhood = sum(is.na(neighbourhood))/n() * 100
  ) %>%
  arrange(desc(n_listings))

print(missing_by_property_type)

# 4. Geographic Patterns
cat("\nGeographic Distribution of Missing Data:\n")
cat("--------------------------------------\n")

# Create a simple grid-based analysis
airbnb_cork <- airbnb_cork %>%
  mutate(
    lat_rounded = round(latitude, 2),
    lon_rounded = round(longitude, 2)
  )

missing_by_location <- airbnb_cork %>%
  group_by(lat_rounded, lon_rounded) %>%
  summarise(
    n_listings = n(),
    missing_price = sum(is.na(price))/n() * 100,
    missing_bathrooms = sum(is.na(bathrooms))/n() * 100,
    missing_bedrooms = sum(is.na(bedrooms))/n() * 100,
    missing_neighborhood = sum(is.na(neighbourhood))/n() * 100
  )

print(missing_by_location)

# 5. Host Patterns
cat("\nMissing Data by Host Characteristics:\n")
cat("-----------------------------------\n")

missing_by_host <- airbnb_cork %>%
  group_by(host_is_superhost) %>%
  summarise(
    n_listings = n(),
    missing_price = sum(is.na(price))/n() * 100,
    missing_bathrooms = sum(is.na(bathrooms))/n() * 100,
    missing_bedrooms = sum(is.na(bedrooms))/n() * 100,
    missing_neighborhood = sum(is.na(neighbourhood))/n() * 100
  )

print(missing_by_host)

# Save the analysis results
write.csv(missing_summary, here(here("output/missing_data_summary.csv")), row.names = FALSE)
write.csv(missing_by_year, here(here("output/missing_by_year.csv")), row.names = FALSE)
write.csv(missing_by_property_type, here(here("output/missing_by_property_type.csv")), row.names = FALSE)
write.csv(missing_by_location, here(here("output/missing_by_location.csv")), row.names = FALSE)
write.csv(missing_by_host, here(here("output/missing_by_host.csv")), row.names = FALSE)

# Print summary of findings
cat("\nKey Findings:\n")
cat("------------\n")
cat("1. Overall missing data rates for key columns:\n")
print(missing_summary %>% 
  filter(column %in% c("price", "bathrooms", "bedrooms", "neighbourhood")) %>%
  arrange(desc(missing_percentage)))

cat("\n2. Most common property types with missing data:\n")
print(missing_by_property_type %>% 
  filter(n_listings > 10) %>%
  arrange(desc(missing_price)) %>%
  head(5))

cat("\n3. Temporal trends in missing data:\n")
print(missing_by_year %>%
  arrange(host_since_year) %>%
  select(host_since_year, missing_price, missing_bathrooms, missing_bedrooms)) 
