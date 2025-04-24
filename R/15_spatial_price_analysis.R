# Spatial Price Analysis for Cork City Housing
# This script performs the following analyses:
# 1. Creates price heatmaps for both PPR and Airbnb data
# 2. Identifies price hotspots in Cork City
# 3. Compares spatial patterns between property sales and Airbnb listings

# ---- 1. Libraries and Setup ----

# Load required libraries
library(sf)
library(tmap)
library(ggplot2)
library(dplyr)
library(spatstat)
library(mapview)
library(spdep)
library(raster)
library(stars)
library(viridis)
library(leaflet)
library(RColorBrewer)
library(htmlwidgets)

# Set paths
ppr_csv_path <- "data/processed/final/ppr_corkCity.csv"
airbnb_spatial_path <- "data/processed/final/airbnb_corkCity_with_price.gpkg"
boundary_path <- "data/boundaries/cork_city_boundary.gpkg"
output_dir <- "output/price_maps"

# Create output directory if it doesn't exist
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ---- 2. Data Loading and Preparation ----

# Load datasets
print("Loading datasets...")

# Load PPR data from CSV and convert to spatial
ppr_data_raw <- read.csv(ppr_csv_path)
print(paste("Loaded", nrow(ppr_data_raw), "PPR records from CSV"))

# Convert coordinates to numeric
ppr_data_raw$longitude <- as.numeric(ppr_data_raw$longitude)
ppr_data_raw$latitude <- as.numeric(ppr_data_raw$latitude)

# Check for missing coordinates
na_coords <- sum(is.na(ppr_data_raw$longitude) | is.na(ppr_data_raw$latitude))
if(na_coords > 0) {
  print(paste("Warning:", na_coords, "records have missing coordinates. Removing them."))
  ppr_data_raw <- ppr_data_raw[!is.na(ppr_data_raw$longitude) & !is.na(ppr_data_raw$latitude),]
  print(paste("Remaining PPR records:", nrow(ppr_data_raw)))
}

# Determine coordinate system based on value ranges
lon_range <- range(ppr_data_raw$longitude)
lat_range <- range(ppr_data_raw$latitude)
print(paste("Longitude range:", paste(lon_range, collapse=" - ")))
print(paste("Latitude range:", paste(lat_range, collapse=" - ")))

# Convert to spatial
is_irish_grid <- mean(lon_range) > 100000 # Check if coordinates are likely Irish Grid
if(is_irish_grid) {
  print("Detected Irish Grid coordinates - setting CRS accordingly")
  ppr_data <- st_as_sf(ppr_data_raw, coords = c("longitude", "latitude"), crs = 29902)
} else {
  print("Assumed WGS84 coordinates - setting CRS accordingly")
  ppr_data <- st_as_sf(ppr_data_raw, coords = c("longitude", "latitude"), crs = 4326)
}

# Check if price is available and summarize
if ("price" %in% names(ppr_data)) {
  price_summary <- summary(ppr_data$price)
  print("PPR Price Summary:")
  print(price_summary)
} else {
  stop("Price column not found in PPR data. Cannot proceed with price analysis.")
}

# Load Airbnb data
airbnb_data <- st_read(airbnb_spatial_path, quiet = TRUE)
print(paste("Loaded", nrow(airbnb_data), "Airbnb listings"))

# Check if price is available and summarize
if ("price" %in% names(airbnb_data)) {
  price_summary <- summary(airbnb_data$price)
  print("Airbnb Price Summary:")
  print(price_summary)
  
  # Count how many have valid prices
  n_with_price <- sum(!is.na(airbnb_data$price))
  print(paste("Airbnb listings with valid price:", n_with_price, 
              "(", round(n_with_price/nrow(airbnb_data)*100, 1), "%)"))
  
  # Filter to keep only records with valid prices
  airbnb_data <- airbnb_data[!is.na(airbnb_data$price),]
  print(paste("Filtered Airbnb data to", nrow(airbnb_data), "listings with valid prices"))
} else {
  stop("Price column not found in Airbnb data. Cannot proceed with price analysis.")
}

