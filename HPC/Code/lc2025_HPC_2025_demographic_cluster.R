# Questions 3-4: run one of 100 demographic array tasks.
rm(list = ls())
graphics.off()
source("Code/lc2025_HPC_2025_main.R")
source("Code/Demographic.R")

iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))
if (length(iter) != 1 || is.na(iter) || iter != floor(iter) || iter < 1 || iter > 100) {
  stop("PBS_ARRAY_INDEX must be an integer from 1 to 100.")
}
set.seed(iter)

# Allocate exactly 25 tasks to each initial condition.
initial_condition <- ceiling(iter / 25)
initial_size <- c(100, 10, 100, 10)[initial_condition]
if (initial_condition <= 2) {
  initial_state <- state_initialise_adult(4, initial_size)
} else {
  initial_state <- state_initialise_spread(4, initial_size)
}
parameters <- demographic_parameters()
simulation_length <- 120
n_simulations <- 150
dir.create("Data", showWarnings = FALSE)
output_file_name <- file.path("Data", paste0("lc2025_demographic_", iter, ".rda"))
if (file.exists(output_file_name)) {
  stop("Output already exists. Preserve the previous file before rerunning this task.")
}

results_list <- vector("list", n_simulations)
for (simulation in seq_len(n_simulations)) {
  results_list[[simulation]] <- stochastic_simulation(
    initial_state, parameters$growth_matrix, parameters$reproduction_matrix,
    parameters$clutch_distribution, simulation_length
  )
}
save(results_list, iter, initial_condition, initial_state, simulation_length,
     n_simulations, parameters, file = output_file_name)
cat("Array task:", iter, "Initial condition:", initial_condition, "\n")
cat("Saved", n_simulations, "simulations to", output_file_name, "\n")
