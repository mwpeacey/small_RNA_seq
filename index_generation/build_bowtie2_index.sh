#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=32G
#$ -N build_bowtie2_index
#$ -o build_bowtie2_index_output.txt
#$ -e build_bowtie2_index_output.txt

## Requirements
## bowtie2

## Inputs
## $1 : index directory
## $2 : FASTA file containing sequences
## $3: basename

echo "###########################"
echo "New run started on $(date)"
echo "Index depositied in {$1}"
echo "###########################"

INDEX_DIRECTORY=$1
INPUT=$2
BASENAME=$3

cd ${INDEX_DIRECTORY}

## Build bowtie index of genome:

bowtie2-build ${INPUT} ${BASENAME}

echo "Finished run on $(date)"

mv /grid/schorn/home/mpeacey/scripts/build_index/build_bowtie2_index_output.txt ${INDEX_DIRECTORY}
cp /grid/schorn/home/mpeacey/scripts/build_index/build_bowtie2_index.sh ${INDEX_DIRECTORY}
