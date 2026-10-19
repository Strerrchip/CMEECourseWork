# Run from the coursework root: Rscript --vanilla Code/check_stage3.R
sentinel <- "Keep the caller's workspace intact"
set.seed(2025)
seed_before_source <- .Random.seed
output <- capture.output(source("Code/lc2025_HPC_2025_main.R"))
stopifnot(length(output) == 0, exists("sentinel"), identical(.Random.seed, seed_before_source))

# Question 15: check both probability endpoints and the example's allowed changes.
set.seed(15)
for (i in seq_len(200)) {
  original <- c(1, 1, 2)
  new <- neutral_step_speciation(original, 1)
  stopifnot(length(new) == 3, sum(new != original) == 1, sum(new == 3) == 1)
  no_speciation <- neutral_step_speciation(original, 0)
  stopifnot(length(no_speciation) == 3, all(no_speciation %in% original))
  stopifnot(identical(neutral_step_speciation(c(7, 7, 7), 0), c(7, 7, 7)))
}
stopifnot(identical(neutral_step_speciation(7, 1), 8))
# Starting with two identical species labels makes a new label unambiguous.
set.seed(1515)
new_species_events <- replicate(10000, any(neutral_step_speciation(c(1, 1), 0.1) == 2))
observed_fraction <- mean(new_species_events)
stopifnot(abs(observed_fraction - 0.1) < 0.015)
invalid <- try(neutral_step_speciation(c(1, 1), 1.2), silent = TRUE)
stopifnot(inherits(invalid, "try-error"))
cat("Question 15 passed: replacement rules and speciation frequency.\n")

# Question 16: count calls made by the actual generation function.
test_environment <- new.env(parent = globalenv())
invisible(capture.output(sys.source("Code/lc2025_HPC_2025_main.R", envir = test_environment)))
test_environment$calls <- 0L
test_environment$neutral_step_speciation <- function(community, speciation_rate) {
  test_environment$calls <- test_environment$calls + 1L
  return(community)
}
invisible(test_environment$neutral_generation_speciation(rep(1, 10), 0.1))
stopifnot(test_environment$calls == 5)
set.seed(16)
counts <- replicate(2000, {
  test_environment$calls <- 0L
  invisible(test_environment$neutral_generation_speciation(rep(1, 7), 0.1))
  test_environment$calls
})
stopifnot(all(counts %in% c(3, 4)), abs(mean(counts) - 3.5) < 0.06)
set.seed(160)
community <- init_community_min(100)
for (i in seq_len(100)) {
  community <- neutral_generation_speciation(community, 0.1)
  stopifnot(length(community) == 100, species_richness(community) >= 1,
            species_richness(community) <= 100)
}
cat("Question 16 passed: generation length and fixed community size.\n")

# Question 17: initial value, duration, zero-duration behaviour and reproducibility.
set.seed(17)
series <- neutral_time_series_speciation(init_community_max(7), 0.1, 20)
stopifnot(length(series) == 21, series[1] == 7, all(series >= 1 & series <= 7),
          identical(neutral_time_series_speciation(init_community_min(7), 0.1, 0), 1),
          all(neutral_time_series_speciation(init_community_min(7), 0, 30) == 1))
set.seed(17)
stopifnot(identical(series, neutral_time_series_speciation(init_community_max(7), 0.1, 20)))
cat("Question 17 passed: time-series format and reproducibility.\n")

# Question 18: save the required figure and its answer; do not assert identical paths.
set.seed(2025)
answer <- question_18()
writeLines(answer, "Results/question_18_answer.txt")
stopifnot(file.exists("Results/question_18.png"))
cat("Question 18 saved: Results/question_18.png and Results/question_18_answer.txt.\n")
cat("Stage 3 checks passed.\n")
