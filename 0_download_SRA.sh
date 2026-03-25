#!/bin/bash
#SBATCH --job-name=download_SRA
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=download_SRA_output.txt
#SBATCH --error=download_SRA_output.txt

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

mv /grid/schorn/home/mpeacey/scripts/small_RNA_seq/download_SRA_output.txt $2/fastq
cp /grid/schorn/home/mpeacey/scripts/small_RNA_seq/0_download_SRA.sh $2/scripts/0_download_SRA.sh
