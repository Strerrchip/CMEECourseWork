# Code/MyFunctionScript.R
setwd("~/Documents/CMEECourseWork/Week3")

# Define a function to describe a numeric vector
DescribeVector <- function(vec) {
  stats <- list(
    mean = mean(vec),
    sd = sd(vec),
    min = min(vec),
    max = max(vec)
  )
  return(stats)
}

# Example usage
data_vec <- c(12, 15, 18, 20, 25, 30)

# Call the function
result <- DescribeVector(data_vec)

# Print the result
print(result)

# Save the result as CSV
result_df <- as.data.frame(result)
write.csv(result_df, "./Results/VectorSummary.csv", row.names = FALSE)
cat("VectorSummary.csv saved to ./Results/\n")

# Code/MyFunctionScript.R

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript MyFunctionScript.R <number1> <number2>")
}

x <- as.numeric(args[1])
y <- as.numeric(args[2])

AddTwoNumbers <- function(a, b) {
  return(a + b)
}

cat("Sum =", AddTwoNumbers(x, y), "\n")
