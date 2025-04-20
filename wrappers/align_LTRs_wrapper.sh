#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=4G
#$ -N align_LTRs_wrapper 
#$ -o align_LTRs_wrapper_output.txt
#$ -e align_LTRs_wrapper_output.txt

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2
GENOME=$3

cd ${DATA_DIRECTORY}

cd alignment
mkdir alignment_LTRs

cd ${FASTQ_DIRECTORY}

for SAMPLE in *.fastq; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

	qsub -N ${SAMPLE_NAME}_align_LTRs \
	-o ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_LTRs_output.txt \
	-e ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_LTRs_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/align_LTRs.sh \
	${SAMPLE} ${SAMPLE_NAME} \
	${DATA_DIRECTORY} ${FASTQ_DIRECTORY} ${GENOME}

done
