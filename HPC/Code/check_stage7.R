# Readiness check only. Do not invent substitute results for missing cluster runs.
# Run from the coursework root: Rscript --vanilla Code/check_stage7.R
source("Code/lc2025_HPC_2025_main.R")
stopifnot(is.function(process_neutral_cluster_results),
          is.function(plot_neutral_cluster_results))
files <- find_cluster_files("neutral")
task_ids <- as.integer(sub(".*_([0-9]+)\\.rda$", "\\1", basename(files)))
cat("Question 26 functions loaded.\n")
cat("Neutral task files found:", length(files), "/ 100\n")
if (length(files) == 100 && !anyDuplicated(task_ids) && setequal(task_ids, 1:100)) {
  combined <- process_neutral_cluster_results()
  plotted <- plot_neutral_cluster_results()
  stopifnot(identical(combined, plotted))
  cat("Processed all 100 task files and saved the four-panel graph.\n")
  cat("Saved Data/neutral_cluster_summary.rda.\n")
  cat("Saved Results/plot_neutral_cluster_results.png.\n")
} else {
  cat("Waiting for the complete set of real HPC results.\n")
  cat("No averages or final graphs were created from incomplete data.\n")
}
cat("Stage 7 readiness check passed. This does not certify HPC job completion.\n")
