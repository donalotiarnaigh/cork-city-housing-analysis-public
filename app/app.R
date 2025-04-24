
library(shiny)
library(shinydashboard)
library(leaflet)
library(leaflet.extras)
library(sf)
library(dplyr)
library(viridis)
library(RColorBrewer)
library(ggplot2)
library(plotly)
library(DT)
library(htmlwidgets)
library(lubridate)

# Load data
# Property Price Register data
ppr_data <- st_read("../data/processed/final/ppr_corkCity_with_dates.gpkg", quiet = TRUE)

# Airbnb listings data
airbnb_data <- st_read("../data/processed/final/airbnb_corkCity_with_dates.gpkg", quiet = TRUE)

# Cork City boundary
cork_boundary <- st_read("../data/boundaries/cork_city_boundary.gpkg", quiet = TRUE)

# Transform all data to WGS84 for Leaflet compatibility
if (st_crs(ppr_data)$epsg != 4326) {
  ppr_data <- st_transform(ppr_data, 4326)
}

if (st_crs(airbnb_data)$epsg != 4326) {
  airbnb_data <- st_transform(airbnb_data, 4326)
}

if (st_crs(cork_boundary)$epsg != 4326) {
  cork_boundary <- st_transform(cork_boundary, 4326)
}

# Calculate price ranges for sliders
ppr_min_price <- floor(min(ppr_data$price, na.rm = TRUE) / 10000) * 10000
ppr_max_price <- ceiling(max(ppr_data$price, na.rm = TRUE) / 100000) * 100000
ppr_median_price <- median(ppr_data$price, na.rm = TRUE)

airbnb_min_price <- floor(min(airbnb_data$price, na.rm = TRUE) / 10) * 10
airbnb_max_price <- ceiling(max(airbnb_data$price, na.rm = TRUE) / 50) * 50
airbnb_median_price <- median(airbnb_data$price, na.rm = TRUE)

