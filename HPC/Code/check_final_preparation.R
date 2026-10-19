# Check required function signatures and submission-script format, without long runs.
# Run from the coursework root: Rscript --vanilla Code/check_final_preparation.R
required_signatures <- list(
  state_initialise_adult = c("num_stages", "initial_size"),
  state_initialise_spread = c("num_stages", "initial_size"),
  question_1 = character(0), question_2 = character(0),
  question_5 = character(0), question_6 = character(0),
  species_richness = "community", init_community_max = "size",
  init_community_min = "size", choose_two = "max_value",
  neutral_step = "community", neutral_generation = "community",
  neutral_time_series = c("community", "duration"), question_14 = character(0),
  neutral_step_speciation = c("community", "speciation_rate"),
  neutral_generation_speciation = c("community", "speciation_rate"),
  neutral_time_series_speciation = c("community", "speciation_rate", "duration"),
  question_18 = character(0), species_abundance = "community",
  octaves = "abundance_vector", sum_vect = c("x", "y"),
  question_22 = character(0),
  neutral_cluster_run = c("speciation_rate", "size", "wall_time", "interval_rich",
                          "interval_oct", "burn_in_generations", "output_file_name"),
  process_neutral_cluster_results = character(0),
  plot_neutral_cluster_results = character(0)
)
sentinel <- "The main file must not clear the caller's workspace"
set.seed(2025)
previous_seed <- .Random.seed
previous_wd <- getwd()
previous_devices <- dev.list()
files_before <- list.files(c("Data", "Results"), recursive = TRUE, full.names = TRUE)
started <- proc.time()[["elapsed"]]
output <- capture.output(source("Code/lc2025_HPC_2025_main.R"))
source_seconds <- proc.time()[["elapsed"]] - started
stopifnot(exists("sentinel"), identical(previous_seed, .Random.seed),
          identical(previous_wd, getwd()), identical(previous_devices, dev.list()),
          length(output) == 0,
          identical(files_before, list.files(c("Data", "Results"), recursive = TRUE, full.names = TRUE)))
for (function_name in names(required_signatures)) {
  stopifnot(exists(function_name, mode = "function"))
  actual <- names(formals(get(function_name)))
  if (is.null(actual)) actual <- character(0)
  if (!identical(actual, required_signatures[[function_name]])) {
    stop(paste("Function parameters do not match the pro forma:", function_name))
  }
}
required_files <- c("Code/Demographic.R", "Code/lc2025_HPC_2025_main.R",
                    "Code/lc2025_HPC_2025_demographic_cluster.R",
                    "Code/lc2025_HPC_2025_neutral_cluster.R",
                    "Code/run_demographic.sh", "Code/run_neutral.sh",
                    "Data/personal_speciation_rate.rda")
stopifnot(all(file.exists(required_files)), all(dir.exists(c("Code", "Data", "Results", "Log"))))
for (script in c("Code/run_demographic.sh", "Code/run_neutral.sh")) {
  bytes <- readBin(script, what = "raw", n = file.info(script)$size)
  if (any(bytes == as.raw(13))) stop(paste("Shell script contains Windows line endings:", script))
  if (!identical(bytes[1:2], charToRaw("#!"))) stop(paste("Missing shell shebang or unexpected BOM:", script))
}
for (script in c("Code/lc2025_HPC_2025_demographic_cluster.R", "Code/lc2025_HPC_2025_neutral_cluster.R")) {
  invisible(parse(file = script))
}
personal <- new.env()
load("Data/personal_speciation_rate.rda", envir = personal)
stopifnot(identical(personal$username, username), personal$year_of_course == 2025,
          identical(personal$personal_speciation_rate, 0.0021811))
dir.create("Results", showWarnings = FALSE)
report <- c(
  "HPC coursework preparation check",
  paste("Required function signatures passed:", length(required_signatures)),
  paste("Main file source time (seconds):", round(source_seconds, 4)),
  "Main file: no printed output, simulation output, graphics, RNG or directory changes when sourced.",
  "Required R and shell files are present; R syntax and shell line endings passed.",
  "Personal rate identity, course year and value passed.",
  paste("Name field completed:", nzchar(name)),
  paste("Preferred name field completed:", nzchar(preferred_name)),
  paste("Demographic task files:", length(find_cluster_files("demographic")), "/ 100"),
  paste("Neutral task files:", length(find_cluster_files("neutral")), "/ 100"),
  "This checks local preparation, not HPC execution or scheduler compatibility.",
  "Actual R availability, job logs and complete simulation outputs must still be checked on HPC."
)
writeLines(report, "Results/preparation_check.txt")
cat(paste(report, collapse = "\n"), "\n")
cat("Final preparation check passed. This is not a complete-submission check.\n")
