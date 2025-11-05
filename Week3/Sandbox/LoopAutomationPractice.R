# Sandbox/LoopAutomationPractice.R
# Looping and Automation Basics 

# Simple for loop
for (i in 1:5) {
  cat("Iteration:", i, "\n")
}

# Loop through a vector
names <- c("Alice", "Bob", "Charlie")
for (n in names) {
  cat("Hello,", n, "!\n")
}

#  Using list.files()
files <- list.files(path = "./Data", pattern = "*.csv", full.names = TRUE)
cat("Found", length(files), "CSV files in Data folder:\n")
print(files)

# Read each CSV file and show the first few lines
for (f in files) {
  cat("\n--- Reading:", f, "---\n")
  data <- read.csv(f)
  print(head(data, 3))
}
