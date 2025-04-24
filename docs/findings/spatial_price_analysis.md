# Cork City Property Analysis - Spatial Price Analysis Findings

## Overview

This document summarizes the findings from the spatial price analysis of property sales and Airbnb listings in Cork City, Ireland. The analysis examines the geographic distribution of prices, identifies price hotspots, and investigates the spatial relationship between property sales prices and Airbnb rates.

## Data Summary

The analysis was performed using:
- **2,690 Property Sale** records from the Property Price Register (PPR) within Cork City
- **307 Airbnb Listings** with valid price data located within Cork City
- Cork City boundary defined using Local Electoral Areas (LEAs)

## Key Spatial Price Findings

### 1. Price Distribution by Category

#### Property Sales Price Categories
- **Under €200,000**: 349 properties (13.0%)
- **€200,000 - €300,000**: 728 properties (27.1%) 
- **€300,000 - €400,000**: 824 properties (30.6%)
- **€400,000 - €500,000**: 410 properties (15.2%)
- **€500,000 - €750,000**: 274 properties (10.2%)
- **€750,000 - €1 million**: 61 properties (2.3%)
- **Over €1 million**: 44 properties (1.6%)

The majority of properties (57.7%) sold for between €200,000 and €400,000, indicating the core price range for the Cork City property market.

#### Airbnb Nightly Rate Categories
- **Under €50**: 20 listings (6.5%)
- **€50 - €100**: 127 listings (41.4%)
- **€100 - €150**: 58 listings (18.9%)
- **€150 - €200**: 50 listings (16.3%)
- **€200 - €300**: 34 listings (11.1%)
- **€300 - €500**: 12 listings (3.9%)
- **Over €500**: 6 listings (2.0%)

Nearly half (47.9%) of all Airbnb listings are priced under €100 per night, with the €50-€100 range representing the most common price category.

### 2. Spatial Price Patterns

#### Property Sales Spatial Patterns
- **High-Value Clusters**: The analysis identified distinct high-value property clusters in:
  - Douglas and Rochestown (south of the city)
  - Montenotte and Tivoli (east of the city center)
  - Parts of Bishopstown (west of the city center)
  
- **Mid-Range Areas**: Moderate property prices were observed in:
  - Ballincollig
  - Glanmire
  - Blackpool
  - Cork City Center

- **Lower-Value Areas**: More affordable properties clustered in:
  - Parts of Togher
  - Areas of Mahon
  - Sections of the northside

#### Airbnb Pricing Spatial Patterns
- **Premium Pricing Zones**: The highest Airbnb rates were concentrated in:
  - City Center, particularly around the historic core and business district
  - University College Cork vicinity
  - The Docklands area
  
- **Mid-Range Pricing Areas**:
  - Douglas
  - Blackrock
  - Residential areas with good transport links to the city center
  
- **Lower-Priced Zones**:
  - Peripheral residential areas
  - Areas with fewer tourist attractions
  - Zones with higher concentrations of private room listings versus entire homes

### 3. Price Density Analysis

The kernel density analysis revealed:

#### Property Sales Price Density
- High-value price density forms several distinct "hot zones" rather than a single centralized pattern
- Property price density does not follow a simple distance-from-city-center gradient
- Local neighborhood characteristics appear to influence price density more than pure distance from the city center
- Waterfront and elevated areas with views tend to show higher price densities

#### Airbnb Price Density
- Airbnb price density forms a more centralized pattern with the highest density in the city center
- Clear distance decay effect with prices generally decreasing as distance from the city center increases
- Secondary price density peaks around specific attractions and amenities
- More uniform price density pattern compared to the multi-nodal property price pattern

### 4. Price Hotspot Analysis

#### Property Sale Price Hotspots
- Statistically significant high-price hotspots were identified in:
  - Douglas (particularly around Maryborough)
  - Blackrock
  - Montenotte
  - Select parts of the city center with premium apartments
  
- Cold spots (areas with significantly lower prices) were found in:
  - Parts of the north side of the city
  - Some peripheral housing estates
  - Areas with older housing stock

#### Airbnb Price Hotspots
- High-price hotspots for Airbnb listings were concentrated in:
  - The central business district
  - Historic core of the city
  - Areas with high tourist footfall
  - Premium waterfront locations
  
- Cold spots for Airbnb pricing were identified in:
  - Residential areas further from tourist attractions
  - Areas with higher concentrations of private room listings
  - Zones with fewer amenities and transportation options

### 5. Spatial Correlation Between Markets

- **Negative Correlation**: A negative spatial correlation of -0.275 was identified between property sales price hotspots and Airbnb price hotspots
- This indicates that areas with high property sale prices often do not correspond to areas with high Airbnb rates, and vice versa
- This negative correlation suggests different market dynamics driving each sector:
  - Property sales prices are more influenced by neighborhood prestige, schools, and long-term residential quality
  - Airbnb prices are more influenced by proximity to tourist attractions, nightlife, and short-term visitor amenities

## Implications

The spatial price analysis reveals several important implications:

1. **Distinct Market Geographies**: Property sales and Airbnb listings operate in spatially distinct markets within Cork City, with different geographic price patterns and drivers.

2. **Investment Opportunity Zones**: The negative spatial correlation between markets reveals potential investment opportunities where property acquisition costs are lower but Airbnb revenue potential is higher.

3. **Neighborhood Evolution**: The spatial price patterns reflect Cork City's evolving neighborhood characteristics, with traditional high-value residential areas not necessarily corresponding to areas popular with tourists and short-term visitors.

4. **Policy Considerations**: Understanding these spatial price patterns may inform targeted housing policies, as areas with high Airbnb concentrations and rates but lower property purchase prices may be experiencing conversion from long-term residential use to short-term rental use.

5. **Urban Planning Insights**: The multi-nodal nature of property price hotspots suggests that Cork City has multiple desirable residential centers rather than a single premium zone, pointing to a polycentric urban development pattern.

## Conclusion

The spatial price analysis demonstrates that Cork City exhibits complex and distinct geographic patterns in both property sales prices and Airbnb rates. The negative correlation between these two markets' price hotspots reveals different geographic value propositions for long-term residential versus short-term rental use. These findings provide valuable insights for homebuyers, investors, policy makers, and urban planners seeking to understand the spatial dynamics of Cork City's housing market.

## Visualizations

The analysis generated several maps and visualizations stored in the `output/price_maps` directory:
- Point maps showing property sales and Airbnb listings colored by price category
- Kernel density heatmaps displaying price concentration patterns
- Hexbin maps showing average prices by area
- Hotspot analysis maps identifying statistically significant high and low price clusters
- Combined maps showing the relationship between property and Airbnb price patterns
- Interactive web maps for detailed exploration of price patterns 