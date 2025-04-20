#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=4G
#$ -N align_tRF_wrapper 
#$ -o align_tRF_wrapper_output.txt
#$ -e align_tRF_wrapper_output.txt

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2
GENOME=$3

cd ${DATA_DIRECTORY}

mkdir alignment
mkdir alignment/alignment_tRNA

cd ${FASTQ_DIRECTORY}

for SAMPLE in *.fastq; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

	qsub -N ${SAMPLE_NAME}_align_tRF \
	-o ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_tRF_output.txt \
	-e ${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_tRF_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/2_align_tRF.sh \
	${SAMPLE} ${SAMPLE_NAME} \
	${DATA_DIRECTORY} ${FASTQ_DIRECTORY} ${GENOME}

done

mv /grid/schorn/home/mpeacey/scripts/small_RNA_seq/wrappers/align_tRF_wrapper_output.txt ${DATA_DIRECTORY}/alignment/
cp /grid/schorn/home/mpeacey/scripts/small_RNA_seq/2_align_tRF.sh  ${DATA_DIRECTORY}/scripts
