library(tidyverse)
library(glue)

args = commandArgs(TRUE)

data = args[1]
sample = args[2]
genome = args[3]

print(glue('Counting reads from sample {sample} in directory {data}'))

# Import tRF info

tRFa_info = read_csv(glue('/grid/schorn/home/mpeacey/scripts/tRF_target_prediction/import/{genome}_tRF3a.csv'))
tRFb_info = read_csv(glue('/grid/schorn/home/mpeacey/scripts/tRF_target_prediction/import/{genome}_tRF3b.csv'))

################################################################################
# tRFs
################################################################################

print('Counting tRFs...')

tRFs = read.table(glue('{data}/bed_intersect/{sample}_tRNA_intersect.bed'), header=F)

tRFs = dplyr::rename(tRFs, tRNA = V1, read_start = V2, read_end = V3, read = V4, annotation_start = V14, annotation_end = V15) %>%
  mutate(read_length = (read_end - read_start)) %>%
  mutate(class = case_when((annotation_end - read_end) <= 3 ~ 'other-tRF3',
                          (read_start - annotation_start) <= 3 ~ 'tRF5', 
                          T ~ 'internal-tRF')) %>%
  mutate(class = case_when(class == 'other-tRF3' & (annotation_end - read_start) >= 14 & (annotation_end - read_start) < 20 ~ 'tRF3a',
                           class == 'other-tRF3' & read_length >= 20 & read_length < 24 ~ 'tRF3b',
                           T ~ class)) %>%
  separate('tRNA', into = c('A', 'B', 'C', 'D'), sep = '-') %>%
  unite('tRNA', c('B', 'C'), sep = '-') %>%
  unite('ID', c('tRNA', 'class'), sep = '_', remove = F) %>%
  select(c('tRNA', 'ID', 'read_start', 'read_end', 'read', 'annotation_start', 'annotation_end', 'read_length', 'class'))

tRFs$sample = sample

tRF3_counts = filter(tRFs, class == 'tRF3a' | class == 'tRF3b') %>%
  group_by(class, tRNA, sample) %>%
  summarise(n = n())

tRF3a_counts = filter(tRF3_counts, class == 'tRF3a') %>%
  rowwise() %>%
  mutate(
    match_row = list(tRFa_info %>% 
                       filter(str_detect(source_tRNAs, fixed(tRNA))) %>% 
                       select(sequence, unique_name))
  ) %>%
  unnest(cols = c(match_row)) %>%
  group_by(sample, unique_name, sequence) %>%
  summarise(total_count = sum(n), .groups = 'drop')

tRF3b_counts = filter(tRF3_counts, class == 'tRF3b') %>%
  rowwise() %>%
  mutate(
    match_row = list(tRFb_info %>% 
                       filter(str_detect(source_tRNAs, fixed(tRNA))) %>% 
                       select(sequence, unique_name)) 
  ) %>%
  unnest(cols = c(match_row)) %>%
  group_by(sample, unique_name, sequence) %>%
  summarise(total_count = sum(n), .groups = 'drop')

################################################################################
# miRNAs
################################################################################

print('Counting miRNAs...')

miRNAs = read.table(glue('{data}/bed_intersect/{sample}_miRNAs.bed'), header=F)

miRNAs = dplyr::rename(miRNAs, read_chromosome = V1, read_start = V2, read_end = V3, 
                       read = V4, read_strand = V6, annotation_chromosome = V7,
                       annotation_start = V8, annotation_end = V9, annotation = V10,
                       annotation_strand = V12) %>%
  mutate(read_length = read_end - read_start) %>%
  mutate(read_length = (read_end - read_start)) %>%
  filter(read_length > 15) %>%
  mutate(ID = annotation) %>%
  mutate(source_tRNA = NA) %>%
  select(-c('V5', 'V11', 'V13', 'V14', 'V15'))

miRNAs$sample = sample

miRNA_counts = miRNAs %>%
  group_by(ID, sample) %>%
  summarise(n = n())

################################################################################
# Unassigned
################################################################################

unassigned = read.table(glue('{data}/bed_intersect/{sample}_unassigned.bed'), header=F)

unassigned$ID = 'unassigned'
unassigned$sample = sample

unassigned_counts = unassigned %>%
  group_by(ID, sample) %>%
  summarise(n = n())

head(unassigned_counts)

################################################################################
# Build counts table
################################################################################

tRF3a_counts = tRF3a_counts %>%
  mutate(class = "tRF3a")

tRF3b_counts = tRF3b_counts %>%
  mutate(class = "tRF3b")
 
tRF_counts = tRFs %>%
  group_by(ID, sample) %>%
  summarise(n = n())

final_counts = bind_rows(tRF_counts, miRNA_counts, unassigned_counts)

saveRDS(object = final_counts, file = glue('{data}/bed_intersect/counts/{sample}_raw_counts.rds'))

