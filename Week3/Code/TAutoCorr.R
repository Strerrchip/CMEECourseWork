setwd("~/Documents/CMEECourseWork/Week3")
library(dplyr)

# read data
data <- read.csv("./Data/florida_weather.csv")

# calculate autocorrelation for adjacent years
results <- data %>%
  arrange(location, year) %>%
  group_by(location) %>%
  summarise(
    real_cor = cor(mean_temp[-n()], mean_temp[-1], use = "pairwise.complete.obs")
  )

write.csv(results, "./Results/TAutoCorr_summary.csv", row.names = FALSE)
cat("Autocorrelation results saved to ./Results/TAutoCorr_summary.csv\n")
