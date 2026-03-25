#!/bin/bash
#SBATCH --job-name=counts_from_bed_wrapper
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=48:00:00
#SBATCH --output=counts_from_bed_wrapper_output.txt
#SBATCH --error=counts_from_bed_wrapper_output.txt

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

	sbatch --job-name=${SAMPLE_NAME}_counts_from_bed \
	--output=${DATA_DIRECTORY}/bed_intersect/counts/${SAMPLE_NAME}_counts_from_bed_output.txt \
	--error=${DATA_DIRECTORY}/bed_intersect/counts/${SAMPLE_NAME}_counts_from_bed_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/6_counts_from_bed.sh \
	${DATA_DIRECTORY} ${SAMPLE_NAME} ${GENOME}

done
