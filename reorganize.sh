#!/bin/bash
# Repository reorganization script for Cork City Property Public

# Exit on error
set -e

# Welcome message
echo "=========================================="
echo "Cork City Property Analysis - Public Repo Reorganization"
echo "=========================================="
echo "This script will reorganize the repository to follow best practices."
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Create backup branch
echo "Creating backup branch..."
git checkout -b backup/pre-cleanup main || echo "Backup branch already exists, continuing..."

# Move R scripts to appropriate directories
echo "Moving R scripts to new locations..."

# Data cleaning scripts (01-04)
for file in R/01_ppr_data_cleaning.R R/02_airbnb_data_cleaning.R R/03_missing_data_analysis.R R/04_create_complete_dataset.R; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        newname=$(echo "$basename" | sed 's/^[0-9]*_//')
        cp "$file" "scripts/01_data_cleaning/$newname"
        echo "Moved: $file → scripts/01_data_cleaning/$newname"
    fi
done

# Geocoding scripts (05-10)
for file in R/05_ppr_geocoding.R R/06_prepare_ppr_for_arcgis.R R/07_import_geocoded_ppr.R R/08_clean_geocoded_ppr.R R/09_verify_geocoded_data.R R/10_fix_geocoded_data.R; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        newname=$(echo "$basename" | sed 's/^[0-9]*_//')
        cp "$file" "scripts/02_geocoding/$newname"
        echo "Moved: $file → scripts/02_geocoding/$newname"
    fi
done

# Analysis scripts (11-16)
for file in R/11_standardize_property_types.R R/12_geographic_analysis.R R/13_price_statistics.R R/14_restore_airbnb_price.R R/15_spatial_price_analysis.R R/16_restore_date_columns.R; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        newname=$(echo "$basename" | sed 's/^[0-9]*_//')
        cp "$file" "scripts/03_analysis/$newname"
        echo "Moved: $file → scripts/03_analysis/$newname"
    fi
done

# Move auxiliary scripts
if [ -f "R/12_geographic_analysis_test.R" ]; then
    cp "R/12_geographic_analysis_test.R" "scripts/03_analysis/geographic_analysis_test.R"
    echo "Moved: R/12_geographic_analysis_test.R → scripts/03_analysis/geographic_analysis_test.R"
fi

# Move documentation files
echo "Moving documentation files..."
if [ -f "app_deployment_guide.md" ]; then
    cp "app_deployment_guide.md" "docs/technical/app_deployment_guide.md"
    echo "Moved: app_deployment_guide.md → docs/technical/app_deployment_guide.md"
fi

# Copy deploy.R to scripts
if [ -f "deploy.R" ]; then
    cp "deploy.R" "scripts/deploy.R"
    echo "Moved: deploy.R → scripts/deploy.R"
fi

# Copy template READMEs from the private repository
echo "Copying README templates..."

# Create README for scripts directory
cat << 'EOF' > scripts/README.md
# Scripts Documentation

This directory contains all R scripts used for data processing, analysis, and visualization in the Cork City Property Analysis project.

## Directory Structure

```
scripts/
├── 01_data_cleaning/     # Scripts for cleaning and preparing data
├── 02_geocoding/         # Scripts for geocoding property addresses
├── 03_analysis/          # Scripts for statistical analysis
└── 04_visualization/     # Scripts for generating visualizations
```

## Execution Order

The scripts should be executed in the following order to reproduce the analysis:

### 1. Data Cleaning

- `ppr_data_cleaning.R` - Clean and prepare PPR data
- `airbnb_data_cleaning.R` - Clean and prepare Airbnb data
- `missing_data_analysis.R` - Analyzes missing data patterns
- `create_complete_dataset.R` - Creates the initial complete dataset

### 2. Geocoding

- `ppr_geocoding.R` - Prepares data for geocoding
- `prepare_ppr_for_arcgis.R` - Prepares data for ArcGIS geocoding
- `import_geocoded_ppr.R` - Imports geocoded results
- `clean_geocoded_ppr.R` - Cleans up geocoded data
- `verify_geocoded_data.R` - Verifies geocoding accuracy
- `fix_geocoded_data.R` - Fixes geocoding issues

### 3. Analysis

