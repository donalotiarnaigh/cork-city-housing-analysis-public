# Data Dictionary

## Property Price Register (PPR) Dataset
**File:** `data/PropertySales/PPR-2024-Cork.csv`

| Column Name | Description | Data Type | Notes |
|------------|-------------|-----------|-------|
| Date of Sale | Date when the property was sold | Date (dd/mm/yyyy) | |
| Address | Full property address | String | |
| County | County where property is located | String | Always "Cork" in this dataset |
| Eircode | Irish postal code | String | Some entries may be empty |
| Price | Sale price in euros | Numeric | Includes € symbol in raw data |
| Not Full Market Price | Indicates if sale was below market value | Boolean (Yes/No) | |
| VAT Exclusive | Indicates if price excludes VAT | Boolean (Yes/No) | |
| Description of Property | Type of property | String | "New Dwelling house /Apartment" or "Second-Hand Dwelling house /Apartment" |
| Property Size Description | Additional property details | String | Often empty |

## Airbnb Listings Dataset
**File:** `data/Airbnb/listings.csv`

### Location Data
| Column Name | Description | Data Type | Notes |
|------------|-------------|-----------|-------|
| latitude | Geographic latitude | Numeric | |
| longitude | Geographic longitude | Numeric | |
| neighbourhood | Neighborhood name | String | |
| host_neighbourhood | Host's neighborhood | String | |

### Property Information
| Column Name | Description | Data Type | Notes |
|------------|-------------|-----------|-------|
| property_type | Type of property | String | e.g., "Apartment", "House" |
| room_type | Type of room | String | "Entire home/apt", "Private room", "Shared room" |
| accommodates | Number of guests property can accommodate | Integer | |
| bedrooms | Number of bedrooms | Integer | |
| beds | Number of beds | Integer | |
| bathrooms | Number of bathrooms | Numeric | May include half-baths |
| bathrooms_text | Text description of bathrooms | String | |
| amenities | List of amenities | String | Comma-separated list |

### Pricing and Availability
| Column Name | Description | Data Type | Notes |
|------------|-------------|-----------|-------|
| price | Listing price | String | Includes currency symbol |
| minimum_nights | Minimum stay requirement | Integer | |
| maximum_nights | Maximum stay allowed | Integer | |
| availability_30 | Days available in next 30 days | Integer | |
| availability_60 | Days available in next 60 days | Integer | |
| availability_90 | Days available in next 90 days | Integer | |
| availability_365 | Days available in next 365 days | Integer | |

### Host Information
| Column Name | Description | Data Type | Notes |
|------------|-------------|-----------|-------|
| host_name | Name of the host | String | |
| host_since | Date host joined Airbnb | Date | |
| host_is_superhost | Superhost status | Boolean | |
| host_listings_count | Number of host's listings | Integer | |
| calculated_host_listings_count | Total listings by host | Integer | |
| calculated_host_listings_count_entire_homes | Number of entire home listings | Integer | |
| calculated_host_listings_count_private_rooms | Number of private room listings | Integer | |
| calculated_host_listings_count_shared_rooms | Number of shared room listings | Integer | |

### Review Data
| Column Name | Description | Data Type | Notes |
|------------|-------------|-----------|-------|
| number_of_reviews | Total number of reviews | Integer | |
| number_of_reviews_ltm | Reviews in last 12 months | Integer | |
| number_of_reviews_l30d | Reviews in last 30 days | Integer | |
| review_scores_rating | Average review score | Numeric | Scale 0-100 |
| review_scores_location | Location rating | Numeric | Scale 0-10 |
| review_scores_value | Value rating | Numeric | Scale 0-10 |
| reviews_per_month | Average reviews per month | Numeric | |

## Notes
- All monetary values in the PPR dataset are in euros (€)
- Airbnb price data may need cleaning to convert to numeric values
- Geographic coordinates are in WGS84 (standard GPS coordinates)
- Some fields may contain missing values (NA or empty strings) 