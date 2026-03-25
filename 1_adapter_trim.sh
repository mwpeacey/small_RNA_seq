#!/bin/bash
#SBATCH --job-name=adapter_trim
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=48:00:00
#SBATCH --output=adapter_trim_output.txt
#SBATCH --error=adapter_trim_output.txt

# Description
#
# Trims sequencing adapters from reads, quality and length filters, and returns a quality control summary.

# Requirements
#
# Environment: small_RNA_sequencing
# cutadapt v4.6
# fastQC v0.12.1
# FASTX toolkit v0.0.14

echo "##################################################"
echo "New run started on $(date)"
echo "Running on sample {$2} in {$3}"
echo "##################################################"

SAMPLE=$1
SAMPLE_NAME=$2
HOME_DIRECTORY=$3
FASTQ_DIRECTORY=$4
TRIM=$5
POLY_A=$6

cd "${FASTQ_DIRECTORY}"

echo "Processing sample ${SAMPLE_NAME}"

###############################################################################
# Detect adapter/adaptor fasta/fa file
###############################################################################

ADAPTER_FILE=""

for base in adapter adaptor; do
  for ext in fasta fa; do
    cand="${base}.${ext}"
    if [[ -f "${cand}" ]]; then
      ADAPTER_FILE="${cand}"
      break 2   # break out of both loops
    fi
  done
done

if [[ -z "${ADAPTER_FILE}" ]]; then
  echo "ERROR: No adapter/adaptor file found (tried adapter/adaptor with .fasta/.fa) in ${FASTQ_DIRECTORY}" >&2
  exit 1
fi

echo "Using adapter file: ${ADAPTER_FILE}"

###############################################################################

if [[ "${POLY_A}" == "T" ]]; then

    cutadapt -a "file:${ADAPTER_FILE}" -u "${TRIM}" -m 14 -M 50 \
             --rename='{id}_{cut_prefix}' \
             -o "cutadapt_processed/${SAMPLE_NAME}_cut.fastq" \
             --poly-a \
             "${SAMPLE}"

else

    cutadapt -a "file:${ADAPTER_FILE}" -u "${TRIM}" -m 14 -M 50 \
             --rename='{id}_{cut_prefix}' \
             -o "cutadapt_processed/${SAMPLE_NAME}_cut.fastq" \
             "${SAMPLE}"

fi

fastqc "cutadapt_processed/${SAMPLE_NAME}_cut.fastq" -o fastqc

fastq_quality_filter -i "cutadapt_processed/${SAMPLE_NAME}_cut.fastq" \
                     -o "quality_filtered/${SAMPLE_NAME}_filtered.fastq" \
                     -Q33 -q 20 -p 95

fastqc "quality_filtered/${SAMPLE_NAME}_filtered.fastq" -o fastqc

cp /grid/schorn/home/mpeacey/scripts/small_RNA_seq/1_adapter_trim.sh "${HOME_DIRECTORY}/scripts"

echo "Finished run on $(date)"
