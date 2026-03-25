#!/bin/bash
#SBATCH --job-name=align_remaining_wrapper
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=48:00:00
#SBATCH --output=align_remaining_wrapper_output.txt
#SBATCH --error=align_remaining_wrapper_output.txt

## Takes reads that fail to align to a tRNA annotation and aligns them to a tRNA-masked genome.

## Requirements
## bowtie2, samtools, bedtools

## Inputs
## $1 : data directory 
## $2 : directory containing the *original* fastq files (e.g. cutadapt-trimmed, spike-depleted)
## $3 : genome (mm10 or hg38)

SUBMIT_DIR="${SLURM_SUBMIT_DIR:-$PWD}"

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2
GENOME=$3

cd ${DATA_DIRECTORY}/alignment

mkdir alignment_other

cd alignment_tRNA

for SAMPLE in *_remap.fastq; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

	sbatch --job-name=${SAMPLE_NAME}_align_remaining \
	--output=${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_remaining_output.txt \
	--error=${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_remaining_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/3_align_remaining.sh \
	${SAMPLE} ${SAMPLE_NAME} \
	${DATA_DIRECTORY} ${FASTQ_DIRECTORY} ${GENOME}

done

mv "${SUBMIT_DIR}/align_remaining_wrapper_output.txt" "${DATA_DIRECTORY}/alignment"
cp /grid/schorn/home/mpeacey/scripts/small_RNA_seq/3_align_remaining.sh  ${DATA_DIRECTORY}/scripts
