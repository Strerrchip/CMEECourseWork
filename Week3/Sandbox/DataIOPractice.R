# Sandbox/DataIOPractice.R

# Read the CSV file
trees <- read.csv("./Data/trees.csv")

# View the first few rows
head(trees)

# View the structure of the data
str(trees)

# Calculate the average distance
mean_distance <- mean(trees$Distance.m)
cat("Average distance =", mean_distance, "\n")



# Write out a space-separated file
write.table(trees, "./Data/trees_space.txt", sep = " ", row.names = FALSE)

# Read the space-separated file
trees_space <- read.table("./Data/trees_space.txt", header = TRUE, sep = " ")

# View the first few rows
head(trees_space)

# Write out CSV 
write.csv(trees, "./Results/trees_copy.csv", row.names = FALSE)

# Write out TXT 
write.table(trees, "./Results/trees_copy.txt", sep = "\t", row.names = FALSE)

cat("Files written to ./Results\n")


library(readxl)

# Save as RData
save(trees, file = "./Results/trees.RData")

# Save as RDS 
saveRDS(trees, "./Results/trees.rds")

# Reload 
load("./Results/trees.RData")
trees_rds <- readRDS("./Results/trees.rds")

cat("RData and RDS files reloaded successfully.\n")
