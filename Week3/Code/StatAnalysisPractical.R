# Code/StatAnalysisPractical.R
setwd("~/Documents/CMEECourseWork/Week3")

trees <- read.csv("./Data/trees.csv", check.names = TRUE)

# create Tree.Height.m
if (!"Tree.Height.m" %in% names(trees) && all(c("Distance.m", "Angle.degrees") %in% names(trees))) {
  trees$Tree.Height.m <- trees$Distance.m * tan(trees$Angle.degrees * pi / 180)
}

# statistical results directory
summary_stats <- data.frame(
  Mean = mean(trees$Tree.Height.m, na.rm = TRUE),
  SD   = sd(trees$Tree.Height.m, na.rm = TRUE),
  Min  = min(trees$Tree.Height.m, na.rm = TRUE),
  Max  = max(trees$Tree.Height.m, na.rm = TRUE)
)

# relevant correlation
correlation <- cor(trees$Distance.m, trees$Tree.Height.m, use = "complete.obs")

# regression model
lm_model <- lm(Tree.Height.m ~ Distance.m, data = trees)
lm_summary <- summary(lm_model)

# t-test
t_test <- t.test(trees$Tree.Height.m, mu = 10)

# save results
sink("./Results/Statistical_Results.txt")
cat(" Basic Summary Statistics:\n")
print(summary_stats)
cat("\n Correlation (Distance vs Height):", correlation, "\n\n")
cat(" Linear Model Summary:\n")
print(lm_summary)
cat("\n One-sample t-test (mu = 10):\n")
print(t_test)
sink()

cat("All statistical results saved to ./Results/Statistical_Results.txt\n")

# plot regression
pdf("./Results/RegressionPlot.pdf", width = 6, height = 4)
plot(trees$Distance.m, trees$Tree.Height.m,
     main = "Regression: Height vs Distance",
     xlab = "Distance (m)", ylab = "Height (m)",
     pch = 19, col = "darkgreen")
abline(lm_model, col = "red", lwd = 2)
dev.off()
