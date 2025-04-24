# Cork City Property Analysis - Price Statistics Findings

## Overview

This document summarizes the findings from the price statistics analysis of property sales and Airbnb listings in Cork City, Ireland. The analysis examines price distributions, comparative statistics between different property types, and patterns in the data.

## Data Summary

The analysis was performed using:
- **2,690 Property Sale** records from the Property Price Register (PPR) within Cork City
- **307 Airbnb Listings** with valid price data located within Cork City

## Key Price Statistics Findings

### 1. Overall Price Summary

#### Property Sales Prices
- **Median Sale Price**: €335,000
- **Mean Sale Price**: €365,889
- **Price Range**: €6,246 to €3,261,094
- **Interquartile Range**: €252,500 (Q1) to €420,000 (Q3)
- **Standard Deviation**: €224,454

These figures indicate significant variability in property prices across Cork City, with a positively skewed distribution (mean > median), suggesting the presence of high-value outliers pulling the average upward.

#### Airbnb Listing Prices
- **Median Nightly Rate**: €105
- **Mean Nightly Rate**: €142.47
- **Price Range**: €35 to €1,000 per night
- **Interquartile Range**: €70 (Q1) to €176.50 (Q3)
- **Standard Deviation**: €116.43

The Airbnb pricing data also shows a positively skewed distribution with considerable variation, indicating diverse accommodation options at different price points.

### 2. Price Distributions by Property Type

#### Property Sales by Type

**New Properties** (525 sales, 19.5% of total):
- **Median Price**: €355,749
- **Mean Price**: €389,846
- **Price Range**: €45,000 to €2,890,837

**Second-Hand Properties** (2,165 sales, 80.5% of total):
- **Median Price**: €325,000
- **Mean Price**: €360,080
- **Price Range**: €6,246 to €3,261,094

New properties command a premium of approximately 9.5% at the median price point compared to second-hand properties, though both categories show similar patterns of price variability and skew.

#### Airbnb Listings by Room Type

**Entire Home/Apartment** (151 listings, 49.2% of total):
- **Median Price**: €174 per night
- **Mean Price**: €208 per night
- **Price Range**: €42 to €1,000 per night

**Private Room** (155 listings, 50.5% of total):
- **Median Price**: €70 per night
- **Mean Price**: €79.50 per night
- **Price Range**: €35 to €395 per night

**Shared Room** (1 listing, 0.3% of total):
- **Price**: €72 per night

Entire home/apartment listings command a substantial premium (approximately 149% higher at the median price) compared to private room listings, reflecting the value placed on privacy and space.

### 3. Price Distribution Characteristics

#### Property Sales Distribution
- The distribution of property sale prices shows significant positive skew
- A concentration of properties in the €200,000 to €500,000 range
- A long tail of high-value properties exceeding €1 million
- Log-transformed distributions reveal a closer approximation to normal distribution, suggesting multiplicative rather than additive price factors

#### Airbnb Price Distribution
- Airbnb prices show a similarly skewed distribution
- Distinct price clusters for different room types
- Greater concentration in lower price ranges (€50-€200)
- Fewer extreme outliers compared to property sales, but still some high-end luxury options

### 4. Price per Guest Analysis (Airbnb)

- **Median Price per Guest**: €47.50
- **Mean Price per Guest**: €54.95
- **Range**: €4.50 to €500 per guest

This analysis reveals that while larger properties may have higher overall prices, the per-guest cost often decreases with occupancy capacity, representing better value for larger groups.

## Implications

The price statistics analysis reveals several important implications:

1. **Market Segmentation**: Clear price differences between new and second-hand properties in the sales market, and between room types in the Airbnb market, indicating distinct market segments.

2. **Investment Considerations**: The premium commanded by new properties suggests potential investment value in new developments, while the high per-night rates of entire home Airbnb listings relative to their purchase price may indicate favorable short-term rental economics for property investors.

3. **Affordability Concerns**: The median property price of €335,000 represents approximately 8.4 times the average Irish annual salary (€40,000), highlighting potential affordability challenges for local residents.

4. **High-End Market Influence**: The substantial difference between mean and median prices in both datasets indicates that high-value properties and luxury short-term rentals have a significant impact on market averages.

5. **Pricing Strategy Insights**: For Airbnb hosts, the data suggests that private rooms offer competitive value in the market and may target budget-conscious travelers, while entire homes command premium rates that may be justifiable for larger groups when considered on a per-guest basis.

## Conclusion

The price statistics analysis of Cork City's property sales and Airbnb listings reveals a complex and segmented market with distinct pricing patterns. While property sales prices show considerable variation based on property type and condition, Airbnb pricing demonstrates similarly pronounced differences based primarily on the type of accommodation offered. Both markets exhibit positively skewed distributions with significant high-end outliers, reflecting the diverse nature of Cork City's housing market and its appeal to different segments of buyers and visitors.

## Visualizations

The analysis generated several visualizations stored in the `output/visualizations` directory:
- Price distribution histograms for both datasets
- Log-transformed price distributions
- Box plots showing price variations by property type
- Box plots showing Airbnb prices by room type
- Price per guest distribution for Airbnb listings 