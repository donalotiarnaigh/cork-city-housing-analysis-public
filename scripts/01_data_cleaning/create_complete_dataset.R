# Create Complete Dataset Script
# This script creates a dataset containing only columns with no missing values

# Load required packages
library(dplyr)
library(readr)
library(here)

# Import the Cork City filtered dataset
airbnb_cork <- readr::read_csv(here(here("data/processed/airbnb_cleaned_corkCity.csv")),
                              show_col_types = FALSE)

# Print initial dataset info
cat("Original Dataset Information:\n")
cat("---------------------------\n")
cat("Number of listings:", nrow(airbnb_cork), "\n")
cat("Number of columns:", ncol(airbnb_cork), "\n\n")

# Identify columns with no missing values
missing_counts <- colSums(is.na(airbnb_cork))
complete_columns <- names(missing_counts[missing_counts == 0])

# Create dataset with only complete columns
airbnb_cork_complete <- airbnb_cork %>%
  select(all_of(complete_columns))

# Print information about the complete dataset
cat("Complete Dataset Information:\n")
cat("--------------------------\n")
cat("Number of listings:", nrow(airbnb_cork_complete), "\n")
cat("Number of columns:", ncol(airbnb_cork_complete), "\n\n")

cat("Columns retained in complete dataset:\n")
cat("----------------------------------\n")
print(names(airbnb_cork_complete))

# Save the complete dataset
write.csv(airbnb_cork_complete, 
          here(here("data/processed/airbnb_cork_complete.csv")), 
          row.names = FALSE)

# Print summary of complete dataset
cat("\nSummary of complete dataset:\n")
cat("-------------------------\n")
summary(airbnb_cork_complete) 
