# Geographic Analysis of Cork City Housing Data
# This script performs the following tasks:
# 1. Loads and prepares spatial data (PPR and Airbnb)
# 2. Creates density maps for both datasets
# 3. Performs cluster analysis

# Load required libraries
library(sf)
library(tmap)
library(dplyr)
library(ggplot2)
library(spatstat)
library(mapview)
library(dbscan)
library(units)
library(raster)
library(stars)
library(htmlwidgets)
library(here)

# Set paths
ppr_path <- here(here("data/processed/final/ppr_corkCity.csv"))
airbnb_path <- here(here("data/processed/final/airbnb_cork_complete.csv"))
lea_boundary_path <- here(here("data/boundaries/CSO_Local_Electoral_Areas_National_Statistical_Boundaries_2022_Ungeneralised_view_-2156783281817775184.gpkg"))
urban_boundary_path <- here(here("data/boundaries/Urban_Areas_National_Statistical_Boundaries_2022_Ungeneralised_View_1807155406692103826.gpkg"))
output_dir <- here(here("output/maps"))

# Create output directory if it doesn't exist
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ---- 1.1.1 Load and prepare spatial data ----

# Load PPR data
ppr_data_raw <- read.csv(ppr_path)
print("PPR data loaded:")
print(paste("Number of properties:", nrow(ppr_data_raw)))

# Check if data already has an in_cork_bounds column and if they're already filtered
if ("in_cork_bounds" %in% names(ppr_data_raw)) {
  print("Data already has Cork City boundary filtering")
  if (all(ppr_data_raw$in_cork_bounds == TRUE)) {
    print("All properties are already marked as within Cork City boundary")
  } else {
    # Filter to only include properties within Cork City
    ppr_data_raw <- ppr_data_raw[ppr_data_raw$in_cork_bounds == TRUE, ]
    print(paste("Filtered to", nrow(ppr_data_raw), "properties within Cork City boundary"))
  }
}

# Check the range of coordinates to determine if they're in Irish Grid or WGS84
lon_range <- range(as.numeric(ppr_data_raw$longitude), na.rm = TRUE)
lat_range <- range(as.numeric(ppr_data_raw$latitude), na.rm = TRUE)
print(paste("Longitude range:", paste(lon_range, collapse = " to ")))
print(paste("Latitude range:", paste(lat_range, collapse = " to ")))

# Determine if coordinates are likely Irish Grid (larger numbers) or WGS84 (smaller numbers)
is_irish_grid <- mean(lon_range) > 100000 # Irish Grid has larger numbers

if (is_irish_grid) {
  print("Detected Irish Grid coordinates - setting CRS to EPSG:29902")
  ppr_data <- st_as_sf(ppr_data_raw,
                       coords = c("longitude", "latitude"),
                       crs = 29902) # Irish Grid
} else {
  print("Detected WGS84 coordinates - setting CRS to EPSG:4326")
  ppr_data <- st_as_sf(ppr_data_raw,
                       coords = c("longitude", "latitude"),
                       crs = 4326) # WGS84
}

print(paste("CRS:", st_crs(ppr_data)$input))

# Load Airbnb data and convert to spatial
airbnb_data <- read.csv(airbnb_path)
airbnb_sf <- st_as_sf(airbnb_data, 
                      coords = c("longitude", "latitude"), 
                      crs = 4326)
print("Airbnb data loaded:")
print(paste("Number of listings:", nrow(airbnb_sf)))
print(paste("CRS:", st_crs(airbnb_sf)$input))

# Load boundary data
lea_boundaries <- st_read(lea_boundary_path)
print("Local Electoral Areas loaded:")
print(paste("Number of areas:", nrow(lea_boundaries)))
print(paste("CRS:", st_crs(lea_boundaries)$input))

urban_boundaries <- st_read(urban_boundary_path)
print("Urban Areas loaded:")
print(paste("Number of areas:", nrow(urban_boundaries)))
print(paste("CRS:", st_crs(urban_boundaries)$input))

# Extract Cork City boundary
# From LEA boundaries (filter for Cork City areas)
print("Column names in LEA boundaries:")
print(names(lea_boundaries))

