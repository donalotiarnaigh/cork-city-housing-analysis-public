# Cork City Property Analysis - Analysis Techniques

This document describes the key analysis techniques used in the Cork City Property Analysis project to process, analyze, and visualize the property sales and Airbnb data.

## Spatial Analysis Techniques

### 1. Geocoding

Geocoding was used to convert street addresses in the Property Price Register (PPR) dataset into geographic coordinates. The process involved:

- Address standardization and cleaning
- Using ArcGIS geocoding services for initial geocoding
- Verification of geocoded results
- Manual correction of incorrectly geocoded addresses
- Assessment of geocoding accuracy and confidence levels

### 2. Spatial Filtering

To ensure accurate analysis of Cork City specifically:

- Properties were filtered using the official Cork City Council boundary
- Spatial intersection operations were used to identify properties within the boundary
- Properties outside the boundary were excluded from the analysis

### 3. Spatial Clustering

Clustering techniques were used to identify patterns in property and Airbnb distribution:

- Visual clustering on the interactive map (using Leaflet's marker clustering)
- Density-based analysis to identify high-concentration areas
- Comparison of property sale clusters versus Airbnb listing clusters

### 4. Spatial Correlation

To understand the relationship between property sales and Airbnb listings:

- Spatial correlation calculations between property prices and Airbnb prices
- Identification of areas with high property prices but low Airbnb prices (and vice versa)
- Calculation of spatial autocorrelation (how prices are related to nearby prices)

## Statistical Analysis Techniques

### 1. Price Distribution Analysis

Multiple techniques were used to analyze price distributions:

- Histogram analysis of price distributions for both datasets
- Calculation of basic statistics (mean, median, quartiles)
- Identification of outliers using standard deviation methods
- Comparison of distributions between property types and areas

### 2. Time Series Analysis

For temporal patterns in the data:

- Aggregation of data by month/year
- Trend analysis of property prices over time
- Seasonal pattern identification in Airbnb pricing
- Correlation between property sale timing and Airbnb listing activity

### 3. Comparative Analysis

To compare different subsets of the data:

- Property type comparison (different property categories)
- Room type comparison for Airbnb listings
- Geographic area comparisons within Cork City
- Price-to-feature ratio analysis

## Data Visualization Techniques

### 1. Choropleth Mapping

- Color-coded maps based on property and Airbnb prices
- Dynamic color scale generation based on data distribution
- Quintile-based color assignments for balanced visualization
- Fallback coloring methods for limited data scenarios

### 2. Interactive Visualization

Several interactive visualization techniques were implemented:

- Filtering controls for user-driven exploration
- Pop-up information windows with detailed data
- Dynamic recalculation of statistics based on filters
- Linked views between maps and charts

### 3. Statistical Charts

Various chart types were used to visualize different aspects of the data:

- Histograms for price distribution
- Scatter plots for spatial correlation analysis
- Time series plots for temporal trends
- Bar charts for categorical comparisons

## Data Processing Techniques

### 1. Data Cleaning

Extensive data cleaning was performed on both datasets:

- Standardization of formats and units
- Handling of missing values
- Removal of duplicates and invalid entries
- Transformation of data types

### 2. Feature Engineering

New features were created to enhance analysis:

- Derived spatial features (distance to city center, etc.)
- Categorization of continuous variables
- Standardization of property and room types
- Temporal features (month, year, season)

### 3. Error Handling

Robust error handling techniques were implemented:

- Validation of data integrity during processing
- Detection and handling of outliers
- Graceful degradation when data is limited
- User notification of data limitations

## Machine Learning Approaches

### 1. Classification

Classification techniques were used for:

- Categorizing properties into market segments
- Identifying potentially misclassified property types
- Detecting anomalous listings

### 2. Clustering

Unsupervised learning approaches for:

- Identifying natural groupings in the property market
- Discovering price "hotspots" and "coldspots"
- Recognizing patterns not obvious from manual analysis

## Conclusion

The Cork City Property Analysis project combined multiple analytical techniques to provide a comprehensive understanding of the property and short-term rental market in Cork City. The integration of spatial, statistical, and visual analysis methods enabled the identification of meaningful patterns and relationships that would not be apparent from a single analytical approach. 