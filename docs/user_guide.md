# Cork City Property Analysis - User Guide

This guide provides instructions for using the Cork City Property Analysis application, which visualizes and analyzes property sales and Airbnb listings in Cork City, Ireland.

## Application Overview

The Cork City Property Analysis application is an interactive R Shiny dashboard that allows users to explore property sales and Airbnb listings data through maps, charts, and statistical summaries. The application provides insights into geographic patterns, price distributions, and the spatial relationships between these two markets.

## Getting Started

### System Requirements

- Web browser (Chrome, Firefox, Safari, or Edge)
- Internet connection
- Minimum screen resolution: 1280 x 720

### Accessing the Application

The application can be accessed in two ways:

1. **Online Version**: Access the hosted version at `[URL will be provided upon deployment]`
2. **Local Installation**: See the README.md file for instructions on installing and running the application locally

## Navigation

The application has a dashboard layout with the following components:

### Header
- Application title
- Information about the current data selection

### Sidebar
- Data source selection
- Filtering options
- Dataset information

### Main Content Area
- Map tab with interactive visualization
- Charts tab with statistical visualizations
- About tab with project information

## Features and Usage

### 1. Data Source Selection

In the sidebar, you can select which data source to view:

- **Property Sales**: Show only property transactions from the Property Price Register
- **Airbnb Listings**: Show only Airbnb rental listings
- **Both**: Display both datasets simultaneously for comparison

To change the data source:
1. Click on the radio button for your desired option
2. The map and available filters will update automatically

### 2. Filtering Data

The application provides several filtering options that change dynamically based on the selected data source:

#### Price Filters
- Use the slider to set minimum and maximum price ranges
- For property sales, prices are in Euros (€)
- For Airbnb listings, prices are per night in Euros (€)

#### Property Type Filters (Property Sales)
- Available when viewing Property Sales data
- Select property types (e.g., New Dwelling, Second-Hand Dwelling)
- Multiple selections are allowed

#### Room Type Filters (Airbnb)
- Available when viewing Airbnb data
- Select room types (e.g., Entire home/apt, Private room)
- Multiple selections are allowed

#### Minimum Reviews Filter (Airbnb)
- Available when viewing Airbnb data
- Set the minimum number of reviews for included listings

#### Apply Filters
- After setting your filters, click the "Apply Custom Filters" button
- The map and statistics will update to reflect your selections

### 3. Map Visualization

The main map provides an interactive view of the data with the following features:

#### Base Maps
- Click the layers icon in the top right to change the base map style
- Options include Positron (default), OpenStreetMap, and Satellite

#### Marker Options
- Toggle "Enable Clustering" to group nearby points (useful for dense areas)
- Each marker is color-coded by price range
- Click on any marker to view detailed information about the property or listing

#### Map Navigation
- Zoom: Use the + and - buttons, or your mouse scroll wheel
- Pan: Click and drag the map
- Reset view: Click the home button to return to the default view

#### Information Popups
When you click on a marker, a popup will show:
- For Property Sales: Address, price, date of sale, property type
- For Airbnb Listings: Name, price per night, room type, number of reviews

### 4. Statistics and Charts

The Charts tab provides visualizations of the data with the following sections:

#### Price Distributions
- Histograms showing the distribution of prices for the selected data
- Adjusts automatically based on your filters
- Hover over bars to see detailed counts

#### Price Correlation
- Visualizes the relationship between property and Airbnb prices geographically
- Shows hotspots and clusters
- Includes statistical measures of correlation

#### Time Analysis
- Shows trends over time (for property sales)
- Includes quarterly price trends and sales volumes
- Adjusts based on your date filters (if applicable)

### 5. About Information

The About tab provides context for the project:
- Project overview
- Key findings
- Data sources and methodology
- Contact information

## Example Workflows

### Example 1: Exploring High-Value Properties
1. Select "Property Sales" as the data source
2. Set the price range to €500,000 - €3,000,000
3. Toggle clustering off for a clearer view
4. Navigate to areas like Douglas or Blackrock to see where luxury properties are concentrated
5. Click on individual properties to see details
6. Switch to the Charts tab to see how these high-value properties compare to the overall distribution

### Example 2: Comparing Airbnb Room Types
1. Select "Airbnb Listings" as the data source
2. Use the Room Type filter to select "Entire home/apt"
3. Apply filters and note the distribution
4. Change the selection to "Private room" 
5. Compare the geographic patterns and price distributions between the two room types
6. Use the Charts tab to see the price distribution differences

### Example 3: Finding Investment Opportunities
1. Select "Both" as the data source
2. Focus on areas with moderate property prices but high Airbnb rates
3. Use the map to identify areas where Airbnb listings seem to command premium rates
4. Click on properties in those areas to compare purchase prices with nearby Airbnb rates
5. Use the Charts tab to examine the correlation between property and Airbnb prices

## Known Issues and Limitations

1. **Performance with Large Datasets**:
   - When viewing both datasets simultaneously with no filters, the map may load slowly
   - Solution: Apply filters to reduce the number of displayed points or enable clustering

2. **Date Range Limitations**:
   - The application currently displays data for a specific time period and does not support custom date range filtering
   - Property sales are from the most recent available data
   - Airbnb listings were scraped on December 12, 2024

3. **Browser Compatibility**:
   - The application works best in Chrome and Firefox
   - Some visualization features may have limited functionality in Internet Explorer

4. **Screen Size**:
   - The application is optimized for desktop/laptop screens
   - Mobile support is limited, and some features may be difficult to use on small screens

5. **Map Synchronization**:
   - When viewing both datasets, zooming and panning affects both layers simultaneously
   - Individual layer controls are not currently available

## Troubleshooting

### Issue: Map is not loading
- Try refreshing the browser
- Check your internet connection
- Clear your browser cache

### Issue: Filters not working
- Ensure you've clicked the "Apply Custom Filters" button after making changes
- Try resetting to default filters and applying changes incrementally

### Issue: Application appears frozen
- If the application becomes unresponsive, it may be processing a complex filter
- Wait a few moments or refresh the page

## Getting Help

For additional assistance or to report issues:
- Check the project GitHub repository: [URL]
- Contact the development team at: [Contact Information]

## Future Enhancements

Planned improvements for future versions:
- Mobile-responsive design
- Additional filtering options (e.g., by neighborhood)
- Time-series analysis with date range selection
- Downloadable reports and data export options
- Advanced spatial analysis tools 