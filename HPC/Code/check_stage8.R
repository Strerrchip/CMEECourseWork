# Readiness check for Questions 5-6; analyse only a complete set of real tasks.
# Run locally: Rscript --vanilla Code/check_stage8.R
source("Code/lc2025_HPC_2025_main.R")
stopifnot(is.function(question_5), is.function(question_6))
files <- find_cluster_files("demographic")
ids <- as.integer(sub(".*_([0-9]+)\\.rda$", "\\1", basename(files)))
cat("Questions 5-6 functions loaded.\n")
cat("Demographic task files found:", length(files), "/ 100\n")
if (length(files) == 100 && !anyDuplicated(ids) && setequal(ids, 1:100)) {
  answer_5 <- question_5()
  answer_6 <- question_6()
  writeLines(answer_5, "Results/question_5_answer.txt")
  writeLines(answer_6, "Results/question_6_answer.txt")
  cat("Processed 15000 simulations across four initial conditions.\n")
  cat("Saved Results/question_5.png and Results/question_6.png, tables and English answers.\n")
} else {
  cat("Waiting for the complete set of real HPC results.\n")
  cat("No final graphs or numerical conclusions were created from incomplete data.\n")
}
cat("Stage 8 readiness check passed. This does not certify HPC job completion.\n")
