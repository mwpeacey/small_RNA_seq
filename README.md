# small_RNA_seq
Scripts for analysis of small RNA-seq data with a focus on tRNA-derived fragments, particularly CCA-terminating 3' tRFs.

# Work flow for analysis of small RNA-seq data

Scripts should be executed in order using the corresponding wrapper script, which will loop through al$
and submit jobs to run in parallel.

1. If necessary, download fastq files using the metadata file downloaded from SRA explorer (0_download$
2. Trim adapters and filter by size and quality (1_adapter_trim.sh)
3. If necessary, remove spike-in reads for later quantification (1.5_remove-spike.sh)
4. Extract CCA-terminating reads and clip the CCA (2_CCA_extract.sh)
5. Align all reads to the genome, which will provide a total mapped read count for normalization (3_al$
6. Align both CCA and non-CCA reads to tRNA genomic sequence with the rest of the genome masked (4_ali$
7. Align any non-aligning reads from the preceding step to the genome with tRNA sequence masked (5_ali$
8. Filter bam output to remove unmapped reads, or reads with more than 2 mismatches to the reference. $
9. Intersect mapped reads with the tRNA and miRNA annotations (7_bed_intersect.sh)
10. Count total mapped reads from step 5 for normalization (8_total_mapped.sh)
11. Counts miRNA and tRF (3' and 5') reads (9_counts_from_bed.sh)

The normalization and count files should be moved to a local folder for further analysis in R.
