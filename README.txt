################################################################
Work flow for analysis of small RNA-seq data
################################################################

Scripts should be executed in order using the corresponding wrapper script, which will loop through all samples in a directory
and submit jobs to run in parallel.

1. If necessary, download fastq files using the metadata file downloaded from SRA explorer (0_download_sra.sh)
2. Trim adapters and filter by size and quality (1_adapter_trim.sh) 
3. If necessary, remove spike-in reads for later quantification (1.5_remove-spike.sh)
4. Extract CCA-terminating reads and clip the CCA (2_CCA_extract.sh)
5. Align all reads to the genome, which will provide a total mapped read count for normalization (3_align_all.sh)
6. Align both CCA and non-CCA reads to tRNA genomic sequence with the rest of the genome masked (4_align_tRF.sh)
7. Align any non-aligning reads from the preceding step to the genome with tRNA sequence masked (5_align_remaining.sh)
8. Filter bam output to remove unmapped reads, or reads with more than 2 mismatches to the reference. Also converts to bed format (6_filter_alignments.sh)
9. Intersect mapped reads with the tRNA and miRNA annotations (7_bed_intersect.sh)
10. Count total mapped reads from step 5 for normalization (8_total_mapped.sh)
11. Counts miRNA and tRF (3' and 5') reads (9_counts_from_bed.sh)

The normalization and count files should be moved to a local folder for further analysis in R.