- `standardize_property_types.R` - Standardizes property type categories
- `geographic_analysis.R` - Performs spatial analysis
- `price_statistics.R` - Calculates price statistics
- `restore_airbnb_price.R` - Fixes Airbnb price formatting
- `spatial_price_analysis.R` - Analyzes spatial price patterns
- `restore_date_columns.R` - Fixes date formatting

## Requirements

All scripts require R 4.0.0 or higher and the following packages:
- dplyr
- sf
- leaflet
- ggplot2
- plotly
- lubridate
- stringr
EOF

# Create README for data directory
cat << 'EOF' > data/README.md
# Data Documentation

This directory contains the datasets used in the Cork City Property Analysis project. Due to file size constraints, most of the actual data files are not included in the repository but can be generated using the scripts in the `scripts/` directory.

## Directory Structure

```
data/
├── raw/               # Original, unmodified data
├── processed/         # Cleaned and processed data
├── boundaries/        # Geographic boundary files for Cork City
└── samples/           # Sample data for testing and demonstration
```

## Data Sources

### Property Price Register (PPR)

- **Source**: Property Services Regulatory Authority (PSRA)
- **URL**: https://www.propertypriceregister.ie/
- **Description**: Contains records of residential property sales in Ireland
- **Time Period**: From January 1, 2010, to December 31, 2022
- **File Format**: CSV

### Airbnb Listings

- **Source**: Inside Airbnb
- **URL**: http://insideairbnb.com/get-the-data/
- **Description**: Information about Airbnb listings in Cork City
- **Time Period**: Data as of February 2023
- **File Format**: CSV

### Cork City Boundary

- **Source**: Ordnance Survey Ireland (OSi)
- **URL**: https://data.gov.ie/
- **Description**: Geographic boundary file for Cork City
- **File Format**: Shapefile/GeoPackage
EOF

# Create README for app directory
cat << 'EOF' > app/README.md
# Shiny Application Documentation

This directory contains the Cork City Property Analysis Shiny application, which provides interactive visualizations of property sales and Airbnb listings in Cork City.

## Application Structure

```
app/
├── app.R            # Main application file
└── www/             # Static assets (CSS, images)
```

## Features

The application provides the following features:

- **Interactive Map**: Visualize property sales and Airbnb listings on an interactive map
- **Filtering Options**: Filter by data source, price range, property type, etc.
- **Statistical Summaries**: View key statistics about the data
- **Price Analysis**: Analyze price distributions and trends

## Running the Application Locally

To run the application locally:

1. Ensure you have R installed (version 4.0.0 or higher)
2. Install the required packages:

```r
# Install required packages if not already installed
install.packages(c("shiny", "shinydashboard", "leaflet", "leaflet.extras", 
                  "sf", "dplyr", "viridis", "RColorBrewer", "ggplot2", 
                  "plotly", "DT", "htmlwidgets", "lubridate"))
```

3. Open R or RStudio and run:

```r
# Option 1: Run from R/RStudio
setwd("/path/to/repo/app")
shiny::runApp()

# Option 2: Run directly from any location
shiny::runApp("/path/to/repo/app")
```
EOF

# Create README for docs directory
cat << 'EOF' > docs/README.md
# Documentation

This directory contains documentation for the Cork City Property Analysis project.

## Directory Structure

```
docs/
├── technical/       # Technical documentation and guides
├── user_guides/     # User guides and manuals
└── report/          # Final report and findings
```

## Key Documents

### Technical Documentation

- **App Deployment Guide**: Instructions for deploying the Shiny app
- **Data Processing Workflow**: Details on how data is processed and analyzed

### User Guides

- **Application User Guide**: Instructions for using the Shiny application

### Report

- **Final Analysis Report**: Complete findings and analysis results
EOF

# Create path fixing script
echo "Creating path fixing utilities..."

cat << 'EOF' > scripts/setup_project.R
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
if (!file.exists(here::here(".here"))) {
  file.create(here::here(".here"))
  cat("Created .here file at project root\n")
} else {
  cat(".here file already exists at project root\n")
}

cat("Project setup complete!\n")
EOF

echo "Reorganization complete!"

# Final message
echo ""
echo "=========================================="
echo "Repository reorganization completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Run the scripts/setup_project.R script to initialize the project"
echo "2. Update the READMEs with project-specific information"
echo "3. Test scripts and app to ensure they work with the new structure"
echo "4. Commit changes with a clear message"
echo ""
echo "Note: The original files are still present in their original locations."
echo "After testing, you may want to remove them to avoid confusion." 