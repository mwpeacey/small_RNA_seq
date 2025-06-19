#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=4G
#$ -N counts_from_bed_wrapper
#$ -o counts_from_bed_wrapper_output.txt
#$ -e counts_from_bed_wrapper_output.txt

## Inputs
## $1 : data directory 
## $2 : genome (mm10 or hg38)

DATA_DIRECTORY=$1
GENOME=$2

cd ${DATA_DIRECTORY}/bed_intersect

mkdir counts

cd ${DATA_DIRECTORY}/alignment/alignment_other

for SAMPLE in *.sam; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'.' -f 1`

	qsub -N ${SAMPLE_NAME}_counts_from_bed \
	-o ${DATA_DIRECTORY}/bed_intersect/counts/${SAMPLE_NAME}_counts_from_bed_output.txt \
	-e ${DATA_DIRECTORY}/bed_intersect/counts/${SAMPLE_NAME}_counts_from_bed_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/6_counts_from_bed.sh \
	${DATA_DIRECTORY} ${SAMPLE_NAME} ${GENOME}

done
