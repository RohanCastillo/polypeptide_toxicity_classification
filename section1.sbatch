#!/bin/bash
#SBATCH --job-name=toxicity-section1
#SBATCH --partition=main
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=1-00:00:00
#SBATCH --output=results/section1-%j.log

set -euo pipefail
cd "${SLURM_SUBMIT_DIR}"

# Limit the grid search to the allocation and avoid nested thread pools.
export LOKY_MAX_CPU_COUNT="${SLURM_CPUS_PER_TASK}"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export MPLBACKEND=Agg

date -u
uv run --frozen --no-sync python -u run_section1.py
date -u
