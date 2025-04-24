# Cork City Property Analysis - Deployment Guide

This guide provides instructions for deploying the Cork City Property Analysis application using different hosting solutions.

## 1. Deploying to shinyapps.io

[shinyapps.io](https://www.shinyapps.io/) is the simplest way to host your Shiny app online. It's maintained by RStudio/Posit and offers both free and paid plans.

### Prerequisites

1. Create a shinyapps.io account at https://www.shinyapps.io/
2. Install and load the rsconnect package:
   ```r
   install.packages("rsconnect")
   library(rsconnect)
   ```
3. Set up your account credentials:
   ```r
   rsconnect::setAccountInfo(
     name="YOUR_ACCOUNT_NAME",
     token="YOUR_TOKEN",
     secret="YOUR_SECRET"
   )
   ```
   (You can find your token and secret in your shinyapps.io dashboard under Account → Tokens)

### Using the Deployment Script

We've created a deployment script that bundles all necessary files for the application:

1. Open R or RStudio
2. Run the deployment script:
   ```r
   source("deploy.R")
   ```

The script will:
- Check if all required files exist
- Calculate the total package size
- Deploy the application to shinyapps.io
- Open the deployed app in your browser when complete

### Manual Deployment

If you need more control over the deployment process:

1. Open R or RStudio
2. Run:
   ```r
   library(rsconnect)
   
   # List files to deploy
   files <- c(
     "app/app.R",
     "app/www/custom.css",
     "data/processed/final/airbnb_corkCity.gpkg",
     "data/processed/final/ppr_corkCity_with_dates.gpkg",
     "data/processed/final/airbnb_corkCity_with_dates.gpkg",
     "data/boundaries/cork_city_boundary.gpkg"
   )
   
   # Deploy
   rsconnect::deployApp(
     appDir = ".",
     appName = "CorkCityPropertyAnalysis",
     appFiles = files
   )
   ```

### Troubleshooting shinyapps.io Deployment

If you encounter issues:

1. **File size limits**: shinyapps.io has a 1GB total app size limit. If your data is too large:
   - Create smaller subsets of the data
   - Host the data elsewhere and have the app fetch it at runtime

2. **Package dependency issues**:
   - Specify exact packages with `appDependencies`:
     ```r
     rsconnect::deployApp(
       # ...other parameters
       appDependencies = c("shiny", "sf", "leaflet", "dplyr", "shinydashboard", "viridis", "plotly", "tidyr")
     )
     ```

3. **Deployment timeout**:
   - Increase the timeout:
     ```r
     rsconnect::deployApp(
       # ...other parameters
       timeout = 600  # 10 minutes
     )
     ```

4. **Missing system dependencies**:
   - For spatial packages (sf, rgdal, etc.), shinyapps.io may need specific system libraries
   - Add the required GDAL/GEOS libraries by adding these lines at the top of app.R:
     ```r
     if (Sys.info()["sysname"] == "Linux") {
       Sys.setenv(LD_LIBRARY_PATH=paste0(Sys.getenv("LD_LIBRARY_PATH"), ":/usr/lib/x86_64-linux-gnu/"))
     }
     ```

## 2. Deploying to Shiny Server (Self-Hosted)

If you need more control or have higher resource requirements, you can deploy the app on your own Shiny Server.

### Prerequisites

1. A Linux server (Ubuntu/Debian recommended)
2. R installed on the server
3. Shiny Server installed on the server

### Installation Steps

1. **Install R and necessary system dependencies**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y r-base r-base-dev
   sudo apt-get install -y libssl-dev libcurl4-openssl-dev libxml2-dev
   sudo apt-get install -y libgdal-dev libgeos-dev libproj-dev libudunits2-dev
   ```

2. **Install Shiny Server**:
   ```bash
   sudo apt-get install -y gdebi-core
   wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
   sudo gdebi shiny-server-1.5.20.1002-amd64.deb
   ```

3. **Install required R packages**:
   ```bash
   sudo su - -c "R -e \"install.packages(c('shiny', 'shinydashboard', 'leaflet', 'sf', 'dplyr', 'ggplot2', 'plotly', 'viridis', 'tidyr'), repos='http://cran.rstudio.com/')\""
   ```

### Deploying the Application

1. **Create a directory for your application**:
   ```bash
   sudo mkdir -p /srv/shiny-server/CorkCityPropertyAnalysis
   ```

2. **Upload the application files to the server**:
   - Using SCP:
     ```bash
     scp -r app/* user@your-server:/srv/shiny-server/CorkCityPropertyAnalysis/
     scp -r data/processed/final/*.gpkg user@your-server:/srv/shiny-server/CorkCityPropertyAnalysis/data/
     scp -r data/boundaries/*.gpkg user@your-server:/srv/shiny-server/CorkCityPropertyAnalysis/data/
     ```
   - Or use SFTP with a GUI client like FileZilla

3. **Update file paths in app.R**:
   You may need to update file paths in app.R to point to the new locations on the server.

4. **Set correct permissions**:
   ```bash
   sudo chown -R shiny:shiny /srv/shiny-server/CorkCityPropertyAnalysis
   sudo chmod -R 755 /srv/shiny-server/CorkCityPropertyAnalysis
   ```

5. **Restart Shiny Server**:
   ```bash
   sudo systemctl restart shiny-server
   ```

6. **Access your application**:
   Your application should now be available at:
   ```
   http://your-server-ip:3838/CorkCityPropertyAnalysis/
   ```

## 3. Deploying with Docker

Docker provides a containerized approach that ensures consistency across different environments.

### Prerequisites

1. Docker installed on your system or server
2. Basic understanding of Docker commands

### Creating a Dockerfile

Create a file named `Dockerfile` in your project root:

```dockerfile
FROM rocker/shiny:latest

# Install system dependencies for sf, leaflet, etc.
RUN apt-get update && apt-get install -y \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libssl-dev \
    libcurl4-openssl-dev

# Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'leaflet', 'sf', 'dplyr', 'ggplot2', 'plotly', 'viridis', 'tidyr'), repos='http://cran.rstudio.com/')"

# Copy app files
COPY app /srv/shiny-server/CorkCityPropertyAnalysis
RUN mkdir -p /srv/shiny-server/CorkCityPropertyAnalysis/data

# Copy data files
COPY data/processed/final/airbnb_corkCity.gpkg /srv/shiny-server/CorkCityPropertyAnalysis/data/
COPY data/processed/final/ppr_corkCity_with_dates.gpkg /srv/shiny-server/CorkCityPropertyAnalysis/data/
COPY data/processed/final/airbnb_corkCity_with_dates.gpkg /srv/shiny-server/CorkCityPropertyAnalysis/data/
COPY data/boundaries/cork_city_boundary.gpkg /srv/shiny-server/CorkCityPropertyAnalysis/data/

# Set correct permissions
RUN chown -R shiny:shiny /srv/shiny-server/CorkCityPropertyAnalysis
RUN chmod -R 755 /srv/shiny-server/CorkCityPropertyAnalysis

# Configure Shiny Server
RUN echo '{\n  "listen": 3838,\n  "server_name": 0.0.0.0,\n  "location": "/",\n  "directory_index": true,\n  "site_dir": "/srv/shiny-server",\n  "log_dir": "/var/log/shiny-server",\n  "access_log": "/var/log/shiny-server/access.log",\n  "error_log": "/var/log/shiny-server/error.log"\n}' > /etc/shiny-server/shiny-server.conf

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
```

### Building and Running the Docker Container

1. **Build the Docker image**:
   ```bash
   docker build -t cork-property-analysis .
   ```

2. **Run the container**:
   ```bash
   docker run -d -p 3838:3838 --name cork-property-app cork-property-analysis
   ```

3. **Access your application**:
   Your application should now be available at:
   ```
   http://localhost:3838/CorkCityPropertyAnalysis/
   ```

### Deploying to Cloud Services

You can push your Docker container to cloud services like:

1. **AWS Elastic Container Service**:
   - Push your container to Amazon ECR
   - Deploy using ECS or Fargate

2. **Google Cloud Run**:
   - Push your container to Google Container Registry
   - Deploy as a Cloud Run service

3. **Microsoft Azure Container Instances**:
   - Push your container to Azure Container Registry
   - Deploy as a Container Instance

## 4. Reducing App Size for Deployment

If your app size exceeds hosting limits, consider these strategies:

1. **Create smaller dataset versions**:
   - Reduce the precision of geometries
   - Sample a subset of the data
   - Aggregate data at a higher level

2. **Use remote data storage**:
   - Store large datasets in a database or cloud storage
   - Have the app fetch data as needed
   - Consider using AWS S3, Google Cloud Storage, or a PostgreSQL/PostGIS database

3. **Implement progressive loading**:
   - Load only the data needed for the current view
   - Implement pagination or lazy loading

## 5. Additional Resources

- [shinyapps.io Documentation](https://docs.rstudio.com/shinyapps.io/)
- [Shiny Server Administrator's Guide](https://docs.rstudio.com/shiny-server/)
- [Docker Documentation](https://docs.docker.com/)
- [Leaflet for R](https://rstudio.github.io/leaflet/)
- [sf Package Documentation](https://r-spatial.github.io/sf/) 