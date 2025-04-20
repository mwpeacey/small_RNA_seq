#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=10G

# Description
#
# Trims sequencing adapters from reads, quality and length filters, and returns a quality control summary.

# Requirements
#
# Environment: small_RNA_sequencing
# cutadapt v4.6
# fastQC v0.12.1
# FASTX toolkit v0.0.14

echo "##################################################"
echo "New run started on $(date)"
echo "Running on sample {$2} in {$3}"
echo "##################################################"

SAMPLE=$1
SAMPLE_NAME=$2
FASTQ_DIRECTORY=$3
TRIM=$4
POLY_A=$5

cd ${FASTQ_DIRECTORY}

echo "Processing sample ${SAMPLE_NAME}"

if [ ${POLY_A} == "T" ]; then

	cutadapt -a file:adapter.fasta -u ${TRIM} -m 14 -M 50 \
		 --rename='{id}_{cut_prefix}' \
         	-o cutadapt_processed/${SAMPLE_NAME}_cut.fastq \
 	 	--poly-a \
		${SAMPLE}

else

	cutadapt -a file:adapter.fasta -u ${TRIM} -m 14 -M 50 \
                 --rename='{id}_{cut_prefix}' \
                -o cutadapt_processed/${SAMPLE_NAME}_cut.fastq \
                ${SAMPLE}

fi

fastqc cutadapt_processed/${SAMPLE_NAME}_cut.fastq -o fastqc

fastq_quality_filter -i cutadapt_processed/${SAMPLE_NAME}_cut.fastq \
		     -o quality_filtered/${SAMPLE_NAME}_filtered.fastq \
		     -Q33 -q 20 -p 95

fastqc quality_filtered/${SAMPLE_NAME}_filtered.fastq -o fastqc

echo "Finished run on $(date)"
