#!/bin/bash
#SBATCH --job-name=bed_intersect_wrapper
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=48:00:00
#SBATCH --output=bed_intersect_wrapper_output.txt
#SBATCH --error=bed_intersect_wrapper_output.txt

## Description

## Requirements
## bowtie2, samtools, bedtools

## Inputs
## $1 : data directory 
## $2 : genome (mm10 or hg38)

DATA_DIRECTORY=$1
GENOME=$2

cd ${DATA_DIRECTORY}
mkdir bed_intersect

cd ${DATA_DIRECTORY}/alignment/alignment_other

for SAMPLE in *.sam; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'.' -f 1`

	sbatch --job-name=${SAMPLE_NAME}_bed_intersect \
	--output=${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_bed_intersect_output.txt \
	--error=${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_bed_intersect_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/5_bed_intersect.sh \
	${SAMPLE_NAME} ${DATA_DIRECTORY} ${GENOME}

done
