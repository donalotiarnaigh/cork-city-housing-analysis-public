# Setup script for Cork City Property Analysis
# Run this script once to initialize the project

# Install and load required packages
if (!require("here")) {
  install.packages("here", repos = "https://cloud.r-project.org")
}
library(here)

# Print the project root directory
cat("Project root directory:", here(), "\n")

# Create a .here file at the project root to ensure consistent path resolution
if (!file.exists(here::here(".here")))) {
  file.create(here::here(".here")))
  cat("Created .here file at project root\n")
} else {
  cat(".here file already exists at project root\n")
}

cat("Project setup complete!\n")
