#!/bin/bash -l
#PBS -N lc2025_demographic
#PBS -l select=1:ncpus=1:mem=1gb
#PBS -l walltime=00:10:00
#PBS -o Log/
#PBS -e Log/

set -euo pipefail
cd "${PBS_O_WORKDIR:?Submit this script from the coursework root}"

module load R/4.4.2-gfbf-2024a
# Check the R environment before submission. Its setup depends on the cluster.
if ! command -v Rscript >/dev/null 2>&1; then
    echo "Rscript is unavailable. Set up the supported R environment before submitting." >&2
    exit 1
fi

echo "Host: $(hostname)"
echo "Array task: ${PBS_ARRAY_INDEX:?Missing array index}"
Rscript --vanilla Code/lc2025_HPC_2025_demographic_cluster.R
