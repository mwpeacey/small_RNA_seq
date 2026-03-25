#!/bin/bash
#SBATCH --job-name=total_mapped
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=48:00:00
#SBATCH --output=total_mapped_output.txt
#SBATCH --error=total_mapped_output.txt

## Calculates total mapped reads.

## Requirements
## samtools

echo "#####################################"
echo "New run started on $(date)"
echo "#####################################"

SUBMIT_DIR="${SLURM_SUBMIT_DIR:-$PWD}"

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

mv "${SUBMIT_DIR}/total_mapped_output.txt" "${DATA_DIRECTORY}"
