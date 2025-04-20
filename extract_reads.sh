#!/bin/bash
#$ -cwd
#$ -pe threads 1
#$ -l m_mem_free=8G
#$ -N extract_reads
#$ -o extract_reads_output.txt
#$ -e extract_reads_output.txt

## Extracts reads of interest from a FASTQ file.

## Requirements
## 

echo "#####################################"
echo "New run started on $(date)"
echo "#####################################"

FASTQ_DIRECTORY=$1
FASTQ=$2
READ_LIST=$3

cd ${FASTQ_DIRECTORY}
touch output.txt

READS=$(cat $READ_LIST)

for READ in ${READS}; do

	echo ${READ}

	cat ${FASTQ} | sed -n "/${READ}/,/>/p" | head -2 | tail -1 >> output.txt

done

echo "Finished run on $(date)"



