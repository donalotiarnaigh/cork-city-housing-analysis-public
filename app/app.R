# Load required libraries
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

# Function to safely load data with error handling
safe_load_data <- function(file_path) {
  tryCatch({
    cat("Attempting to load file:", file_path, "\n")
    if (!file.exists(file_path)) {
      stop(paste("File does not exist:", file_path))
    }
    data <- st_read(file_path, quiet = TRUE)
    if (nrow(data) == 0) {
      stop(paste("Loaded data is empty for file:", file_path))
    }
    cat("Successfully loaded file:", file_path, "\n")
    return(data)
  }, error = function(e) {
    cat("Error loading file:", file_path, "\n")
    cat("Error message:", e$message, "\n")
    return(NULL)
  })
}

# Function to calculate price ranges
calculate_price_ranges <- function(data, is_ppr = TRUE) {
  tryCatch({
    if (is_ppr) {
      min_price <- floor(min(data$price, na.rm = TRUE) / 10000) * 10000
      max_price <- ceiling(max(data$price, na.rm = TRUE) / 100000) * 100000
      median_price <- median(data$price, na.rm = TRUE)
    } else {
      min_price <- floor(min(data$price, na.rm = TRUE) / 10) * 10
      max_price <- ceiling(max(data$price, na.rm = TRUE) / 50) * 50
      median_price <- median(data$price, na.rm = TRUE)
    }
    return(list(min = min_price, max = max_price, median = median_price))
  }, error = function(e) {
    cat("Error calculating price ranges:", e$message, "\n")
    return(list(min = 0, max = 1000000, median = 500000))
  })
}

