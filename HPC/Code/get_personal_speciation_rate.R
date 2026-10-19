# Generate the personal rate using the supplied Get_my_speciation_rate.R method.
# Course year is 2025, even though the coursework is being completed in 2026.
# Run from the coursework root: Rscript --vanilla Code/get_personal_speciation_rate.R
# digest is used only by this supplied rate-generation method, not by the models.

username <- "lc2025"
year_of_course <- 2025

if (!requireNamespace("digest", quietly = TRUE)) {
  stop("The supplied rate generator requires digest. Install it locally, then rerun this file.")
}

# Same algorithm and defaults as the teacher's supplied generator.
get_my_seed <- function(username, year, min = 0.002, max = 0.007, sigfig = 5) {
  seed_from_hash <- digest::digest2int(paste(username, year))
  set.seed(seed_from_hash)
  speciation_rate <- signif(runif(1) * (max - min) + min, sigfig)
  return(speciation_rate)
}

personal_speciation_rate <- get_my_seed(username, year_of_course)
stopifnot(is.finite(personal_speciation_rate),
          personal_speciation_rate >= 0.002, personal_speciation_rate <= 0.007)
R_version <- as.character(getRversion())
digest_version <- as.character(utils::packageVersion("digest"))
dir.create("Data", showWarnings = FALSE)
output_file <- "Data/personal_speciation_rate.rda"
if (file.exists(output_file)) {
  previous <- new.env()
  load(output_file, envir = previous)
  if (!identical(previous$username, username) ||
      !identical(previous$year_of_course, year_of_course) ||
      !identical(previous$personal_speciation_rate, personal_speciation_rate)) {
    stop("An existing personal rate differs. Check the identity and course year before replacing it.")
  }
}
save(username, year_of_course, personal_speciation_rate, R_version, digest_version,
     file = output_file)
cat("School username:", username, "\n")
cat("Course year:", year_of_course, "\n")
cat("Personal speciation rate:", format(personal_speciation_rate, digits = 5), "\n")
cat("Saved:", output_file, "\n")
cat("Use this rate for Question 24. Keep 0.1 for Questions 18, 22 and the Question 23 local test.\n")
