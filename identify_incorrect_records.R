library(readr)
library(dplyr)
library(stringr)

# Towns that are definitely outside Cork City boundary
outside_towns <- c(
  "BANTRY", "KINSALE", "YOUGHAL", "BANDON", 
  "CHARLEVILLE", "FERMOY", "MALLOW", "MITCHELSTOWN", 
  "SKIBBEREEN", "CLONAKILTY", "MACROOM", "MILLSTREET",
  "DUNMANWAY", "COBH", "CARRIGALINE", "CASTLEMARTYR",
  "INNISHANNON", "CROSSHAVEN", "BLARNEY"
)

# More precise function to check if an address contains an outside town
# Using word boundary matching to avoid partial matches
contains_outside_town <- function(address) {
  if (is.na(address) || address == "") return(FALSE)
  
  address <- toupper(address)
  # Create patterns with word boundaries
  patterns <- paste0("\\b", outside_towns, "\\b")
  any(sapply(patterns, function(pattern) str_detect(address, pattern)))
}

# Load the data
ppr_data <- read_csv("data/processed/final/ppr_corkCity.csv")

# Add more detailed debugging
cat("Checking for potentially incorrect geocoding...\n")

# Identify potentially incorrect records
potentially_incorrect <- ppr_data %>%
  mutate(
    contains_outside_town_orig = sapply(original_address, contains_outside_town),
    contains_outside_town_match = sapply(geocoding_match_address, contains_outside_town)
  ) %>%
  filter(contains_outside_town_orig | contains_outside_town_match) %>%
  select(-contains_outside_town_orig, -contains_outside_town_match)

# Save results
write_csv(potentially_incorrect, "potentially_incorrect_records.csv")

# Print summary
cat("Total records in Cork City dataset:", nrow(ppr_data), "\n")
cat("Potentially incorrectly geocoded records found:", nrow(potentially_incorrect), "\n")

# Print some examples with addresses
if (nrow(potentially_incorrect) > 0) {
  cat("\nExamples of potentially incorrect records:\n")
  examples <- head(potentially_incorrect, 10)
  for (i in 1:nrow(examples)) {
    cat(i, ": Original:", examples$original_address[i], "\n")
    cat("   Geocoded:", examples$geocoding_match_address[i], "\n\n")
  }
}

cat("Results saved to potentially_incorrect_records.csv\n") 