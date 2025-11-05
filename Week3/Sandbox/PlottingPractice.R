# Sandbox/PlottingPractice.R 

trees <- read.csv("./Data/trees.csv", check.names = TRUE)
nms <- names(trees)

normalize_course_computed <- function(df) {
  df$Tree.Height.m <- as.numeric(df$Tree.Height.m)
  df$Distance.m    <- as.numeric(df$Distance.m)
  if (!"Species" %in% names(df)) df$Species <- "Unknown"
  df
}

normalize_course_raw <- function(df) {
  # first convert to numeric
  df$Distance.m    <- as.numeric(df$Distance.m)
  df$Angle.degrees <- as.numeric(df$Angle.degrees)
  # calculate tree height
  df$Tree.Height.m <- df$Distance.m * tan(df$Angle.degrees * pi / 180)
  df
}

normalize_base_trees <- function(df) {
  df$Tree.Height.m <- as.numeric(df$Height)  # Use Height as Tree Height
  df$Distance.m    <- as.numeric(df$Girth)   # Use Girth as Distance
  df$Species       <- "Unknown"
  df
}

if (all(c("Tree.Height.m","Distance.m") %in% nms)) {
  trees <- normalize_course_computed(trees)
} else if (all(c("Species","Distance.m","Angle.degrees") %in% nms)) {
  trees <- normalize_course_raw(trees)
} else if (all(c("Girth","Height","Volume") %in% nms)) {
  trees <- normalize_base_trees(trees)
} else {
  stop("Unrecognized columns in ./Data/trees.csv: ",
       paste(nms, collapse=", "),
       "\n期望之一：{Tree.Height.m, Distance.m, (Species)}",
       " 或 {Species, Distance.m, Angle.degrees}",
       " 或 {Girth, Height, Volume}")
}

# Plotting
plot(trees$Distance.m, trees$Tree.Height.m,
     main = "Tree Height vs Distance",
     xlab = "Distance (m)", ylab = "Tree Height (m)",
     pch = 19, col = "blue")

hist(trees$Tree.Height.m,
     main = "Distribution of Tree Heights",
     xlab  = "Height (m)",
     col = "lightgreen", border = "white")

boxplot(trees$Tree.Height.m ~ trees$Species,
        main = "Tree Height by Species",
        xlab = "Species", ylab = "Height (m)",
        col = c("orange","skyblue","pink"))


# png("./Results/tree_height_hist.png", 600, 400); hist(trees$Tree.Height.m, main="Distribution of Tree Heights", xlab="Height (m)"); dev.off()
# pdf("./Results/tree_scatter.pdf", 6, 4); plot(trees$Distance.m, trees$Tree.Height.m, main="Tree Height vs Distance", xlab="Distance (m)", ylab="Height (m)", pch=19, col="blue"); dev.off()
