# HPC coursework, course year 2025. All non-challenge functions are defined.
# The candidate username must be confirmed before final submission.
name <- "Leyu Chen"
preferred_name <- "Avery"
email <- "leyu.chen25@imperial.ac.uk"
username <- "lc2025"

# Source this file as a toolbox. Do not clear the workspace or run simulations.

state_initialise_adult <- function(num_stages, initial_size) {
  state <- rep(0, num_stages)
  state[num_stages] <- initial_size
  return(state)
}

state_initialise_spread <- function(num_stages, initial_size) {
  state <- rep(floor(initial_size / num_stages), num_stages)
  remainder <- initial_size %% num_stages
  if (remainder > 0) {
    state[seq_len(remainder)] <- state[seq_len(remainder)] + 1
  }
  return(state)
}

# Question 21 helper, needed early because the provided demographic code uses it.
sum_vect <- function(x, y) {
  result <- numeric(max(length(x), length(y)))
  if (length(x) > 0) result[seq_along(x)] <- x
  if (length(y) > 0) result[seq_along(y)] <- result[seq_along(y)] + y
  return(result)
}

demographic_parameters <- function() {
  growth_matrix <- matrix(c(
    0.1, 0.0, 0.0, 0.0,
    0.5, 0.4, 0.0, 0.0,
    0.0, 0.4, 0.7, 0.0,
    0.0, 0.0, 0.25, 0.4
  ), nrow = 4, byrow = TRUE)
  reproduction_matrix <- matrix(c(
    0.0, 0.0, 0.0, 2.6,
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0
  ), nrow = 4, byrow = TRUE)
  return(list(
    growth_matrix = growth_matrix,
    reproduction_matrix = reproduction_matrix,
    projection_matrix = growth_matrix + reproduction_matrix,
    clutch_distribution = c(0.06, 0.08, 0.13, 0.15, 0.16, 0.18, 0.15, 0.06, 0.03)
  ))
}

plot_demographic_pair <- function(adult, spread, filename, title) {
  dir.create("Results", showWarnings = FALSE)
  png(file.path("Results", filename), width = 1600, height = 1100, res = 180)
  on.exit(dev.off())
  par(mar = c(4.5, 5, 3, 1))
  matplot(seq.int(0, length(adult) - 1), cbind(adult, spread),
          type = "l", lty = 1, lwd = 2, col = c("#3366AA", "#D97706"),
          xlab = "Time (months)", ylab = "Total population size", main = title)
  legend("topleft", c("100 adults", "100 individuals spread across stages"),
         col = c("#3366AA", "#D97706"), lty = 1, lwd = 2, bty = "n", cex = 0.8)
}

question_1 <- function() {
  source("Code/Demographic.R", local = TRUE)
  parameters <- demographic_parameters()
  adult <- deterministic_simulation(
    state_initialise_adult(4, 100), parameters$projection_matrix, 24
  )
  spread <- deterministic_simulation(
    state_initialise_spread(4, 100), parameters$projection_matrix, 24
  )
  plot_demographic_pair(adult, spread, "question_1.png", "Deterministic population trajectories")
  return(paste(
    "The adult population increases more rapidly at first because all initial individuals can reproduce.",
    "The spread population has fewer adults, and its younger stages must mature before reproducing.",
    "Both trajectories eventually approach the same proportional growth rate because they share",
    "the same projection matrix, although their population sizes need not become equal."
  ))
}

question_2 <- function() {
  source("Code/Demographic.R", local = TRUE)
  parameters <- demographic_parameters()
  # Seeds are controlled by the calling test or analysis script.
  adult <- stochastic_simulation(
    state_initialise_adult(4, 100), parameters$growth_matrix,
    parameters$reproduction_matrix, parameters$clutch_distribution, 24
  )
  spread <- stochastic_simulation(
    state_initialise_spread(4, 100), parameters$growth_matrix,
    parameters$reproduction_matrix, parameters$clutch_distribution, 24
  )
  plot_demographic_pair(adult, spread, "question_2.png", "Stochastic population trajectories")
  return(paste(
    "The stochastic trajectories fluctuate because survival, maturation and reproduction are random.",
    "The deterministic model uses expected transitions, producing more regular trajectories.",
    "A stochastic run can depart from the deterministic prediction and will generally change",
    "when the random seed changes. Initial stage composition can still cause early transients",
    "in either model."
  ))
}

