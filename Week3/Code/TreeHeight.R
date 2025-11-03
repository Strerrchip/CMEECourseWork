TreeHeight <- function(degrees, distance) {
  radians <- degrees * pi / 180
  distance * tan(radians)
}

# Read data from ../Data/trees.csv
trees <- read.csv("../Data/trees.csv")

trees$Tree.Height.m <- TreeHeight(trees$Angle.degrees, trees$Distance.m)

# Write output to ../Results/TreeHts.csv
write.csv(
  trees[, c("Species", "Distance.m", "Angle.degrees", "Tree.Height.m")],
  "../Results/TreeHts.csv",
  row.names = FALSE
)

cat("Tree heights calculated and saved to ../Results/TreeHts.csv\n")
system.time(source("Code/Vectorize2.R"))
