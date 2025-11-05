# Code/DataIOPractical.R
setwd("~/Documents/CMEECourseWork/Week3")

# 1️Read in the data
trees <- read.csv("./Data/trees.csv")

# 2️Data processing: Calculate mean and max tree height
mean_height <- mean(trees$Tree.Height.m)
max_height <- max(trees$Tree.Height.m)

# 3️Write out the results
summary_df <- data.frame(
  MeanHeight = mean_height,
  MaxHeight = max_height
)
write.csv(summary_df, "./Results/TreeHeightSummary.csv", row.names = FALSE)

cat(" TreeHeightSummary.csv saved to ./Results/\n")
