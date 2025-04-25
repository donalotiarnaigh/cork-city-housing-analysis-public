# Enhanced path fixing script for Cork City Property Analysis
# This script uses more advanced techniques to fix paths in R scripts

# Load required packages
if (!require("here")) {
  install.packages("here", repos = "https://cloud.r-project.org")
}
library(here)

# Function to log message with timestamp
log_message <- function(message) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(paste0("[", timestamp, "] ", message, "\n"))
}

log_message("Starting path correction process...")

# Get list of all R files in the repository
r_files <- list.files(
  path = ".",
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = TRUE
)

log_message(paste("Found", length(r_files), "R files to process"))

# Function to fix paths in a file
fix_paths_in_file <- function(file_path) {
  log_message(paste("Processing file:", file_path))
  
  # Read the file content
  content <- readLines(file_path, warn = FALSE)
  original_content <- content
  
  # Get the script's directory (relative to repo root)
  script_dir <- dirname(file_path)
  
  # Define path patterns and their replacements
  path_patterns <- list(
    # Data directory paths
    list(
      pattern = "data/Airbnb/",
      replacement = "data/raw/airbnb/"
    ),
    list(
      pattern = "data/PropertySales/",
      replacement = "data/raw/property_sales/"
    ),
    list(
      pattern = "\"data/processed/",
      replacement = "here(\"data/processed/"
    ),
    list(
      pattern = "\"data/raw/",
      replacement = "here(\"data/raw/"
    ),
    list(
      pattern = "\"../data/processed/",
      replacement = "here(\"data/processed/"
    ),
    list(
      pattern = "\"../data/raw/",
      replacement = "here(\"data/raw/"
    ),
    list(
      pattern = "\"data/boundaries/",
      replacement = "here(\"data/boundaries/"
    ),
    list(
      pattern = "\"data/samples/",
      replacement = "here(\"data/samples/"
    ),
    
    # Output directory paths
    list(
      pattern = "\"output/",
      replacement = "here(\"output/"
    ),
    list(
      pattern = "\"../output/",
      replacement = "here(\"output/"
    ),
    
    # Script references
    list(
      pattern = "source\\(\"R/",
      replacement = "source(here(\"scripts/"
    ),
    list(
      pattern = "source\\(\"scripts/",
      replacement = "source(here(\"scripts/"
    )
  )
  
  # Apply each pattern replacement
  for (pattern_set in path_patterns) {
    content <- gsub(pattern_set$pattern, pattern_set$replacement, content)
  }
  
  # Add here package to scripts that need path correction
  if (!any(grepl("library\\(here\\)", content)) && 
      !identical(content, original_content)) {
    
    # Find where libraries are loaded
    lib_lines <- grep("library\\(", content)
    if (length(lib_lines) > 0) {
      # Insert after the last library() call
      insert_pos <- max(lib_lines) + 1
      content <- append(content, "library(here)", after = insert_pos - 1)
    } else {
      # Insert at the beginning after any comments/shebang
      non_comment_lines <- which(!grepl("^\\s*#", content))
      if (length(non_comment_lines) > 0) {
        non_comment_line <- min(non_comment_lines)
        content <- append(content, "library(here)", after = non_comment_line - 1)
      } else {
        # If file is all comments, add at the end
        content <- c(content, "library(here)")
      }
    }
  }
  
  # Check for closing parentheses after here() calls
  content <- gsub('here\\("([^"]+)"', 'here("\\1")', content)
  
  # Write the modified content back to the file if changes were made
  if (!identical(content, original_content)) {
    writeLines(content, file_path)
    log_message(paste("Updated paths in:", file_path))
    return(TRUE)
  } else {
    log_message(paste("No path changes needed in:", file_path))
    return(FALSE)
  }
}

# Process all R files
modified_files <- 0
for (file in r_files) {
  # Skip this file itself
  if (grepl("fix_paths\\.R$", file)) {
    log_message(paste("Skipping self:", file))
    next
  }
  
  if (fix_paths_in_file(file)) {
    modified_files <- modified_files + 1
  }
}

log_message(paste("Path correction completed.", modified_files, "files were modified"))

# Create a .here file at the root if it doesn't exist
if (!file.exists(here::here(".here"))) {
  file.create(here::here(".here"))
  log_message("Created .here file at project root")
}

# Output completion message
cat("\n===========================================================\n")
cat("PATH CORRECTION COMPLETED\n")
cat("===========================================================\n")
cat("\n")
cat("Next steps:\n")
cat("1. Test scripts individually to verify path corrections\n")
cat("2. Update app.R to use the here package for data loading\n")
cat("\n===========================================================\n") 