# First check if we can directly identify Cork in the LEAs
if ("COUNTY" %in% names(lea_boundaries)) {
  cork_leas <- lea_boundaries %>%
    filter(grepl("Cork", COUNTY, ignore.case = TRUE))
  
  print(paste("Number of Cork LEAs found:", nrow(cork_leas)))
  if (nrow(cork_leas) > 0) {
    print("Cork LEAs counties found:")
    print(unique(cork_leas$COUNTY))
  }
} else {
  print("No COUNTY column found in LEA boundaries")
}

# As a backup, try to identify Cork LEAs by examining all text columns
if (nrow(cork_leas) == 0) {
  possible_columns <- names(lea_boundaries)[sapply(lea_boundaries, is.character)]
  print("Checking for Cork in text columns of LEA data:")
  print(possible_columns)
  
  # Print unique values in these columns to help identify Cork
  for (col in possible_columns) {
    if (col != "SHAPE") {  # Skip geometry column
      print(paste("Values in", col, "column:"))
      print(unique(lea_boundaries[[col]]))
    }
  }
  
  # Now explicitly check each text column for Cork and select matching LEAs
  for (col in possible_columns) {
    if (col != "SHAPE") {  # Skip geometry column
      matches <- grepl("Cork", lea_boundaries[[col]], ignore.case = TRUE)
      if (any(matches)) {
        print(paste("Found Cork matches in column:", col))
        cork_leas <- lea_boundaries[matches, ]
        print(paste("Number of Cork LEAs found:", nrow(cork_leas)))
        break
      }
    }
  }
}

# From Urban boundaries (as a fallback)
if ("COUNTYNAME" %in% names(urban_boundaries)) {
  cork_urban <- urban_boundaries %>%
    filter(grepl("Cork", COUNTYNAME, ignore.case = TRUE))
} else if ("COUNTY" %in% names(urban_boundaries)) {
  cork_urban <- urban_boundaries %>%
    filter(grepl("Cork", COUNTY, ignore.case = TRUE))
} else {
  print("No COUNTY or COUNTYNAME column found in urban boundaries. Using all urban areas.")
  cork_urban <- urban_boundaries
}

print(paste("Number of Cork Urban Areas:", nrow(cork_urban)))

# Transform all to the same projected CRS (Irish Grid - EPSG:29902)
if (st_crs(ppr_data) != st_crs(29902)) {
  ppr_data <- st_transform(ppr_data, 29902)
  print("PPR data transformed to Irish Grid (EPSG:29902)")
}

if (st_crs(airbnb_sf) != st_crs(29902)) {
  airbnb_sf <- st_transform(airbnb_sf, 29902)
  print("Airbnb data transformed to Irish Grid (EPSG:29902)")
}

if (nrow(cork_leas) > 0 && !is.null(st_crs(cork_leas))) {
  if (st_crs(cork_leas) != st_crs(29902)) {
    cork_leas <- st_transform(cork_leas, 29902)
    print("Cork LEAs transformed to Irish Grid (EPSG:29902)")
  }
}

if (st_crs(cork_urban) != st_crs(29902)) {
  cork_urban <- st_transform(cork_urban, 29902)
  print("Cork Urban Areas transformed to Irish Grid (EPSG:29902)")
}

# Create a single Cork City boundary - prioritize using LEA boundaries
if (nrow(cork_leas) > 0) {
  # Create a union of all Cork LEAs to get the full Cork boundary
  cork_city_boundary <- st_union(cork_leas)
  print("Cork City boundary created from Local Electoral Areas - Local Authority boundary")
} else if (nrow(cork_urban) > 0) {
  # Fallback to urban boundaries if no LEAs found
  cork_city_boundary <- st_union(cork_urban)
  print("WARNING: Using Urban Areas boundary as fallback - not the local authority boundary")
} else {
  stop("No Cork boundaries found in either dataset.")
}

# Save the Cork City boundary
st_write(cork_city_boundary, here(here("data/boundaries/cork_city_boundary.gpkg")), delete_layer = TRUE)

