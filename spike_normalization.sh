#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=8G
#$ -N spike_normalization
#$ -o spike_normalization_output.txt
#$ -e spike_normalization_output.txt

## Normalizes raw reads to spike-in.

## Requirements
## None

echo "New run started on $(date)"

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2

cd ${DATA_DIRECTORY}

touch spike_reads.txt

cd ${FASTQ_DIRECTORY}

for i in *stats.txt; do

	SAMPLE_NAME=`echo ${i} | cut -d'_' -f 1`

	echo "${SAMPLE_NAME}"

	spike_reads=`cat ${i} | grep '#Matched' | awk '{ print $2 }'`

	echo "${SAMPLE_NAME}:${spike_reads}" >> ${DATA_DIRECTORY}/spike_reads.txt

done

echo "Finished run on $(date)"

mv /grid/schorn/home/mpeacey/scripts/small_RNA_seq/spike_normalization_output.txt ${DATA_DIRECTORY}


