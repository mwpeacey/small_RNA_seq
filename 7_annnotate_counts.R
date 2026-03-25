library(tidyverse)
library(glue)

data_directory = '~/RNA-seq/Mus_musculus/Pessina_2025_GSE304267/'

################################################################################
# Import data
################################################################################

counts_directory = glue('{data_directory}/counts')

filenames = list.files(counts_directory, pattern="*_all_counts.rds", full.names=TRUE)

counter = 1
for (file in filenames){
  
  temp = readRDS(file = file)
  
  if (counter == 1){
    
    counts = temp
    
  }
  
  else{
    
    counts = bind_rows(counts, temp)
    
  }
  
  remove(temp)
  counter = counter + 1
  
}

samples = read_csv(glue('{data_directory}/sample_info.csv'))

################################################################################
# Reformat counts
################################################################################

wide_counts =
  counts %>%
  mutate(
    ID_clean = if_else(
      # only touch miRNAs with a MIMAT ID that has a numeric suffix, e.g. "MIMAT0000533_1"
      grepl("^MIMAT\\d+_\\d+$", ID),
      sub("(_\\d+)$", "", ID),  # strip the trailing "_<number>"
      ID                        # leave everything else unchanged (tRFs etc.)
    )
  ) %>%
  group_by(ID = ID_clean, sample) %>%
  summarise(counts = sum(n), .groups = "drop")

wide_counts = pivot_wider(wide_counts, values_from = counts, names_from = sample)

wide_counts = as.data.frame(wide_counts)

row.names(wide_counts) = wide_counts$ID

wide_counts = dplyr::select(wide_counts, -c('ID'))

wide_counts[is.na(wide_counts)] = 0

saveRDS(object = wide_counts, file = glue('{data_directory}/wide_counts.rds'))

################################################################################
# RPM
################################################################################

## Total mapped reads

total_mapped_reads = read.table(glue('{data_directory}/total_mapped_reads.txt'), header=F) %>%
  separate(col = 'V1', into = c('sample', 'total_reads'), sep = ':')

rpm = wide_counts
for (column in colnames(wide_counts)){
  
  normalizer = filter(total_mapped_reads, sample == column)$total_reads
  rpm[, column] = (wide_counts[, column] / as.numeric(normalizer))*10^6
  
}

rpm$Geneid = row.names(rpm)

## Add name

gff = read.delim("~/annotation_tables/mm10_miRNA.gff3", header=F, comment.char="#") %>%
  separate(V9, into = c('Geneid', 'Alias', 'Name', 'Derives_from'), sep = ';') %>%
  dplyr::select(c('Geneid', 'Name'))

gff$Geneid = stringr::str_remove(gff$Geneid, 'ID=')
gff$Name = stringr::str_remove(gff$Name, 'Name=')

rpm = merge(rpm, gff, by = 'Geneid', all.x = T)

rpm[!grepl('MIMAT', rpm$Geneid),]$Name = rpm[!grepl('MIMAT', rpm$Geneid),]$Geneid

## Trim names

rpm[grepl('MIMAT', rpm$Geneid),]$Name = stringr::str_remove(rpm[grepl('MIMAT', rpm$Geneid),]$Name,
                                                            'mmu-')

saveRDS(object = rpm, file = glue('{data_directory}/bed_intersect_rpm.rds'))

################################################################################
# Pivot longer
################################################################################

long_counts = pivot_longer(rpm, cols = colnames(wide_counts)) %>%
  dplyr::rename(sample = 'name', RPM = 'value') %>%
  merge(samples)

long_counts = long_counts %>%
  dplyr::filter(Geneid != 'unassigned') %>%
  mutate(type = case_when(grepl('MIMAT', Geneid) ~ 'miRNA',
                          grepl('other-tRF3', Geneid) ~ 'other-tRF3',
                          grepl('tRF5', Geneid) ~ 'tRF5',
                          grepl('tRF3a', Geneid) ~ 'tRF3a',
                          grepl('tRF3b', Geneid) ~ 'tRF3b',
                          grepl('internal', Geneid) ~ 'internal-tRF'))

saveRDS(object = long_counts, file = glue('{data_directory}/bed_intersect_long_counts.rds'))