# Section two: neutral community dynamics without speciation.

# Question 7: count the distinct species labels present.
species_richness <- function(community) {
  return(length(unique(community)))
}

# Question 8: assign a different species label to every individual.
init_community_max <- function(size) {
  if (length(size) != 1 || !is.finite(size) || size < 1 || size != floor(size)) {
    stop("Community size must be a positive integer.")
  }
  return(seq_len(size))
}

# Question 9: all individuals belong to species 1.
init_community_min <- function(size) {
  if (length(size) != 1 || !is.finite(size) || size < 1 || size != floor(size)) {
    stop("Community size must be a positive integer.")
  }
  return(rep(1, size))
}

# Question 10: ordered, uniformly sampled indices without replacement.
choose_two <- function(max_value) {
  return(sample.int(max_value, size = 2, replace = FALSE))
}

# Question 11: the first individual dies; the second is the parent.
neutral_step <- function(community) {
  if (length(community) < 2) return(community)
  indices <- choose_two(length(community))
  community[indices[1]] <- community[indices[2]]
  return(community)
}

# For odd community sizes, round the half-size up or down with equal probability.
neutral_steps_per_generation <- function(size) {
  steps <- floor(size / 2)
  if (size %% 2 == 1) steps <- steps + rbinom(1, size = 1, prob = 0.5)
  return(steps)
}

# Question 12: one generation contains approximately size/2 replacements.
neutral_generation <- function(community) {
  steps <- neutral_steps_per_generation(length(community))
  for (i in seq_len(steps)) {
    community <- neutral_step(community)
  }
  return(community)
}

# Question 13: record richness at generation zero and after each generation.
neutral_time_series <- function(community, duration) {
  if (length(duration) != 1 || !is.finite(duration) || duration < 0 || duration != floor(duration)) {
    stop("Duration must be a non-negative integer number of generations.")
  }
  time_series <- numeric(duration + 1)
  time_series[1] <- species_richness(community)
  for (generation in seq_len(duration)) {
    community <- neutral_generation(community)
    time_series[generation + 1] <- species_richness(community)
  }
  return(time_series)
}

# Question 14: use the preceding functions to produce the required example plot.
question_14 <- function() {
  time_series <- neutral_time_series(init_community_max(100), duration = 200)
  dir.create("Results", showWarnings = FALSE)
  png("Results/question_14.png", width = 1600, height = 1100, res = 180)
  on.exit(dev.off())
  par(mar = c(4.5, 5, 3, 1))
  plot(0:200, time_series, type = "l", lwd = 2, col = "#3366AA",
       ylim = c(0, 100), xlab = "Generation", ylab = "Species richness",
       main = "Neutral dynamics without speciation")
  abline(h = 1, lty = 2, col = "#777777")
  legend("topright", c("Simulated richness", "Monodominance (one species)"),
         col = c("#3366AA", "#777777"), lty = c(1, 2), lwd = c(2, 1),
         bty = "n", cex = 0.85)
  return(paste(
    "In a finite closed community without speciation, richness can decrease but cannot increase.",
    "Random replacement eventually leaves a single species with probability one.",
    "This state is absorbing: offspring cannot reintroduce an absent species.",
    "The time to reach monodominance is random, so it need not occur within the 200 generations plotted."
  ))
}

# Question 15: a replacement is a new species with probability speciation_rate.
neutral_step_speciation <- function(community, speciation_rate) {
  if (length(speciation_rate) != 1 || !is.finite(speciation_rate) ||
      speciation_rate < 0 || speciation_rate > 1) {
    stop("Speciation rate must be a probability between zero and one.")
  }
  if (length(community) == 0) stop("Community must contain at least one individual.")
  if (runif(1) < speciation_rate) {
    # The label must differ from every label currently present.
    new_species <- max(community) + 1
    death_index <- sample.int(length(community), size = 1)
    community[death_index] <- new_species
    return(community)
  }
  return(neutral_step(community))
}