# ---- NEW SECTION: Create trimmed datasets for Cork City only ----
print("Filtering data to include only properties within Cork City boundary...")

# Trim PPR data to include only properties within Cork City boundary
# Since the data already has in_cork_bounds column, we'll use that directly
print("Using pre-filtered Cork City data...")
ppr_cork_city <- ppr_data
print(paste("Number of PPR properties in Cork City dataset:", nrow(ppr_cork_city)))

# Save the Cork City boundary for reference
st_write(cork_city_boundary, here(here("data/boundaries/cork_city_boundary.gpkg")), delete_layer = TRUE)

# Trim Airbnb data to include only listings within Cork City boundary
airbnb_cork_city <- st_intersection(airbnb_sf, cork_city_boundary)
print(paste("Number of Airbnb listings within Cork City boundary:", nrow(airbnb_cork_city)))
print(paste("Filtered out", nrow(airbnb_sf) - nrow(airbnb_cork_city), "listings outside Cork City"))

# Add a flag indicating it's within Cork City bounds
airbnb_cork_city$in_cork_bounds <- TRUE

# Save the trimmed Airbnb data
st_write(airbnb_cork_city, here(here("data/processed/final/airbnb_corkCity.gpkg")), delete_layer = TRUE)
print("Airbnb Cork City data saved as GPKG")

# Update the variables to use the trimmed datasets for all subsequent analyses
ppr_data <- ppr_cork_city
airbnb_sf <- airbnb_cork_city

print("Datasets trimmed and ready for analysis")

# Save the prepared Airbnb spatial data (full dataset for reference)
st_write(airbnb_sf, here(here("data/processed/airbnb_geocoded.gpkg")), delete_layer = TRUE)

# Quick visual check with boundaries using mapview
map_check <- mapview(cork_city_boundary, alpha.regions = 0.2, col.regions = "gray", 
                     layer.name = "Cork City Boundary") +
             mapview(ppr_data, col.regions = "blue", alpha = 0.5, cex = 3, 
                     layer.name = "Property Sales") + 
             mapview(airbnb_sf, col.regions = "red", alpha = 0.5, cex = 3,
                     layer.name = "Airbnb Listings")

# Display the map
map_check

# Save the interactive map
saveWidget(map_check@map, file.path(output_dir, "initial_spatial_distribution.html"))
print(paste("Interactive map saved to", file.path(output_dir, "initial_spatial_distribution.html")))

# Create and save a static map using tmap
tm_basemap <- tm_shape(cork_city_boundary) + 
  tm_borders(col = "black", lwd = 2) + 
  tm_fill(col = "gray", alpha = 0.2)

# Sample a subset of points for better visualization if too many
ppr_sample <- ppr_data[sample(nrow(ppr_data), min(1000, nrow(ppr_data))),]
airbnb_sample <- airbnb_sf[sample(nrow(airbnb_sf), min(400, nrow(airbnb_sf))),]

# Create the map
static_map <- tm_basemap +
  tm_shape(ppr_sample) + 
  tm_dots(col = "blue", size = 0.1, alpha = 0.7, title = "Property Sales") +
  tm_shape(airbnb_sample) +
  tm_dots(col = "red", size = 0.1, alpha = 0.7, title = "Airbnb Listings") +
  tm_layout(title = "Cork City Housing: Property Sales and Airbnb Listings",
            legend.outside = TRUE,
            legend.position = c("right", "bottom"))

# Save the static map
tmap_save(static_map, file.path(output_dir, "spatial_distribution.png"), 
          width = 10, height = 8, units = "in", dpi = 300)
print(paste("Static map saved to", file.path(output_dir, "spatial_distribution.png")))

# ---- 1.1.2 Create density maps ----

