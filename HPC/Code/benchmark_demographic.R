# Measure the required 120-step simulations before choosing a PBS wall time.
# This is local preparation, not evidence of completed cluster jobs.
source("Code/lc2025_HPC_2025_main.R")
source("Code/Demographic.R")
parameters <- demographic_parameters()
initial_states <- list(
  state_initialise_adult(4, 100), state_initialise_adult(4, 10),
  state_initialise_spread(4, 100), state_initialise_spread(4, 10)
)
labels <- c("Large adult", "Small adult", "Large mixed", "Small mixed")
rows <- vector("list", 4)
for (i in seq_along(initial_states)) {
  elapsed <- numeric(3)
  for (repeat_number in seq_len(3)) {
    set.seed(1000 * i + repeat_number)
    elapsed[repeat_number] <- system.time({
      result <- stochastic_simulation(
        initial_states[[i]], parameters$growth_matrix, parameters$reproduction_matrix,
        parameters$clutch_distribution, 120
      )
    })[["elapsed"]]
    stopifnot(length(result) == 121, all(result >= 0))
  }
  rows[[i]] <- data.frame(initial_condition = labels[i],
                          median_seconds = median(elapsed),
                          maximum_seconds = max(elapsed))
  cat("Completed timing:", labels[i], "\n")
}
timing <- do.call(rbind, rows)
dir.create("Results", showWarnings = FALSE)
write.csv(timing, "Results/demographic_timing.csv", row.names = FALSE)
print(timing, row.names = FALSE)
cat("\nMultiply per-simulation timing by 150, then allow a margin.\n")
cat("Cluster speed and random population growth can change the required time.\n")
