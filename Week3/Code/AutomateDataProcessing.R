# Code/AutomateDataProcessing.R
# Automatically process all CSV files in Data/ and save summaries

setwd("~/Documents/CMEECourseWork/Week3")

# List all CSV files
files <- list.files(path = "./Data", pattern = "*.csv", full.names = TRUE)
cat("Found", length(files), "CSV files.\n")

# Create a data frame to hold summary results
summary_results <- data.frame(File = character(),
                              Rows = integer(),
                              Cols = integer(),
                              Mean_Numeric = numeric())

# Loop through each file
for (f in files) {
  cat("\nProcessing:", f, "\n")
  data <- read.csv(f)
  
  # Get basic info
  num_rows <- nrow(data)
  num_cols <- ncol(data)
  
  # Compute mean of all numeric columns (if any)
  numeric_cols <- sapply(data, is.numeric)
  if (any(numeric_cols)) {
    mean_val <- mean(unlist(data[, numeric_cols]), na.rm = TRUE)
  } else {
    mean_val <- NA
  }
  
  # Append to summary table
  summary_results <- rbind(summary_results,
                           data.frame(File = basename(f),
                                      Rows = num_rows,
                                      Cols = num_cols,
                                      Mean_Numeric = round(mean_val, 3)))
}

#  Write summary to Results
write.csv(summary_results, "./Results/DataSummary.csv", row.names = FALSE)
cat("\n Summary saved to ./Results/DataSummary.csv\n")
