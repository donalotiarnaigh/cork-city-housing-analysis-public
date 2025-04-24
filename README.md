# Cork City Property Analysis

This project analyzes property data in Cork City, Ireland, using two primary datasets:

1. **Property Price Register (PPR)** - Records of property sales in Cork City
2. **Airbnb Listings** - Data on Airbnb rental properties in Cork City

## Project Overview

This application provides an interactive visualization and analysis of property sales and Airbnb listings in Cork City, Ireland. It explores the geographic patterns, price distributions, and spatial relationships between these two markets, revealing insights into Cork City's housing dynamics.

## Project Structure

- `data/` - Contains raw and processed datasets
  - `raw/` - Original unmodified data
  - `processed/` - Cleaned and transformed data
  - `processed/final/` - Final datasets ready for analysis and used by the app
  - `boundaries/` - Geographic boundary files for Cork City
- `R/` - R scripts for data cleaning, analysis, and visualization
  - `app/` - Shiny application files
- `output/` - Generated visualizations and analysis results
  - `maps/` - Geographic visualizations
  - `statistics/` - Statistical analysis outputs
  - `visualizations/` - Charts and diagrams
  - `price_maps/` - Price-focused spatial visualizations
  - `logs/` - Processing logs

## Key Scripts

### Data Processing Scripts

- **01_ppr_data_cleaning.R**: Cleans and standardizes Property Price Register data
- **02_airbnb_data_cleaning.R**: Cleans and standardizes Airbnb listings data
- **03_missing_data_analysis.R**: Analyzes patterns in missing data for datasets
- **04_create_complete_dataset.R**: Combines cleaned data for further processing
- **05_ppr_geocoding.R** to **11_standardize_property_types.R**: Handles geocoding, verification, and standardization of property data

### Analysis Scripts

- **12_geographic_analysis.R**: Analyzes spatial distribution of properties and Airbnb listings
- **13_price_statistics.R**: Generates statistical summaries of price data
- **14_restore_airbnb_price.R**: Handles issues with Airbnb price data
- **15_spatial_price_analysis.R**: Analyzes spatial distribution of prices
- **16_restore_date_columns.R**: Ensures date columns are correctly formatted

### Application

- **app/app.R**: Main Shiny application file with UI and server logic

## Dependencies

### R Packages

- **Data Processing**: dplyr, tidyr, readr, stringr, lubridate
- **Spatial Analysis**: sf, spatstat, spdep, leaflet, mapview, tmap, stars
- **Visualization**: ggplot2, plotly, viridis, RColorBrewer
- **Application**: shiny, shinydashboard, shinyjs, leaflet

### Data Requirements

- Property Price Register (PPR) data for Cork
- Inside Airbnb listings data for Cork (December 12, 2024)
- Cork City boundary files (Local Electoral Areas)

## Installation and Setup

1. **Clone the repository**
   ```
   git clone https://github.com/donalotiarnaigh/cork-city-housing-analysis-public.git
   cd cork-city-housing-analysis-public
   ```

2. **Install required R packages**
   ```R
   install.packages(c("shiny", "shinydashboard", "leaflet", "sf", "dplyr", 
                      "ggplot2", "plotly", "viridis", "tidyr", "lubridate",
                      "tmap", "spatstat", "spdep", "raster", "stars"))
   ```

3. **Download required data (if not included)**
   - Property Price Register: https://www.propertypriceregister.ie/website/npsra/pprweb.nsf/PPRDownloads?OpenForm
   - Airbnb listings: https://insideairbnb.com/get-the-data/
   - Place downloaded data in the `data/raw/` directory

4. **Prepare the data**
   Run the data processing scripts in sequential order (01 to 16)
   ```
   Rscript R/01_ppr_data_cleaning.R
   Rscript R/02_airbnb_data_cleaning.R
   # Continue with remaining scripts
   ```

5. **Launch the Shiny app**
   ```
   Rscript -e "shiny::runApp('app/app.R')"
   ```

## Usage Examples

### Interactive Map

1. Select data source (Property Sales, Airbnb, or Both)
2. Use price filters to narrow the range of properties displayed
3. Filter by property type or room type as needed
4. Toggle marker clustering for cleaner visualization
5. Click on points to view detailed information

### Statistical Analysis

1. Navigate to the Charts tab
2. Explore price distributions through histograms
3. Analyze spatial correlations between property types
4. Examine time-based trends in the data

## Key Findings

### Geographic Patterns

- Property sales are widely distributed across Cork City with notable concentrations in Douglas/Rochestown, Blackpool/Mayfield, and parts of the City Center
- Airbnb listings show stronger concentration in the City Center, especially around the university area and tourist districts
- Both datasets show different spatial clustering patterns, with Airbnb listings more centrally concentrated

### Price Insights

- Median property sale price: €335,000 (range: €6,246 to €3,261,094)
- Median Airbnb nightly rate: €105 (range: €35 to €1,000)
- New properties command a 9.5% premium over second-hand properties
- Entire home Airbnb listings are priced approximately 149% higher than private rooms

### Spatial Price Analysis

- Property prices form distinct "hot zones" rather than following a simple center-to-periphery gradient
- Airbnb prices show a more centralized pattern with clear distance decay from the city center
- A negative correlation (-0.275) exists between property sales price hotspots and Airbnb price hotspots
- This indicates different market dynamics driving each sector, with property values influenced by residential quality factors, while Airbnb prices are driven by tourism proximity

## Contributors

- Daniel Tierney

## License

This project is licensed under the terms of the MIT license.

## Acknowledgments

- Data provided by the Property Price Register Ireland and Inside Airbnb
- Cork City Council for boundary data
- All open-source package contributors 