# Question 16: apply the same half-size generation rule as in Question 12.
neutral_generation_speciation <- function(community, speciation_rate) {
  steps <- neutral_steps_per_generation(length(community))
  for (i in seq_len(steps)) {
    community <- neutral_step_speciation(community, speciation_rate)
  }
  return(community)
}

# Question 17: include the initial richness before applying any generations.
neutral_time_series_speciation <- function(community, speciation_rate, duration) {
  if (length(duration) != 1 || !is.finite(duration) || duration < 0 || duration != floor(duration)) {
    stop("Duration must be a non-negative integer number of generations.")
  }
  time_series <- numeric(duration + 1)
  time_series[1] <- species_richness(community)
  for (generation in seq_len(duration)) {
    community <- neutral_generation_speciation(community, speciation_rate)
    time_series[generation + 1] <- species_richness(community)
  }
  return(time_series)
}

# Question 18 uses the worksheet's fixed probability, not the personal HPC rate.
question_18 <- function() {
  maximum <- neutral_time_series_speciation(init_community_max(100), 0.1, 200)
  minimum <- neutral_time_series_speciation(init_community_min(100), 0.1, 200)
  dir.create("Results", showWarnings = FALSE)
  png("Results/question_18.png", width = 1600, height = 1100, res = 180)
  on.exit(dev.off())
  par(mar = c(4.5, 5, 3, 1))
  matplot(0:200, cbind(maximum, minimum), type = "l", lty = 1, lwd = 2,
          col = c("#3366AA", "#D97706"), ylim = c(0, 100),
          xlab = "Generation", ylab = "Species richness",
          main = "Neutral dynamics with speciation (probability = 0.1)")
  legend("topright", c("Initially 100 species", "Initially one species"),
         col = c("#3366AA", "#D97706"), lty = 1, lwd = 2, bty = "n", cex = 0.85)
  return(paste(
    "Initial conditions strongly affect early richness: the maximally diverse community loses species,",
    "while the single-species community gains species through speciation.",
    "With the same community size and speciation probability, the initial-condition effect",
    "weakens over time as both communities approach the same stationary distribution of richness.",
    "They do not have to follow identical paths or reach the same richness at a particular generation.",
    "Unlike the model without speciation, monodominance is not absorbing because new species can appear."
  ))
}

# Question 19: return abundances, rather than species identities, largest first.
species_abundance <- function(community) {
  return(sort(as.numeric(table(community)), decreasing = TRUE))
}

# Question 20: bins are 1, 2-3, 4-7, 8-15, and so on.
octaves <- function(abundance_vector) {
  if (length(abundance_vector) == 0) return(integer(0))
  if (any(!is.finite(abundance_vector)) || any(abundance_vector < 1) ||
      any(abundance_vector != floor(abundance_vector))) {
    stop("Abundances must be positive integers.")
  }
  classes <- floor(log2(abundance_vector)) + 1
  return(tabulate(classes))
}

# Question 21: sum_vect is defined earlier because Demographic.R also uses it.

mean_octave_vectors <- function(abundance_list) {
  if (length(abundance_list) == 0) stop("No octave readings to average.")
  total <- numeric(0)
  for (reading in abundance_list) total <- sum_vect(total, reading)
  return(total / length(abundance_list))
}

collect_neutral_octaves <- function(community, speciation_rate, burn_in, duration, interval) {
  # Keep the community state: do not restart after burn-in or between readings.
  for (generation in seq_len(burn_in)) {
    community <- neutral_generation_speciation(community, speciation_rate)
  }
  abundance_list <- vector("list", 1 + floor(duration / interval))
  abundance_list[[1]] <- octaves(species_abundance(community))
  reading <- 1
  for (generation in seq_len(duration)) {
    community <- neutral_generation_speciation(community, speciation_rate)
    if (generation %% interval == 0) {
      reading <- reading + 1
      abundance_list[[reading]] <- octaves(species_abundance(community))
    }
  }
  return(abundance_list)
}

