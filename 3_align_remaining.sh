#!/bin/bash
#SBATCH --job-name=align_remaining
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=48:00:00
#SBATCH --output=align_remaining_output.txt
#SBATCH --error=align_remaining_output.txt

echo "########################################"
echo "New run started on $(date)"
echo "Analyzing sample {$2 } from {$3}"
echo "########################################"

SAMPLE=$1
SAMPLE_NAME=$2
DATA_DIRECTORY=$3
FASTQ_DIRECTORY=$4
GENOME=$5

cd ${FASTQ_DIRECTORY}

echo "Aligning reads to tRNA-masked genome..."

cd /grid/schorn/home/mpeacey/index/bowtie2/${GENOME}

bowtie2 -q ${DATA_DIRECTORY}/alignment/alignment_tRNA/${SAMPLE_NAME}_remap.fastq \
	-N 1 \
	-p 4 \
	-L 10 \
	-R 10 \
	--gbar 20 \
	-x masktRNA_${GENOME} \
	--time \
	-S ${DATA_DIRECTORY}/alignment/alignment_other/${SAMPLE_NAME}.sam

cd ${DATA_DIRECTORY}/alignment/alignment_other/

echo "Extracting reads that align with 2 or fewer mismatches..."

samtools view -b -o ${SAMPLE_NAME}.bam ${SAMPLE_NAME}.sam 

bamtools filter -tag XM:"<=2" -in ${SAMPLE_NAME}.bam -out ${SAMPLE_NAME}_filtered.bam 

echo "Finished run on $(date)"
