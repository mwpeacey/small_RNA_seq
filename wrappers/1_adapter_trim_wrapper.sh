#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=4G
#$ -N adapter_trim_wrapper 
#$ -o adapter_trim_wrapper_output.txt
#$ -e adapter_trim_wrapper_output.txt

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
# 1 : home directory
# 2 : directory containing untrimmed reads in fastq format.
# 3 : fixed number of bases to trim from the 5' end.
# 4 : enables polyA trimming 
# 5 : Note that the 3' adapter sequence(s) must be in a fasta file named adapter.fasta, located in the fastq directory (input 1).

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

	qsub -N ${SAMPLE_NAME}_adapter_trim \
	-o ${SAMPLE_NAME}_adapter_trim_output.txt -e ${SAMPLE_NAME}_adapter_trim_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/1_adapter_trim.sh \
	${SAMPLE} ${SAMPLE_NAME} \
	${DATA_DIRECTORY} ${FASTQ_DIRECTORY} ${TRIM} ${POLY_A}

done
