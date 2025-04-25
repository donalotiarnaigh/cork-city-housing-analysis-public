# Cork City Property Analysis - Deployment Script
# This script bundles all necessary files for deployment to shinyapps.io

library(rsconnect)
library(here)

# Specify all files needed for the app
files <- c(
  # App code
  "app/app.R",
  "app/www/custom.css",
  
  # Data files
  here(here("data/processed/final/airbnb_corkCity.gpkg")),
  here(here("data/processed/final/ppr_corkCity_with_dates.gpkg")),
  here(here("data/processed/final/airbnb_corkCity_with_dates.gpkg")), # Additional file
  
  # Boundary files
  here(here("data/boundaries/cork_city_boundary.gpkg"))
)

# Check if all files exist before deployment
missing_files <- files[!file.exists(files)]
if (length(missing_files) > 0) {
  cat("Warning: Missing files required for deployment:\n")
  cat(paste(" -", missing_files, collapse = "\n"), "\n\n")
  
  proceed <- readline(prompt = "Do you want to proceed anyway? (yes/no): ")
  if (tolower(proceed) != "yes") {
    stop("Deployment cancelled")
  }
}

# Calculate total size of deployment files
total_size_bytes <- sum(file.info(files[file.exists(files)])$size)
total_size_mb <- total_size_bytes / (1024 * 1024)

cat(sprintf("\nDeployment package size: %.2f MB\n", total_size_mb))
if (total_size_mb > 100) {
  cat("Warning: Large deployment package (>100MB) may take longer to upload\n")
}
if (total_size_mb > 1000) {
  stop("Error: Deployment package exceeds shinyapps.io 1GB limit")
}

# Optional: Set your account info
# rsconnect::setAccountInfo(name="<ACCOUNT>", token="<TOKEN>", secret="<SECRET>")

# Deploy with the correct appDir
cat("\nDeploying app to shinyapps.io...\n")
rsconnect::deployApp(
  appDir = "app",  # Point to the directory containing app.R
  appName = "CorkCityPropertyAnalysis",
  appFiles = c("app.R", "www/custom.css", 
               here(here("data/processed/final/airbnb_corkCity.gpkg")),
               here(here("data/processed/final/ppr_corkCity_with_dates.gpkg")),
               here(here("data/processed/final/airbnb_corkCity_with_dates.gpkg")),
               "../data/boundaries/cork_city_boundary.gpkg"),
  launch.browser = TRUE,
  lint = FALSE,
  forceUpdate = TRUE
)

# Note: If deployment fails, consider:
# 1. Creating a copy of the app with reduced dataset sizes
# 2. Adding explicit package dependencies with:
#    appDependencies = c("shiny", "sf", "leaflet", "dplyr", "shinydashboard", "viridis", "plotly", "tidyr")
# 3. Increasing the deployment timeout with:
#    deployApp(..., timeout = 600) 