# Question 22: 200 burn-in generations, then 2000 more, sampled every 20.
question_22 <- function() {
  size <- 100
  speciation_rate <- 0.1
  burn_in <- 200
  duration <- 2000
  interval <- 20
  abundance_list_max <- collect_neutral_octaves(
    init_community_max(size), speciation_rate, burn_in, duration, interval
  )
  abundance_list_min <- collect_neutral_octaves(
    init_community_min(size), speciation_rate, burn_in, duration, interval
  )
  mean_octaves_max <- mean_octave_vectors(abundance_list_max)
  mean_octaves_min <- mean_octave_vectors(abundance_list_min)
  # Use a common set of bins and vertical limits for a fair panel comparison.
  n_bins <- floor(log2(size)) + 1
  mean_octaves_max <- sum_vect(mean_octaves_max, numeric(n_bins))
  mean_octaves_min <- sum_vect(mean_octaves_min, numeric(n_bins))
  lower <- 2^(seq_len(n_bins) - 1)
  upper <- 2^seq_len(n_bins) - 1
  bin_labels <- ifelse(lower == upper, as.character(lower), paste(lower, upper, sep = "-"))
  sampling_generations <- seq.int(burn_in, burn_in + duration, by = interval)
  dir.create("Data", showWarnings = FALSE)
  save(abundance_list_max, abundance_list_min, mean_octaves_max, mean_octaves_min,
       sampling_generations, size, speciation_rate, burn_in, duration, interval,
       file = "Data/question_22.rda")
  dir.create("Results", showWarnings = FALSE)
  png("Results/question_22.png", width = 1800, height = 1000, res = 180)
  on.exit(dev.off())
  par(mfrow = c(1, 2), mar = c(5, 4.5, 3, 1), oma = c(0, 0, 2, 0))
  upper_y <- 1.15 * max(mean_octaves_max, mean_octaves_min)
  barplot(mean_octaves_max, names.arg = bin_labels, col = "#3366AA", border = NA,
          ylim = c(0, upper_y), xlab = "Individuals per species (octave class)",
          ylab = "Mean number of species", main = "Initially 100 species", cex.names = 0.85)
  barplot(mean_octaves_min, names.arg = bin_labels, col = "#D97706", border = NA,
          ylim = c(0, upper_y), xlab = "Individuals per species (octave class)",
          ylab = "Mean number of species", main = "Initially one species", cex.names = 0.85)
  mtext("Species abundance distributions after burn-in", outer = TRUE, cex = 1.1)
  return(paste(
    "The initial condition affects the early dynamics, but its influence is expected to weaken after sufficient burn-in.",
    "Both simulations have the same community size and speciation probability and approach the same stationary distribution.",
    "Their mean octave distributions should therefore be similar, although finite stochastic samples will differ.",
    "Readings from one continuing simulation can remain correlated; sampling every 20 generations does not guarantee independence.",
    "These two trajectories illustrate reduced initial-condition effects, rather than proving that 200 generations are sufficient in every run."
  ))
}

