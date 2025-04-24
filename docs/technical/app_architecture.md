# Cork City Property Analysis - Application Architecture

This document describes the architecture of the Cork City Property Analysis Shiny application, detailing its structure, components, and data flow.

## Overview

The Cork City Property Analysis application is built using R Shiny, a web application framework for R. The application visualizes property sales and Airbnb listings in Cork City, Ireland, providing interactive maps, charts, and data filtering capabilities.

## Application Components

### 1. UI Components

The user interface is built using `shinydashboard` and consists of the following components:

#### Header
- Application title: "Cork City Housing Analysis 2024"

#### Sidebar
- Data source selection radio buttons (Property Sales, Airbnb Listings, Both)
- Filter controls that change dynamically based on the selected data source:
  - Price range sliders
  - Property type selection for Property Sales
  - Room type selection for Airbnb
  - Minimum reviews filter for Airbnb
- Marker clustering toggle
- Filter application button
- Dataset information section that displays record counts and statistics

#### Main Content Area
The main content is organized into tabs:

1. **Map Tab**
   - Statistics boxes showing key metrics
   - Interactive Leaflet map with:
     - Multiple base layer options (Positron, OpenStreetMap, Satellite)
     - Cork City boundary overlay
     - Color-coded markers for properties and Airbnb listings
     - Popups with detailed information
     - Legend for data interpretation

2. **Charts Tab**
   - Price Distribution: Histograms showing price distributions
   - Price Correlation: Scatter plots showing spatial price distribution
   - Time Analysis: Time series plots showing price and count trends over time

3. **About Tab**
   - Project overview
   - Key findings
   - Data sources and attribution

### 2. Server Components

The server-side logic implements the following key functions:

#### Reactive Data Processing
- `filtered_ppr()`: Creates a filtered subset of property data based on user selections
- `filtered_airbnb()`: Creates a filtered subset of Airbnb data based on user selections

#### Map Visualization
- `add_markers_to_map()`: Adds markers to the Leaflet map with appropriate styling and popups
- Marker clustering based on user preference
- Dynamic legend creation based on available data
- Smart handling of color scales based on data distribution

#### Statistical Visualization
- Price distribution histograms
- Spatial price correlation plots
- Time-based analysis charts
- Dynamic chart generation based on available data

#### Event Handlers
- Data source change events that reset appropriate filters
- Filter application button handler
- Clusttering toggle handler

### 3. Data Flow

1. **Data Loading**
   - Application loads pre-processed GeoPackage (GPKG) files at startup
   - Data is transformed to the appropriate coordinate reference system (WGS84)
   - Initial statistics are calculated (min/max/median price values)

2. **User Interaction**
   - User selects data source and applies filters
   - Reactive expressions recalculate filtered datasets
   - Map and chart outputs are updated to reflect filtered data

3. **Visualization Generation**
   - Map markers are added with appropriate styling based on price
   - Charts are generated based on the currently selected data
   - Statistics boxes are updated with current metrics

4. **Error Handling**
   - Application checks for empty result sets and shows appropriate notifications
   - Handles edge cases like insufficient data for visualizations
   - Provides fallback options when data is limited

## Technical Implementation Details

### Data Storage
- Spatial data stored in GeoPackage (GPKG) format
- Coordinate system standardized to WGS84 (EPSG:4326) for compatibility with Leaflet

### Key Libraries
- **shiny**: Core web application framework
- **shinydashboard**: Dashboard layout and components
- **leaflet**: Interactive mapping
- **sf**: Spatial data handling
- **dplyr**: Data manipulation
- **ggplot2**: Static plots base
- **plotly**: Interactive charts
- **viridis** & **RColorBrewer**: Color palettes for visualization

### Error Resilience
The application includes several error-handling mechanisms:
- Robust handling of empty datasets
- Fallback visualization options when data is limited
- Dynamic color scale generation based on available data
- Notifications for filter results

### Application Responsiveness
- Progressive loading of data and visualizations
- Filtering performed on pre-loaded data for quick response times
- Map rendering optimizations including marker clustering

## Application Flow

1. User selects data source (Property Sales, Airbnb Listings, or Both)
2. User adjusts filters specific to the selected data source
3. User clicks "Apply Custom Filters" button
4. Application filters data and updates visualizations
5. User explores the data using the interactive map and charts
6. User can switch between tabs to view different aspects of the data

## Design Considerations

- **Modularity**: The application is designed with modular components for easier maintenance
- **Progressive Enhancement**: Core functionality works with minimal data, with enhanced features when more data is available
- **Error Resilience**: Multiple levels of error checking and fallback options
- **Visual Consistency**: Consistent color schemes and styling throughout the application
- **Performance Optimization**: Data pre-processing and efficient filtering techniques 