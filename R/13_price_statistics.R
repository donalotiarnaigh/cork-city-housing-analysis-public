# Cork City Housing - Basic Price Statistics Analysis
# This script performs the following analyses:
# 1. Summary statistics for both PPR and Airbnb datasets
# 2. Price distributions through histograms and box plots
# 3. Time series analysis of property prices
# 4. Comparative analyses between different property and listing types

# Load required libraries
library(dplyr)
library(ggplot2)
library(sf)
library(scales)
library(tidyr)
library(lubridate)
library(knitr)
library(gridExtra)

# Set paths
ppr_path <- "data/processed/final/ppr_corkCity.csv"
airbnb_path <- "data/processed/final/airbnb_corkCity_with_price.gpkg"
output_dir <- "output/statistics"
viz_dir <- "output/visualizations"

# Create output directories if they don't exist
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(viz_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Load and prepare data ----

# Load PPR data
print("Loading PPR data...")
ppr_data <- read.csv(ppr_path)
print(paste("Number of PPR records:", nrow(ppr_data)))

# Check for and convert the date column
if ("date_of_sale" %in% names(ppr_data)) {
  ppr_data$date_of_sale <- as.Date(ppr_data$date_of_sale)
  ppr_data$year <- year(ppr_data$date_of_sale)
  ppr_data$quarter <- paste0(year(ppr_data$date_of_sale), "-Q", quarter(ppr_data$date_of_sale))
} else {
  # Attempt to extract year from another column if available
  print("No date_of_sale column found. Checking for year information...")
  if (any(grepl("year", names(ppr_data), ignore.case = TRUE))) {
    year_col <- names(ppr_data)[grepl("year", names(ppr_data), ignore.case = TRUE)][1]
    print(paste("Using", year_col, "column for year information"))
    ppr_data$year <- ppr_data[[year_col]]
  } else {
    print("No year information found in PPR data. Time-based analysis will be limited.")
  }
}

# Load Airbnb data
print("Loading Airbnb data...")
airbnb_data <- st_read(airbnb_path, quiet = TRUE)
airbnb_df <- st_drop_geometry(airbnb_data)  # Non-spatial version for statistics
print(paste("Number of Airbnb listings:", nrow(airbnb_df)))

# Flag to control whether to perform Airbnb price analysis
perform_airbnb_analysis <- TRUE

# Check if Airbnb data has price column
if (!"price" %in% names(airbnb_df)) {
  print("Price column not found in Airbnb data.")
  # Check if we have a price field with a different name
  possible_price_cols <- names(airbnb_df)[grep("price", names(airbnb_df), ignore.case = TRUE)]
  
  if (length(possible_price_cols) > 0) {
    print(paste("Using", possible_price_cols[1], "as price column"))
    airbnb_df$price <- airbnb_df[[possible_price_cols[1]]]
  } else {
    print("No price data found. Skipping Airbnb price analysis.")
    perform_airbnb_analysis <- FALSE
  }
}

# Ensure price columns are numeric
ppr_data$price <- as.numeric(ppr_data$price)
if (perform_airbnb_analysis) {
  airbnb_df$price <- as.numeric(airbnb_df$price)
  # Remove records with missing or invalid prices
  original_count <- nrow(airbnb_df)
  airbnb_df <- airbnb_df[!is.na(airbnb_df$price) & airbnb_df$price > 0, ]
  filtered_count <- nrow(airbnb_df)
  
  if (filtered_count == 0) {
    print("No valid price data found in Airbnb dataset. Skipping Airbnb price analysis.")
    perform_airbnb_analysis <- FALSE
  } else if (filtered_count < original_count) {
    print(paste("Filtered out", original_count - filtered_count, "Airbnb listings with missing or invalid prices."))
    print(paste("Proceeding with", filtered_count, "valid Airbnb listings."))
  }
}

# ---- 1.2.1a: Summary Statistics ----

# Function to calculate summary statistics
calculate_summary_stats <- function(data, price_col = "price") {
  if (!price_col %in% names(data)) {
    stop(paste("Column", price_col, "not found in data"))
  }
  
  # Remove missing or invalid prices
  valid_data <- data[!is.na(data[[price_col]]) & data[[price_col]] > 0, ]
  
  # Calculate statistics
  stats <- data.frame(
    count = nrow(valid_data),
    min = min(valid_data[[price_col]], na.rm = TRUE),
    q1 = quantile(valid_data[[price_col]], 0.25, na.rm = TRUE),
    median = median(valid_data[[price_col]], na.rm = TRUE),
    mean = mean(valid_data[[price_col]], na.rm = TRUE),
    q3 = quantile(valid_data[[price_col]], 0.75, na.rm = TRUE),
    max = max(valid_data[[price_col]], na.rm = TRUE),
    sd = sd(valid_data[[price_col]], na.rm = TRUE)
  )
  
  return(stats)
}

# PPR overall summary
ppr_summary <- calculate_summary_stats(ppr_data)
print("PPR Overall Price Summary:")
print(ppr_summary)
write.csv(ppr_summary, file.path(output_dir, "ppr_price_summary.csv"), row.names = FALSE)

# Airbnb overall summary
if (perform_airbnb_analysis) {
  airbnb_summary <- calculate_summary_stats(airbnb_df)
  print("Airbnb Overall Price Summary:")
  print(airbnb_summary)
  write.csv(airbnb_summary, file.path(output_dir, "airbnb_price_summary.csv"), row.names = FALSE)
}

# ---- 1.2.1b: Price Distributions - Histograms ----

# PPR price histogram
ppr_hist <- ggplot(ppr_data, aes(x = price)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  scale_x_continuous(labels = scales::comma) +
  labs(title = "Distribution of Property Sale Prices in Cork City",
       x = "Price (€)", y = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"))

# Save the plot
ggsave(file.path(viz_dir, "ppr_price_histogram.png"), ppr_hist, width = 10, height = 6)

# Airbnb price histogram
if (perform_airbnb_analysis) {
  airbnb_hist <- ggplot(airbnb_df, aes(x = price)) +
    geom_histogram(bins = 30, fill = "coral", color = "white") +
    scale_x_continuous(labels = scales::comma) +
    labs(title = "Distribution of Airbnb Listing Prices in Cork City",
         x = "Price per Night (€)", y = "Count") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"))
  
  # Save the plot
  ggsave(file.path(viz_dir, "airbnb_price_histogram.png"), airbnb_hist, width = 10, height = 6)
}

# Log-transformed histograms for better visualization of skewed distributions
# PPR log price
ppr_log_hist <- ggplot(ppr_data, aes(x = price)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  scale_x_log10(labels = scales::comma) +
  labs(title = "Distribution of Property Sale Prices in Cork City (Log Scale)",
       x = "Price (€) - Log Scale", y = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"))

# Save the plot
ggsave(file.path(viz_dir, "ppr_price_histogram_log.png"), ppr_log_hist, width = 10, height = 6)

# Airbnb log price
if (perform_airbnb_analysis) {
  airbnb_log_hist <- ggplot(airbnb_df, aes(x = price)) +
    geom_histogram(bins = 30, fill = "coral", color = "white") +
    scale_x_log10(labels = scales::comma) +
    labs(title = "Distribution of Airbnb Listing Prices in Cork City (Log Scale)",
         x = "Price per Night (€) - Log Scale", y = "Count") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"))
  
  # Save the plot
  ggsave(file.path(viz_dir, "airbnb_price_histogram_log.png"), airbnb_log_hist, width = 10, height = 6)
}

# ---- 1.2.1c: Box Plots by Property/Room Types ----

# PPR box plot by property description
if ("property_description" %in% names(ppr_data)) {
  ppr_box_desc <- ggplot(ppr_data, aes(x = property_description, y = price)) +
    geom_boxplot(fill = "steelblue", alpha = 0.7) +
    scale_y_continuous(labels = scales::comma) +
    labs(title = "Property Prices by Description Type in Cork City",
         x = "Property Description", y = "Price (€)") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"),
          axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Save the plot
  ggsave(file.path(viz_dir, "ppr_price_boxplot_by_description.png"), ppr_box_desc, width = 12, height = 8)
}

# PPR box plot by property size if available
if ("property_size" %in% names(ppr_data) && sum(!is.na(ppr_data$property_size)) > 0) {
  ppr_box_size <- ggplot(ppr_data[!is.na(ppr_data$property_size),], aes(x = property_size, y = price)) +
    geom_boxplot(fill = "steelblue", alpha = 0.7) +
    scale_y_continuous(labels = scales::comma) +
    labs(title = "Property Prices by Size in Cork City",
         x = "Property Size", y = "Price (€)") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"),
          axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Save the plot
  ggsave(file.path(viz_dir, "ppr_price_boxplot_by_size.png"), ppr_box_size, width = 12, height = 8)
}

# Airbnb box plot by room type
if (perform_airbnb_analysis && "room_type" %in% names(airbnb_df)) {
  airbnb_box_type <- ggplot(airbnb_df, aes(x = room_type, y = price)) +
    geom_boxplot(fill = "coral", alpha = 0.7) +
    scale_y_continuous(labels = scales::comma) +
    labs(title = "Airbnb Prices by Room Type in Cork City",
         x = "Room Type", y = "Price per Night (€)") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"),
          axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Save the plot
  ggsave(file.path(viz_dir, "airbnb_price_boxplot_by_room_type.png"), airbnb_box_type, width = 12, height = 8)
}

# Airbnb box plot by number of bedrooms
if (perform_airbnb_analysis && "bedrooms" %in% names(airbnb_df) && sum(!is.na(airbnb_df$bedrooms)) > 0) {
  # Convert bedrooms to factor to treat it as categorical
  airbnb_df$bedrooms_factor <- factor(airbnb_df$bedrooms)
  
  airbnb_box_bedrooms <- ggplot(airbnb_df[!is.na(airbnb_df$bedrooms),], 
                                aes(x = bedrooms_factor, y = price)) +
    geom_boxplot(fill = "coral", alpha = 0.7) +
    scale_y_continuous(labels = scales::comma) +
    labs(title = "Airbnb Prices by Number of Bedrooms in Cork City",
         x = "Number of Bedrooms", y = "Price per Night (€)") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"))
  
  # Save the plot
  ggsave(file.path(viz_dir, "airbnb_price_boxplot_by_bedrooms.png"), airbnb_box_bedrooms, width = 12, height = 8)
}

# ---- 1.2.1d: Time Series Analysis for PPR data ----

if (exists("year", where = ppr_data) && sum(!is.na(ppr_data$year)) > 0) {
  # Yearly median price trends
  yearly_prices <- ppr_data %>%
    group_by(year) %>%
    summarize(
      median_price = median(price, na.rm = TRUE),
      mean_price = mean(price, na.rm = TRUE),
      count = n()
    ) %>%
    arrange(year)
  
  # Save yearly price data
  write.csv(yearly_prices, file.path(output_dir, "ppr_yearly_price_trends.csv"), row.names = FALSE)
  
  # Create time series plot
  ts_plot <- ggplot(yearly_prices, aes(x = year)) +
    geom_line(aes(y = median_price), color = "steelblue", size = 1.2) +
    geom_point(aes(y = median_price), color = "steelblue", size = 3) +
    geom_line(aes(y = mean_price), color = "darkred", size = 1.2, linetype = "dashed") +
    geom_point(aes(y = mean_price), color = "darkred", size = 3) +
    scale_y_continuous(labels = scales::comma) +
    labs(title = "Property Price Trends in Cork City Over Time",
         subtitle = "Median and Mean Property Prices by Year",
         x = "Year", y = "Price (€)") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"))
  
  # Save the plot
  ggsave(file.path(viz_dir, "ppr_price_time_series.png"), ts_plot, width = 12, height = 8)
  
  # Create transaction volume plot
  volume_plot <- ggplot(yearly_prices, aes(x = year, y = count)) +
    geom_bar(stat = "identity", fill = "steelblue", alpha = 0.7) +
    labs(title = "Property Transaction Volume in Cork City Over Time",
         x = "Year", y = "Number of Transactions") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"))
  
  # Save the plot
  ggsave(file.path(viz_dir, "ppr_transaction_volume.png"), volume_plot, width = 12, height = 8)
  
  # If quarterly data exists, create quarterly trends
  if (exists("quarter", where = ppr_data) && sum(!is.na(ppr_data$quarter)) > 0) {
    quarterly_prices <- ppr_data %>%
      group_by(quarter) %>%
      summarize(
        median_price = median(price, na.rm = TRUE),
        mean_price = mean(price, na.rm = TRUE),
        count = n()
      ) %>%
      arrange(quarter)
    
    # Save quarterly price data
    write.csv(quarterly_prices, file.path(output_dir, "ppr_quarterly_price_trends.csv"), row.names = FALSE)
    
    # Create quarterly time series plot (if there are enough quarters to show a trend)
    if (nrow(quarterly_prices) > 4) {
      qts_plot <- ggplot(quarterly_prices, aes(x = quarter, y = median_price, group = 1)) +
        geom_line(color = "steelblue", size = 1.2) +
        geom_point(color = "steelblue", size = 3) +
        scale_y_continuous(labels = scales::comma) +
        labs(title = "Quarterly Property Price Trends in Cork City",
             x = "Quarter", y = "Median Price (€)") +
        theme_minimal() +
        theme(plot.title = element_text(size = 14, face = "bold"),
              axis.text.x = element_text(angle = 90, hjust = 1))
      
      # Save the plot
      ggsave(file.path(viz_dir, "ppr_price_quarterly_time_series.png"), qts_plot, width = 14, height = 8)
    }
  }
}

# ---- 1.2.1e: Comparative Analysis - Price per bedroom/guest ----

# Airbnb price per bedroom
if (perform_airbnb_analysis && all(c("price", "bedrooms") %in% names(airbnb_df)) && sum(!is.na(airbnb_df$bedrooms) & airbnb_df$bedrooms > 0) > 0) {
  airbnb_df$price_per_bedroom <- airbnb_df$price / airbnb_df$bedrooms
  
  # Summary statistics for price per bedroom
  price_per_bedroom_summary <- airbnb_df %>%
    filter(!is.na(bedrooms) & bedrooms > 0) %>%
    summarize(
      count = n(),
      min = min(price_per_bedroom, na.rm = TRUE),
      median = median(price_per_bedroom, na.rm = TRUE),
      mean = mean(price_per_bedroom, na.rm = TRUE),
      max = max(price_per_bedroom, na.rm = TRUE)
    )
  
  print("Airbnb price per bedroom summary:")
  print(price_per_bedroom_summary)
  write.csv(price_per_bedroom_summary, file.path(output_dir, "airbnb_price_per_bedroom_summary.csv"), row.names = FALSE)
  
  # Histogram of price per bedroom
  price_per_bedroom_hist <- ggplot(airbnb_df %>% filter(!is.na(bedrooms) & bedrooms > 0), 
                                  aes(x = price_per_bedroom)) +
    geom_histogram(bins = 30, fill = "coral", color = "white") +
    scale_x_continuous(labels = scales::comma) +
    labs(title = "Distribution of Airbnb Price per Bedroom in Cork City",
         x = "Price per Bedroom (€)", y = "Count") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"))
  
  # Save the plot
  ggsave(file.path(viz_dir, "airbnb_price_per_bedroom_histogram.png"), price_per_bedroom_hist, width = 10, height = 6)
}

# Airbnb price per guest
if (perform_airbnb_analysis && all(c("price", "accommodates") %in% names(airbnb_df)) && sum(!is.na(airbnb_df$accommodates) & airbnb_df$accommodates > 0) > 0) {
  airbnb_df$price_per_guest <- airbnb_df$price / airbnb_df$accommodates
  
  # Summary statistics for price per guest
  price_per_guest_summary <- airbnb_df %>%
    filter(!is.na(accommodates) & accommodates > 0) %>%
    summarize(
      count = n(),
      min = min(price_per_guest, na.rm = TRUE),
      median = median(price_per_guest, na.rm = TRUE),
      mean = mean(price_per_guest, na.rm = TRUE),
      max = max(price_per_guest, na.rm = TRUE)
    )
  
  print("Airbnb price per guest summary:")
  print(price_per_guest_summary)
  write.csv(price_per_guest_summary, file.path(output_dir, "airbnb_price_per_guest_summary.csv"), row.names = FALSE)
  
  # Histogram of price per guest
  price_per_guest_hist <- ggplot(airbnb_df %>% filter(!is.na(accommodates) & accommodates > 0), 
                                aes(x = price_per_guest)) +
    geom_histogram(bins = 30, fill = "coral", color = "white") +
    scale_x_continuous(labels = scales::comma) +
    labs(title = "Distribution of Airbnb Price per Guest in Cork City",
         x = "Price per Guest (€)", y = "Count") +
    theme_minimal() +
    theme(plot.title = element_text(size = 14, face = "bold"))
  
  # Save the plot
  ggsave(file.path(viz_dir, "airbnb_price_per_guest_histogram.png"), price_per_guest_hist, width = 10, height = 6)
}

# ---- 1.2.1f: Price comparison between New vs. Second-Hand properties ----

if ("property_description" %in% names(ppr_data)) {
  # Check if we can identify New vs Second-Hand properties
  if (any(grepl("New", ppr_data$property_description, ignore.case = TRUE)) &&
      any(grepl("Second-Hand", ppr_data$property_description, ignore.case = TRUE))) {
    
    # Create a simplified property type column
    ppr_data$property_type <- ifelse(
      grepl("New", ppr_data$property_description, ignore.case = TRUE), 
      "New", 
      ifelse(grepl("Second-Hand", ppr_data$property_description, ignore.case = TRUE),
             "Second-Hand", "Other")
    )
    
    # Calculate summary statistics by property type
    property_type_summary <- ppr_data %>%
      filter(property_type %in% c("New", "Second-Hand")) %>%
      group_by(property_type) %>%
      summarize(
        count = n(),
        min = min(price, na.rm = TRUE),
        q1 = quantile(price, 0.25, na.rm = TRUE),
        median = median(price, na.rm = TRUE),
        mean = mean(price, na.rm = TRUE),
        q3 = quantile(price, 0.75, na.rm = TRUE),
        max = max(price, na.rm = TRUE),
        sd = sd(price, na.rm = TRUE)
      )
    
    print("Property prices by type (New vs Second-Hand):")
    print(property_type_summary)
    write.csv(property_type_summary, file.path(output_dir, "ppr_price_by_property_type.csv"), row.names = FALSE)
    
    # Create comparative box plot
    property_type_box <- ggplot(ppr_data %>% filter(property_type %in% c("New", "Second-Hand")), 
                               aes(x = property_type, y = price, fill = property_type)) +
      geom_boxplot(alpha = 0.7) +
      scale_fill_manual(values = c("New" = "springgreen4", "Second-Hand" = "steelblue")) +
      scale_y_continuous(labels = scales::comma) +
      labs(title = "Property Prices: New vs. Second-Hand Properties in Cork City",
           x = "Property Type", y = "Price (€)") +
      theme_minimal() +
      theme(plot.title = element_text(size = 14, face = "bold"))
    
    # Save the plot
    ggsave(file.path(viz_dir, "ppr_price_by_property_type_boxplot.png"), property_type_box, width = 10, height = 8)
    
    # If we have year data, we can create time series by property type
    if (exists("year", where = ppr_data) && sum(!is.na(ppr_data$year)) > 0) {
      yearly_type_prices <- ppr_data %>%
        filter(property_type %in% c("New", "Second-Hand")) %>%
        group_by(year, property_type) %>%
        summarize(
          median_price = median(price, na.rm = TRUE),
          count = n()
        ) %>%
        arrange(year)
      
      # Save data
      write.csv(yearly_type_prices, file.path(output_dir, "ppr_yearly_price_by_type.csv"), row.names = FALSE)
      
      # Create time series plot by property type
      ts_type_plot <- ggplot(yearly_type_prices, aes(x = year, y = median_price, color = property_type, group = property_type)) +
        geom_line(size = 1.2) +
        geom_point(size = 3) +
        scale_color_manual(values = c("New" = "springgreen4", "Second-Hand" = "steelblue")) +
        scale_y_continuous(labels = scales::comma) +
        labs(title = "Property Price Trends by Type in Cork City",
             subtitle = "Median Property Prices for New vs. Second-Hand Properties",
             x = "Year", y = "Median Price (€)", color = "Property Type") +
        theme_minimal() +
        theme(plot.title = element_text(size = 14, face = "bold"),
              legend.position = "bottom")
      
      # Save the plot
      ggsave(file.path(viz_dir, "ppr_price_trends_by_property_type.png"), ts_type_plot, width = 12, height = 8)
    }
  }
}

# ---- 1.2.1g: Price comparison between different room types (Airbnb) ----

if (perform_airbnb_analysis && "room_type" %in% names(airbnb_df) && sum(!is.na(airbnb_df$room_type)) > 0) {
  # Calculate summary statistics by room type
  room_type_summary <- airbnb_df %>%
    group_by(room_type) %>%
    summarize(
      count = n(),
      min = min(price, na.rm = TRUE),
      q1 = quantile(price, 0.25, na.rm = TRUE),
      median = median(price, na.rm = TRUE),
      mean = mean(price, na.rm = TRUE),
      q3 = quantile(price, 0.75, na.rm = TRUE),
      max = max(price, na.rm = TRUE),
      sd = sd(price, na.rm = TRUE)
    )
  
  print("Airbnb prices by room type:")
  print(room_type_summary)
  write.csv(room_type_summary, file.path(output_dir, "airbnb_price_by_room_type.csv"), row.names = FALSE)
  
  # Also calculate price per guest by room type if data available
  if ("accommodates" %in% names(airbnb_df) && sum(!is.na(airbnb_df$accommodates) & airbnb_df$accommodates > 0) > 0) {
    room_type_per_guest_summary <- airbnb_df %>%
      filter(!is.na(accommodates) & accommodates > 0) %>%
      group_by(room_type) %>%
      summarize(
        count = n(),
        min_price_per_guest = min(price / accommodates, na.rm = TRUE),
        median_price_per_guest = median(price / accommodates, na.rm = TRUE),
        mean_price_per_guest = mean(price / accommodates, na.rm = TRUE),
        max_price_per_guest = max(price / accommodates, na.rm = TRUE)
      )
    
    print("Airbnb price per guest by room type:")
    print(room_type_per_guest_summary)
    write.csv(room_type_per_guest_summary, file.path(output_dir, "airbnb_price_per_guest_by_room_type.csv"), row.names = FALSE)
  }
}

# ---- Output a summary report of all analyses ----

# Create a simple summary of the analyses performed
summary_text <- c(
  "# Cork City Housing Price Analysis - Summary Report",
  paste("Analysis Date:", format(Sys.Date(), "%B %d, %Y")),
  "",
  "## Datasets Used",
  paste("- Property Price Register (PPR) Data:", nrow(ppr_data), "records"),
  paste("- Airbnb Listings:", nrow(airbnb_df), "records"),
  "",
  "## Analyses Performed",
  "1. Summary statistics for both datasets",
  "2. Price distributions through histograms",
  "3. Box plots by property and room types",
  "4. Time series analysis of property prices (where applicable)",
  "5. Comparative analyses between different property categories",
  if (perform_airbnb_analysis) "6. Price per bedroom and per guest calculations for Airbnb" else NULL,
  "",
  "## Key Findings",
  paste("- PPR Median Price: €", format(round(ppr_summary$median), big.mark=",")),
  if (perform_airbnb_analysis) paste("- Airbnb Median Price: €", format(round(airbnb_summary$median), big.mark=",")) else "- Airbnb Price Analysis: Not performed due to missing price data",
  "",
  "## Output Files",
  paste("- Statistics tables saved to:", output_dir),
  paste("- Visualizations saved to:", viz_dir)
)

# Remove NULL entries
summary_text <- summary_text[!sapply(summary_text, is.null)]

# Write the summary to a file
writeLines(summary_text, file.path(output_dir, "price_analysis_summary.md"))

print("Price statistics analysis complete!")
print(paste("Output saved to", output_dir, "and", viz_dir)) 