# Function to create density surface
create_density_surface <- function(points, boundary, cell_size = 250) {
  # Make sure we're working with the right CRS
  if (st_crs(points) != st_crs(boundary)) {
    points <- st_transform(points, st_crs(boundary))
  }
  
  # Create a bounding box for the study area with some buffer
  bbox <- st_bbox(boundary)
  
  # NOTE: Since we're now using pre-filtered data, this intersection is redundant
  # but keeping for safety and in case this function is reused elsewhere
  points_in_boundary <- st_intersection(points, boundary)
  print(paste("Number of points within boundary:", nrow(points_in_boundary)))
  
  # If no points within boundary, return NULL
  if (nrow(points_in_boundary) == 0) {
    print("No points within boundary. Cannot create density surface.")
    return(NULL)
  }
  
  # Use a simplified approach - create a raster grid and count points
  # Create a raster template based on boundary bbox
  rast_template <- raster(extent(bbox), 
                          resolution = c(cell_size, cell_size),
                          crs = st_crs(boundary)$proj4string)
  
  # Extract coordinates
  coords <- st_coordinates(points_in_boundary)
  
  # Rasterize the points (count points per cell)
  point_raster <- rasterize(coords, rast_template, fun = "count", background = 0)
  
  # Smooth the point counts using focal function (moving window average)
  smooth_raster <- focal(point_raster, w = matrix(1, 5, 5), fun = mean, na.rm = TRUE)
  
  # Mask to boundary
  boundary_raster <- rasterize(as(boundary, "Spatial"), rast_template, background = 1)
  masked_raster <- mask(smooth_raster, boundary_raster)
  
  # Convert raster to sf for mapping
  raster_sf <- st_as_stars(masked_raster) %>% st_as_sf()
  
  return(list(
    raster = masked_raster,
    sf = raster_sf
  ))
}

# PPR density - calculate when running
ppr_density_calc <- function() {
  ppr_density <- create_density_surface(ppr_data, cork_city_boundary)
  
  # Save results if not NULL
  if (!is.null(ppr_density)) {
    saveRDS(ppr_density, file.path(output_dir, "ppr_density.rds"))
    
    # Create density map - put boundary on top for visibility
    ppr_density_map <- tm_shape(ppr_density$sf) +
      tm_fill(col = "layer", style = "fisher", palette = "Blues", title = "PPR Density") +
      tm_shape(cork_city_boundary) + 
      tm_borders(lwd = 1.5, col = "black") +
      tm_layout(main.title = "Property Sale Density in Cork City",
                legend.outside = TRUE)
    
    # Save the density map
    tmap_save(ppr_density_map, file.path(output_dir, "ppr_density.png"), 
              width = 10, height = 8, units = "in", dpi = 300)
    print(paste("PPR density map saved to", file.path(output_dir, "ppr_density.png")))
    
    return(ppr_density_map)
  } else {
    print("Could not create PPR density map.")
    return(NULL)
  }
}

# Airbnb density - calculate when running
airbnb_density_calc <- function() {
  airbnb_density <- create_density_surface(airbnb_sf, cork_city_boundary)
  
  # Save results if not NULL
  if (!is.null(airbnb_density)) {
    saveRDS(airbnb_density, file.path(output_dir, "airbnb_density.rds"))
    
    # Create density map - put boundary on top for visibility
    airbnb_density_map <- tm_shape(airbnb_density$sf) +
      tm_fill(col = "layer", style = "fisher", palette = "Reds", title = "Airbnb Density") +
      tm_shape(cork_city_boundary) + 
      tm_borders(lwd = 1.5, col = "black") +
      tm_layout(main.title = "Airbnb Listing Density in Cork City",
                legend.outside = TRUE)
    
    # Save the density map
    tmap_save(airbnb_density_map, file.path(output_dir, "airbnb_density.png"), 
              width = 10, height = 8, units = "in", dpi = 300)
    print(paste("Airbnb density map saved to", file.path(output_dir, "airbnb_density.png")))
    
    # Create a combined density map for comparison if both densities exist
    ppr_density <- try(readRDS(file.path(output_dir, "ppr_density.rds")), silent = TRUE)
    
    if (!inherits(ppr_density, "try-error") && !is.null(ppr_density)) {
      # Combined density map - put boundary on top for visibility
      combined_density_map <- tm_shape(ppr_density$sf) +
        tm_fill(col = "layer", style = "fisher", palette = "Blues", alpha = 0.5, title = "Property Sales") +
        tm_shape(airbnb_density$sf) +
        tm_fill(col = "layer", style = "fisher", palette = "Reds", alpha = 0.5, title = "Airbnb Listings") +
        tm_shape(cork_city_boundary) + 
        tm_borders(lwd = 1.5, col = "black") +
        tm_layout(main.title = "Comparison of Property Sales and Airbnb Listing Densities",
                  legend.outside = TRUE)
      
      # Save the combined map
      tmap_save(combined_density_map, file.path(output_dir, "combined_density.png"), 
                width = 10, height = 8, units = "in", dpi = 300)
      print(paste("Combined density map saved to", file.path(output_dir, "combined_density.png")))
    }
    
    return(airbnb_density_map)
  } else {
    print("Could not create Airbnb density map.")
    return(NULL)
  }
}

