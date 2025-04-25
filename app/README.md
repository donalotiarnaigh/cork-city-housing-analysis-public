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
