#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=4G
#$ -N bed_intersect_wrapper
#$ -o bed_intersect_wrapper_output.txt
#$ -e bed_intersect_wrapper_output.txt

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

	qsub -N ${SAMPLE_NAME}_bed_intersect \
	-o ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_bed_intersect_output.txt \
	-e ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_bed_intersect_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/5_bed_intersect.sh \
	${SAMPLE_NAME} ${DATA_DIRECTORY} ${GENOME}

done
