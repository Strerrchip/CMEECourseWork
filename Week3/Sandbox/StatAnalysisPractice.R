# Sandbox/StatAnalysisPractice.R
# Basic Statistics in R 

trees <- read.csv("./Data/trees.csv", check.names = TRUE)

# If Tree.Height.m is not present, calculate it from Distance.m and Angle.degrees
if (!"Tree.Height.m" %in% names(trees) && all(c("Distance.m", "Angle.degrees") %in% names(trees))) {
  trees$Tree.Height.m <- trees$Distance.m * tan(trees$Angle.degrees * pi / 180)
}

# Check data structure
str(trees)
summary(trees)

# calculate basic statistics for Tree.Height.m
mean_height <- mean(trees$Tree.Height.m, na.rm = TRUE)
sd_height   <- sd(trees$Tree.Height.m, na.rm = TRUE)
min_height  <- min(trees$Tree.Height.m, na.rm = TRUE)
max_height  <- max(trees$Tree.Height.m, na.rm = TRUE)

cat("Mean height:", mean_height, "\n")
cat("SD height:", sd_height, "\n")
cat("Range:", min_height, "-", max_height, "\n")

# calculate correlation between Distance.m and Tree.Height.m
if ("Distance.m" %in% names(trees)) {
  corr <- cor(trees$Distance.m, trees$Tree.Height.m, use = "complete.obs")
  cat("Correlation (Distance vs Height):", corr, "\n")
}

# simple linear regression
model <- lm(Tree.Height.m ~ Distance.m, data = trees)
cat("\n📈 Linear model summary:\n")
print(summary(model))

# visualization
plot(trees$Distance.m, trees$Tree.Height.m,
     main = "Tree Height vs Distance with Regression Line",
     xlab = "Distance (m)", ylab = "Height (m)",
     pch = 19, col = "skyblue")
abline(model, col = "red", lwd = 2)