# Define UI with shinydashboard
ui <- dashboardPage(
  # Dashboard header
  dashboardHeader(
    title = "Cork City Property Analysis",
    titleWidth = 300
  ),
  
  # Dashboard sidebar
  dashboardSidebar(
    width = 300,
    # Data selection
    radioButtons("dataSource", "Data Source:",
                choices = list("Property Sales" = "ppr",
                              "Airbnb Listings" = "airbnb",
                              "Both" = "both"),
                selected = "ppr"),
    
    # Filtering options
    tags$div(
      class = "filter-section",
      
      # Property filters
      conditionalPanel(
        condition = "input.dataSource == 'ppr' || input.dataSource == 'both'",
        tags$h4("Property Filters"),
        sliderInput("pprPriceRange", "Price Range (€):",
                   min = ppr_min_price, max = ppr_max_price, 
                   value = c(ppr_min_price, ppr_max_price),
                   step = 10000),
        selectInput("propertyType", "Property Type:",
                   choices = c("All", sort(unique(ppr_data$property_description))),
                   selected = "All")
      ),
      
      # Airbnb filters
      conditionalPanel(
        condition = "input.dataSource == 'airbnb' || input.dataSource == 'both'",
        tags$h4("Airbnb Filters"),
        sliderInput("airbnbPriceRange", "Price Range (€ per night):",
                   min = airbnb_min_price, max = airbnb_max_price, 
                   value = c(airbnb_min_price, airbnb_max_price),
                   step = 10),
        selectInput("roomType", "Room Type:",
                   choices = c("All", sort(unique(airbnb_data$room_type))),
                   selected = "All"),
        sliderInput("minReviews", "Minimum Reviews:",
                   min = 0, max = max(airbnb_data$number_of_reviews, na.rm = TRUE),
                   value = 0, step = 1)
      )
    ),
    
    # Clustering toggle
    checkboxInput("enableClustering", "Enable Marker Clustering", value = TRUE),
    
    # Apply filter button
    actionButton("applyFilters", "Apply Custom Filters", 
                style="color: #fff; background-color: #337ab7; border-color: #2e6da4; margin-top: 15px;"),
    
    # Dataset information
    tags$div(
      class = "info-section",
      tags$hr(),
      tags$h4("Dataset Information", style = "margin-top: 20px;"),
      conditionalPanel(
        condition = "input.dataSource == 'ppr' || input.dataSource == 'both'",
        tags$p(tags$strong("Property Sales:"), paste(nrow(ppr_data), "records")),
        tags$p("Median Price: €", formatC(ppr_median_price, format="f", digits=0, big.mark=","))
      ),
      conditionalPanel(
        condition = "input.dataSource == 'airbnb' || input.dataSource == 'both'",
        tags$p(tags$strong("Airbnb Listings:"), paste(nrow(airbnb_data), "listings")),
        tags$p("Median Price: €", formatC(airbnb_median_price, format="f", digits=0, big.mark=","), "per night")
      ),
      # Add info about correlation
      conditionalPanel(
        condition = "input.dataSource == 'both'",
        tags$hr(),
        tags$p("Correlation between property and Airbnb price hotspots:", tags$strong("-0.289"))
      ),
      # Info text about features
      tags$small(
        tags$p("All records are shown by default. Use the filters and 'Apply Custom Filters' button to narrow down the dataset."),
        tags$p("Switch between data sources to explore different property types and compare their prices.")
      )
    )
  ),
  
  # Dashboard body
  dashboardBody(
    # Custom CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
      tags$style(HTML("
        /* Dashboard styling */
        .skin-blue .main-header .logo { background-color: #0033A0; }
        .skin-blue .main-header .navbar { background-color: #0033A0; }
        .skin-blue .main-header .logo:hover { background-color: #002D8D; }
        
        /* Filter section styling */
        .filter-section h4 { 
          color: #0033A0; 
          margin-top: 15px;
          border-bottom: 1px solid #eee;
          padding-bottom: 5px;
          font-weight: bold;
        }
        
        /* Info box styling */
        .info-box {
          min-height: 90px;
        }
        .info-box-icon {
          height: 90px;
          line-height: 90px;
        }
        .info-box-content {
          padding-top: 10px;
          padding-bottom: 10px;
        }
      "))
    ),
    
    # Main content area with tabs
    tabBox(
      width = 12,
      id = "tabselected",
      tabPanel(
        "Map",
        value = "map",
        fluidRow(
          # Statistics boxes
          valueBoxOutput("totalRecords", width = 4),
          valueBoxOutput("medianPrice", width = 4),
          valueBoxOutput("priceRange", width = 4)
        ),
        fluidRow(
          box(
            width = 12,
            solidHeader = TRUE,
            title = "Cork City Property Map",
            status = "primary",
            leafletOutput("map", height = "600px")
          )
        )
      ),
      
      tabPanel(
        "Charts",
        value = "charts",
        fluidRow(
          box(
            title = "Price Distribution", 
            status = "primary", 
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("priceDistribution", height = "300px")
          ),
          box(
            title = "Price Correlation", 
            status = "primary", 
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("priceCorrelation", height = "300px")
          )
        ),
        fluidRow(
          box(
            title = "Time Analysis", 
            status = "primary", 
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("timeAnalysis", height = "300px")
          )
        )
      ),
      
      tabPanel(
        "About",
        value = "about",
        fluidRow(
          box(
            width = 12,
            title = "Cork City Property Analysis",
            status = "primary",
            solidHeader = TRUE,
            tags$div(
              tags$h3("Project Overview"),
              tags$p("This application visualizes the relationship between property sales and Airbnb listings in Cork City, Ireland."),
              tags$p("Use the filters in the sidebar to explore different price ranges and data sources."),
              tags$h4("Key Findings:"),
              tags$ul(
                tags$li("Clear spatial patterns exist in both property sales and Airbnb listings"),
                tags$li("Price distributions show significant differences between property sales and Airbnb listings"),
                tags$li("Negative correlation (-0.289) between property price hotspots and Airbnb price hotspots")
              ),
              tags$h4("Data Sources:"),
              tags$ul(
                tags$li(tags$strong("Property Price Register (PPR)"), " - Records of property sales in Cork City", 
                    tags$br(),
                    "Contains all house sales for County Cork, trimmed to those within the Cork City Council local electoral areas.",
                    tags$br(),
                    "Source: ", tags$a(href="https://www.propertypriceregister.ie/website/npsra/pprweb.nsf/PPRDownloads?OpenForm", 
                                     "Property Price Register Ireland", target="_blank")),
                tags$li(tags$strong("Airbnb Listings"), " - Data on Airbnb rental properties in Cork City",
                    tags$br(),
                    "Scraped by InsideAirbnb on December 12, 2024.",
                    tags$br(),
                    "Source: ", tags$a(href="https://insideairbnb.com/get-the-data/", 
                                     "Inside Airbnb Data", target="_blank"))
              )
            )
          )
        )
      )
    )
  )
)

# Define server
server <- function(input, output, session) {
  # Create reactive filtered datasets with safer initialization
  filtered_ppr <- reactive({
    if (input$dataSource %in% c("ppr", "both")) {
      filtered <- ppr_data %>%
        filter(price >= input$pprPriceRange[1] & price <= input$pprPriceRange[2])
      
      # Apply property type filter
      if (input$propertyType != "All") {
        filtered <- filtered %>%
          filter(property_description == input$propertyType)
      }
      
      filtered
    } else {
      NULL
    }
  })
  
  filtered_airbnb <- reactive({
    if (input$dataSource %in% c("airbnb", "both")) {
      filtered <- airbnb_data %>%
        filter(price >= input$airbnbPriceRange[1] & price <= input$airbnbPriceRange[2])
      
      # Apply room type filter
      if (input$roomType != "All") {
        filtered <- filtered %>%
          filter(room_type == input$roomType)
      }
      
      # Apply minimum reviews filter
      filtered <- filtered %>%
        filter(number_of_reviews >= input$minReviews)
      
      filtered
    } else {
      NULL
    }
  })
  
  # Function to get cluster options based on input
  getClusterOptions <- function() {
    if (input$enableClustering) {
      markerClusterOptions(
        spiderfyOnMaxZoom = TRUE,
        zoomToBoundsOnClick = TRUE,
        disableClusteringAtZoom = 16
      )
    } else {
      NULL
    }
  }
  
  # Function to add markers and legends to the map - reusable
  add_markers_to_map <- function(map_proxy, ppr_data_to_show, airbnb_data_to_show) {
    # Clear existing markers and legends
    map_proxy <- map_proxy %>%
      clearMarkers() %>%
      clearGroup("Property Sales") %>%
      clearGroup("Airbnb Listings") %>%
      clearControls()
    
    # Add PPR data if available
    if (!is.null(ppr_data_to_show) && nrow(ppr_data_to_show) > 0) {
      # Check that we have enough data points to create a visualization
      if (nrow(ppr_data_to_show) > 1) {
        # Check if we have at least 2 unique price values for valid breaks
        unique_prices <- unique(ppr_data_to_show$price)
        if(length(unique_prices) > 4) {
          # Enough unique values for quantile breaks
          # Quantile breaks for colors
          price_breaks <- quantile(ppr_data_to_show$price, 
                                 probs = seq(0, 1, length.out = 5), 
                                 na.rm = TRUE)
          
          # Check if the breaks are unique
          if(length(unique(price_breaks)) < 5) {
            # Not enough unique breaks, use equal interval breaks instead
            min_price <- min(ppr_data_to_show$price, na.rm = TRUE)
            max_price <- max(ppr_data_to_show$price, na.rm = TRUE)
            price_range <- max_price - min_price
            
            if(price_range > 0) {
              price_breaks <- seq(min_price, max_price, length.out = 5)
            } else {
              # If min and max are the same, create simple offset breaks
              price_breaks <- c(min_price - 1, min_price - 0.5, min_price, min_price + 0.5, min_price + 1)
            }
          }
          
          # Create color palette
          price_pal <- colorBin(
            palette = "Blues",
            domain = ppr_data_to_show$price,
            bins = price_breaks
          )
          
          # Add markers
          map_proxy <- map_proxy %>%
            addCircleMarkers(
              data = ppr_data_to_show,
              group = "Property Sales",
              radius = 6,
              color = "white",
              weight = 1,
              fillColor = ~price_pal(price),
              fillOpacity = 0.8,
              label = ~paste("€", formatC(price, format="f", digits=0, big.mark=",")),
              popup = ~paste(
                "<div style='min-width: 200px;'>",
                "<h4 style='margin-top: 0;'>Property Sale</h4>",
                "<strong>Price:</strong> €", formatC(price, format="f", digits=0, big.mark=","), "<br>",
                "<strong>Address:</strong> ", original_address, "<br>",
                "<strong>Type:</strong> ", property_description,
                "</div>"
              ),
              clusterOptions = getClusterOptions()
            )
            
          # Only add the legend if we have valid breaks
          if(length(unique(price_breaks)) > 1) {
            map_proxy <- map_proxy %>%
              # Add legend for property prices
              addLegend(
                position = "bottomleft",
                pal = price_pal,
                values = ppr_data_to_show$price,
                title = "Property Prices (€)",
                opacity = 0.8,
                labFormat = labelFormat(prefix = "€", big.mark = ",", transform = function(x) round(x)),
                group = "Property Sales"
              )
          } else {
            # Add a simple legend for single price
            map_proxy <- map_proxy %>%
              addLegend(
                position = "bottomleft",
                colors = "#1E88E5",
                labels = paste("€", formatC(unique_prices[1], format="f", digits=0, big.mark=",")),
                title = "Property Price (€)",
                opacity = 0.8,
                group = "Property Sales"
              )
          }
        } else {
          # Not enough unique values for quantile breaks, use a simpler approach
          # Use min and max for a simple scale if there are at least 2 different prices
          if(length(unique_prices) > 1) {
            min_price <- min(unique_prices, na.rm = TRUE)
            max_price <- max(unique_prices, na.rm = TRUE)
            
            # Create a simple two-color palette
            price_pal <- colorBin(
              palette = "Blues",
              domain = c(min_price, max_price),
              bins = c(min_price, (min_price + max_price)/2, max_price)
            )
            
            # Add markers with simple color palette
            map_proxy <- map_proxy %>%
              addCircleMarkers(
                data = ppr_data_to_show,
                group = "Property Sales",
                radius = 6,
                color = "white",
                weight = 1,
                fillColor = ~price_pal(price),
                fillOpacity = 0.8,
                label = ~paste("€", formatC(price, format="f", digits=0, big.mark=",")),
                popup = ~paste(
                  "<div style='min-width: 200px;'>",
                  "<h4 style='margin-top: 0;'>Property Sale</h4>",
                  "<strong>Price:</strong> €", formatC(price, format="f", digits=0, big.mark=","), "<br>",
                  "<strong>Address:</strong> ", original_address, "<br>",
                  "<strong>Type:</strong> ", property_description,
                  "</div>"
                ),
                clusterOptions = getClusterOptions()
              ) %>%
              # Add a simple legend
              addLegend(
                position = "bottomleft",
                colors = c(colorRampPalette(brewer.pal(3, "Blues"))(2)),
                labels = c(paste("€", formatC(min_price, format="f", digits=0, big.mark=",")),
                         paste("€", formatC(max_price, format="f", digits=0, big.mark=","))),
                title = "Property Prices (€)",
                opacity = 0.8,
                group = "Property Sales"
              )
          } else {
            # If all prices are the same value, use a simple color mapping
            single_price_value <- unique_prices[1]
            map_proxy <- map_proxy %>%
              addCircleMarkers(
                data = ppr_data_to_show,
                group = "Property Sales",
                radius = 6,
                color = "white",
                weight = 1,
                fillColor = "#1E88E5",  # Use a fixed color
                fillOpacity = 0.8,
                label = ~paste("€", formatC(price, format="f", digits=0, big.mark=",")),
                popup = ~paste(
                  "<div style='min-width: 200px;'>",
                  "<h4 style='margin-top: 0;'>Property Sale</h4>",
                  "<strong>Price:</strong> €", formatC(price, format="f", digits=0, big.mark=","), "<br>",
                  "<strong>Address:</strong> ", original_address, "<br>",
                  "<strong>Type:</strong> ", property_description,
                  "</div>"
                ),
                clusterOptions = getClusterOptions()
              ) %>%
              # Add a simple legend
              addLegend(
                position = "bottomleft",
                colors = "#1E88E5",
                labels = paste("€", formatC(single_price_value, format="f", digits=0, big.mark=",")),
                title = "Property Price (€)",
                opacity = 0.8,
                group = "Property Sales"
              )
          }
        }
      } else if (nrow(ppr_data_to_show) == 1) {
        # Special case for just one property
        map_proxy <- map_proxy %>%
          addCircleMarkers(
            data = ppr_data_to_show,
            group = "Property Sales",
            radius = 6,
            color = "white",
            weight = 1,
            fillColor = "#1E88E5",  # Use a fixed color
            fillOpacity = 0.8,
            label = ~paste("€", formatC(price, format="f", digits=0, big.mark=",")),
            popup = ~paste(
              "<div style='min-width: 200px;'>",
              "<h4 style='margin-top: 0;'>Property Sale</h4>",
              "<strong>Price:</strong> €", formatC(price, format="f", digits=0, big.mark=","), "<br>",
              "<strong>Address:</strong> ", original_address, "<br>",
              "<strong>Type:</strong> ", property_description,
              "</div>"
            )
          ) %>%
          # Add a simple legend for one property
          addLegend(
            position = "bottomleft",
            colors = "#1E88E5",
            labels = paste("€", formatC(ppr_data_to_show$price[1], format="f", digits=0, big.mark=",")),
            title = "Property Price (€)",
            opacity = 0.8,
            group = "Property Sales"
          )
      }
    }
    
    # Add Airbnb data if available
    if (!is.null(airbnb_data_to_show) && nrow(airbnb_data_to_show) > 0) {
      # Check that we have enough data points to create a visualization
      if (nrow(airbnb_data_to_show) > 1) {
        # Check if we have at least 2 unique price values for valid breaks
        unique_prices <- unique(airbnb_data_to_show$price)
        if(length(unique_prices) > 4) {
          # Enough unique values for quantile breaks
          # Quantile breaks for colors
          price_breaks <- quantile(airbnb_data_to_show$price, 
                                 probs = seq(0, 1, length.out = 5), 
                                 na.rm = TRUE)
          
          # Check if the breaks are unique
          if(length(unique(price_breaks)) < 5) {
            # Not enough unique breaks, use equal interval breaks instead
            min_price <- min(airbnb_data_to_show$price, na.rm = TRUE)
            max_price <- max(airbnb_data_to_show$price, na.rm = TRUE)
            price_range <- max_price - min_price
            
            if(price_range > 0) {
              price_breaks <- seq(min_price, max_price, length.out = 5)
            } else {
              # If min and max are the same, create simple offset breaks
              price_breaks <- c(min_price - 1, min_price - 0.5, min_price, min_price + 0.5, min_price + 1)
            }
          }
          
          # Create color palette
          price_pal <- colorBin(
            palette = "Reds",
            domain = airbnb_data_to_show$price,
            bins = price_breaks
          )
          
          # Add markers
          map_proxy <- map_proxy %>%
            addCircleMarkers(
              data = airbnb_data_to_show,
              group = "Airbnb Listings",
              radius = 6,
              color = "white",
              weight = 1,
              fillColor = ~price_pal(price),
              fillOpacity = 0.8,
              label = ~paste("€", price, "per night"),
              popup = ~paste(
                "<div style='min-width: 200px;'>",
                "<h4 style='margin-top: 0;'>Airbnb Listing</h4>",
                "<strong>Price:</strong> €", price, " per night<br>",
                "<strong>Name:</strong> ", name, "<br>",
                "<strong>Type:</strong> ", room_type, "<br>",
                "<strong>Reviews:</strong> ", number_of_reviews,
                "</div>"
              ),
              clusterOptions = getClusterOptions()
            )
          
          # Only add the legend if we have valid breaks
          if(length(unique(price_breaks)) > 1) {
            map_proxy <- map_proxy %>%
              # Add legend for Airbnb prices
              addLegend(
                position = ifelse(is.null(ppr_data_to_show) || nrow(ppr_data_to_show) == 0, "bottomleft", "bottomright"),
                pal = price_pal,
                values = airbnb_data_to_show$price,
                title = "Airbnb Prices (€/night)",
                opacity = 0.8,
                labFormat = labelFormat(prefix = "€"),
                group = "Airbnb Listings"
              )
          } else {
            # Add a simple legend for single price
            map_proxy <- map_proxy %>%
              addLegend(
                position = ifelse(is.null(ppr_data_to_show) || nrow(ppr_data_to_show) == 0, "bottomleft", "bottomright"),
                colors = "#D81B60",
                labels = paste("€", airbnb_data_to_show$price[1], "per night"),
                title = "Airbnb Price",
                opacity = 0.8,
                group = "Airbnb Listings"
              )
          }
        } else {
          # Not enough unique values for quantile breaks, use a simpler approach
          # Use min and max for a simple scale if there are at least 2 different prices
          if(length(unique_prices) > 1) {
            min_price <- min(unique_prices, na.rm = TRUE)
            max_price <- max(unique_prices, na.rm = TRUE)
            
            # Create a simple two-color palette
            price_pal <- colorBin(
              palette = "Reds",
              domain = c(min_price, max_price),
              bins = c(min_price, (min_price + max_price)/2, max_price)
            )
            
            # Add markers with simple color palette
            map_proxy <- map_proxy %>%
              addCircleMarkers(
                data = airbnb_data_to_show,
                group = "Airbnb Listings",
                radius = 6,
                color = "white",
                weight = 1,
                fillColor = ~price_pal(price),
                fillOpacity = 0.8,
                label = ~paste("€", price, "per night"),
                popup = ~paste(
                  "<div style='min-width: 200px;'>",
                  "<h4 style='margin-top: 0;'>Airbnb Listing</h4>",
                  "<strong>Price:</strong> €", price, " per night<br>",
                  "<strong>Name:</strong> ", name, "<br>",
                  "<strong>Type:</strong> ", room_type, "<br>",
                  "<strong>Reviews:</strong> ", number_of_reviews,
                  "</div>"
                ),
                clusterOptions = getClusterOptions()
              ) %>%
              # Add a simple legend
              addLegend(
                position = ifelse(is.null(ppr_data_to_show) || nrow(ppr_data_to_show) == 0, "bottomleft", "bottomright"),
                colors = c(colorRampPalette(brewer.pal(3, "Reds"))(2)),
                labels = c(paste("€", min_price, "per night"),
                         paste("€", max_price, "per night")),
                title = "Airbnb Prices (€/night)",
                opacity = 0.8,
                group = "Airbnb Listings"
              )
          } else {
            # If all prices are the same value, use a simple color mapping
            single_price_value <- unique_prices[1]
            map_proxy <- map_proxy %>%
              addCircleMarkers(
                data = airbnb_data_to_show,
                group = "Airbnb Listings",
                radius = 6,
                color = "white",
                weight = 1,
                fillColor = "#D81B60",  # Use a fixed color for Airbnb
                fillOpacity = 0.8,
                label = ~paste("€", price, "per night"),
                popup = ~paste(
                  "<div style='min-width: 200px;'>",
                  "<h4 style='margin-top: 0;'>Airbnb Listing</h4>",
                  "<strong>Price:</strong> €", price, " per night<br>",
                  "<strong>Name:</strong> ", name, "<br>",
                  "<strong>Type:</strong> ", room_type, "<br>",
                  "<strong>Reviews:</strong> ", number_of_reviews,
                  "</div>"
                ),
                clusterOptions = getClusterOptions()
              ) %>%
              # Add a simple legend
              addLegend(
                position = ifelse(is.null(ppr_data_to_show) || nrow(ppr_data_to_show) == 0, "bottomleft", "bottomright"),
                colors = "#D81B60",
                labels = paste("€", formatC(single_price_value, format="f", digits=0, big.mark=","), "per night"),
                title = "Airbnb Price",
                opacity = 0.8,
                group = "Airbnb Listings"
              )
          }
        }
      } else if (nrow(airbnb_data_to_show) == 1) {
        # Special case for just one Airbnb listing
        map_proxy <- map_proxy %>%
          addCircleMarkers(
            data = airbnb_data_to_show,
            group = "Airbnb Listings",
            radius = 6,
            color = "white",
            weight = 1,
            fillColor = "#D81B60",  # Use a fixed color for Airbnb
            fillOpacity = 0.8,
            label = ~paste("€", price, "per night"),
            popup = ~paste(
              "<div style='min-width: 200px;'>",
              "<h4 style='margin-top: 0;'>Airbnb Listing</h4>",
              "<strong>Price:</strong> €", price, " per night<br>",
              "<strong>Name:</strong> ", name, "<br>",
              "<strong>Type:</strong> ", room_type, "<br>",
              "<strong>Reviews:</strong> ", number_of_reviews,
              "</div>"
            )
          ) %>%
          # Add a simple legend for one Airbnb
          addLegend(
            position = ifelse(is.null(ppr_data_to_show) || nrow(ppr_data_to_show) == 0, "bottomleft", "bottomright"),
            colors = "#D81B60",
            labels = paste("€", airbnb_data_to_show$price[1], "per night"),
            title = "Airbnb Price",
            opacity = 0.8,
            group = "Airbnb Listings"
          )
      }
    }
    
    return(map_proxy)
  }

  # Automatically update the map when data source changes
  observeEvent(input$dataSource, {
    # This ensures the map updates whenever the data source changes
    ppr_data_to_show <- if (input$dataSource %in% c("ppr", "both")) filtered_ppr() else NULL
    airbnb_data_to_show <- if (input$dataSource %in% c("airbnb", "both")) filtered_airbnb() else NULL
    
    # Update the map
    add_markers_to_map(leafletProxy("map"), ppr_data_to_show, airbnb_data_to_show)
  })
  
  # Reset filters when data source changes
  observe({
    # Reset filters when data source changes to prevent unexpected behavior
    if (input$dataSource == "ppr") {
      # Reset Airbnb filters to initial values
      updateSliderInput(session, "airbnbPriceRange", 
                       value = c(airbnb_min_price, airbnb_max_price))
      updateSelectInput(session, "roomType", selected = "All")
      updateSliderInput(session, "minReviews", value = 0)
    } else if (input$dataSource == "airbnb") {
      # Reset PPR filters to initial values
      updateSliderInput(session, "pprPriceRange", 
                       value = c(ppr_min_price, ppr_max_price))
      updateSelectInput(session, "propertyType", selected = "All")
    } else if (input$dataSource == "both") {
      # Reset both filter sets to show all data
      updateSliderInput(session, "pprPriceRange", 
                       value = c(ppr_min_price, ppr_max_price))
      updateSelectInput(session, "propertyType", selected = "All")
      updateSliderInput(session, "airbnbPriceRange", 
                       value = c(airbnb_min_price, airbnb_max_price))
      updateSelectInput(session, "roomType", selected = "All")
      updateSliderInput(session, "minReviews", value = 0)
    }
  })
  
  # Add a trigger for the Apply Filters button
  observeEvent(input$applyFilters, {
    # This will trigger a map update with current filter settings
    ppr_data_to_show <- if (input$dataSource %in% c("ppr", "both")) filtered_ppr() else NULL
    airbnb_data_to_show <- if (input$dataSource %in% c("airbnb", "both")) filtered_airbnb() else NULL
    
    # Update the map
    add_markers_to_map(leafletProxy("map"), ppr_data_to_show, airbnb_data_to_show)
    
    # Notifications about filter results
    ppr_empty <- is.null(ppr_data_to_show) || nrow(ppr_data_to_show) == 0
    airbnb_empty <- is.null(airbnb_data_to_show) || nrow(airbnb_data_to_show) == 0
    
    if ((input$dataSource == "ppr" && ppr_empty) ||
        (input$dataSource == "airbnb" && airbnb_empty) ||
        (input$dataSource == "both" && ppr_empty && airbnb_empty)) {
      showNotification("No data matches your filter criteria. Try adjusting your filters.", type = "warning")
    } else {
      # Check if filtered data has very few records
      if ((input$dataSource == "ppr" && !ppr_empty && nrow(ppr_data_to_show) < 5) ||
          (input$dataSource == "airbnb" && !airbnb_empty && nrow(airbnb_data_to_show) < 5) ||
          (input$dataSource == "both" && 
            ((!ppr_empty && nrow(ppr_data_to_show) < 5) || 
             (!airbnb_empty && nrow(airbnb_data_to_show) < 5)))) {
        showNotification("Very few data points match your filters. Some visualizations may be limited.", 
                         type = "warning", duration = 8)
      } else {
        # Show confirmation that filters were applied
        showNotification("Filters applied successfully", type = "message")
      }
    }
  })
  
  # Value box outputs
  output$totalRecords <- renderValueBox({
    if (input$dataSource == "ppr") {
      # Handle case when filtered_ppr() is NULL
      count <- if (is.null(filtered_ppr())) 0 else nrow(filtered_ppr())
      valueBox(
        count,
        "Property Sales",
        icon = icon("home"),
        color = "blue"
      )
    } else if (input$dataSource == "airbnb") {
      # Handle case when filtered_airbnb() is NULL
      count <- if (is.null(filtered_airbnb())) 0 else nrow(filtered_airbnb())
      valueBox(
        count,
        "Airbnb Listings",
        icon = icon("bed"),
        color = "red"
      )
    } else {
      # Handle case when either dataset is NULL
      ppr_count <- if (is.null(filtered_ppr())) 0 else nrow(filtered_ppr())
      airbnb_count <- if (is.null(filtered_airbnb())) 0 else nrow(filtered_airbnb())
      valueBox(
        paste(ppr_count, "+", airbnb_count),
        "Total Records",
        icon = icon("map-marker"),
        color = "purple"
      )
    }
  })
  
  output$medianPrice <- renderValueBox({
    if (input$dataSource == "ppr") {
      # Handle case when filtered_ppr() is NULL or empty
      if (is.null(filtered_ppr()) || nrow(filtered_ppr()) == 0) {
        valueBox(
          "N/A",
          "Median Property Price",
          icon = icon("euro-sign"),
          color = "green"
        )
      } else {
      valueBox(
        paste0("€", formatC(median(filtered_ppr()$price, na.rm = TRUE), format = "f", digits = 0, big.mark = ",")),
        "Median Property Price",
        icon = icon("euro-sign"),
        color = "green"
      )
      }
    } else if (input$dataSource == "airbnb") {
      # Handle case when filtered_airbnb() is NULL or empty
      if (is.null(filtered_airbnb()) || nrow(filtered_airbnb()) == 0) {
        valueBox(
          "N/A",
          "Median Nightly Rate",
          icon = icon("euro-sign"),
          color = "green"
        )
      } else {
      valueBox(
        paste0("€", formatC(median(filtered_airbnb()$price, na.rm = TRUE), format = "f", digits = 0, big.mark = ",")),
        "Median Nightly Rate",
        icon = icon("euro-sign"),
        color = "green"
      )
      }
    } else {
      # Handle case when either dataset is NULL or empty
      ppr_median <- if (is.null(filtered_ppr()) || nrow(filtered_ppr()) == 0) "N/A" else 
                     paste0("€", formatC(median(filtered_ppr()$price, na.rm = TRUE), format = "f", digits = 0, big.mark = ","))
      
      airbnb_median <- if (is.null(filtered_airbnb()) || nrow(filtered_airbnb()) == 0) "N/A" else 
                        paste0("€", formatC(median(filtered_airbnb()$price, na.rm = TRUE), format = "f", digits = 0, big.mark = ","))
      
      valueBox(
        paste0(ppr_median, " / ", airbnb_median),
        "Median Prices (Property/Night)",
        icon = icon("euro-sign"),
        color = "green"
      )
    }
  })
  
  output$priceRange <- renderValueBox({
    if (input$dataSource == "ppr") {
      # Handle case when filtered_ppr() is NULL or empty
      if (is.null(filtered_ppr()) || nrow(filtered_ppr()) == 0) {
        valueBox(
          "N/A",
          "Property Price Range",
          icon = icon("arrows-alt-h"),
          color = "yellow"
        )
      } else {
      min_price <- min(filtered_ppr()$price, na.rm = TRUE)
      max_price <- max(filtered_ppr()$price, na.rm = TRUE)
      valueBox(
        paste0("€", formatC(min_price, format = "f", digits = 0, big.mark = ","), 
               " - €", formatC(max_price, format = "f", digits = 0, big.mark = ",")),
        "Property Price Range",
        icon = icon("arrows-alt-h"),
        color = "yellow"
      )
      }
    } else if (input$dataSource == "airbnb") {
      # Handle case when filtered_airbnb() is NULL or empty
      if (is.null(filtered_airbnb()) || nrow(filtered_airbnb()) == 0) {
        valueBox(
          "N/A",
          "Nightly Rate Range",
          icon = icon("arrows-alt-h"),
          color = "yellow"
        )
      } else {
      min_price <- min(filtered_airbnb()$price, na.rm = TRUE)
      max_price <- max(filtered_airbnb()$price, na.rm = TRUE)
      valueBox(
        paste0("€", min_price, " - €", max_price),
        "Nightly Rate Range",
        icon = icon("arrows-alt-h"),
        color = "yellow"
      )
      }
    } else {
      # Handle case when either dataset is NULL or empty
      if ((is.null(filtered_ppr()) || nrow(filtered_ppr()) == 0) && 
          (is.null(filtered_airbnb()) || nrow(filtered_airbnb()) == 0)) {
        valueBox(
          "N/A",
          "Price Ranges",
          icon = icon("arrows-alt-h"),
          color = "yellow"
        )
      } else {
        ppr_range <- if (is.null(filtered_ppr()) || nrow(filtered_ppr()) == 0) {
          "N/A"
    } else {
      ppr_min <- min(filtered_ppr()$price, na.rm = TRUE)
      ppr_max <- max(filtered_ppr()$price, na.rm = TRUE)
          paste0("€", formatC(ppr_min, format = "f", digits = 0, big.mark = ","), 
                " - €", formatC(ppr_max, format = "f", digits = 0, big.mark = ","))
        }
        
        airbnb_range <- if (is.null(filtered_airbnb()) || nrow(filtered_airbnb()) == 0) {
          "N/A"
        } else {
      airbnb_min <- min(filtered_airbnb()$price, na.rm = TRUE)
      airbnb_max <- max(filtered_airbnb()$price, na.rm = TRUE)
          paste0("€", airbnb_min, " - €", airbnb_max)
        }
        
      valueBox(
        HTML(paste0(
            "Property: ", ppr_range, 
            "<br>Airbnb: ", airbnb_range
        )),
        "Price Ranges",
        icon = icon("arrows-alt-h"),
        color = "yellow"
      )
      }
    }
  })
  
  # Price Distribution Chart
  output$priceDistribution <- renderPlotly({
    # Create different plots based on selected data source
    if(input$dataSource == "ppr" && !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0) {
      # Create binwidth based on data range
      price_range <- max(filtered_ppr()$price, na.rm = TRUE) - min(filtered_ppr()$price, na.rm = TRUE)
      bin_width <- price_range / 30
      
      p <- ggplot(filtered_ppr(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#1E88E5", color = "white", alpha = 0.8) +
        scale_x_continuous(labels = scales::label_number(big.mark = ",")) +
        labs(title = "Property Price Distribution",
             x = "Price (€)",
             y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(face = "bold"),
          axis.title = element_text(face = "bold")
        )
    } else if(input$dataSource == "airbnb" && !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      p <- ggplot(filtered_airbnb(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#D81B60", color = "white", alpha = 0.8) +
        labs(title = "Airbnb Price Distribution",
             x = "Price per Night (€)",
             y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(face = "bold"),
          axis.title = element_text(face = "bold")
        )
    } else if(input$dataSource == "both" && 
              !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0 &&
              !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      # Create two separate plots for different scales
      p1 <- ggplot(filtered_ppr(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#1E88E5", color = "white", alpha = 0.8) +
        scale_x_continuous(labels = scales::label_number(big.mark = ",")) +
        labs(title = "Property Price Distribution",
             x = "Price (€)",
             y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(face = "bold"),
          axis.title = element_text(face = "bold")
        )
      
      p2 <- ggplot(filtered_airbnb(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#D81B60", color = "white", alpha = 0.8) +
        labs(title = "Airbnb Price Distribution",
             x = "Price per Night (€)",
             y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(face = "bold"),
          axis.title = element_text(face = "bold")
        )
      
      # Combine plots using subplot
      p <- subplot(p1, p2, nrows = 2, shareX = FALSE, titleY = TRUE) %>%
        layout(title = "Price Distribution Comparison")
      
      return(p)
    } else {
      # Create empty plot if no data available
      p <- ggplot() +
        geom_blank() +
        labs(title = "No Data Available",
             x = "Price (€)",
             y = "Count") +
        theme_minimal()
    }
    
    # Convert to plotly object
    if(exists("p1") && exists("p2")) {
      return(p)  # Already returned above
    } else {
      ggplotly(p) %>% 
        config(displayModeBar = FALSE)
    }
  })
  
  # Price Correlation Chart
  output$priceCorrelation <- renderPlotly({
    # Only show this plot when both datasets are selected
    if(input$dataSource == "both" && 
       !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0 &&
       !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      
      # Extract coordinates and prices for spatial correlation analysis
      ppr_coords <- st_coordinates(filtered_ppr())
      airbnb_coords <- st_coordinates(filtered_airbnb())
      
      # Create dataframes for plotting
      ppr_df <- data.frame(
        x = ppr_coords[,1],
        y = ppr_coords[,2],
        price = filtered_ppr()$price,
        type = "Property Sales"
      )
      
      airbnb_df <- data.frame(
        x = airbnb_coords[,1],
        y = airbnb_coords[,2],
        price = filtered_airbnb()$price,
        type = "Airbnb Listings"
      )
      
      # Combine data for plotting
      combined_df <- rbind(ppr_df, airbnb_df)
      
      # Create scatter plot with price encoded in size and color
      p <- plot_ly(data = combined_df, 
                 x = ~x, 
                 y = ~y, 
                 color = ~type,
                 size = ~price,
                 colors = c("Property Sales" = "#1E88E5", "Airbnb Listings" = "#D81B60"),
                 type = "scatter",
                 mode = "markers",
                 marker = list(opacity = 0.7, 
                              line = list(width = 1, color = "#FFFFFF")),
                 hoverinfo = "text",
                 text = ~paste("Type:", type, "<br>Price: €", formatC(price, format="f", digits=0, big.mark=","))) %>%
        layout(title = "Spatial Price Distribution",
               xaxis = list(title = "Longitude", showgrid = FALSE, zeroline = FALSE),
               yaxis = list(title = "Latitude", showgrid = FALSE, zeroline = FALSE),
               showlegend = TRUE)
      
      return(p)
    } else if(input$dataSource == "ppr" && !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0) {
      # Create property-only plot
      ppr_coords <- st_coordinates(filtered_ppr())
      
      ppr_df <- data.frame(
        x = ppr_coords[,1],
        y = ppr_coords[,2],
        price = filtered_ppr()$price,
        property_type = filtered_ppr()$property_description
      )
      
      # Create scatter plot for properties only
      p <- plot_ly(data = ppr_df, 
                 x = ~x, 
                 y = ~y,
                 color = ~property_type,
                 size = ~price,
                 type = "scatter",
                 mode = "markers",
                 marker = list(opacity = 0.7, 
                              line = list(width = 1, color = "#FFFFFF")),
                 hoverinfo = "text",
                 text = ~paste("Type:", property_type, "<br>Price: €", formatC(price, format="f", digits=0, big.mark=","))) %>%
        layout(title = "Property Price by Location and Type",
               xaxis = list(title = "Longitude", showgrid = FALSE, zeroline = FALSE),
               yaxis = list(title = "Latitude", showgrid = FALSE, zeroline = FALSE))
      
      return(p)
    } else if(input$dataSource == "airbnb" && !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      # Create Airbnb-only plot
      airbnb_coords <- st_coordinates(filtered_airbnb())
      
      airbnb_df <- data.frame(
        x = airbnb_coords[,1],
        y = airbnb_coords[,2],
        price = filtered_airbnb()$price,
        room_type = filtered_airbnb()$room_type
      )
      
      # Create scatter plot for Airbnb only
      p <- plot_ly(data = airbnb_df, 
                 x = ~x, 
                 y = ~y,
                 color = ~room_type,
                 size = ~price,
                 type = "scatter",
                 mode = "markers",
                 marker = list(opacity = 0.7, 
                              line = list(width = 1, color = "#FFFFFF")),
                 hoverinfo = "text",
                 text = ~paste("Type:", room_type, "<br>Price: €", price, "per night")) %>%
        layout(title = "Airbnb Price by Location and Room Type",
               xaxis = list(title = "Longitude", showgrid = FALSE, zeroline = FALSE),
               yaxis = list(title = "Latitude", showgrid = FALSE, zeroline = FALSE))
      
      return(p)
    } else {
      # Create empty plot if no data available
      plot_ly() %>%
        add_annotations(
          x = 0.5,
          y = 0.5,
          text = "No Data Available",
          showarrow = FALSE,
          font = list(size = 16)
        ) %>%
        layout(
          xaxis = list(visible = FALSE),
          yaxis = list(visible = FALSE)
        )
    }
  })
  
  # Time Analysis Chart
  output$timeAnalysis <- renderPlotly({
    # For property data, we need to check if date_of_sale column exists
    ppr_has_dates <- FALSE
    airbnb_has_dates <- FALSE
    
    # Check if filtered data exists and has the required date columns
    if (!is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0) {
      ppr_has_dates <- "date_of_sale" %in% colnames(filtered_ppr()) && 
                      sum(!is.na(filtered_ppr()$date_of_sale)) > 0
    }
    
    if (!is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      airbnb_has_dates <- "last_review" %in% colnames(filtered_airbnb()) && 
                         sum(!is.na(filtered_airbnb()$last_review)) > 0
    }
    
    # PPR Time Analysis
    if(input$dataSource == "ppr" && !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0 && ppr_has_dates) {
      # Group by month and calculate stats, handling potential errors
      time_data <- tryCatch({
        filtered_ppr() %>%
        st_drop_geometry() %>%
        mutate(month = floor_date(date_of_sale, "month")) %>%
        group_by(month) %>%
        summarize(
          avg_price = mean(price, na.rm = TRUE),
          median_price = median(price, na.rm = TRUE),
          count = n()
        )
      }, error = function(e) {
        # Return NULL if an error occurs
        showNotification(paste("Error processing time data:", e$message), type = "error")
        return(NULL)
      })
      
      # Check if time_data is valid
      if(is.null(time_data) || nrow(time_data) < 2) {
        return(
          plot_ly() %>%
            add_annotations(
              x = 0.5,
              y = 0.5,
              text = "Insufficient time data for analysis",
              showarrow = FALSE,
              font = list(size = 16)
            ) %>%
            layout(
              title = "Time Analysis",
              xaxis = list(visible = FALSE),
              yaxis = list(visible = FALSE)
            )
        )
      }
      
      # Create a plot with two y-axes
      p <- plot_ly() %>%
        add_trace(
          data = time_data,
          x = ~month,
          y = ~median_price,
          name = "Median Price",
          type = "scatter",
          mode = "lines+markers",
          line = list(color = "#1E88E5", width = 3),
          marker = list(color = "#1E88E5", size = 8)
        ) %>%
        add_trace(
          data = time_data,
          x = ~month,
          y = ~count,
          name = "Number of Sales",
          yaxis = "y2",
          type = "scatter",
          mode = "lines+markers",
          line = list(color = "#FFC107", width = 3, dash = "dot"),
          marker = list(color = "#FFC107", size = 8)
        ) %>%
        layout(
          title = "Property Sales Over Time",
          xaxis = list(title = "Month"),
          yaxis = list(
            title = "Median Price (€)",
            titlefont = list(color = "#1E88E5"),
            tickfont = list(color = "#1E88E5"),
            side = "left"
          ),
          yaxis2 = list(
            title = "Number of Sales",
            titlefont = list(color = "#FFC107"),
            tickfont = list(color = "#FFC107"),
            overlaying = "y",
            side = "right"
          ),
          legend = list(x = 0.01, y = 0.99)
        )
      
      return(p)
    }
    # Airbnb Time Analysis
    else if(input$dataSource == "airbnb" && !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0 && airbnb_has_dates) {
      # Group by month and calculate stats, handling potential errors
      time_data <- tryCatch({
        filtered_airbnb() %>%
        st_drop_geometry() %>%
        mutate(month = floor_date(last_review, "month")) %>%
        group_by(month) %>%
        summarize(
          avg_price = mean(price, na.rm = TRUE),
          median_price = median(price, na.rm = TRUE),
          count = n(),
          avg_reviews = mean(number_of_reviews, na.rm = TRUE)
        )
      }, error = function(e) {
        # Return NULL if an error occurs
        showNotification(paste("Error processing time data:", e$message), type = "error")
        return(NULL)
      })
      
      # Check if time_data is valid
      if(is.null(time_data) || nrow(time_data) < 2) {
        return(
          plot_ly() %>%
            add_annotations(
              x = 0.5,
              y = 0.5,
              text = "Insufficient time data for analysis",
              showarrow = FALSE,
              font = list(size = 16)
            ) %>%
            layout(
              title = "Time Analysis",
              xaxis = list(visible = FALSE),
              yaxis = list(visible = FALSE)
            )
        )
      }
      
      # Create a plot with two y-axes
      p <- plot_ly() %>%
        add_trace(
          data = time_data,
          x = ~month,
          y = ~median_price,
          name = "Median Price",
          type = "scatter",
          mode = "lines+markers",
          line = list(color = "#D81B60", width = 3),
          marker = list(color = "#D81B60", size = 8)
        ) %>%
        add_trace(
          data = time_data,
          x = ~month,
          y = ~avg_reviews,
          name = "Average Reviews",
          yaxis = "y2",
          type = "scatter",
          mode = "lines+markers",
          line = list(color = "#FFC107", width = 3, dash = "dot"),
          marker = list(color = "#FFC107", size = 8)
        ) %>%
        layout(
          title = "Airbnb Listings Over Time",
          xaxis = list(title = "Month"),
          yaxis = list(
            title = "Median Price (€)",
            titlefont = list(color = "#D81B60"),
            tickfont = list(color = "#D81B60"),
            side = "left"
          ),
          yaxis2 = list(
            title = "Average Reviews",
            titlefont = list(color = "#FFC107"),
            tickfont = list(color = "#FFC107"),
            overlaying = "y",
            side = "right"
          ),
          legend = list(x = 0.01, y = 0.99)
        )
      
      return(p)
    }
    # Both datasets
    else if(input$dataSource == "both" && 
            !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0 && ppr_has_dates &&
            !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0 && airbnb_has_dates) {
      
      # Prepare property data with error handling
      ppr_time_data <- tryCatch({
        filtered_ppr() %>%
        st_drop_geometry() %>%
        mutate(month = floor_date(date_of_sale, "month")) %>%
        group_by(month) %>%
        summarize(median_price = median(price, na.rm = TRUE)) %>%
        mutate(type = "Property Sales")
      }, error = function(e) {
        showNotification(paste("Error processing property time data:", e$message), type = "error")
        return(NULL)
      })
      
      # Prepare Airbnb data with error handling
      airbnb_time_data <- tryCatch({
        filtered_airbnb() %>%
        st_drop_geometry() %>%
        mutate(month = floor_date(last_review, "month")) %>%
        group_by(month) %>%
        summarize(median_price = median(price, na.rm = TRUE)) %>%
        mutate(type = "Airbnb Listings")
      }, error = function(e) {
        showNotification(paste("Error processing Airbnb time data:", e$message), type = "error")
        return(NULL)
      })
      
      # Check if both time datasets are valid
      if(is.null(ppr_time_data) || is.null(airbnb_time_data) || 
         nrow(ppr_time_data) < 2 || nrow(airbnb_time_data) < 2) {
        return(
          plot_ly() %>%
            add_annotations(
              x = 0.5,
              y = 0.5,
              text = "Insufficient time data for analysis",
              showarrow = FALSE,
              font = list(size = 16)
            ) %>%
            layout(
              title = "Time Analysis",
              xaxis = list(visible = FALSE),
              yaxis = list(visible = FALSE)
            )
        )
      }
      
      # Combine the datasets
      p <- plot_ly() %>%
        add_trace(
          data = ppr_time_data,
          x = ~month,
          y = ~median_price,
          name = "Property Sales (Median)",
          type = "scatter",
          mode = "lines+markers",
          line = list(color = "#1E88E5", width = 3),
          marker = list(color = "#1E88E5", size = 8)
        ) %>%
        add_trace(
          data = airbnb_time_data,
          x = ~month,
          y = ~median_price,
          name = "Airbnb Listings (Median)",
          yaxis = "y2",
          type = "scatter",
          mode = "lines+markers",
          line = list(color = "#D81B60", width = 3),
          marker = list(color = "#D81B60", size = 8)
        ) %>%
        layout(
          title = "Price Trends Over Time",
          xaxis = list(title = "Month"),
          yaxis = list(
            title = "Property Price (€)",
            titlefont = list(color = "#1E88E5"),
            tickfont = list(color = "#1E88E5"),
            side = "left"
          ),
          yaxis2 = list(
            title = "Airbnb Price (€)",
            titlefont = list(color = "#D81B60"),
            tickfont = list(color = "#D81B60"),
            overlaying = "y",
            side = "right"
          ),
          legend = list(x = 0.01, y = 0.99)
        )
      
      return(p)
    }
    else {
      # Create empty plot if no time data available
      plot_ly() %>%
        add_annotations(
          x = 0.5,
          y = 0.5,
          text = "Time data not available for selected filters",
          showarrow = FALSE,
          font = list(size = 16)
        ) %>%
        layout(
          title = "Time Analysis",
          xaxis = list(visible = FALSE),
          yaxis = list(visible = FALSE)
        )
    }
  })
  
  # Render the map
  output$map <- renderLeaflet({
    # Create base map
    leaflet() %>%
      # Add base tiles
      addProviderTiles(providers$CartoDB.Positron, group = "Positron") %>%
      addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
      # Set view to center on Cork City
      setView(lng = -8.4677, lat = 51.9, zoom = 12) %>%
      # Add Cork City boundary
      addPolygons(
        data = cork_boundary,
        fillColor = "transparent",
        weight = 2,
        color = "#0033A0",
        dashArray = "3",
        fillOpacity = 0.1,
        label = "Cork City",
        group = "Cork City Boundary"
      ) %>%
      # Add layer controls
      addLayersControl(
        baseGroups = c("Positron", "OpenStreetMap", "Satellite"),
        overlayGroups = c("Cork City Boundary", "Property Sales", "Airbnb Listings"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      # Add legend
      addLegend(
        position = "bottomright",
        colors = c("#1E88E5", "#D81B60"),
        labels = c("Property Sales", "Airbnb Listings"),
        opacity = 0.7,
        title = "Data Sources"
      )
  })
}

# Run the app
shinyApp(ui = ui, server = server) 
