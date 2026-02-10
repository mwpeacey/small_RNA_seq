# small_RNA_seq
[![bioRxiv](https://img.shields.io/badge/bioRxiv-10.64898%2F2026.01.22.698655-B31B1B.svg)](https://doi.org/10.64898/2026.01.22.698655)
[![DOI](https://zenodo.org/badge/927843426.svg)](https://doi.org/10.5281/zenodo.18601791)

Scripts for analysis of small RNA-seq data with a focus on tRNA-derived fragments, particularly CCA-terminating 3' tRFs. These scripts contain absolute file paths from my computing environment at CSHL, provided for reproducibility. 
Users will need to adjust the paths to match their own system.

## Requirements

1. Use index_generation/build_bowtie2_index.sh to build an index from the mature tRNA annotation, minus CCA, downloaded from GtRNAdb (https://gtrnadb.org).
2. Use index_generation/build_bowtie2_index.sh to build an index from the genome, optionally with tRNA sequences masked. See index_generation/tRNA_mask_readme.txt for details. 
3. miRNA annotation. See index_generation/small_RNA_annotation_readme.txt for details. Can be modified to include piRNAs if necessary.
4. Install dependencies with conda env create -f small_RNA_seq.

## Work flow

Scripts should be executed in order using the corresponding wrapper script, which will loop through all samples in a directory
and submit jobs to run in parallel, except for steps 1 and 9, which are executed directly.

1. 0_download_sra.sh : if necessary, download fastq files using the metadata file downloaded from SRA explorer (https://sra-explorer.info) in tsv format.
2. 1_adapter_trim.sh : trim adapters and filter by size and quality. Requires one or more adapter sequences in the fastq directory under "adapter.fa".
3. 1.5_remove-spike.sh : if necessary, remove spike-in reads for later quantification.
4. 2_align_tRF.sh : align reads to the tRNA annotation.
5. 3_align_remaining.sh : align unmapped reads from the previous step to the genome.
6. 4_total_mapped.sh : count the total number of aligned reads for later normalization.
7. 5_bed_intersect.sh : intersect reads with the tRNA, miRNA, and piRNA annotations.
8. 6_counts_from_bed.sh : classify and count reads. The normalization and count files should be moved to a local folder for further analysis (step 9).
9. 7_annnotate_counts.R : pool reads from across samples, normalize to total mapped or spike-in reads, and export for differential expression analysis.