# ---- 1.1.3 Cluster analysis ----

# Function to perform DBSCAN clustering
perform_clustering <- function(points, eps_distance = 500, min_points = 5) {
  # NOTE: Since we're now using pre-filtered data, this intersection is redundant
  # but keeping for safety and in case this function is reused elsewhere
  points_in_boundary <- st_intersection(points, cork_city_boundary)
  print(paste("Number of points within boundary for clustering:", nrow(points_in_boundary)))
  
  # Check if there are any points to cluster
  if (nrow(points_in_boundary) == 0) {
    print("No points within boundary for clustering. Cannot perform clustering.")
    return(NULL)
  }
  
  # Extract coordinates
  coords <- st_coordinates(points_in_boundary)
  
  # Check for NA values
  if (any(is.na(coords))) {
    print("Removing points with missing coordinates...")
    valid_rows <- complete.cases(coords)
    coords <- coords[valid_rows, ]
    points_in_boundary <- points_in_boundary[valid_rows, ]
    print(paste("Points after removing NAs:", nrow(points_in_boundary)))
  }
  
  # Check if we still have enough points to cluster
  if (nrow(points_in_boundary) < min_points) {
    print(paste("Not enough valid points for clustering. Need at least", min_points))
    return(NULL)
  }
  
  # Perform DBSCAN clustering
  db <- dbscan::dbscan(coords, eps = eps_distance, minPts = min_points)
  
  # Add cluster information to the original data
  points_in_boundary$cluster <- as.factor(db$cluster)
  
  # Calculate cluster statistics
  cluster_stats <- points_in_boundary %>%
    st_drop_geometry() %>%
    group_by(cluster) %>%
    summarize(count = n(),
              mean_price = ifelse("price" %in% names(.), mean(price, na.rm = TRUE), NA),
              mean_size = ifelse("size" %in% names(.), mean(size, na.rm = TRUE), NA)) %>%
    arrange(desc(count))
  
  # Return data with clusters and stats
  return(list(
    points_with_clusters = points_in_boundary,
    cluster_statistics = cluster_stats
  ))
}

# PPR clustering - to be executed when running
ppr_clustering_calc <- function(eps = 500, min_pts = 10) {
  ppr_clusters <- perform_clustering(ppr_data, eps_distance = eps, min_points = min_pts)
  
  # Only proceed if clustering was successful
  if (is.null(ppr_clusters)) {
    print("PPR clustering could not be performed.")
    return(NULL)
  }
  
  # Save results
  saveRDS(ppr_clusters, file.path(output_dir, "ppr_clusters.rds"))
  
  # Visualize clusters
  # Color palette for clusters (excluding noise which is cluster 0)
  cluster_count <- length(unique(ppr_clusters$points_with_clusters$cluster)) - 1
  colors <- c("gray", rainbow(cluster_count))
  
  # Map
  ppr_cluster_map <- tm_shape(cork_city_boundary) + 
    tm_borders() +
    tm_shape(ppr_clusters$points_with_clusters) +
    tm_dots(col = "cluster", palette = colors, size = 0.1, title = "PPR Clusters") +
    tm_layout(main.title = "Property Sale Clusters in Cork City",
              legend.outside = TRUE)
  
  # Save the cluster map
  tmap_save(ppr_cluster_map, file.path(output_dir, "ppr_clusters.png"), 
            width = 10, height = 8, units = "in", dpi = 300)
  print(paste("PPR cluster map saved to", file.path(output_dir, "ppr_clusters.png")))
  
  # Create an interactive cluster map
  interactive_ppr <- mapview(cork_city_boundary, alpha.regions = 0.2, col.regions = "gray") +
                     mapview(ppr_clusters$points_with_clusters, zcol = "cluster", 
                             cex = 3, layer.name = "Property Sale Clusters")
  
  # Save interactive map
  saveWidget(interactive_ppr@map, file.path(output_dir, "ppr_clusters_interactive.html"))
  print(paste("Interactive PPR cluster map saved to", file.path(output_dir, "ppr_clusters_interactive.html")))
  
  # Write cluster statistics to CSV
  write.csv(ppr_clusters$cluster_statistics, file.path(output_dir, "ppr_cluster_statistics.csv"), row.names = FALSE)
  print(paste("PPR cluster statistics saved to", file.path(output_dir, "ppr_cluster_statistics.csv")))
  
  return(ppr_cluster_map)
}

