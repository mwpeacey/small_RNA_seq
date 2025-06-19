# small_RNA_seq
Scripts for analysis of small RNA-seq data with a focus on tRNA-derived fragments, particularly CCA-terminating 3' tRFs.

## Work flow for analysis of small RNA-seq data

Scripts should be executed in order using the corresponding wrapper script, which will loop through all samples in a directory
and submit jobs to run in parallel.

1. If necessary, download fastq files using the metadata file downloaded from SRA explorer (0_download_sra.sh)
2. Trim adapters and filter by size and quality (1_adapter_trim.sh)
3. If necessary, remove spike-in reads for later quantification (1.5_remove-spike.sh)
4. Align reads to the tRNA annotation (2_align_tRF.sh).
5. Align unmapped reads from the previous step to the genome (3).
6. Count the total number of aligned reads.
7. Intersect reads with the tRNA, miRNA, and piRNA annotations.
8. Count reads.

The normalization and count files should be moved to a local folder for further analysis in R.