# Define UI
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
                   min = 0, max = 1000000, 
                   value = c(0, 1000000),
                   step = 10000),
        selectInput("propertyType", "Property Type:",
                   choices = c("All"),
                   selected = "All")
      ),
      
      # Airbnb filters
      conditionalPanel(
        condition = "input.dataSource == 'airbnb' || input.dataSource == 'both'",
        tags$h4("Airbnb Filters"),
        sliderInput("airbnbPriceRange", "Price Range (€ per night):",
                   min = 0, max = 1000, 
                   value = c(0, 1000),
                   step = 10),
        selectInput("roomType", "Room Type:",
                   choices = c("All"),
                   selected = "All"),
        sliderInput("minReviews", "Minimum Reviews:",
                   min = 0, max = 100,
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
        tags$p(tags$strong("Property Sales:"), textOutput("pprRecordCount")),
        tags$p("Median Price: ", textOutput("pprMedianPrice"))
      ),
      conditionalPanel(
        condition = "input.dataSource == 'airbnb' || input.dataSource == 'both'",
        tags$p(tags$strong("Airbnb Listings:"), textOutput("airbnbRecordCount")),
        tags$p("Median Price: ", textOutput("airbnbMedianPrice"))
      ),
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
                tags$li(tags$strong("Property Price Register (PPR)"), " - Records of property sales in Cork City"),
                tags$li(tags$strong("Airbnb Listings"), " - Data on Airbnb rental properties in Cork City")
              )
            )
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Load and process data
  data <- reactive({
    # Load data with error handling
    ppr_data <- safe_load_data("data/processed/final/ppr_corkCity_with_dates.gpkg")
    airbnb_data <- safe_load_data("data/processed/final/airbnb_corkCity_with_dates.gpkg")
    cork_boundary <- safe_load_data("data/boundaries/cork_city_boundary.gpkg")
    
    # Check if data loading was successful
    if (is.null(ppr_data) || is.null(airbnb_data) || is.null(cork_boundary)) {
      stop("Failed to load required data files")
    }
    
    # Transform to WGS84
    ppr_data <- st_transform(ppr_data, 4326)
    airbnb_data <- st_transform(airbnb_data, 4326)
    cork_boundary <- st_transform(cork_boundary, 4326)
    
    # Calculate price ranges
    ppr_prices <- calculate_price_ranges(ppr_data, TRUE)
    airbnb_prices <- calculate_price_ranges(airbnb_data, FALSE)
    
    # Update UI elements
    updateSliderInput(session, "pprPriceRange",
                     min = ppr_prices$min,
                     max = ppr_prices$max,
                     value = c(ppr_prices$min, ppr_prices$max))
    
    updateSliderInput(session, "airbnbPriceRange",
                     min = airbnb_prices$min,
                     max = airbnb_prices$max,
                     value = c(airbnb_prices$min, airbnb_prices$max))
    
    updateSelectInput(session, "propertyType",
                     choices = c("All", sort(unique(ppr_data$property_description))))
    
    updateSelectInput(session, "roomType",
                     choices = c("All", sort(unique(airbnb_data$room_type))))
    
    list(
      ppr = ppr_data,
      airbnb = airbnb_data,
      boundary = cork_boundary,
      ppr_prices = ppr_prices,
      airbnb_prices = airbnb_prices
    )
  })
  
  # Create reactive filtered datasets
  filtered_ppr <- reactive({
    if (input$dataSource %in% c("ppr", "both")) {
      filtered <- data()$ppr %>%
        filter(price >= input$pprPriceRange[1] & price <= input$pprPriceRange[2])
      
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
      filtered <- data()$airbnb %>%
        filter(price >= input$airbnbPriceRange[1] & price <= input$airbnbPriceRange[2])
      
      if (input$roomType != "All") {
        filtered <- filtered %>%
          filter(room_type == input$roomType)
      }
      
      filtered <- filtered %>%
        filter(number_of_reviews >= input$minReviews)
      
      filtered
    } else {
      NULL
    }
  })
  
  # Function to get cluster options
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
  
  # Function to add markers and legends to the map
  add_markers_to_map <- function(map_proxy, ppr_data_to_show, airbnb_data_to_show) {
    # Clear existing markers and legends
    map_proxy <- map_proxy %>%
      clearMarkers() %>%
      clearGroup("Property Sales") %>%
      clearGroup("Airbnb Listings") %>%
      clearControls()
    
    # Add PPR data if available
    if (!is.null(ppr_data_to_show) && nrow(ppr_data_to_show) > 0) {
      # Create color palette for PPR
      price_pal <- colorBin(
        palette = "Blues",
        domain = ppr_data_to_show$price,
        bins = 5
      )
      
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
        addLegend(
          position = "bottomleft",
          pal = price_pal,
          values = ppr_data_to_show$price,
          title = "Property Prices (€)",
          opacity = 0.8,
          labFormat = labelFormat(prefix = "€", big.mark = ","),
          group = "Property Sales"
        )
    }
    
    # Add Airbnb data if available
    if (!is.null(airbnb_data_to_show) && nrow(airbnb_data_to_show) > 0) {
      # Create color palette for Airbnb
      price_pal <- colorBin(
        palette = "Reds",
        domain = airbnb_data_to_show$price,
        bins = 5
      )
      
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
        addLegend(
          position = ifelse(is.null(ppr_data_to_show) || nrow(ppr_data_to_show) == 0, "bottomleft", "bottomright"),
          pal = price_pal,
          values = airbnb_data_to_show$price,
          title = "Airbnb Prices (€/night)",
          opacity = 0.8,
          labFormat = labelFormat(prefix = "€"),
          group = "Airbnb Listings"
        )
    }
    
    return(map_proxy)
  }
  
  # Render map
  output$map <- renderLeaflet({
    # Create base map
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron, group = "Positron") %>%
      addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
      setView(lng = -8.4677, lat = 51.9, zoom = 12) %>%
      addPolygons(
        data = data()$boundary,
        fillColor = "transparent",
        weight = 2,
        color = "#0033A0",
        dashArray = "3",
        fillOpacity = 0.1,
        label = "Cork City",
        group = "Cork City Boundary"
      ) %>%
      addLayersControl(
        baseGroups = c("Positron", "OpenStreetMap", "Satellite"),
        overlayGroups = c("Cork City Boundary", "Property Sales", "Airbnb Listings"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  # Update map when filters change
  observeEvent(input$applyFilters, {
    ppr_data_to_show <- filtered_ppr()
    airbnb_data_to_show <- filtered_airbnb()
    
    add_markers_to_map(leafletProxy("map"), ppr_data_to_show, airbnb_data_to_show)
  })
  
  # Value box outputs
  output$totalRecords <- renderValueBox({
    if (input$dataSource == "ppr") {
      count <- if (is.null(filtered_ppr())) 0 else nrow(filtered_ppr())
      valueBox(
        count,
        "Property Sales",
        icon = icon("home"),
        color = "blue"
      )
    } else if (input$dataSource == "airbnb") {
      count <- if (is.null(filtered_airbnb())) 0 else nrow(filtered_airbnb())
      valueBox(
        count,
        "Airbnb Listings",
        icon = icon("bed"),
        color = "red"
      )
    } else {
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
    if(input$dataSource == "ppr" && !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0) {
      p <- ggplot(filtered_ppr(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#1E88E5", color = "white", alpha = 0.8) +
        scale_x_continuous(labels = scales::label_number(big.mark = ",")) +
        labs(title = "Property Price Distribution",
             x = "Price (€)",
             y = "Count") +
        theme_minimal()
    } else if(input$dataSource == "airbnb" && !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      p <- ggplot(filtered_airbnb(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#D81B60", color = "white", alpha = 0.8) +
        labs(title = "Airbnb Price Distribution",
             x = "Price per Night (€)",
             y = "Count") +
        theme_minimal()
    } else if(input$dataSource == "both" && 
              !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0 &&
              !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      p1 <- ggplot(filtered_ppr(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#1E88E5", color = "white", alpha = 0.8) +
        scale_x_continuous(labels = scales::label_number(big.mark = ",")) +
        labs(title = "Property Price Distribution",
             x = "Price (€)",
             y = "Count") +
        theme_minimal()
      
      p2 <- ggplot(filtered_airbnb(), aes(x = price)) +
        geom_histogram(bins = 30, fill = "#D81B60", color = "white", alpha = 0.8) +
        labs(title = "Airbnb Price Distribution",
             x = "Price per Night (€)",
             y = "Count") +
        theme_minimal()
      
      p <- subplot(p1, p2, nrows = 2, shareX = FALSE, titleY = TRUE) %>%
        layout(title = "Price Distribution Comparison")
      
      return(p)
    } else {
      p <- ggplot() +
        geom_blank() +
        labs(title = "No Data Available",
             x = "Price (€)",
             y = "Count") +
        theme_minimal()
    }
    
    ggplotly(p) %>% 
      config(displayModeBar = FALSE)
  })
  
  # Price Correlation Chart
  output$priceCorrelation <- renderPlotly({
    if(input$dataSource == "both" && 
       !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0 &&
       !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0) {
      
      ppr_coords <- st_coordinates(filtered_ppr())
      airbnb_coords <- st_coordinates(filtered_airbnb())
      
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
      
      combined_df <- rbind(ppr_df, airbnb_df)
      
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
    } else {
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
    if(input$dataSource == "ppr" && !is.null(filtered_ppr()) && nrow(filtered_ppr()) > 0 &&
       "date_of_sale" %in% colnames(filtered_ppr())) {
      
      time_data <- filtered_ppr() %>%
        st_drop_geometry() %>%
        mutate(month = floor_date(date_of_sale, "month")) %>%
        group_by(month) %>%
        summarize(
          avg_price = mean(price, na.rm = TRUE),
          median_price = median(price, na.rm = TRUE),
          count = n()
        )
      
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
    } else if(input$dataSource == "airbnb" && !is.null(filtered_airbnb()) && nrow(filtered_airbnb()) > 0 &&
              "last_review" %in% colnames(filtered_airbnb())) {
      
      time_data <- filtered_airbnb() %>%
        st_drop_geometry() %>%
        mutate(month = floor_date(last_review, "month")) %>%
        group_by(month) %>%
        summarize(
          avg_price = mean(price, na.rm = TRUE),
          median_price = median(price, na.rm = TRUE),
          count = n(),
          avg_reviews = mean(number_of_reviews, na.rm = TRUE)
        )
      
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
    } else {
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
  
  # Record count outputs
  output$pprRecordCount <- renderText({
    if (is.null(filtered_ppr())) "0 records" else paste(nrow(filtered_ppr()), "records")
  })
  
  output$airbnbRecordCount <- renderText({
    if (is.null(filtered_airbnb())) "0 listings" else paste(nrow(filtered_airbnb()), "listings")
  })
  
  # Median price outputs
  output$pprMedianPrice <- renderText({
    if (is.null(filtered_ppr()) || nrow(filtered_ppr()) == 0) {
      "N/A"
    } else {
      paste0("€", formatC(median(filtered_ppr()$price, na.rm = TRUE), format = "f", digits = 0, big.mark = ","))
    }
  })
  
  output$airbnbMedianPrice <- renderText({
    if (is.null(filtered_airbnb()) || nrow(filtered_airbnb()) == 0) {
      "N/A"
    } else {
      paste0("€", formatC(median(filtered_airbnb()$price, na.rm = TRUE), format = "f", digits = 0, big.mark = ","), " per night")
    }
  })
}

# Create Shiny app
shinyApp(ui = ui, server = server) 