#!/bin/bash
#SBATCH --job-name=adapter_trim_wrapper
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=48:00:00
#SBATCH --output=adapter_trim_wrapper_output.txt
#SBATCH --error=adapter_trim_wrapper_output.txt

# Description
#
# Trims sequencing adapters from reads, quality and length filters, and returns a quality control summary.

# Requirements
#
# Environment: small_RNA_sequencing
# cutadapt v4.6
# fastQC v0.12.1
# FASTX toolkit v0.0.14

# Inputs
# 1 : home directory.
# 2 : directory containing untrimmed reads in fastq format.
# 3 : fixed number of bases to trim from the 5' end.
# 4 : enables polyA trimming. 
# 5 : Note that the 3' adapter sequence(s) must be in a fasta file named adapter.fasta, adapter.fa, 
#     adaptor.fasta, or adaptor.fa, located in the fastq directory (input 1).

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2
TRIM=$3
POLY_A=$4

cd ${FASTQ_DIRECTORY}

mkdir cutadapt_processed
mkdir fastqc
mkdir quality_filtered

for SAMPLE in *.fastq; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'.' -f 1`

	sbatch --job-name=${SAMPLE_NAME}_adapter_trim \
	--output=${SAMPLE_NAME}_adapter_trim_output.txt --error=${SAMPLE_NAME}_adapter_trim_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/1_adapter_trim.sh \
	${SAMPLE} ${SAMPLE_NAME} \
	${DATA_DIRECTORY} ${FASTQ_DIRECTORY} ${TRIM} ${POLY_A}

done
