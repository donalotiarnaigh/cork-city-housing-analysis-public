# Data Documentation

This directory contains the datasets used in the Cork City Property Analysis project. Due to file size constraints, most of the actual data files are not included in the repository but can be generated using the scripts in the `scripts/` directory.

## Directory Structure

```
data/
├── raw/               # Original, unmodified data
├── processed/         # Cleaned and processed data
├── boundaries/        # Geographic boundary files for Cork City
└── samples/           # Sample data for testing and demonstration
```

## Data Sources

### Property Price Register (PPR)

- **Source**: Property Services Regulatory Authority (PSRA)
- **URL**: https://www.propertypriceregister.ie/
- **Description**: Contains records of residential property sales in Ireland
- **Time Period**: From January 1, 2010, to December 31, 2022
- **File Format**: CSV

### Airbnb Listings

- **Source**: Inside Airbnb
- **URL**: http://insideairbnb.com/get-the-data/
- **Description**: Information about Airbnb listings in Cork City
- **Time Period**: Data as of February 2023
- **File Format**: CSV

### Cork City Boundary

- **Source**: Ordnance Survey Ireland (OSi)
- **URL**: https://data.gov.ie/
- **Description**: Geographic boundary file for Cork City
- **File Format**: Shapefile/GeoPackage
