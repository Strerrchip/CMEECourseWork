# Check Question 24 parameters without running an 11.5-hour simulation.
# Run locally: Rscript --vanilla Code/check_stage6.R
old_index <- Sys.getenv("PBS_ARRAY_INDEX", unset = NA_character_)
old_validate <- Sys.getenv("HPC_VALIDATE_ONLY", unset = NA_character_)

run_checks <- function() {
  on.exit({
    if (is.na(old_index)) Sys.unsetenv("PBS_ARRAY_INDEX") else Sys.setenv(PBS_ARRAY_INDEX = old_index)
    if (is.na(old_validate)) Sys.unsetenv("HPC_VALIDATE_ONLY") else Sys.setenv(HPC_VALIDATE_ONLY = old_validate)
  })
  Sys.setenv(HPC_VALIDATE_ONLY = "true")
  source("Code/lc2025_HPC_2025_main.R", local = TRUE)
  before_data <- list.files("Data", full.names = TRUE)
  rows <- vector("list", 100)
  for (task in seq_len(100)) {
    Sys.setenv(PBS_ARRAY_INDEX = as.character(task))
    job <- new.env(parent = globalenv())
    invisible(capture.output(sys.source("Code/lc2025_HPC_2025_neutral_cluster.R", envir = job)))
    stopifnot(job$validation_only, job$iter == task,
              job$size == c(500, 1000, 2500, 5000)[ceiling(task / 25)],
              job$wall_time == 690, job$interval_rich == 1,
              job$interval_oct == job$size / 10,
              job$burn_in_generations == 8 * job$size,
              identical(job$speciation_rate, 0.0021811))
    seed_after_source <- .Random.seed
    set.seed(task)
    stopifnot(identical(seed_after_source, .Random.seed))
    rows[[task]] <- data.frame(iter = task, size = job$size,
                               speciation_rate = job$speciation_rate,
                               simulation_minutes = job$wall_time,
                               interval_rich = job$interval_rich,
                               interval_oct = job$interval_oct,
                               burn_in_generations = job$burn_in_generations,
                               output_file = job$output_file_name)
  }
  settings <- do.call(rbind, rows)
  stopifnot(all(table(settings$size) == 25), !anyDuplicated(settings$output_file),
            identical(before_data, list.files("Data", full.names = TRUE)))
  Sys.setenv(PBS_ARRAY_INDEX = "0")
  invalid <- try(invisible(capture.output(sys.source(
    "Code/lc2025_HPC_2025_neutral_cluster.R", envir = new.env()
  ))), silent = TRUE)
  stopifnot(inherits(invalid, "try-error"))
  dir.create("Results", showWarnings = FALSE)
  write.csv(settings, "Results/neutral_task_settings.csv", row.names = FALSE)
  cat("Question 24 parameter checks passed for all 100 tasks.\n")
  cat("Tasks per community size:\n")
  print(table(settings$size))
  cat("Simulation time: 690 minutes per task; requested cluster wall time: 12 hours.\n")
  cat("Saved Results/neutral_task_settings.csv.\n")
  cat("No long simulations were run and no cluster results were created.\n")
  cat("Stage 6 parameter check passed.\n")
}
run_checks()