# Question 23: run for wall_time minutes and save state plus indexed readings.
neutral_cluster_run <- function(speciation_rate, size, wall_time, interval_rich,
                                interval_oct, burn_in_generations, output_file_name) {
  if (length(speciation_rate) != 1 || !is.finite(speciation_rate) ||
      speciation_rate < 0 || speciation_rate > 1) {
    stop("Speciation rate must be a probability between zero and one.")
  }
  counts <- c(size, interval_rich, interval_oct)
  if (length(counts) != 3 || any(!is.finite(counts)) ||
      any(counts < 1) || any(counts != floor(counts))) {
    stop("Size and recording intervals must be positive integers.")
  }
  if (length(burn_in_generations) != 1 || !is.finite(burn_in_generations) ||
      burn_in_generations < 0 || burn_in_generations != floor(burn_in_generations)) {
    stop("Burn-in must be a non-negative integer number of generations.")
  }
  if (length(wall_time) != 1 || !is.finite(wall_time) || wall_time <= 0) {
    stop("Wall time must be a positive number of minutes.")
  }
  if (length(output_file_name) != 1 || !nzchar(output_file_name)) {
    stop("Provide one output filename.")
  }
  if (file.exists(output_file_name)) {
    stop("Output already exists. Preserve it before rerunning this simulation.")
  }
  if (!dir.exists(dirname(output_file_name))) {
    stop("Output directory does not exist.")
  }

  community <- init_community_min(size)
  # Generation zero is included in the burn-in richness record.
  n_richness <- 1L
  time_series <- numeric(1 + floor(burn_in_generations / interval_rich))
  richness_generations <- numeric(length(time_series))
  time_series[1] <- species_richness(community)
  richness_generations[1] <- 0
  abundance_list <- vector("list", 1024)
  abundance_generations <- numeric(1024)
  n_abundance <- 0L
  generations_completed <- 0
  # The caller controls the seed. Save its state for provenance.
  rng_state_start <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    get(".Random.seed", envir = .GlobalEnv)
  } else NULL
  started <- proc.time()[["elapsed"]]
  limit_seconds <- wall_time * 60
  while (proc.time()[["elapsed"]] - started < limit_seconds) {
    community <- neutral_generation_speciation(community, speciation_rate)
    generations_completed <- generations_completed + 1
    if (generations_completed <= burn_in_generations &&
        generations_completed %% interval_rich == 0) {
      n_richness <- n_richness + 1L
      time_series[n_richness] <- species_richness(community)
      richness_generations[n_richness] <- generations_completed
    }
    # Save abundance readings during and after burn-in, as required.
    if (generations_completed %% interval_oct == 0) {
      n_abundance <- n_abundance + 1L
      if (n_abundance > length(abundance_list)) {
        new_length <- 2 * length(abundance_list)
        length(abundance_list) <- new_length
        length(abundance_generations) <- new_length
      }
      abundance_list[[n_abundance]] <- octaves(species_abundance(community))
      abundance_generations[n_abundance] <- generations_completed
    }
  }
  total_time <- (proc.time()[["elapsed"]] - started) / 60
  time_series <- time_series[seq_len(n_richness)]
  richness_generations <- richness_generations[seq_len(n_richness)]
  abundance_list <- abundance_list[seq_len(n_abundance)]
  abundance_generations <- abundance_generations[seq_len(n_abundance)]
  rng_state_end <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    get(".Random.seed", envir = .GlobalEnv)
  } else NULL
  # total_time and wall_time are both in minutes; saving occurs after the timer.
  save(time_series, abundance_list, community, total_time, speciation_rate,
       size, wall_time, interval_rich, interval_oct, burn_in_generations,
       richness_generations, abundance_generations, generations_completed,
       rng_state_start, rng_state_end, file = output_file_name)
  return(invisible(NULL))
}

# Locate real task files in Data, or in the current directory as in the worksheet.
find_cluster_files <- function(model) {
  pattern <- paste0("^", username, "_", model, "_[0-9]+\\.rda$")
  files <- c(list.files("Data", pattern = pattern, full.names = TRUE),
             list.files(".", pattern = pattern, full.names = TRUE))
  if (anyDuplicated(basename(files))) {
    stop("Duplicate task filenames in Data and the current directory. Keep one copy of each.")
  }
  return(files)
}

