# Cork City Property Analysis - Geographic Analysis Findings

## Overview

This document summarizes the findings from the geographic analysis of property sales and Airbnb listings in Cork City, Ireland. The analysis examines the spatial distribution, clustering patterns, and geographic relationships between these two datasets.

## Data Summary

The analysis was performed using:
- **2,690 Property Sales** records from the Property Price Register (PPR) within Cork City
- **424 Airbnb Listings** located within Cork City
- Cork City boundary defined using Local Electoral Areas (LEAs)

## Key Geographic Findings

### 1. Spatial Distribution

#### Property Sales Distribution
- Property sales are widely distributed across Cork City, with notable concentrations in:
  - Douglas/Rochestown area in the south
  - Blackpool/Mayfield area in the north
  - City Center, particularly around the western parts
  
- Areas with fewer property sales include:
  - Industrial zones
  - Undeveloped green spaces
  - Commercial districts with limited residential properties

#### Airbnb Listings Distribution
- Airbnb listings show a different spatial pattern than property sales, with strong concentrations in:
  - City Center, especially around the university area
  - Tourist-oriented districts
  - Waterfront areas along the River Lee

- Notable gaps in Airbnb coverage are observed in:
  - Many suburban residential areas with high property sales
  - Industrial zones
  - Outskirts of the city boundary

### 2. Clustering Analysis

#### Property Sales Clusters
- Property sales form several distinct clusters throughout Cork City:
  - High-density clusters in established residential neighborhoods
  - Medium-density clusters in mixed-use areas
  - Low-density patterns in newer developments or more exclusive neighborhoods

- The clustering of property sales generally follows existing residential development patterns, with higher concentrations in areas with:
  - Good transportation links
  - Proximity to schools and amenities
  - Established residential infrastructure

#### Airbnb Clusters
- Airbnb listings demonstrate more concentrated clustering than property sales:
  - Very high density in the city center and tourist areas
  - Moderate presence in select residential areas with good transport links
  - Sparse representation in many suburban areas

- The clustering of Airbnb listings appears to be strongly influenced by:
  - Proximity to tourist attractions
  - Access to public transport
  - Walking distance to entertainment and dining options

### 3. Spatial Relationships

#### Overlay Analysis
- When overlaying property sales and Airbnb listings, several patterns emerge:
  - Areas with high property sales activity do not necessarily have high Airbnb presence
  - Some neighborhoods have high concentrations of both property sales and Airbnb listings
  - Certain areas have exclusive concentrations of either property sales or Airbnb listings

#### Boundary Effects
- The Cork City boundary analysis reveals:
  - Some property sales clusters extending to the city boundary
  - Airbnb listings generally concentrated away from the boundary edges
  - Higher density of both datasets in central areas compared to peripheral zones

### 4. Neighborhood-Level Insights

#### High-Activity Neighborhoods
The following neighborhoods show significant activity in both property sales and Airbnb listings:
- City Center
- University area
- Douglas
- Blackpool

#### Property Sales Dominant Areas
These neighborhoods have high property sales activity but relatively few Airbnb listings:
- Rochestown
- Glanmire
- Ballincollig outskirts
- Togher

#### Airbnb Dominant Areas
These areas show high Airbnb concentration but fewer property sales:
- Waterfront areas
- Historic district around Shandon
- Sections of the university precinct

## Implications

The geographic analysis reveals distinct spatial patterns that suggest:

1. **Different Market Dynamics**: Property sales and Airbnb listings operate in partially overlapping but distinct geographic markets within Cork City.

2. **Investment Patterns**: Areas with high Airbnb concentration but moderate property sales may indicate investment properties being utilized for short-term rentals rather than long-term housing.

3. **Residential Stability**: Neighborhoods with high property sales but low Airbnb presence likely represent stable residential communities with fewer transient accommodations.

4. **Urban Development Influences**: The spatial patterns reflect Cork City's development history, with newer residential areas showing different patterns than established neighborhoods.

5. **Transportation Network Effects**: Both datasets show clustering patterns that follow major transportation corridors, suggesting accessibility is a key factor in both markets.

## Conclusion

The geographic analysis demonstrates that while property sales and Airbnb listings both represent aspects of Cork City's housing market, they exhibit distinct spatial patterns that reflect different market forces, user needs, and neighborhood characteristics. These findings provide valuable context for understanding the relationship between the traditional property market and the short-term rental market in Cork City.

## Maps and Visualizations

The analysis generated several maps and visualizations stored in the `output/maps` directory:
- Property sales density map
- Airbnb listings density map
- Cluster analysis maps
- Comparative overlay maps
- Interactive web maps showing both datasets with the Cork City boundary 