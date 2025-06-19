#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=4G
#$ -N align_remaining_wrapper 
#$ -o align_remaining_wrapper_output.txt
#$ -e align_remaining_wrapper_output.txt

## Takes reads that fail to align to a tRNA annotation and aligns them to a tRNA-masked genome.

## Requirements
## bowtie2, samtools, bedtools

## Inputs
## $1 : data directory 
## $2 : directory containing the *original* fastq files (e.g. cutadapt-trimmed, spike-depleted)
## $3 : genome (mm10 or hg38)

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2
GENOME=$3

cd ${DATA_DIRECTORY}/alignment

mkdir alignment_other

cd alignment_tRNA

for SAMPLE in *_remap.fastq; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

	qsub -N ${SAMPLE_NAME}_align_remaining \
	-o ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_remaining_output.txt \
	-e ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_remaining_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/3_align_remaining.sh \
	${SAMPLE} ${SAMPLE_NAME} \
	${DATA_DIRECTORY} ${FASTQ_DIRECTORY} ${GENOME}

done

mv /grid/schorn/home/mpeacey/scripts/small_RNA_seq/wrappers/align_remaining_wrapper_output.txt ${DATA_DIRECTORY}/alignment
cp /grid/schorn/home/mpeacey/scripts/small_RNA_seq/3_align_remaining.sh  ${DATA_DIRECTORY}/scripts
