#!/bin/bash
#SBATCH --job-name=align_tRF
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=48:00:00
#SBATCH --output=align_tRF_output.txt
#SBATCH --error=align_tRF_output.txt

## Aligns CCA and non-CCA reads to a tRNA-masked genome.

## Requirements
## bowtie2, samtools, bedtools, picard

## Inputs
## $1 : data directory

echo "################################################################################"
echo "New run started on $(date)"
echo "Analyzing sample {$2} from {$3}"
echo "################################################################################"

SAMPLE=$1
SAMPLE_NAME=$2
DATA_DIRECTORY=$3
FASTQ_DIRECTORY=$4
GENOME=$5

echo "Aligning reads to tRNAs..."

cd /grid/schorn/home/mpeacey/index/bowtie2/${GENOME}/${GENOME}_tRNA

bowtie2 -q ${FASTQ_DIRECTORY}/${SAMPLE} \
	-N 1 \
	-p 4 \
	-L 10 \
	-R 10 \
	--gbar 20 \
	-x ${GENOME}_tRNA \
	--time \
	-S ${DATA_DIRECTORY}/alignment/alignment_tRNA/${SAMPLE_NAME}.sam

cd ${DATA_DIRECTORY}/alignment/alignment_tRNA/

echo "Extracting reads that are unmapped or map with more than 2 mismatches..."

samtools view -b -o ${SAMPLE_NAME}.bam ${SAMPLE_NAME}.sam 

bamtools filter -tag XM:">2" -in ${SAMPLE_NAME}.bam -out ${SAMPLE_NAME}_mapped_gt2_mismatches.bam

bamtools filter -isMapped false -in ${SAMPLE_NAME}.bam -out ${SAMPLE_NAME}_unmapped.bam

samtools merge -O SAM ${SAMPLE_NAME}_remap.sam ${SAMPLE_NAME}_mapped_gt2_mismatches.bam ${SAMPLE_NAME}_unmapped.bam

echo "Converting to fastq for remapping..."

picard SamToFastq -I ${SAMPLE_NAME}_remap.sam -F ${SAMPLE_NAME}_remap.fastq --QUIET

echo "Extracting reads that align with 2 or fewer mismatches..."

bamtools filter -tag XM:"<=2" -in ${SAMPLE_NAME}.bam -out ${SAMPLE_NAME}_filtered.bam

echo "Finished run on $(date)"