# Load Cork City boundary
cork_boundary <- st_read(boundary_path, quiet = TRUE)
print("Loaded Cork City boundary")

# Ensure all data is in the same CRS
target_crs <- st_crs(cork_boundary)
if (st_crs(ppr_data) != target_crs) {
  ppr_data <- st_transform(ppr_data, target_crs)
  print("Transformed PPR data to match boundary CRS")
}
if (st_crs(airbnb_data) != target_crs) {
  airbnb_data <- st_transform(airbnb_data, target_crs)
  print("Transformed Airbnb data to match boundary CRS")
}

# Create price categories for visualization
# For PPR data
ppr_price_breaks <- c(0, 200000, 300000, 400000, 500000, 750000, 1000000, Inf)
ppr_price_labels <- c("<200K", "200K-300K", "300K-400K", "400K-500K", "500K-750K", "750K-1M", ">1M")
ppr_data$price_category <- cut(ppr_data$price, 
                              breaks = ppr_price_breaks,
                              labels = ppr_price_labels,
                              include.lowest = TRUE)

# For Airbnb data
airbnb_price_breaks <- c(0, 50, 100, 150, 200, 300, 500, Inf)
airbnb_price_labels <- c("<€50", "€50-100", "€100-150", "€150-200", "€200-300", "€300-500", ">€500")
airbnb_data$price_category <- cut(airbnb_data$price, 
                                 breaks = airbnb_price_breaks,
                                 labels = airbnb_price_labels, 
                                 include.lowest = TRUE)

# Print category summaries
print("PPR price categories:")
print(table(ppr_data$price_category))

print("Airbnb price categories:")
print(table(airbnb_data$price_category))

print("Data preparation complete!")

# Define color palettes for visualizations
ppr_colors <- colorRampPalette(c("#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#E34A33", "#B30000"))(7)
airbnb_colors <- colorRampPalette(c("#EDF8FB", "#B3CDE3", "#8C96C6", "#8856A7", "#810F7C"))(7)
hotspot_colors <- c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B")

# ---- 3. PPR Price Heatmaps ----
print("Creating PPR price heatmaps...")

# --- 3.1. Basic point map with price categories ---
# Create a static map showing property sales colored by price category
ppr_point_map <- tm_shape(cork_boundary) +
  tm_borders() +
  tm_shape(ppr_data) +
  tm_dots(col = "price_category", 
          palette = ppr_colors, 
          size = 0.1,
          title = "Property Sale Price") +
  tm_layout(title = "Property Sales in Cork City by Price Category",
            legend.outside = TRUE,
            frame = FALSE)

