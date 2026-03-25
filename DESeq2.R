################################################################################
# DESeq2
################################################################################

library(tidyverse)
library(glue)
library(DESeq2)

data_directory = '~/RNA-seq/Mus_musculus/Pessina_2025_GSE304267/'
contrast = c('pbody', 'pbody', 'cytoplasm')

# Import samples

samples = read_csv(glue('{data_directory}/sample_info.csv'))

samples$tissue = factor(samples$tissue)
samples$pbody = factor(samples$pbody)

wide_counts = read_rds(file = glue('{data_directory}/wide_counts.rds'))

# Run DESeq2

counter = 1
for (tissue in 1:length(unique(samples$tissue))){
  
  print(glue('Processing tissue {levels(samples$tissue)[counter]}...'))
  
  sample_subset = dplyr::filter(samples, 
                                tissue == levels(samples$tissue)[counter],
                                method == 'traditional')
  
  input = wide_counts[, sample_subset$sample]
  
  dds = DESeqDataSetFromMatrix(countData = input, 
                               colData = sample_subset, 
                               design = ~pbody)
  
  dds = DESeq(dds)
  
  dds = dds[ rowSums(counts(dds)) >= 1, ]
  
  results = results(dds, 
                    contrast = contrast,
                    independentFiltering = T)
  
  results_df = as.data.frame(results)
  
  results_df$Geneid = row.names(results_df)
  
  ## Add name
  
  gff = read.delim("~/annotation_tables/mm10_miRNA.gff3", header=F, comment.char="#") %>%
    separate(V9, into = c('Geneid', 'Alias', 'Name', 'Derives_from'), sep = ';') %>%
    dplyr::select(c('Geneid', 'Name'))
  
  gff$Geneid = stringr::str_remove(gff$Geneid, 'ID=')
  gff$Name = stringr::str_remove(gff$Name, 'Name=')
  
  results_df = merge(results_df, gff, by = 'Geneid', all.x = T)
  
  results_df[!grepl('MIMAT', results_df$Geneid),]$Name = results_df[!grepl('MIMAT', results_df$Geneid),]$Geneid
  
  ## Trim names
  
  results_df[grepl('MIMAT', results_df$Geneid),]$Name = stringr::str_remove(results_df[grepl('MIMAT', results_df$Geneid),]$Name,
                                                                            'mmu-')
  
  results_df[!grepl('MIMAT', results_df$Geneid),]$Name = stringr::str_remove(results_df[!grepl('MIMAT', results_df$Geneid),]$Name,
                                                                             'tRNA-')
  
  results_df$tissue = levels(samples$tissue)[counter]
  
  head(results_df)
  
  if (counter == 1){
    
    output = results_df
    
  }
  
  else{
    
    output = bind_rows(output, results_df)
    
  }
  
  counter = counter + 1
  
}

saveRDS(object = output, file = glue('{data_directory}/bed_intersect_results.rds'))
