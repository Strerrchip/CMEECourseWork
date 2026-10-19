# Run from the coursework root: Rscript --vanilla Code/check_stage4.R
sentinel <- "Keep the caller's workspace intact"
output <- capture.output(source("Code/lc2025_HPC_2025_main.R"))
stopifnot(length(output) == 0, exists("sentinel"))

# Question 19: worksheet example, fixed total and number of occupied species.
example_community <- c(1, 5, 3, 6, 5, 6, 1, 1)
abundance_vector <- species_abundance(example_community)
stopifnot(identical(abundance_vector, c(3, 2, 2, 1)),
          sum(abundance_vector) == length(example_community),
          length(abundance_vector) == species_richness(example_community))
cat("Question 19 passed: sorted species abundances.\n")

# Question 20: all octave boundaries, including singleton and monodominant cases.
boundary_abundances <- c(1, 2, 3, 4, 7, 8, 15, 16, 31, 32, 63, 64, 100)
boundary_octaves <- octaves(boundary_abundances)
stopifnot(identical(boundary_octaves, c(1L, 2L, 2L, 2L, 2L, 2L, 2L)),
          identical(octaves(rep(1, 100)), 100L),
          identical(octaves(100), c(0L, 0L, 0L, 0L, 0L, 0L, 1L)),
          sum(boundary_octaves) == length(boundary_abundances))
dir.create("Data", showWarnings = FALSE)
save(example_community, abundance_vector, boundary_abundances, boundary_octaves,
     file = "Data/question_20.rda")
cat("Question 20 passed: octave boundaries. Saved Data/question_20.rda.\n")

# Question 21: avoid R's vector recycling when lengths differ.
stopifnot(identical(sum_vect(c(1, 3), c(1, 0, 5, 2)), c(2, 3, 5, 2)),
          identical(sum_vect(c(1, 0, 5, 2), c(1, 3)), c(2, 3, 5, 2)),
          identical(sum_vect(numeric(0), c(2, 3)), c(2, 3)))
stopifnot(identical(mean_octave_vectors(list(c(2, 4), c(4, 2, 6))), c(3, 3, 3)))
cat("Question 21 passed: zero-padded vector addition and averaging.\n")

# Verify sampling times with an instrumented generation function.
test_environment <- new.env(parent = globalenv())
invisible(capture.output(sys.source("Code/lc2025_HPC_2025_main.R", envir = test_environment)))
test_environment$calls <- 0L
test_environment$neutral_generation_speciation <- function(community, speciation_rate) {
  test_environment$calls <- test_environment$calls + 1L
  return(community)
}
readings <- test_environment$collect_neutral_octaves(rep(1, 100), 0.1, 200, 2000, 20)
stopifnot(test_environment$calls == 2200, length(readings) == 101,
          all(vapply(readings, function(x) identical(x, c(0L, 0L, 0L, 0L, 0L, 0L, 1L)), logical(1))))
cat("Question 22 sampling passed: 2200 generations and 101 readings per trajectory.\n")

set.seed(2025)
answer <- question_22()
writeLines(answer, "Results/question_22_answer.txt")
saved <- new.env()
load("Data/question_22.rda", envir = saved)
stopifnot(length(saved$abundance_list_max) == 101, length(saved$abundance_list_min) == 101,
          identical(saved$sampling_generations, seq.int(200, 2200, 20)),
          saved$size == 100, saved$speciation_rate == 0.1)
for (readings in list(saved$abundance_list_max, saved$abundance_list_min)) {
  for (reading in readings) {
    lower <- 2^(seq_along(reading) - 1)
    upper <- 2^seq_along(reading) - 1
    stopifnot(all(reading >= 0), sum(reading) >= 1, sum(reading) <= 100,
              sum(reading * lower) <= 100, sum(reading * upper) >= 100)
  }
}
stopifnot(isTRUE(all.equal(saved$mean_octaves_max,
                          sum_vect(mean_octave_vectors(saved$abundance_list_max), numeric(7)))),
          isTRUE(all.equal(saved$mean_octaves_min,
                          sum_vect(mean_octave_vectors(saved$abundance_list_min), numeric(7)))),
          file.exists("Results/question_22.png"))
cat("Question 22 saved: Data/question_22.rda, Results/question_22.png and English answer.\n")
cat("Stage 4 checks passed.\n")
