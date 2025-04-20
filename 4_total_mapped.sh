#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=8G
#$ -N total_mapped
#$ -o total_mapped_output.txt
#$ -e total_mapped_output.txt

## Calculates total mapped reads.

## Requirements
## samtools

echo "#####################################"
echo "New run started on $(date)"
echo "#####################################"

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2

cd ${DATA_DIRECTORY}
touch total_mapped_reads.txt

cd ${FASTQ_DIRECTORY}

for SAMPLE in *.fastq; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

	tRNA_reads=`samtools view -c ${DATA_DIRECTORY}/alignment/alignment_tRNA/${SAMPLE_NAME}_filtered.bam`
	other_reads=`samtools view -c ${DATA_DIRECTORY}/alignment/alignment_other/${SAMPLE_NAME}_filtered.bam`
	total_reads=$((tRNA_reads + other_reads))

	echo "${SAMPLE_NAME}:${total_reads}" >> ${DATA_DIRECTORY}/total_mapped_reads.txt

done

echo "Finished run on $(date)"

mv /grid/schorn/home/mpeacey/scripts/small_RNA_seq/total_mapped_output.txt ${DATA_DIRECTORY}

