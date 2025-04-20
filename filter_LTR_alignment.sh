#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=16G

## Filters bowtie2-outputted alignments to remove unmapped reads and alignments with more
## than 2 mismatches.

## Requirements
## bamtools

## Inputs
## $1 : directory containing unfiltered .sam format alignments 

echo "###########################"
echo "New run started on $(date)"
echo "Filtering reads from sample {$1} in directory {$2}"
echo "###########################"

SAMPLE_NAME=$1
DATA_DIRECTORY=$2

echo "Filtering all reads..."

cd ${DATA_DIRECTORY}/alignment/alignment_LTRs

#Removes unmapped reads and outputs to .bam format.
samtools view -b -F 4 -o ${SAMPLE_NAME}.bam ${SAMPLE_NAME}.sam 

# Removes reads with more than 2 mismatches to the reference.
bamtools filter -tag XM:"<=2" -in ${SAMPLE_NAME}.bam -out ${SAMPLE_NAME}_filtered.bam

# Converts from .bam format to a .bed file sorted by coordinates.
bamToBed -i ${SAMPLE_NAME}_filtered.bam | sort -k1,1 -k2,2n > ${SAMPLE_NAME}_filtered.sorted.bed

rm ${SAMPLE_NAME}.bam

echo "Finished run on $(date)"

