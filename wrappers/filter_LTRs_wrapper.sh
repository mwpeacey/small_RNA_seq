#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=4G
#$ -N filter_LTRs_wrapper
#$ -o filter_LTRs_wrapper_output.txt
#$ -e filter_LTRs_wrapper_output.txt

## Description
## Filters alignments to remove those that are unmapped or map with more than 2 mismatches.

## Requirements
## samtools, bamtools, bedtools (conda environment: small_RNA_seq)

## Inputs
## $1 : data directory 

DATA_DIRECTORY=$1

cd ${DATA_DIRECTORY}/alignment/alignment_LTRs

for SAMPLE in *.sam; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'.' -f 1`

	qsub -N ${SAMPLE_NAME}_filter_alignments \
	-o ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_filter_LTRs_output.txt \
	-e ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_filter_LTRs_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/filter_LTR_alignment.sh \
	${SAMPLE_NAME} ${DATA_DIRECTORY}

done
