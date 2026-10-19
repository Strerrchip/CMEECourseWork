# Question 24: execute one of 100 neutral-model array tasks.
rm(list = ls())
graphics.off()
source("Code/lc2025_HPC_2025_main.R", local = TRUE)

iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))
if (length(iter) != 1 || is.na(iter) || iter != floor(iter) || iter < 1 || iter > 100) {
  stop("PBS_ARRAY_INDEX must be an integer from 1 to 100.")
}
set.seed(iter)

rate_file <- "Data/personal_speciation_rate.rda"
if (!file.exists(rate_file)) stop("Generate Data/personal_speciation_rate.rda first.")
personal <- new.env()
load(rate_file, envir = personal)
if (!identical(personal$username, username) || !identical(personal$year_of_course, 2025)) {
  stop("Personal rate identity or course year does not match this coursework.")
}
speciation_rate <- personal$personal_speciation_rate
if (length(speciation_rate) != 1 || !is.finite(speciation_rate) ||
    speciation_rate < 0.002 || speciation_rate > 0.007) {
  stop("Invalid personal rate. Regenerate it using the supplied course method.")
}

# Each consecutive block of 25 tasks uses one community size.
size <- c(500, 1000, 2500, 5000)[ceiling(iter / 25)]
wall_time <- 11.5 * 60
interval_rich <- 1
interval_oct <- size / 10
burn_in_generations <- 8 * size
output_file_name <- file.path("Data", paste0(username, "_neutral_", iter, ".rda"))

cat("Array task:", iter, "\n")
cat("Community size:", size, "\n")
cat("Personal speciation rate:", format(speciation_rate, digits = 5), "\n")
cat("Simulation minutes:", wall_time, "\n")
cat("Burn-in generations:", burn_in_generations, "\n")
cat("Richness interval:", interval_rich, "Octave interval:", interval_oct, "\n")
cat("Output:", output_file_name, "\n")
flush.console()

# This flag is only for checking parameter allocation locally without a simulation.
# The submission shell script removes it before starting real cluster jobs.
validation_only <- identical(Sys.getenv("HPC_VALIDATE_ONLY"), "true")
if (validation_only) {
  cat("Validation only: no simulation was run and no simulation data were saved.\n")
} else {
  neutral_cluster_run(speciation_rate, size, wall_time, interval_rich,
                      interval_oct, burn_in_generations, output_file_name)
  # Add task metadata without overwriting the saved final community or readings.
  saved <- new.env()
  load(output_file_name, envir = saved)
  saved$iter <- iter
  saved$username <- username
  saved$year_of_course <- 2025
  save(list = ls(saved), envir = saved, file = output_file_name)
  cat("Completed and saved array task:", iter, "\n")
}
