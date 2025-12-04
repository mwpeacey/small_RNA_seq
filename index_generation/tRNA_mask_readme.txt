1. The tRNA annotation file was downloaded from gtRNAdb:
wget http://gtrnadb.ucsc.edu/genomes/eukaryota/Hsapi38/mm10-tRNAs.tar.gz

2. Psuedogenes were removed to leave only the high-confidence set: 
grep -v "NNN" mm10-tRNAs.bed > mm10-tRNAs-high-confidence.bed

3. Mask mouse genome for tRNA sequence:
bedtools maskfasta -fi /grid/schorn/home/shared/mm10_genome_bowtie2_UCSC/mm10.fasta \
		   -fo /grid/schorn/home/mpeacey/index/bowtie2/mm10/masktRNA_mm10.fasta \
		   -bed /grid/schorn/home/mpeacey/index/bowtie2/mm10/mm10-tRNAs-high-confidence.bed

4. Build bowtie2 index of tRNA-masked genome:
qsub build_bowtie2_index.sh /grid/schorn/home/mpeacey/index/bowtie2/mm10 \
			   /grid/schorn/home/mpeacey/index/bowtie2/mm10/masktRNA_mm10.fasta \
			   masktRNA_mm10
