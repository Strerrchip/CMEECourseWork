# Run from the coursework root: Rscript --vanilla Code/check_stage2.R
# Tests and simulations belong here, not at the top level of the main file.
sentinel <- "Keep the caller's workspace intact"
set.seed(2025)
seed_before_source <- .Random.seed
output <- capture.output(source("Code/lc2025_HPC_2025_main.R"))
stopifnot(length(output) == 0, exists("sentinel"),
          identical(.Random.seed, seed_before_source))

# Questions 7-9: examples and initial community sizes.
stopifnot(species_richness(c(1, 4, 4, 5, 1, 6, 1)) == 4)
for (size in c(1, 2, 7, 100)) {
  stopifnot(length(init_community_min(size)) == size,
            species_richness(init_community_min(size)) == 1,
            length(init_community_max(size)) == size,
            species_richness(init_community_max(size)) == size)
}
cat("Questions 7-9 passed: richness and initial communities.\n")

# Question 10: distinct indices and approximate ordered-pair frequencies.
set.seed(10)
pairs <- replicate(12000, choose_two(4))
stopifnot(all(pairs >= 1 & pairs <= 4), all(pairs[1, ] != pairs[2, ]))
frequencies <- table(paste(pairs[1, ], pairs[2, ], sep = ":"))
stopifnot(length(frequencies) == 12, all(abs(as.numeric(frequencies) - 1000) < 150))
cat("Question 10 passed: distinct, approximately uniform ordered pairs.\n")

# Question 11: fixed size, no new labels, and an absorbing one-species state.
community <- init_community_max(25)
set.seed(11)
for (i in seq_len(500)) {
  updated <- neutral_step(community)
  stopifnot(length(updated) == length(community), all(updated %in% community),
            species_richness(updated) <= species_richness(community))
  community <- updated
}
for (i in seq_len(50)) {
  stopifnot(identical(neutral_step(c(7, 7, 7)), c(7, 7, 7)),
            species_richness(neutral_step(c(1, 2))) == 1)
}
cat("Question 11 passed: replacement rules and monodominance.\n")

# Question 12: instrument the actual generation function to count replacements.
test_environment <- new.env(parent = globalenv())
invisible(capture.output(sys.source("Code/lc2025_HPC_2025_main.R", envir = test_environment)))
test_environment$calls <- 0L
test_environment$neutral_step <- function(community) {
  test_environment$calls <- test_environment$calls + 1L
  return(community)
}
invisible(test_environment$neutral_generation(rep(1, 10)))
stopifnot(test_environment$calls == 5)
set.seed(12)
counts <- replicate(2000, {
  test_environment$calls <- 0L
  invisible(test_environment$neutral_generation(rep(1, 7)))
  test_environment$calls
})
stopifnot(all(counts %in% c(3, 4)), abs(mean(counts) - 3.5) < 0.06)
cat("Question 12 passed: half-size generations and unbiased odd-size rounding.\n")

# Question 13: include generation zero; do not create species or lose individuals.
set.seed(13)
series <- neutral_time_series(init_community_max(7), 20)
stopifnot(length(series) == 21, series[1] == 7, all(diff(series) <= 0), all(series >= 1))
stopifnot(identical(neutral_time_series(init_community_max(7), 0), 7),
          all(neutral_time_series(init_community_min(10), 50) == 1))
set.seed(13)
stopifnot(identical(series, neutral_time_series(init_community_max(7), 20)))
cat("Question 13 passed: time-series length, initial value and reproducibility.\n")

# Question 14: produce the required figure with a reproducible caller-controlled seed.
set.seed(2025)
answer <- question_14()
writeLines(answer, "Results/question_14_answer.txt")
stopifnot(file.exists("Results/question_14.png"))
cat("Question 14 saved: Results/question_14.png and Results/question_14_answer.txt.\n")
cat("Stage 2 checks passed.\n")
