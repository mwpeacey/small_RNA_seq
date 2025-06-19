#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=16G
#$ -N remove-spike
#$ -o remove-spike_output.txt
#$ -e remove-spike_output.txt

## Extracts and quantifies spike-in reads for later normalizatiom

## Requirements
## bbmap

## Inputs
## $1: directory containing data

echo "New run started on $(date)"

FASTQ_DIRECTORY=$1
SPIKE_FASTA=$2

cd ${FASTQ_DIRECTORY}
mkdir spike_depleted

for SAMPLE in *.fastq; do

        SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

        echo "Processing sample ${SAMPLE_NAME}"

	seal.sh in=${SAMPLE} \
		ref=${SPIKE_FASTA} \
		outu=spike_depleted/${SAMPLE_NAME}_spike.fastq \
		stats=spike_depleted/${SAMPLE_NAME}_stats.txt \
		k=15

done 

cd spike_depleted
touch spike_reads.txt

for i in *stats.txt; do

	SAMPLE_NAME=`echo ${i} | cut -d'_' -f 1`

	echo "${SAMPLE_NAME}"

	spike_reads=`cat ${i} | grep '#Matched' | awk '{ print $2 }'`

	echo "${SAMPLE_NAME}:${spike_reads}" >> spike_reads.txt

done

mv /grid/schorn/home/mpeacey/scripts/small_RNA_seq/remove_spike_output.txt ${FASTQ_DIRECTORY}/spike_depleted