# Airbnb clustering - to be executed when running
airbnb_clustering_calc <- function(eps = 300, min_pts = 5) {
  airbnb_clusters <- perform_clustering(airbnb_sf, eps_distance = eps, min_points = min_pts)
  
  # Only proceed if clustering was successful
  if (is.null(airbnb_clusters)) {
    print("Airbnb clustering could not be performed.")
    return(NULL)
  }
  
  # Save results
  saveRDS(airbnb_clusters, file.path(output_dir, "airbnb_clusters.rds"))
  
  # Visualize clusters
  # Color palette for clusters (excluding noise which is cluster 0)
  cluster_count <- length(unique(airbnb_clusters$points_with_clusters$cluster)) - 1
  colors <- c("gray", rainbow(cluster_count))
  
  # Map
  airbnb_cluster_map <- tm_shape(cork_city_boundary) + 
    tm_borders() +
    tm_shape(airbnb_clusters$points_with_clusters) +
    tm_dots(col = "cluster", palette = colors, size = 0.1, title = "Airbnb Clusters") +
    tm_layout(main.title = "Airbnb Listing Clusters in Cork City",
              legend.outside = TRUE)
  
  # Save the cluster map
  tmap_save(airbnb_cluster_map, file.path(output_dir, "airbnb_clusters.png"), 
            width = 10, height = 8, units = "in", dpi = 300)
  print(paste("Airbnb cluster map saved to", file.path(output_dir, "airbnb_clusters.png")))
  
  # Create an interactive cluster map
  interactive_airbnb <- mapview(cork_city_boundary, alpha.regions = 0.2, col.regions = "gray") +
                        mapview(airbnb_clusters$points_with_clusters, zcol = "cluster", 
                                cex = 3, layer.name = "Airbnb Clusters")
  
  # Save interactive map
  saveWidget(interactive_airbnb@map, file.path(output_dir, "airbnb_clusters_interactive.html"))
  print(paste("Interactive Airbnb cluster map saved to", file.path(output_dir, "airbnb_clusters_interactive.html")))
  
  # Write cluster statistics to CSV
  write.csv(airbnb_clusters$cluster_statistics, file.path(output_dir, "airbnb_cluster_statistics.csv"), row.names = FALSE)
  print(paste("Airbnb cluster statistics saved to", file.path(output_dir, "airbnb_cluster_statistics.csv")))
  
  return(airbnb_cluster_map)
}

# Main execution block - Uncomment functions to run them
# Initial spatial distribution maps are already generated above

# Generate density maps
ppr_density_map <- ppr_density_calc()
airbnb_density_map <- airbnb_density_calc()

# Generate cluster maps
ppr_cluster_map <- ppr_clustering_calc(eps = 500, min_pts = 10)
airbnb_cluster_map <- airbnb_clustering_calc(eps = 300, min_pts = 5)

print("Geographic analysis script completed.")
print("All maps have been generated and saved to the output/maps directory.") 
