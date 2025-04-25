# Individual script testing utility
# This script tests a single R script and reports detailed errors

# Function to display usage information
show_usage <- function() {
  cat("\nUsage: Rscript test_individual_script.R <script_path>\n")
  cat("  <script_path>: Path to the R script to test\n")
  cat("\nExample: Rscript test_individual_script.R scripts/01_data_cleaning/ppr_data_cleaning.R\n\n")
  quit(status = 1)
}

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  cat("Error: Script path required\n")
  show_usage()
}

script_path <- args[1]
if (!file.exists(script_path)) {
  cat("Error: Script not found:", script_path, "\n")
  show_usage()
}

# Load required packages
if (!require("here")) {
  install.packages("here", repos = "https://cloud.r-project.org")
}
library(here)

# Set up error tracing
options(warn = 1)  # Print warnings as they occur
options(error = quote({
  cat("\n===========================================================\n")
  cat("ERROR TRACEBACK\n")
  cat("===========================================================\n")
  traceback(20)
  cat("\n")
  if (exists("last.warning") && !is.null(last.warning)) {
    cat("\n===========================================================\n")
    cat("LAST WARNING\n")
    cat("===========================================================\n")
    print(last.warning)
    cat("\n")
  }
}))

# Function to log message with timestamp
log_message <- function(message) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(paste0("[", timestamp, "] ", message, "\n"))
}

# Print script information
cat("\n===========================================================\n")
cat("TESTING SCRIPT:", script_path, "\n")
cat("===========================================================\n")
cat("Current working directory:", getwd(), "\n")
cat("Project root directory:", here(), "\n")
cat("R version:", R.version.string, "\n")
cat("\n")

# Run the script with error handling
log_message("Starting script execution...")

# Create a new environment to isolate script execution
test_env <- new.env()

# Record script start time
start_time <- Sys.time()

# Try to source the script
result <- tryCatch({
  source(script_path, local = test_env)
  TRUE
}, error = function(e) {
  cat("\n===========================================================\n")
  cat("SCRIPT FAILED\n")
  cat("===========================================================\n")
  cat("Error message:", e$message, "\n")
  FALSE
})

# Record script end time
end_time <- Sys.time()
execution_time <- difftime(end_time, start_time, units = "secs")

# Print result
cat("\n===========================================================\n")
if (result) {
  cat("SCRIPT EXECUTED SUCCESSFULLY\n")
} else {
  cat("SCRIPT EXECUTION FAILED\n")
}
cat("===========================================================\n")
cat("Execution time:", round(as.numeric(execution_time), 2), "seconds\n")
cat("\n")

# List objects created by the script
if (result) {
  cat("Objects created/modified by the script:\n")
  script_objects <- ls(test_env)
  if (length(script_objects) > 0) {
    for (obj_name in script_objects) {
      obj <- get(obj_name, envir = test_env)
      obj_size <- object.size(obj)
      obj_class <- class(obj)[1]
      if (is.data.frame(obj)) {
        cat("- ", obj_name, " (", obj_class, ", ", format(obj_size, units = "auto"), "): ", 
            nrow(obj), " rows × ", ncol(obj), " columns\n", sep = "")
      } else {
        cat("- ", obj_name, " (", obj_class, ", ", format(obj_size, units = "auto"), ")\n", sep = "")
      }
    }
  } else {
    cat("No objects were created in the global environment.\n")
  }
}

cat("\n===========================================================\n") 