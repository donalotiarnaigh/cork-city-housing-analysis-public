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
