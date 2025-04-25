# Geographic Analysis of Cork City Housing Data - Test Script
# This script tests just the data loading and preparation

# Load required libraries
library(sf)
library(dplyr)
library(mapview)
library(here)

# Set paths
ppr_path <- here(here("data/processed/interim/ppr_geocoded_verified.gpkg"))
airbnb_path <- here(here("data/processed/final/airbnb_cork_complete.csv"))
lea_boundary_path <- here(here("data/boundaries/CSO_Local_Electoral_Areas_National_Statistical_Boundaries_2022_Ungeneralised_view_-2156783281817775184.gpkg"))
urban_boundary_path <- here(here("data/boundaries/Urban_Areas_National_Statistical_Boundaries_2022_Ungeneralised_View_1807155406692103826.gpkg"))
output_dir <- here(here("output/maps"))

# Create output directory if it doesn't exist
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ---- 1.1.1 Load and prepare spatial data ----

# Load PPR data
print("Loading PPR data...")
ppr_data <- st_read(ppr_path)
print("PPR data loaded:")
print(paste("Number of properties:", nrow(ppr_data)))
print(paste("CRS:", st_crs(ppr_data)$input))

# Load Airbnb data and convert to spatial
print("Loading Airbnb data...")
airbnb_data <- read.csv(airbnb_path)
airbnb_sf <- st_as_sf(airbnb_data, 
                      coords = c("longitude", "latitude"), 
                      crs = 4326)
print("Airbnb data loaded:")
print(paste("Number of listings:", nrow(airbnb_sf)))
print(paste("CRS:", st_crs(airbnb_sf)$input))

# Load boundary data
print("Loading boundary data...")
lea_boundaries <- st_read(lea_boundary_path)
print("Local Electoral Areas loaded:")
print(paste("Number of areas:", nrow(lea_boundaries)))
print(paste("CRS:", st_crs(lea_boundaries)$input))
print("LEA column names:")
print(names(lea_boundaries))

urban_boundaries <- st_read(urban_boundary_path)
print("Urban Areas loaded:")
print(paste("Number of areas:", nrow(urban_boundaries)))
print(paste("CRS:", st_crs(urban_boundaries)$input))
print("Urban Areas column names:")
print(names(urban_boundaries))

# Extract Cork City boundary
print("Extracting Cork City boundary...")
# From LEA boundaries (filter for Cork City areas)
cork_leas <- lea_boundaries %>%
  filter(grepl("Cork City", COUNTY))

print(paste("Number of Cork City LEAs:", nrow(cork_leas)))

# From Urban boundaries (filter for Cork)
# Check if we have any Cork Urban Areas
print("Checking Urban Areas data...")
if ("COUNTYNAME" %in% names(urban_boundaries)) {
  cork_urban <- urban_boundaries %>%
    filter(grepl("Cork", COUNTYNAME))
} else if ("COUNTY" %in% names(urban_boundaries)) {
  cork_urban <- urban_boundaries %>%
    filter(grepl("Cork", COUNTY))
} else {
  print("No COUNTY or COUNTYNAME column found. Printing Urban Areas data:")
  print(urban_boundaries)
  cork_urban <- urban_boundaries # Use all urban areas for now
}

print(paste("Number of Cork Urban Areas:", nrow(cork_urban)))

# Transform all to the same projected CRS (Irish Grid - EPSG:29902)
print("Transforming to common CRS...")
if (st_crs(ppr_data) != st_crs(29902)) {
  ppr_data <- st_transform(ppr_data, 29902)
  print("PPR data transformed to Irish Grid (EPSG:29902)")
}

if (st_crs(airbnb_sf) != st_crs(29902)) {
  airbnb_sf <- st_transform(airbnb_sf, 29902)
  print("Airbnb data transformed to Irish Grid (EPSG:29902)")
}

if (st_crs(cork_leas) != st_crs(29902)) {
  cork_leas <- st_transform(cork_leas, 29902)
  print("Cork LEAs transformed to Irish Grid (EPSG:29902)")
}

if (st_crs(cork_urban) != st_crs(29902)) {
  cork_urban <- st_transform(cork_urban, 29902)
  print("Cork Urban Areas transformed to Irish Grid (EPSG:29902)")
}

# Create a single Cork City boundary
print("Creating unified Cork City boundary...")
if (nrow(cork_leas) > 0) {
  cork_city_boundary <- st_union(cork_leas)
  print("Cork City boundary created from LEAs")
} else if (nrow(cork_urban) > 0) {
  cork_city_boundary <- st_union(cork_urban)
  print("Cork City boundary created from Urban Areas")
} else {
  print("No Cork boundaries found. Cannot create a unified boundary.")
  stop("No Cork boundaries found.")
}

# Save the prepared spatial data
print("Saving prepared data...")
st_write(airbnb_sf, here(here("data/processed/airbnb_geocoded.gpkg")), delete_layer = TRUE)
st_write(cork_city_boundary, here(here("data/boundaries/cork_city_boundary.gpkg")), delete_layer = TRUE)

print("Data preparation complete!")
print("Check the output directory for saved files.") 
