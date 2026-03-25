#!/bin/bash
#SBATCH --job-name=align_tRF_wrapper
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=48:00:00
#SBATCH --output=align_tRF_wrapper_output.txt
#SBATCH --error=align_tRF_wrapper_output.txt

SUBMIT_DIR="${SLURM_SUBMIT_DIR:-$PWD}"

DATA_DIRECTORY=$1
FASTQ_DIRECTORY=$2
GENOME=$3

cd ${DATA_DIRECTORY}

mkdir alignment
mkdir alignment/alignment_tRNA

cd ${FASTQ_DIRECTORY}

for SAMPLE in *.fastq; do

	SAMPLE_NAME=`echo ${SAMPLE} | cut -d'_' -f 1`

	sbatch --job-name=${SAMPLE_NAME}_align_tRF \
	--output=${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_tRF_output.txt \
	--error=${DATA_DIRECTORY}/alignment/${SAMPLE_NAME}_align_tRF_output.txt \
	/grid/schorn/home/mpeacey/scripts/small_RNA_seq/2_align_tRF.sh \
	${SAMPLE} ${SAMPLE_NAME} \
	${DATA_DIRECTORY} ${FASTQ_DIRECTORY} ${GENOME}

done

mv "${SUBMIT_DIR}/align_tRF_wrapper_output.txt" "${DATA_DIRECTORY}/alignment/"
cp /grid/schorn/home/mpeacey/scripts/small_RNA_seq/2_align_tRF.sh  ${DATA_DIRECTORY}/scripts/2_align_tRF.sh
