#!/bin/bash
#SBATCH --job-name=counts_from_bed
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=counts_from_bed_output.txt
#SBATCH --error=counts_from_bed_output.txt

DATA_DIRECTORY=$1
SAMPLE_NAME=$2
GENOME=$3

module load EBModules
module load R/4.0.4-fosscuda-2020a

Rscript /grid/schorn/home/mpeacey/scripts/small_RNA_seq/counts_from_bed.R ${DATA_DIRECTORY} ${SAMPLE_NAME} ${GENOME}
