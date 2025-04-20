#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=8G
#$ -N get-counts
#$ -o get-counts_output.txt
#$ -e get-counts_output.txt

## Inputs
## $1 Data directory (e.g./grid/schorn/home/mpeacey/tRF_targets/data/public_RNAseq/Yang_2019)
## $2 Shared directory
## $3 Genome (e.g. hg38, mm10)

## Requirements
## samtools, bedtools

echo "New run started on $(date)"

DATA_DIRECTORY=$1
SHARED_DIRECTORY=$2
GENOME=$3

cd ${DATA_DIRECTORY}/alignment_mask${GENOME}_tRNA

for SAMPLE in *_tRNA-intersect.txt; do
	
	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

	echo "Counting reads in sample ${SAMPLE_NAME}"

	tRF3a_reads=cat ${SAMPLE} | awk '($3-$2) > 13 && ($3-$2) <= 16' | sed 's/[()]//g' | awk '$6==$12' | wc -l
	tRF3b_reads=cat ${SAMPLE} | grep 'Lys' | awk '($3-$2) > 16 && ($3-$2) <= 20' | sed 's/[()]//g' | awk '$6==$12' | wc -l

	echo :${reads}

done

echo "Finished run on $(date)"
