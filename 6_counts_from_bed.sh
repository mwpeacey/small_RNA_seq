#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=16G

DATA_DIRECTORY=$1
SAMPLE_NAME=$2
GENOME=$3

module load EBModules
module load R/4.0.4-fosscuda-2020a

Rscript /grid/schorn/home/mpeacey/scripts/small_RNA_seq/counts_from_bed.R ${DATA_DIRECTORY} ${SAMPLE_NAME} ${GENOME}