# Save the static map
tmap_save(ppr_point_map, 
          filename = file.path(output_dir, "ppr_price_point_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("PPR point map saved")

# --- 3.2. Create Kernel Density Heatmap for PPR prices ---
# Prepare data for kernel density
ppr_points <- st_coordinates(ppr_data)
ppr_window <- as.owin(st_bbox(cork_boundary))
ppr_ppp <- ppp(x = ppr_points[,1], y = ppr_points[,2], window = ppr_window)

# Create a weighted point pattern using price values for weights
ppr_weighted <- ppr_ppp %mark% ppr_data$price

# Perform kernel density estimation with price weights
ppr_kde <- density.ppp(ppr_weighted, weights = ppr_data$price, sigma = 500, eps = 50)

# Convert to raster and clip to Cork city boundary
ppr_raster <- raster(ppr_kde)
cork_boundary_sp <- as(cork_boundary, "Spatial")
ppr_raster_masked <- mask(ppr_raster, cork_boundary_sp)

# Convert back to sf/stars object for mapping
ppr_kde_sf <- st_as_stars(ppr_raster_masked)
st_crs(ppr_kde_sf) <- st_crs(cork_boundary)

# Create price density map
ppr_density_map <- tm_shape(ppr_kde_sf) +
  tm_raster(style = "cont", 
            palette = viridis(256, option = "plasma"), 
            title = "Price Density (€)") +
  tm_shape(cork_boundary) +
  tm_borders(col = "black", lwd = 1.5, alpha = 0.5) +
  tm_layout(title = "Property Price Density Heatmap in Cork City",
            legend.outside = TRUE,
            frame = FALSE)

# Save the density map
tmap_save(ppr_density_map, 
          filename = file.path(output_dir, "ppr_price_density_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("PPR density map saved")

# --- 3.3. Create Hexbin Map for PPR Prices ---
# First create a hexagonal grid covering Cork city
hex_grid <- st_make_grid(cork_boundary, cellsize = 300, square = FALSE)
hex_grid_sf <- st_sf(geometry = hex_grid)
hex_grid_sf <- hex_grid_sf[st_intersects(hex_grid_sf, cork_boundary, sparse = FALSE),]

# Spatial join to count points per hexagon and calculate average price
hex_grid_sf$count <- lengths(st_intersects(hex_grid_sf, ppr_data))

# For each hexagon, calculate average price if there are any points
hex_prices <- list()
for (i in 1:nrow(hex_grid_sf)) {
  hex <- hex_grid_sf[i,]
  points_in_hex <- st_intersection(ppr_data, hex)
  if (nrow(points_in_hex) > 0) {
    hex_prices[[i]] <- mean(points_in_hex$price, na.rm = TRUE)
  } else {
    hex_prices[[i]] <- NA
  }
}
hex_grid_sf$avg_price <- unlist(hex_prices)

# Create hexbin map
hex_map <- tm_shape(hex_grid_sf) +
  tm_fill(col = "avg_price", 
          palette = "viridis", 
          style = "cont", 
          title = "Average Price (€)",
          id = "avg_price") +
  tm_shape(cork_boundary) +
  tm_borders(col = "black", lwd = 1.5, alpha = 0.5) +
  tm_layout(title = "Average Property Prices by Area (Hexbin)",
            legend.outside = TRUE,
            frame = FALSE)

# Save the hexbin map
tmap_save(hex_map, 
          filename = file.path(output_dir, "ppr_hexbin_price_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("PPR hexbin map saved")

# --- 3.4. Create interactive map for PPR data ---
# Transform to WGS84 for Leaflet
ppr_data_wgs84 <- st_transform(ppr_data, 4326)
cork_boundary_wgs84 <- st_transform(cork_boundary, 4326)

# Create an interactive leaflet map with proper field names and missing value handling
ppr_popup <- paste0(
  "<strong>Price:</strong> €", format(ppr_data_wgs84$price, big.mark=","), "<br>",
  "<strong>Address:</strong> ", ifelse(is.na(ppr_data_wgs84$original_address) | ppr_data_wgs84$original_address == "", 
                                     "Not available", 
                                     ppr_data_wgs84$original_address), "<br>",
  "<strong>Property Type:</strong> ", ifelse(is.na(ppr_data_wgs84$property_description) | ppr_data_wgs84$property_description == "", 
                                     "Not specified", 
                                     ppr_data_wgs84$property_description), "<br>",
  "<strong>Market Price:</strong> ", ifelse(ppr_data_wgs84$not_full_market_price == TRUE, 
                                          "No", "Yes"), "<br>",
  "<strong>VAT Exclusive:</strong> ", ifelse(ppr_data_wgs84$vat_exclusive == TRUE, 
                                           "Yes", "No")
)

ppr_leaflet <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = cork_boundary_wgs84, 
              color = "#444444", 
              weight = 1, 
              smoothFactor = 0.5, 
              fillOpacity = 0) %>%
  addCircleMarkers(data = ppr_data_wgs84,
                  radius = 5,
                  color = ~colorQuantile("YlOrRd", price)(price),
                  stroke = FALSE, 
                  fillOpacity = 0.7,
                  popup = ppr_popup) %>%
  addLegend(position = "bottomright", 
            pal = colorQuantile("YlOrRd", ppr_data_wgs84$price),
            values = ppr_data_wgs84$price,
            title = "Property Price Percentiles",
            opacity = 0.7)

# Save the interactive map
saveWidget(ppr_leaflet, file.path(output_dir, "ppr_interactive_price_map.html"), selfcontained = TRUE)

print("PPR interactive map saved")

# Create a summary of price statistics by area
# Join PPR data with electoral divisions for area-based analysis
# (Assuming electoral divisions are available in the cork_boundary file)
# This is a placeholder - adjust based on available data
print("PPR price heatmaps completed")

# ---- 4. Airbnb Price Heatmaps ----
print("Creating Airbnb price heatmaps...")

# --- 4.1. Basic point map with price categories ---
# Create a static map showing Airbnb listings colored by price category
airbnb_point_map <- tm_shape(cork_boundary) +
  tm_borders() +
  tm_shape(airbnb_data) +
  tm_dots(col = "price_category", 
          palette = airbnb_colors, 
          size = 0.1,
          title = "Airbnb Price (per night)") +
  tm_layout(title = "Airbnb Listings in Cork City by Price Category",
            legend.outside = TRUE,
            frame = FALSE)

# Save the static map
tmap_save(airbnb_point_map, 
          filename = file.path(output_dir, "airbnb_price_point_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("Airbnb point map saved")

# --- 4.2. Create Kernel Density Heatmap for Airbnb prices ---
# Prepare data for kernel density
airbnb_points <- st_coordinates(airbnb_data)
airbnb_window <- as.owin(st_bbox(cork_boundary))
airbnb_ppp <- ppp(x = airbnb_points[,1], y = airbnb_points[,2], window = airbnb_window)

# Create a weighted point pattern using price values for weights
airbnb_weighted <- airbnb_ppp %mark% airbnb_data$price

# Perform kernel density estimation with price weights
airbnb_kde <- density.ppp(airbnb_weighted, weights = airbnb_data$price, sigma = 500, eps = 50)

# Convert to raster and clip to Cork city boundary
airbnb_raster <- raster(airbnb_kde)
airbnb_raster_masked <- mask(airbnb_raster, cork_boundary_sp)

# Convert back to sf/stars object for mapping
airbnb_kde_sf <- st_as_stars(airbnb_raster_masked)
st_crs(airbnb_kde_sf) <- st_crs(cork_boundary)

# Create price density map
airbnb_density_map <- tm_shape(airbnb_kde_sf) +
  tm_raster(style = "cont", 
            palette = viridis(256, option = "inferno"), 
            title = "Price Density (€)") +
  tm_shape(cork_boundary) +
  tm_borders(col = "black", lwd = 1.5, alpha = 0.5) +
  tm_layout(title = "Airbnb Price Density Heatmap in Cork City",
            legend.outside = TRUE,
            frame = FALSE)

# Save the density map
tmap_save(airbnb_density_map, 
          filename = file.path(output_dir, "airbnb_price_density_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("Airbnb density map saved")

# --- 4.3. Create Hexbin Map for Airbnb Prices ---
# Use the same hex grid created for PPR data
# Calculate Airbnb statistics for each hexagon
hex_airbnb_prices <- list()
for (i in 1:nrow(hex_grid_sf)) {
  hex <- hex_grid_sf[i,]
  points_in_hex <- st_intersection(airbnb_data, hex)
  if (nrow(points_in_hex) > 0) {
    hex_airbnb_prices[[i]] <- mean(points_in_hex$price, na.rm = TRUE)
  } else {
    hex_airbnb_prices[[i]] <- NA
  }
}
hex_grid_sf$airbnb_avg_price <- unlist(hex_airbnb_prices)
hex_grid_sf$airbnb_count <- lengths(st_intersects(hex_grid_sf, airbnb_data))

# Create hexbin map for Airbnb
airbnb_hex_map <- tm_shape(hex_grid_sf) +
  tm_fill(col = "airbnb_avg_price", 
          palette = "viridis", 
          style = "cont", 
          title = "Average Airbnb Price (€)",
          id = "airbnb_avg_price") +
  tm_shape(cork_boundary) +
  tm_borders(col = "black", lwd = 1.5, alpha = 0.5) +
  tm_layout(title = "Average Airbnb Prices by Area (Hexbin)",
            legend.outside = TRUE,
            frame = FALSE)

# Save the hexbin map
tmap_save(airbnb_hex_map, 
          filename = file.path(output_dir, "airbnb_hexbin_price_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("Airbnb hexbin map saved")

# --- 4.4. Create interactive map for Airbnb data ---
# Transform to WGS84 for Leaflet (if not done already)
airbnb_data_wgs84 <- st_transform(airbnb_data, 4326)
# Cork boundary already transformed above

# Create an improved interactive leaflet map with better popups
airbnb_popup <- paste0(
  "<strong>Price:</strong> €", format(airbnb_data_wgs84$price, big.mark=","), " per night<br>",
  "<strong>Name:</strong> ", ifelse(is.na(airbnb_data_wgs84$name) | airbnb_data_wgs84$name == "", 
                                  "Unnamed listing", 
                                  airbnb_data_wgs84$name), "<br>",
  "<strong>Property Type:</strong> ", ifelse(is.na(airbnb_data_wgs84$property_type) | airbnb_data_wgs84$property_type == "", 
                                           "Not specified", 
                                           airbnb_data_wgs84$property_type), "<br>",
  "<strong>Room Type:</strong> ", ifelse(is.na(airbnb_data_wgs84$room_type) | airbnb_data_wgs84$room_type == "", 
                                       "Not specified", 
                                       airbnb_data_wgs84$room_type), "<br>",
  "<strong>Accommodates:</strong> ", ifelse(is.na(airbnb_data_wgs84$accommodates), 
                                          "Not specified", 
                                          airbnb_data_wgs84$accommodates), "<br>",
  "<strong>Reviews:</strong> ", ifelse(is.na(airbnb_data_wgs84$number_of_reviews), 
                                     "0", 
                                     airbnb_data_wgs84$number_of_reviews), "<br>",
  "<strong>Host Listings:</strong> ", ifelse(is.na(airbnb_data_wgs84$host_listings_count), 
                                           "Unknown", 
                                           airbnb_data_wgs84$host_listings_count)
)

airbnb_leaflet <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = cork_boundary_wgs84, 
              color = "#444444", 
              weight = 1, 
              smoothFactor = 0.5, 
              fillOpacity = 0) %>%
  addCircleMarkers(data = airbnb_data_wgs84,
                  radius = 5,
                  color = ~colorQuantile("YlGnBu", price)(price),
                  stroke = FALSE, 
                  fillOpacity = 0.7,
                  popup = airbnb_popup) %>%
  addLegend(position = "bottomright", 
            pal = colorQuantile("YlGnBu", airbnb_data_wgs84$price),
            values = airbnb_data_wgs84$price,
            title = "Airbnb Price Percentiles",
            opacity = 0.7)

# Save the interactive map
saveWidget(airbnb_leaflet, file.path(output_dir, "airbnb_interactive_price_map.html"), selfcontained = TRUE)

print("Airbnb interactive map saved")

# Compare Airbnb and PPR price distributions
# Create box plots comparing prices by area (if areas available)
print("Airbnb price heatmaps completed")

# ---- 5. Price Hotspot Analysis ----
print("Beginning price hotspot analysis...")

# --- 5.1. Prepare data for hotspot analysis ---
# Convert to projected CRS for accurate distance calculations if not already
if (st_is_longlat(ppr_data)) {
  ppr_data_proj <- st_transform(ppr_data, 2157) # Irish Transverse Mercator
} else {
  ppr_data_proj <- ppr_data
}

if (st_is_longlat(airbnb_data)) {
  airbnb_data_proj <- st_transform(airbnb_data, 2157) # Irish Transverse Mercator
} else {
  airbnb_data_proj <- airbnb_data
}

# --- 5.2. Getis-Ord Gi* hotspot analysis for PPR ---
# Create neighbor list based on distance
ppr_nb <- dnearneigh(st_coordinates(ppr_data_proj), 0, 1000) # 1000m radius
ppr_nb_weights <- nb2listw(ppr_nb, style="W", zero.policy=TRUE)

# Calculate Gi* statistic for PPR price
ppr_data_proj$price_norm <- (ppr_data_proj$price - mean(ppr_data_proj$price, na.rm=TRUE)) / 
                            sd(ppr_data_proj$price, na.rm=TRUE)
ppr_hotspots <- localG(ppr_data_proj$price_norm, ppr_nb_weights, zero.policy=TRUE)
ppr_data_proj$gi_star <- as.numeric(ppr_hotspots)
ppr_data_proj$hotspot_cat <- cut(ppr_data_proj$gi_star, 
                             breaks=c(-Inf, -2.58, -1.96, -1.65, 1.65, 1.96, 2.58, Inf),
                             labels=c("Cold Spot 99%", "Cold Spot 95%", "Cold Spot 90%", 
                                    "Not Significant", "Hot Spot 90%", "Hot Spot 95%", "Hot Spot 99%"))

# --- 5.3. Getis-Ord Gi* hotspot analysis for Airbnb ---
# Create neighbor list based on distance
airbnb_nb <- dnearneigh(st_coordinates(airbnb_data_proj), 0, 1000) # 1000m radius
airbnb_nb_weights <- nb2listw(airbnb_nb, style="W", zero.policy=TRUE)

# Calculate Gi* statistic for Airbnb price
airbnb_data_proj$price_norm <- (airbnb_data_proj$price - mean(airbnb_data_proj$price, na.rm=TRUE)) / 
                              sd(airbnb_data_proj$price, na.rm=TRUE)
airbnb_hotspots <- localG(airbnb_data_proj$price_norm, airbnb_nb_weights, zero.policy=TRUE)
airbnb_data_proj$gi_star <- as.numeric(airbnb_hotspots)
airbnb_data_proj$hotspot_cat <- cut(airbnb_data_proj$gi_star, 
                                 breaks=c(-Inf, -2.58, -1.96, -1.65, 1.65, 1.96, 2.58, Inf),
                                 labels=c("Cold Spot 99%", "Cold Spot 95%", "Cold Spot 90%", 
                                        "Not Significant", "Hot Spot 90%", "Hot Spot 95%", "Hot Spot 99%"))

# Convert back to original CRS for mapping
ppr_hotspot_data <- st_transform(ppr_data_proj, st_crs(cork_boundary))
airbnb_hotspot_data <- st_transform(airbnb_data_proj, st_crs(cork_boundary))

# --- 5.4. Create hotspot maps ---
# Hotspot color palette
hotspot_colors <- c("#0000FF", "#318DFF", "#74B4FF", "#EEEEEE", "#FFAA00", "#FF5500", "#FF0000")

# Create PPR hotspot map
ppr_hotspot_map <- tm_shape(cork_boundary) +
  tm_borders() +
  tm_shape(ppr_hotspot_data) +
  tm_dots(col = "hotspot_cat", 
          palette = hotspot_colors, 
          size = 0.1,
          title = "Price Hotspot Significance") +
  tm_layout(title = "Property Price Hotspots in Cork City",
            legend.outside = TRUE,
            frame = FALSE)

# Save PPR hotspot map
tmap_save(ppr_hotspot_map, 
          filename = file.path(output_dir, "ppr_price_hotspot_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("PPR hotspot map saved")

# Create Airbnb hotspot map
airbnb_hotspot_map <- tm_shape(cork_boundary) +
  tm_borders() +
  tm_shape(airbnb_hotspot_data) +
  tm_dots(col = "hotspot_cat", 
          palette = hotspot_colors, 
          size = 0.1,
          title = "Price Hotspot Significance") +
  tm_layout(title = "Airbnb Price Hotspots in Cork City",
            legend.outside = TRUE,
            frame = FALSE)

# Save Airbnb hotspot map
tmap_save(airbnb_hotspot_map, 
          filename = file.path(output_dir, "airbnb_price_hotspot_map.png"),
          width = 10, 
          height = 8, 
          dpi = 300)

print("Airbnb hotspot map saved")

# --- 5.5. Combine PPR and Airbnb hotspots on a single map ---
# Create hex grid overlay for visualization
hex_grid_sf$ppr_hotspot <- NA
hex_grid_sf$airbnb_hotspot <- NA

# Assign hotspot scores to hex grid
for (i in 1:nrow(hex_grid_sf)) {
  hex <- hex_grid_sf[i,]
  
  # Find PPR points in this hex
  ppr_in_hex <- st_intersection(ppr_hotspot_data, hex)
  if (nrow(ppr_in_hex) > 0) {
    hex_grid_sf$ppr_hotspot[i] <- mean(ppr_in_hex$gi_star, na.rm=TRUE)
  }
  
  # Find Airbnb points in this hex
  airbnb_in_hex <- st_intersection(airbnb_hotspot_data, hex)
  if (nrow(airbnb_in_hex) > 0) {
    hex_grid_sf$airbnb_hotspot[i] <- mean(airbnb_in_hex$gi_star, na.rm=TRUE)
  }
}

# Normalize the values for coloring
max_abs_value <- max(abs(c(hex_grid_sf$ppr_hotspot, hex_grid_sf$airbnb_hotspot)), na.rm=TRUE)
brks <- seq(-max_abs_value, max_abs_value, length.out=8)

# Create side-by-side maps
map_ppr_hex_hotspot <- tm_shape(hex_grid_sf) +
  tm_fill(col = "ppr_hotspot", 
          palette = "-RdBu", 
          breaks = brks,
          title = "Property Price\nHotspot Score") +
  tm_shape(cork_boundary) +
  tm_borders(col = "black", lwd = 1.5) +
  tm_layout(title = "Property Sale Price Hotspots",
            frame = FALSE)

map_airbnb_hex_hotspot <- tm_shape(hex_grid_sf) +
  tm_fill(col = "airbnb_hotspot", 
          palette = "-RdBu", 
          breaks = brks,
          title = "Airbnb Price\nHotspot Score") +
  tm_shape(cork_boundary) +
  tm_borders(col = "black", lwd = 1.5) +
  tm_layout(title = "Airbnb Price Hotspots",
            frame = FALSE)

# Combine maps
combined_hotspot_map <- tmap_arrange(map_ppr_hex_hotspot, map_airbnb_hex_hotspot, ncol = 2)

# Save combined map
tmap_save(combined_hotspot_map, 
          filename = file.path(output_dir, "combined_price_hotspot_map.png"),
          width = 14, 
          height = 8, 
          dpi = 300)

print("Combined hotspot map saved")

# --- 5.6. Calculate hotspot correlation ---
# Calculate correlation between PPR and Airbnb hotspots
hotspot_correlation <- cor(hex_grid_sf$ppr_hotspot, hex_grid_sf$airbnb_hotspot, 
                           use = "pairwise.complete.obs")

# Save correlation to a text file
cat(paste0("Correlation between Property price hotspots and Airbnb price hotspots: ", 
           round(hotspot_correlation, 3), "\n"),
    file = file.path(output_dir, "price_hotspot_correlation.txt"))

print(paste0("Hotspot correlation calculated: ", round(hotspot_correlation, 3)))
print("Price hotspot analysis completed") 