# Cork City Property Analysis - Data Processing Documentation

This document describes the data processing workflow used in the Cork City Property Analysis project. The project processes two main data sources: the Property Price Register (PPR) data and Airbnb listings data for Cork City, Ireland.

## Data Processing Scripts

The data processing workflow consists of a series of R scripts that transform raw data into the final datasets used by the Shiny application. Each script is designed to perform a specific task in the data preparation pipeline.

### Initial Data Cleaning

1. **01_ppr_data_cleaning.R**
   - Purpose: Performs initial cleaning and standardization of the Property Price Register data
   - Key operations:
     - Imports raw PPR data for Cork
     - Standardizes column names and formats
     - Converts price values to numeric format (removing € symbols and commas)
     - Converts dates to proper date format
     - Converts Yes/No fields to Boolean
     - Standardizes address formats
     - Adds unique identifiers
     - Performs data validation checks
     - Saves the cleaned data

2. **02_airbnb_data_cleaning.R**
   - Purpose: Performs initial cleaning and standardization of the Airbnb listings data
   - Key operations:
     - Imports raw Airbnb listings data
     - Selects and renames relevant columns
     - Converts price values to numeric format (removing $ symbols and commas)
     - Converts dates to proper date format
     - Converts percentage values to numeric decimals
     - Converts Boolean indicators (t/f) to TRUE/FALSE
     - Cleans text fields
     - Performs data validation checks
     - Saves the cleaned data

3. **03_missing_data_analysis.R**
   - Purpose: Analyzes patterns in missing data for the Cork City Airbnb dataset
   - Key operations:
     - Imports the cleaned Cork City Airbnb data
     - Generates overall missing data summary
     - Analyzes temporal patterns in missing data
     - Examines missing data patterns by property type
     - Assesses geographic distribution of missing data
     - Investigates host characteristics in relation to missing data
     - Creates visualizations of missing data patterns
     - Saves analysis results for future reference

4. **04_create_complete_dataset.R**
   - Purpose: Combines and prepares cleaned data for further processing
   - Key operations:
     - Merges cleaned datasets as appropriate
     - Ensures data consistency across sources
     - Prepares data for geocoding and spatial analysis

### Geocoding and Spatial Data Processing

5. **05_ppr_geocoding.R**
   - Purpose: Manages the geocoding process for PPR addresses
   - Key operations:
     - Prepares addresses for geocoding
     - Interfaces with geocoding services
     - Processes geocoding results
     - Identifies addresses that need manual geocoding

6. **06_prepare_ppr_for_arcgis.R**
   - Purpose: Prepares PPR data for geocoding using ArcGIS services
   - Key operations:
     - Formats addresses specifically for ArcGIS geocoding
     - Creates necessary input files
     - Configures geocoding parameters

7. **07_import_geocoded_ppr.R**
   - Purpose: Imports results from external geocoding processes
   - Key operations:
     - Reads geocoded data
     - Joins geocoded coordinates with original property data
     - Validates geocoding results

8. **08_clean_geocoded_ppr.R**
   - Purpose: Cleans and standardizes geocoded PPR data
   - Key operations:
     - Removes incorrect or low-confidence geocoded results
     - Standardizes coordinate formats
     - Validates spatial accuracy
     - Flags outliers for review

9. **09_verify_geocoded_data.R**
   - Purpose: Verifies the accuracy of geocoded locations
   - Key operations:
     - Visually checks geocoded points against known boundaries
     - Identifies incorrectly geocoded properties
     - Creates reports of verification results

10. **10_fix_geocoded_data.R**
    - Purpose: Corrects issues identified during verification
    - Key operations:
      - Applies fixes to incorrectly geocoded properties
      - Removes properties that cannot be accurately geocoded
      - Updates coordinates based on manual corrections

11. **11_standardize_property_types.R**
    - Purpose: Standardizes property type descriptions
    - Key operations:
      - Normalizes property type categories
      - Groups similar property types
      - Creates a consistent property type taxonomy

### Analysis and Final Data Preparation

12. **12_geographic_analysis.R**
    - Purpose: Performs geographic analysis on property and Airbnb data
    - Key operations:
      - Filters properties within Cork City boundary
      - Calculates spatial statistics
      - Identifies clusters and patterns
      - Prepares data for spatial visualization

13. **13_price_statistics.R**
    - Purpose: Generates statistical summaries of price data
    - Key operations:
      - Calculates price distributions by area
      - Identifies price trends
      - Performs comparative analysis between property sales and Airbnb prices
      - Creates statistical summaries for visualization

14. **14_restore_airbnb_price.R**
    - Purpose: Handles any issues with Airbnb price data
    - Key operations:
      - Fixes missing or incorrect price values
      - Standardizes price formats
      - Ensures consistency in price data

15. **15_spatial_price_analysis.R**
    - Purpose: Analyzes spatial distribution of prices
    - Key operations:
      - Creates price heatmaps
      - Identifies price hotspots
      - Calculates spatial correlation of property and Airbnb prices
      - Prepares spatial price data for visualization

16. **16_restore_date_columns.R**
    - Purpose: Ensures date columns are correctly formatted
    - Key operations:
      - Fixes date formatting issues
      - Restores missing date information where possible
      - Ensures consistency in date representations
      - Prepares temporal data for time-based visualizations

## Data Processing Workflow

The workflow follows these general steps:

1. **Data Cleaning**: Initial preparation of raw data sources
2. **Data Integration**: Combining data from different sources
3. **Geocoding**: Adding spatial coordinates to property records
4. **Spatial Processing**: Analyzing geographic patterns and relationships
5. **Statistical Analysis**: Generating metrics and summaries
6. **Final Preparation**: Creating the final datasets used by the Shiny app

The processed data is saved in GPKG (GeoPackage) format, which efficiently stores both spatial and attribute data, and is loaded by the Shiny application for visualization and analysis.