# Question 26: combine every post-burn-in reading across all 25 tasks per size.
process_neutral_cluster_results <- function() {
  files <- find_cluster_files("neutral")
  task_ids <- as.integer(sub(".*_([0-9]+)\\.rda$", "\\1", basename(files)))
  if (length(task_ids) != 100 || anyDuplicated(task_ids) ||
      !setequal(task_ids, 1:100)) {
    missing <- setdiff(1:100, task_ids)
    stop(paste("Expected all 100 distinct neutral task files. Missing tasks:",
               paste(missing, collapse = ", ")))
  }
  files <- files[order(task_ids)]
  community_sizes <- c(500, 1000, 2500, 5000)
  sums <- lapply(community_sizes, function(x) numeric(0))
  reading_counts <- numeric(4)
  task_counts <- numeric(4)
  task_summary <- vector("list", 100)
  common_rate <- NULL
  for (task in 1:100) {
    saved <- new.env()
    load(files[task], envir = saved)
    needed <- c("size", "speciation_rate", "interval_oct", "burn_in_generations",
                "abundance_list", "abundance_generations", "generations_completed")
    if (!all(needed %in% ls(saved))) stop(paste("Missing saved fields in", files[task]))
    group <- ceiling(task / 25)
    if (!identical(as.numeric(saved$size), community_sizes[group]) ||
        saved$burn_in_generations != 8 * saved$size ||
        saved$interval_oct != saved$size / 10) {
      stop(paste("Task settings do not match the worksheet:", files[task]))
    }
    if (exists("iter", envir = saved, inherits = FALSE) && saved$iter != task) {
      stop(paste("Stored array index does not match filename:", files[task]))
    }
    if (length(saved$speciation_rate) != 1 || !is.finite(saved$speciation_rate) ||
        saved$speciation_rate < 0.002 || saved$speciation_rate > 0.007) {
      stop(paste("Invalid personal speciation rate:", files[task]))
    }
    if (is.null(common_rate)) common_rate <- saved$speciation_rate
    if (!isTRUE(all.equal(saved$speciation_rate, common_rate))) {
      stop("Tasks contain different personal speciation rates.")
    }
    generations <- saved$abundance_generations
    expected <- seq_len(floor(saved$generations_completed / saved$interval_oct)) * saved$interval_oct
    if (length(generations) != length(saved$abundance_list) ||
        !identical(as.numeric(generations), as.numeric(expected))) {
      stop(paste("Missing or misaligned sampling generations:", files[task]))
    }
    retained <- which(generations > saved$burn_in_generations)
    if (length(retained) == 0) stop(paste("No post-burn-in readings in", files[task]))
    for (i in retained) {
      reading <- saved$abundance_list[[i]]
      if (!is.numeric(reading) || length(reading) == 0 || any(!is.finite(reading)) ||
          any(reading < 0) || any(reading != floor(reading))) {
        stop(paste("Invalid octave vector in", files[task]))
      }
      lower <- 2^(seq_along(reading) - 1)
      upper <- 2^seq_along(reading) - 1
      if (sum(reading) < 1 || sum(reading * lower) > saved$size ||
          sum(reading * upper) < saved$size) {
        stop(paste("Octave vector is inconsistent with community size:", files[task]))
      }
      sums[[group]] <- sum_vect(sums[[group]], reading)
    }
    reading_counts[group] <- reading_counts[group] + length(retained)
    task_counts[group] <- task_counts[group] + 1
    task_summary[[task]] <- data.frame(
      iter = task, size = saved$size, n_post_burn_in_readings = length(retained),
      final_generation = saved$generations_completed, file = basename(files[task])
    )
  }
  stopifnot(all(task_counts == 25), all(reading_counts > 0))
  combined_results <- lapply(seq_along(sums), function(i) sums[[i]] / reading_counts[i])
  names(combined_results) <- as.character(community_sizes)
  speciation_rate <- common_rate
  task_summary <- do.call(rbind, task_summary)
  dir.create("Data", showWarnings = FALSE)
  save(combined_results, community_sizes, reading_counts, task_counts, speciation_rate,
       task_summary, file = "Data/neutral_cluster_summary.rda")
  return(combined_results)
}

