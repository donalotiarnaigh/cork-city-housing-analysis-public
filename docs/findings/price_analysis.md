# Price Analysis of Cork City Property Market

This document summarizes the key findings from the price analysis of property sales and Airbnb listings in Cork City, Ireland.

## Data Overview

- **Property Sales Data (PPR)**: 2,690 property sales records from the Property Price Register
- **Airbnb Data**: 307 valid Airbnb listings with price information (after filtering 117 listings with missing or invalid prices)

## Price Distribution Summary

### Property Sales (PPR)

The property sales in Cork City show the following price characteristics:

| Statistic | Value (€) |
|-----------|-----------|
| Minimum | 6,246 |
| First Quartile (Q1) | 252,500 |
| Median | 335,000 |
| Mean | 365,889 |
| Third Quartile (Q3) | 420,000 |
| Maximum | 3,261,094 |
| Standard Deviation | 224,454 |

Key observations:
- The median property price in Cork City is €335,000, with the average being higher at €365,889, indicating a right-skewed distribution.
- There is a wide range of property prices, from as low as €6,246 to over €3.2 million.
- The interquartile range (Q3-Q1) of €167,500 suggests significant variance in the middle 50% of the market.
- The high standard deviation (€224,454) confirms the substantial spread in property prices.

### Airbnb Listings

The Airbnb listings in Cork City show the following nightly price characteristics:

| Statistic | Value (€) |
|-----------|-----------|
| Minimum | 35 |
| First Quartile (Q1) | 70 |
| Median | 105 |
| Mean | 142.47 |
| Third Quartile (Q3) | 176.5 |
| Maximum | 1,000 |
| Standard Deviation | 116.43 |

Key observations:
- The median nightly rate for Airbnb listings is €105, with the average being significantly higher at €142.47, indicating a right-skewed distribution.
- The price range is substantial, from €35 to €1,000 per night.
- The interquartile range (Q3-Q1) of €106.5 suggests significant variance in the middle range of listings.
- The high standard deviation (€116.43) confirms substantial price diversity.

### Price Per Guest (Airbnb)

For Airbnb listings, the price per guest metric provides additional insights:
- The median price per guest is €47.50
- The average price per guest is €54.95
- The range extends from €4.50 to €500 per guest

## Property Type Analysis

### Property Sales by Type

| Property Type | Count | Median Price (€) | Mean Price (€) | Min Price (€) | Max Price (€) |
|---------------|-------|------------------|----------------|---------------|---------------|
| New | 525 | 355,749 | 389,846 | 45,000 | 2,890,837 |
| Second-Hand | 2,165 | 325,000 | 360,080 | 6,246 | 3,261,094 |

Key observations:
- New properties command a premium of approximately 9.5% in median price compared to second-hand properties.
- New properties represent approximately 19.5% of the sales in the dataset.
- Second-hand properties show a wider price range, with both lower minimum and higher maximum prices.

### Airbnb Listings by Room Type

| Room Type | Count | Median Price (€) | Mean Price (€) | Min Price (€) | Max Price (€) |
|-----------|-------|------------------|----------------|---------------|---------------|
| Entire home/apt | 151 | 174 | 208 | 42 | 1,000 |
| Private room | 155 | 70 | 79.5 | 35 | 395 |
| Shared room | 1 | 72 | 72 | 72 | 72 |

Key observations:
- Entire home/apartment listings command a significant premium, with a median price 2.5 times higher than private rooms.
- There is a near-even split between entire home (151) and private room (155) listings in the dataset.
- The entire home/apartment category shows much greater price variation, with a higher standard deviation.

### Price Per Guest by Room Type (Airbnb)

| Room Type | Median Price Per Guest (€) | Mean Price Per Guest (€) | Min Price Per Guest (€) | Max Price Per Guest (€) |
|-----------|----------------------------|--------------------------|-------------------------|-------------------------|
| Entire home/apt | 52.50 | 61.12 | 14 | 500 |
| Private room | 42 | 48.98 | 8.89 | 350 |
| Shared room | 4.50 | 4.50 | 4.50 | 4.50 |

Key observations:
- On a per-guest basis, entire homes still command a premium but the difference is less dramatic (25% higher median price versus 148% higher for total price).
- Private rooms offer better value on a per-guest basis, which may explain their popularity.

## Price Distribution Patterns

Analysis of the price distribution histograms reveals several important patterns:

1. **Property Sales Distribution**:
   - The distribution is positively skewed, with a concentration of properties in the €200,000 to €450,000 range.
   - There is a long tail of high-value properties extending beyond €1 million.
   - The log-transformed histogram reveals a more normal distribution, suggesting a log-normal price distribution which is common in real estate markets.

2. **Airbnb Listings Distribution**:
   - The distribution is strongly positively skewed, with most listings concentrated in the €50 to €200 range.
   - A small number of premium listings create a long tail extending to €1,000.
   - The log-transformed histogram shows a bimodal distribution, likely corresponding to the private room versus entire home categories.

## Implications

1. **Market Segmentation**:
   - The property sales market shows clear segmentation between mass-market properties (€200,000-€450,000) and premium properties (€500,000+).
   - The Airbnb market shows distinct segmentation between private rooms (clustered around €70) and entire homes (clustered around €174).

2. **Investment Insights**:
   - New properties command a price premium but represent only about one-fifth of the market.
   - The wide range in property prices suggests opportunities for both entry-level investments and premium development.
   - For Airbnb hosts, entire home listings generate substantially higher revenue, but private rooms might offer better returns on a per-room basis.

3. **Affordability Considerations**:
   - With a median property price of €335,000, affordability remains a concern for many potential buyers in Cork City.
   - The presence of properties at the lower end of the spectrum (below €200,000) suggests some affordable options exist, but they represent a small portion of the market.

## Conclusion

The price analysis reveals a diverse property market in Cork City with substantial variation in both sales prices and short-term rental rates. The premium for new properties and the significant price difference between entire homes and private rooms in the Airbnb market highlight clear consumer preferences. 

The positively skewed distributions for both property sales and Airbnb listings are consistent with typical real estate markets, where a smaller number of premium properties extend the upper range of prices. These findings provide valuable insights for potential buyers, investors, and policymakers interested in the Cork City property market. 