# Question 23 local check. Default duration is the worksheet's five-minute test.
# Optional quick diagnostic: Rscript --vanilla Code/check_stage5.R --quick
args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0 && !identical(args, "--quick")) {
  stop("Supported option: --quick. Omit it for the required five-minute local test.")
}
quick <- identical(args, "--quick")
minutes <- if (quick) 0.05 else 5
source("Code/lc2025_HPC_2025_main.R")
dir.create("Data", showWarnings = FALSE)
dir.create("Results", showWarnings = FALSE)
stamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
filename <- file.path("Data", paste0("question_23_local_", if (quick) "quick_" else "5min_", stamp, ".rda"))
cat("Question 23: local timed simulation.\n")
cat("Community size: 100; speciation probability: 0.1.\n")
cat("Richness interval: 1; octave interval: 10; burn-in: 200 generations.\n")
cat("Running for", minutes, "minutes. No progress output is expected until the run ends.\n")
flush.console()
set.seed(2025)
returned <- neutral_cluster_run(
  speciation_rate = 0.1, size = 100, wall_time = minutes,
  interval_rich = 1, interval_oct = 10, burn_in_generations = 200,
  output_file_name = filename
)
stopifnot(is.null(returned), file.exists(filename))
saved <- new.env()
load(filename, envir = saved)
required <- c("time_series", "abundance_list", "community", "total_time",
              "speciation_rate", "size", "wall_time", "interval_rich",
              "interval_oct", "burn_in_generations", "richness_generations",
              "abundance_generations", "generations_completed")
stopifnot(all(required %in% ls(saved)), saved$size == 100,
          saved$speciation_rate == 0.1, saved$wall_time == minutes,
          saved$interval_rich == 1, saved$interval_oct == 10,
          saved$burn_in_generations == 200, saved$total_time >= minutes,
          length(saved$community) == 100,
          length(saved$time_series) == length(saved$richness_generations),
          length(saved$abundance_list) == length(saved$abundance_generations))
expected_richness_times <- seq.int(0, min(200, saved$generations_completed), by = 1)
expected_octave_times <- seq_len(floor(saved$generations_completed / 10)) * 10
stopifnot(identical(as.numeric(saved$richness_generations), as.numeric(expected_richness_times)),
          identical(as.numeric(saved$abundance_generations), as.numeric(expected_octave_times)),
          saved$time_series[1] == 1, all(saved$time_series >= 1 & saved$time_series <= 100))
for (reading in saved$abundance_list) {
  lower <- 2^(seq_along(reading) - 1)
  upper <- 2^seq_along(reading) - 1
  stopifnot(all(reading >= 0), all(reading == floor(reading)),
            sum(reading * lower) <= 100, sum(reading * upper) >= 100)
}
post_burn <- sum(saved$abundance_generations > saved$burn_in_generations)
if (!quick && post_burn == 0) stop("No post-burn-in readings: inspect simulation speed.")
summary <- data.frame(test_type = if (quick) "quick diagnostic" else "five-minute local test",
                      requested_minutes = minutes, observed_minutes = saved$total_time,
                      generations_completed = saved$generations_completed,
                      n_richness_readings = length(saved$time_series),
                      n_octave_readings = length(saved$abundance_list),
                      n_post_burn_in_readings = post_burn, output_file = filename)
write.csv(summary, paste0("Results/question_23_check_", stamp, ".csv"), row.names = FALSE)
cat("Timed simulation checks passed.\n")
cat("Completed generations:", saved$generations_completed, "\n")
cat("Saved richness readings:", length(saved$time_series), "\n")
cat("Saved octave readings:", length(saved$abundance_list), "\n")
cat("Post-burn-in octave readings:", post_burn, "\n")
cat("Saved local data:", filename, "\n")
if (quick) {
  cat("Quick diagnostic only. The five-minute worksheet test is still required.\n")
} else {
  cat("Stage 5 five-minute local check passed. This is not a cluster run.\n")
}