plot_neutral_cluster_results <- function() {
  filename <- "Data/neutral_cluster_summary.rda"
  if (!file.exists(filename)) {
    stop("Run process_neutral_cluster_results() after all 100 real task files are available.")
  }
  saved <- new.env()
  load(filename, envir = saved)
  combined_results <- saved$combined_results
  if (length(combined_results) != 4 || !identical(saved$community_sizes, c(500, 1000, 2500, 5000))) {
    stop("Summary must contain four sizes in increasing order.")
  }
  dir.create("Results", showWarnings = FALSE)
  png("Results/plot_neutral_cluster_results.png", width = 1800, height = 1500, res = 180)
  on.exit(dev.off())
  par(mfrow = c(2, 2), mar = c(6, 4.5, 3, 1), oma = c(0, 0, 2, 0))
  colors <- c("#3366AA", "#D97706", "#228866", "#8844AA")
  for (i in 1:4) {
    values <- combined_results[[i]]
    lower <- 2^(seq_along(values) - 1)
    upper <- 2^seq_along(values) - 1
    labels <- ifelse(lower == upper, as.character(lower), paste(lower, upper, sep = "-"))
    barplot(values, names.arg = labels, col = colors[i], border = NA, las = 2,
            cex.names = 0.8, ylab = "Mean number of species",
            main = paste("Community size =", saved$community_sizes[i]))
    mtext("Individuals per species (octave class)", side = 1, line = 4.5, cex = 0.8)
  }
  mtext("Mean abundance distributions after burn-in", outer = TRUE, cex = 1.1)
  write.csv(saved$task_summary, "Results/neutral_cluster_task_summary.csv", row.names = FALSE)
  return(combined_results)
}

# Read the 100 demographic task files without creating misleading partial summaries.
demographic_cluster_summary <- function() {
  files <- find_cluster_files("demographic")
  ids <- as.integer(sub(".*_([0-9]+)\\.rda$", "\\1", basename(files)))
  if (length(ids) != 100 || anyDuplicated(ids) || !setequal(ids, 1:100)) {
    stop(paste("Expected all 100 distinct demographic task files. Missing tasks:",
               paste(setdiff(1:100, ids), collapse = ", ")))
  }
  files <- files[order(ids)]
  totals <- matrix(0, nrow = 4, ncol = 121)
  n_simulations <- numeric(4)
  n_extinct <- numeric(4)
  for (task in 1:100) {
    saved <- new.env()
    load(files[task], envir = saved)
    needed <- c("results_list", "iter", "initial_condition", "initial_state", "simulation_length")
    if (!all(needed %in% ls(saved))) stop(paste("Missing fields in", files[task]))
    group <- ceiling(task / 25)
    expected_initial <- if (group <= 2) {
      state_initialise_adult(4, c(100, 10)[group])
    } else {
      state_initialise_spread(4, c(100, 10)[group - 2])
    }
    if (saved$iter != task || saved$initial_condition != group ||
        saved$simulation_length != 120 || length(saved$results_list) != 150 ||
        !identical(as.numeric(saved$initial_state), expected_initial)) {
      stop(paste("Unexpected task settings:", files[task]))
    }
    for (trajectory in saved$results_list) {
      if (!is.numeric(trajectory) || length(trajectory) != 121 ||
          any(!is.finite(trajectory)) || any(trajectory < 0) ||
          any(trajectory != floor(trajectory)) || trajectory[1] != sum(expected_initial)) {
        stop(paste("Invalid population trajectory:", files[task]))
      }
      first_zero <- match(0, trajectory, nomatch = 0)
      if (first_zero > 0 && any(trajectory[seq.int(first_zero, 121)] != 0)) {
        stop(paste("Population reappears after extinction:", files[task]))
      }
      totals[group, ] <- totals[group, ] + trajectory
      n_simulations[group] <- n_simulations[group] + 1
      n_extinct[group] <- n_extinct[group] + as.integer(trajectory[121] == 0)
    }
  }
  stopifnot(all(n_simulations == 3750))
  labels <- c("Large adult", "Small adult", "Large mixed", "Small mixed")
  mean_population <- totals / n_simulations
  return(list(labels = labels, n_simulations = n_simulations,
              n_extinct = n_extinct, extinction_proportion = n_extinct / n_simulations,
              mean_population = mean_population, time_months = 0:120))
}

