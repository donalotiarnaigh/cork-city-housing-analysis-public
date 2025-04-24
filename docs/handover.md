# Project Handover: Cork City Property Analysis

## Project Overview

This project analyzes the relationship between Airbnb listings and property prices in Cork City, Ireland. The goal is to understand spatial patterns and potential correlations between property sales and short-term rental markets. The final deliverable will be an interactive web application built with R Shiny that visualizes these findings.

## Current Status

As of April 23, 2025, we have completed the entire data analysis phase of the project:

1. **Data Cleaning & Preparation** ✅
   - Standardized and cleaned both PPR and Airbnb datasets
   - Geocoded property locations
   - Filtered datasets to Cork City boundaries
   - Resolved issues with missing data

2. **Geographic Analysis** ✅
   - Created density maps for both datasets
   - Performed cluster analysis
   - Identified key geographic patterns

3. **Price Analysis** ✅
   - Calculated descriptive statistics
   - Generated price distribution visualizations
   - Created price heatmaps
   - Performed hotspot analysis
   - Identified key correlations (-0.289) between property and Airbnb price hotspots

## Repository Structure

```
/
├── data/                  # Raw and processed datasets
│   ├── raw/               # Original unmodified data
│   ├── processed/         # Cleaned and prepared data
│   ├── processed/final/   # Final datasets ready for analysis
│   ├── Airbnb/            # Airbnb specific data
│   ├── boundaries/        # Geographic boundary files for Cork City
│   └── external/          # External reference data
├── R/                     # R scripts (numbered by execution order)
│   ├── 01-11_*.R          # Data cleaning and preparation scripts
│   ├── 12_geographic_analysis.R  # Geographic analysis
│   ├── 13_price_statistics.R     # Price statistics analysis
│   ├── 14_restore_airbnb_price.R # Data correction
│   └── 15_spatial_price_analysis.R # Spatial price patterns
├── output/                # Analysis outputs
│   ├── maps/              # Geographic analysis maps
│   ├── price_maps/        # Price analysis maps
│   ├── statistics/        # Statistical outputs
│   └── visualizations/    # Other visualizations
├── docs/                  # Project documentation
│   ├── project/           # Project management docs
│   └── technical/         # Technical documentation
└── qgis/                  # QGIS project files
```

## Key Datasets

### Final Analysis Datasets
These are the primary datasets used in the analysis:

1. **PPR Dataset**: `data/processed/final/ppr_corkCity.gpkg`
   - 2,821 property sale records in Cork City
   - Key fields: price, original_address, property_description, geometry

2. **Airbnb Dataset**: `data/processed/final/airbnb_corkCity_with_price.gpkg`
   - 307 Airbnb listings in Cork City with valid price data
   - Key fields: price, name, room_type, number_of_reviews, geometry

3. **Cork City Boundary**: `data/boundaries/cork_city_boundary.gpkg`
   - Administrative boundary for Cork City

## Completed Analysis

### 1. Geographic Analysis (Script: `R/12_geographic_analysis.R`)
- Created point distribution maps for PPR and Airbnb data
- Generated kernel density visualizations
- Performed cluster analysis using DBSCAN
- Created interactive maps using Leaflet
- Outputs stored in `output/maps/`

### 2. Basic Price Statistics (Script: `R/13_price_statistics.R`)
- Calculated descriptive statistics for both datasets
- Created price distribution histograms and box plots
- Analyzed prices by property type and room type
- Outputs stored in `output/statistics/` and `output/visualizations/`

### 3. Spatial Price Analysis (Script: `R/15_spatial_price_analysis.R`)
- Created point maps with price categories
- Generated price density heatmaps
- Developed hexbin maps showing average prices
- Performed Getis-Ord Gi* hotspot analysis
- Found negative correlation (-0.289) between property and Airbnb price hotspots
- Outputs stored in `output/price_maps/`

## Next Steps

According to the project plan, the next steps are:

1. **Application Development (Day 2)**
   - Set up R Shiny framework
   - Implement basic map visualization
   - Add property price layer
   - Create simple filters

2. **Application Enhancement (Day 3)**
   - Add Airbnb distribution layer
   - Implement basic interactivity
   - Add simple analysis tools
   - Basic styling and UI improvements

3. **Documentation & Finalization (Day 4)**
   - Write technical methodology
   - Document key findings
   - Create user instructions
   - Final testing and submission

## Technical Requirements

### Development Environment
- R 4.x with necessary packages:
  - sf, tmap, ggplot2, dplyr, spatstat, mapview, spdep, raster, stars, viridis, leaflet, htmlwidgets
  - shiny, shinydashboard (for upcoming app development)
- QGIS 3.x for spatial visualization (if needed)
- Git for version control

### Data Dependencies
- All required datasets are included in the repository
- External dependencies are documented in code comments

### Notes on R Scripts
- Scripts are numbered sequentially by order of execution
- Each script contains comments explaining its purpose and functionality
- Later scripts (12-15) can be run independently as they use final datasets

## Known Issues and Challenges

1. **Airbnb Price Data**: 27.6% of Airbnb listings have missing price data. We've filtered these out for analysis.

2. **Interactive Maps**: Initial issue with CRS mismatch in Leaflet maps has been fixed by explicit transformation to WGS84.

3. **PPR Data Quality**: Some property records had geocoding issues, but these have been addressed in the data cleaning process.

4. **Shiny Development**: The project requires an interactive Shiny app, which has not been started yet.

## Key Findings So Far

1. Clear spatial patterns exist in both property sales and Airbnb listings in Cork City.

2. Price distributions show significant differences:
   - PPR median: €334,801 (range: €6,246 - €11,226,291)
   - Airbnb median: €105 per night (range: €35 - €1,000)

3. Hotspot analysis revealed an interesting negative correlation (-0.289) between property price hotspots and Airbnb price hotspots.

4. Most property sales (854) fall in the €300K-400K range, while most Airbnb listings (127) are in the €50-100 per night range.

## Contact Information

For any questions or clarifications about the project, please contact:
- [Add appropriate contact details]

## Documentation Resources

For more information, see:
- Project Plan: `docs/project/project_plan.md`
- WBS: `docs/project/work_breakdown_structure.md`
- Technical findings document: `docs/technical/geographic_analysis_findings.md` 