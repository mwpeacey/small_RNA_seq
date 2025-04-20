#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=16G
#$ -N download_SRA
#$ -o download_SRA_output.txt
#$ -e download_SRA_output.txt

## Description
## Downloads selected fastq files input from an SRA explorer tsv file (https://sra-explorer.info)

## Requirements
## sra-tools

## Inputs
## $1 : metadata downloaded from SRA explorer
## $2 : home directory

echo "###########################"
echo "New run started on $(date)"

cd $2

mkdir -p fastq
mkdir -p scripts
cd fastq

codes=$(cut -f1 $1 | tail -n +2) 

for code in $codes; do
	echo "Downloading SRR code: ${code}"
	fastq-dump ${code}
	echo "Download complete."
done

echo "Finished on $(date)."
echo "###########################"

mv /grid/schorn/home/mpeacey/scripts/small_RNA_seq/download_SRA_output.txt $2/scripts
cp /grid/schorn/home/mpeacey/scripts/small_RNA_seq/0_download_SRA.sh $2/scripts