# Question 5: extinction is final population size zero, over all runs per condition.
question_5 <- function() {
  summary <- demographic_cluster_summary()
  dir.create("Results", showWarnings = FALSE)
  png("Results/question_5.png", width = 1600, height = 1100, res = 180)
  on.exit(dev.off())
  par(mar = c(5, 5, 3, 1))
  positions <- barplot(summary$extinction_proportion,
                       names.arg = c("Large\nadult", "Small\nadult", "Large\nmixed", "Small\nmixed"),
                       col = c("#3366AA", "#88AADD", "#D97706", "#E8B86D"), border = NA,
                       ylim = c(0, 1), ylab = "Proportion extinct by month 120",
                       xlab = "Initial population condition", main = "Extinction across initial conditions")
  text(positions, pmin(summary$extinction_proportion + 0.04, 0.98),
       sprintf("%.3f", summary$extinction_proportion), cex = 0.9)
  table <- data.frame(initial_condition = summary$labels, n_simulations = summary$n_simulations,
                      n_extinct = summary$n_extinct, proportion_extinct = summary$extinction_proportion)
  write.csv(table, "Results/question_5_extinction.csv", row.names = FALSE)
  winners <- summary$labels[summary$extinction_proportion == max(summary$extinction_proportion)]
  return(paste(
    "The highest observed extinction proportion was", sprintf("%.3f", max(summary$extinction_proportion)),
    "for", paste(winners, collapse = " and "), ".",
    "Small populations are more vulnerable to demographic fluctuations because fewer individuals buffer random losses.",
    "Stage composition also matters: adults can reproduce immediately, whereas immature individuals must survive until maturity.",
    "The ranking reported here is calculated from all simulations, including extinct runs, rather than assumed in advance."
  ))
}

# Question 6: keep extinct runs as zeros when averaging the mixed-stage conditions.
question_6 <- function() {
  summary <- demographic_cluster_summary()
  source("Code/Demographic.R", local = TRUE)
  parameters <- demographic_parameters()
  deterministic_large <- deterministic_simulation(state_initialise_spread(4, 100),
                                                   parameters$projection_matrix, 120)
  deterministic_small <- deterministic_simulation(state_initialise_spread(4, 10),
                                                   parameters$projection_matrix, 120)
  ratio_large <- summary$mean_population[3, ] / deterministic_large
  ratio_small <- summary$mean_population[4, ] / deterministic_small
  dir.create("Results", showWarnings = FALSE)
  png("Results/question_6.png", width = 1800, height = 1000, res = 180)
  on.exit(dev.off())
  par(mfrow = c(1, 2), mar = c(4.5, 5, 3, 1), oma = c(0, 0, 2, 0))
  limits <- range(c(ratio_large, ratio_small, 1))
  if (diff(limits) < 0.02) limits <- c(0.99, 1.01)
  for (i in 1:2) {
    values <- list(ratio_large, ratio_small)[[i]]
    plot(0:120, values, type = "l", lwd = 2, col = c("#3366AA", "#D97706")[i],
         ylim = limits, xlab = "Time (months)", ylab = "Stochastic mean / deterministic prediction",
         main = c("Large mixed population", "Small mixed population")[i])
    abline(h = 1, lty = 2, col = "#777777")
  }
  mtext("Average stochastic behaviour relative to the deterministic model", outer = TRUE, cex = 1)
  table <- data.frame(time_months = 0:120,
                      stochastic_mean_large = summary$mean_population[3, ],
                      stochastic_mean_small = summary$mean_population[4, ],
                      deterministic_large = deterministic_large,
                      deterministic_small = deterministic_small,
                      ratio_large = ratio_large, ratio_small = ratio_small)
  write.csv(table, "Results/question_6_ratios.csv", row.names = FALSE)
  # Exclude the initial ratio of one from the descriptive comparison.
  errors <- c(mean(abs(ratio_large[-1] - 1)), mean(abs(ratio_small[-1] - 1)))
  closest <- c("large mixed population", "small mixed population")[errors == min(errors)]
  return(paste(
    "In these runs, the", paste(closest, collapse = " and "),
    "had the smaller mean absolute ratio deviation from one over months 1-120.",
    "Larger populations generally have lower relative demographic noise, making empirical mean trajectories more stable.",
    "For this linear model, the deterministic trajectory represents the expected stochastic population for either initial condition.",
    "Finite-simulation averages can differ from that expectation. Extinct populations must remain in the average as zeros;",
    "averaging only survivors would describe a different, conditional quantity."
  ))
}
