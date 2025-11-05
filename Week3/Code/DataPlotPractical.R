# Code/DataPlotPractical.R
setwd("~/Documents/CMEECourseWork/Week3")

# read data 
trees <- read.csv("./Data/trees.csv", check.names = TRUE)

# check columns and create Tree.Height.m if missing 
if (!"Tree.Height.m" %in% names(trees)) {
  if (all(c("Distance.m", "Angle.degrees") %in% names(trees))) {
    trees$Tree.Height.m <- trees$Distance.m * tan(trees$Angle.degrees * pi / 180)
    cat("Calculated Tree.Height.m from Distance.m and Angle.degrees\n")
  } else if (all(c("Height", "Girth") %in% names(trees))) {
    trees$Tree.Height.m <- as.numeric(trees$Height)
    trees$Distance.m <- as.numeric(trees$Girth)
    trees$Species <- "Unknown"
    cat("Using base R dataset structure (Height, Girth)\n")
  } else {
    stop(" Cannot determine how to compute Tree.Height.m — unknown columns in trees.csv")
  }
}

# ensure numeric types 
trees$Tree.Height.m <- as.numeric(trees$Tree.Height.m)
trees$Distance.m <- as.numeric(trees$Distance.m)
if (!"Species" %in% names(trees)) trees$Species <- "Unknown"

# create multiple plot output files 
pdf("./Results/TreePlots.pdf", width = 7, height = 5)

# scatter plot: height vs distance
plot(trees$Distance.m, trees$Tree.Height.m,
     main = "Tree Height vs Distance",
     xlab = "Distance (m)", ylab = "Height (m)",
     col = "darkgreen", pch = 16)

# box plot: tree height by species 
boxplot(trees$Tree.Height.m ~ trees$Species,
        main = "Tree Height by Species",
        xlab = "Species", ylab = "Height (m)",
        col = c("orange", "skyblue", "lightpink"))

#  histogram: height distribution 
hist(trees$Tree.Height.m,
     main = "Distribution of Tree Heights",
     xlab = "Height (m)",
     col = "lightgreen", border = "white")

dev.off()

cat("TreePlots.pdf created successfully in ./Results\n")
