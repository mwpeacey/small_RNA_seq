#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=8G

## Assigns mapped reads to genomic features. tRNA-mapped reads (CCA and non-CCA) are intersected with a tRNA annotation,
## and the remaining reads are intersected with a custom small RNA annotation including miRNAs and piRNAs.

## Requirements
## bamtools

## Inputs
## $1 : data directory 

echo "###########################"
echo "New run started on $(date)"
echo "Analyzing data from {$1}"
echo "###########################"

SAMPLE_NAME=$1
DATA_DIRECTORY=$2
GENOME=$3

cd ${DATA_DIRECTORY}/alignment/alignment_tRNA

echo "Assigning tRNA reads..."

intersectBed -wb -bed -a ${SAMPLE_NAME}_filtered.bam \
-b /grid/schorn/home/mpeacey/index/bowtie2/${GENOME}/${GENOME}_tRNA/tRNA_full_named.bed \
> ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_tRNA_intersect.bed

cd ${DATA_DIRECTORY}/alignment/alignment_other/

bamToBed -i ${SAMPLE_NAME}_filtered.bam | sort -k1,1 -k2,2n > ${SAMPLE_NAME}_filtered.sorted.bed

echo "Assigning other reads..."

intersectBed -wb -sorted -s -a ${SAMPLE_NAME}_filtered.sorted.bed \
-b /grid/schorn/home/mpeacey/annotations/${GENOME}/miRNA/${GENOME}_miRNA.sorted.bed \
> ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_miRNAs.bed

echo "Finished run on $(date)"

