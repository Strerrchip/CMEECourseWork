# Code/RunVectorize2.R
# run this to time the two versions in Vectorize2.R
source("Vectorize2.R")   

loop_version <- function() {
  x <- numeric(1e5)
  for (i in 2:length(x)) x[i] <- x[i-1] + sin(i*0.001)
  x
}

vectorized_version <- function() {
  i <- 1:1e5
  c(0, cumsum(sin(i[-1]*0.001)))
}

t_loop <- system.time({ res1 <- loop_version() })
t_vec  <- system.time({ res2 <- vectorized_version() })

sink("../Results/vectorize_timing.txt")
cat("Loop elapsed: ", t_loop["elapsed"], "\n", sep = "")
cat("Vectorized elapsed: ", t_vec["elapsed"], "\n", sep = "")
cat("First 1000 equal? ", isTRUE(all.equal(res1[1:1000], res2[1:1000])), "\n", sep = "")
sink()

cat(" Timing written to ../Results/vectorize_timing.txt\n")
