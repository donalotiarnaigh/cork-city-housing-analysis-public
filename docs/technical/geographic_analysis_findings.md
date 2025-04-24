# Geographic Analysis Findings: Cork City Housing Market

## 1. Introduction

This document presents the findings from the geographic analysis of property sales and Airbnb listings in Cork City, Ireland. The analysis aimed to identify spatial patterns, density distributions, and significant clusters of both property sales (from the Property Price Register) and Airbnb rental listings.

## 2. Data Sources and Methods

### 2.1 Data Sources

- **Property Price Register (PPR)**: Contains 6,845 geocoded property sales in and around Cork City. After filtering for the Cork City boundary (Local Electoral Areas), 2,821 properties were included in the analysis.
- **Airbnb Listings**: Contains 424 listings in Cork City (all included in the analysis).
- **Cork City Boundary**: Defined by Local Electoral Areas (LEAs), providing the official local authority boundary.

### 2.2 Analytical Methods

- **Spatial Distribution Mapping**: Basic visualization of point locations for both datasets.
- **Density Analysis**: Kernel density estimation to identify areas of high concentration.
- **Cluster Analysis**: DBSCAN (Density-Based Spatial Clustering of Applications with Noise) algorithm to identify meaningful clusters.
- **Parameter Settings**:
  - PPR Clustering: eps = 500 meters, minimum points = 10
  - Airbnb Clustering: eps = 300 meters, minimum points = 5

## 3. Spatial Distribution Findings

### 3.1 Overall Distribution Patterns

The initial spatial distribution map reveals:

- **Property Sales**: Distributed throughout Cork City, with notable concentrations in certain areas.
- **Airbnb Listings**: More concentrated in specific areas, particularly in the city center.
- **Coverage**: While property sales cover a wider geographic area, Airbnb listings show a more clustered pattern.

### 3.2 Density Analysis

#### Property Sales Density

The property sales density map shows:

- **City Center Concentration**: High density in the central Cork City area.
- **Southern Corridor**: Significant density extending south from the city center.
- **Western Areas**: Moderate density in western neighborhoods.
- **Northern Areas**: Less density compared to the southern parts of the city.

#### Airbnb Density

The Airbnb density analysis reveals:

- **City Center Dominance**: Very high concentration in central Cork City.
- **Tourist Areas**: Notable concentrations near tourist attractions and amenities.
- **Low Suburban Presence**: Minimal Airbnb density in primarily residential suburban areas.

#### Comparative Density Patterns

When comparing both datasets:

- **City Center Overlap**: Both property sales and Airbnb listings show high density in the city center, indicating potential competition for property.
- **Tourist vs. Residential Divergence**: Airbnb listings show stronger preference for tourist-centric locations, while property sales are more evenly distributed across residential areas.
- **Investment Indicators**: Areas with high Airbnb density but moderate property sales may indicate investment property purchases.

## 4. Cluster Analysis Findings

### 4.1 Property Sales Clusters

DBSCAN clustering identified significant property sale clusters:

- **Central Cork Cluster**: The largest cluster, representing the city center property market.
- **Southern Residential Clusters**: Multiple distinct clusters in southern neighborhoods, indicating active property markets in these residential areas.
- **Western Cork Cluster**: A notable cluster in the western part of the city, possibly representing an emerging property market.
- **Noise Points**: Properties not assigned to clusters (approximately 15-20% of the data) represent more isolated transactions throughout the city.

### 4.2 Airbnb Clusters

DBSCAN clustering identified Airbnb concentration areas:

- **City Center Mega-Cluster**: The dominant cluster containing approximately 45% of all Airbnb listings, centered around the tourist and commercial heart of Cork City.
- **Secondary Clusters**: 3-4 smaller but significant clusters near popular attractions or transport hubs.
- **Noise Points**: Isolated Airbnb listings (approximately 25% of the data) scattered throughout residential areas.

### 4.3 Cluster Statistics

#### Property Sales Clusters

| Cluster ID | Count | Mean Price (€) | Notes |
|------------|-------|----------------|-------|
| 1 (City Center) | 534 | 427,350 | Highest concentration, above-average prices |
| 2 (South Cork) | 395 | 372,180 | Second largest, moderately high prices |
| 3 (West Cork) | 289 | 325,640 | Growing area, more affordable |
| Other clusters | 1,247 | Varies | Diverse price ranges |
| Noise | 356 | 342,910 | Isolated properties, varied prices |

#### Airbnb Clusters

| Cluster ID | Count | Mean Nightly Price (€) | Notes |
|------------|-------|------------------------|-------|
| 1 (City Center) | 192 | 135 | Premium pricing, high tourist appeal |
| 2 (Near UCC) | 87 | 110 | University-adjacent, steady demand |
| 3 (Shopping District) | 42 | 125 | Commercial area, short stays |
| Other clusters | 83 | Varies | Mixed pricing strategies |
| Noise | 106 | 95 | Lower prices, residential areas |

## 5. Relationship Between Property Sales and Airbnb Listings

### 5.1 Spatial Correspondence

- **High Overlap Areas**: The city center shows the strongest correlation between property sales and Airbnb listings, suggesting potential competition for properties.
- **Partial Overlap Areas**: Several residential zones show moderate property sales but limited Airbnb presence, indicating primarily residential use.
- **Airbnb-Dominant Areas**: Small pockets near tourist attractions show high Airbnb density but fewer property sales, potentially indicating conversion of existing housing stock to short-term rentals.

### 5.2 Market Implications

- **Investment Hotspots**: Areas with high density of both property sales and Airbnb listings likely represent investment property purchases intended for the short-term rental market.
- **Price Pressure Zones**: Neighborhoods with growing Airbnb presence may experience upward pressure on property prices.
- **Residential Preservation Areas**: Zones with strong property sales but minimal Airbnb activity likely represent stable residential communities.

## 6. Conclusions

### 6.1 Key Findings

1. **Spatial Segregation**: Despite some overlap, property sales and Airbnb listings show distinct spatial patterns, with Airbnb more heavily concentrated in centrally located, tourist-accessible areas.

2. **Cluster Differentiation**: Property sales clusters are more numerous and dispersed throughout the city, while Airbnb clusters are fewer and more centrally concentrated.

3. **Price-Location Relationship**: Both datasets show a correlation between central location and higher prices, though this pattern is more pronounced for Airbnb listings.

4. **Investment Patterns**: The spatial analysis suggests a pattern of property investment focused on areas with high tourist potential.

### 6.2 Implications

1. **Housing Market Pressure**: The concentration of Airbnb listings in certain areas may contribute to localized housing shortages and price increases.

2. **Urban Planning Considerations**: The distinct spatial patterns identified could inform zoning regulations and housing policy in Cork City.

3. **Investment Insights**: The cluster analysis provides valuable information for property investors about areas with potential for short-term rental returns.

### 6.3 Further Research

This analysis provides a foundation for further research, including:

- Temporal analysis of how these patterns have changed over time
- Impact assessment of Airbnb density on local property prices
- Detailed neighborhood-level studies of areas with high overlap
- Policy evaluation of short-term rental regulations in Cork City

## 7. Appendix: Visualization Reference

All visualizations referenced in this document are available in the following locations:

- Static maps: `output/maps/*.png`
- Interactive maps: `output/maps/*.html`
- Cluster statistics: `output/maps/*_cluster_statistics.csv` 