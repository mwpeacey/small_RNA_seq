#!/bin/bash
#SBATCH --job-name=bed_intersect
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=48:00:00
#SBATCH --output=bed_intersect_output.txt
#SBATCH --error=bed_intersect_output.txt

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

echo "Assigning miRNA reads..."

intersectBed -wb -sorted -s -a ${SAMPLE_NAME}_filtered.sorted.bed \
-b /grid/schorn/home/mpeacey/annotations/${GENOME}/miRNA/${GENOME}_miRNA.sorted.bed \
> ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_miRNAs.bed

#echo "Assigning piRNA reads..."

# Subtract miRNA reads from total filtered reads
#bedtools subtract -A \
#  -a ${SAMPLE_NAME}_filtered.sorted.bed \
#  -b ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_miRNAs.bed \
#  > ${SAMPLE_NAME}_no_miRNAs.bed

# Intersect remaining reads with piRNA annotations
#intersectBed -wb -sorted -s \
#  -a ${SAMPLE_NAME}_no_miRNAs.bed \
#  -b /grid/schorn/home/mpeacey/annotations/${GENOME}/piRNA/${GENOME}_piRNA.sorted.bed \
#  > ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_piRNAs.bed

echo "Return unassigned reads..."

#bedtools subtract -A \
#  -a ${SAMPLE_NAME}_filtered.sorted.bed \
#  -b ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_miRNAs.bed \
#  > ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_unassigned.bed

bedtools intersect -v -s -sorted \
  -a ${SAMPLE_NAME}_filtered.sorted.bed \
  -b /grid/schorn/home/mpeacey/annotations/${GENOME}/miRNA/${GENOME}_miRNA.sorted.bed \
  > ${DATA_DIRECTORY}/bed_intersect/${SAMPLE_NAME}_unassigned.bed

echo "Finished run on $(date)"
