# Code/MySpeciesData.R
setwd("~/Documents/CMEECourseWork/Week3")

Species <- c("Tiger", "Elephant", "Panda", "Giraffe")
Population <- c(3200, 500000, 1864, 117000)
Lifespan <- c(15, 70, 20, 25)

SpeciesData <- data.frame(Species, Population, Lifespan)

# display the data frame
print(SpeciesData)

# save the results
write.csv(SpeciesData, "./Results/SpeciesData.csv", row.names = FALSE)
cat(" SpeciesData.csv saved to ./Results/\n")
# read back the data
data <- read.csv("./Results/SpeciesData.csv")

# compute statistics
mean_life <- mean(data$Lifespan)
sd_life <- sd(data$Lifespan)
min_life <- min(data$Lifespan)
max_life <- max(data$Lifespan)

cat("Average lifespan:", mean_life, "\n")
cat("SD lifespan:", sd_life, "\n")
cat("Min lifespan:", min_life, "\n")
cat("Max lifespan:", max_life, "\n")
