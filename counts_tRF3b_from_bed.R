## Same as counts_from_bed.R (identical outputs), plus tRF3b-only counts that
## keep the full source tRNA name. tRF3a reads are excluded from the new outputs.
##
##   Rscript counts_tRF3b_from_bed.R <data directory> <sample> <genome>
##
## Additional outputs (in {data}/bed_intersect/counts/):
##   {sample}_tRF3b_sequence_counts.rds : one row per unique tRF3b sequence in
##       {genome}_tRF3b.csv (unique_name, tDRNamer_ID, sequence, source_tRNAs,
##       total_count),
##       zero-filled.
##   {sample}_tRF3b_tRNA_counts.rds : one row per full tRNA name (e.g.
##       tRNA-Arg-TCT-1-1, as written in source_tRNAs), zero-filled.

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
                           T ~ class)) 

tRFs$sample = sample

all_tRFs = tRFs %>%
  separate('tRNA', into = c('A', 'B', 'C', 'D'), sep = '-') %>%
  unite('tRNA', c('B', 'C'), sep = '-') %>%
  unite('ID', c('tRNA', 'class'), sep = '_', remove = F) %>%
  select(c('tRNA', 'ID', 'read_start', 'read_end', 'read', 'annotation_start', 'annotation_end', 'read_length', 'class', 'sample'))

tRF3_counts = tRFs %>%
  filter(class == "tRF3b" | class == "tRF3a") %>%
  rowwise() %>%
  mutate(
    match_row = list(
      tRFb_info %>%
        filter(str_detect(source_tRNAs, fixed(tRNA))) %>%
        select(sequence, unique_name)
    )
  ) %>%
  unnest(cols = c(match_row)) %>%
  group_by(sample, unique_name, sequence) %>%
  summarise(total_count = n(), .groups = "drop") %>%
  right_join(tRFb_info %>% select(sequence, unique_name), by = c("sequence","unique_name")) %>%
  mutate(total_count = replace_na(total_count, 0))

tRF3_counts$sample = sample

################################################################################
# tRF3b only, by full tRNA name and by unique tRF3b sequence
################################################################################

print('Counting tRF3b reads...')

# tDRNamer ID column in {genome}_tRF3b.csv (matched by name, case-insensitive)
tDR_col = grep('tdr', names(tRFb_info), ignore.case = TRUE, value = TRUE)
if (length(tDR_col) != 1) {
  stop(glue('Expected exactly one tDRNamer column (name containing "tDR") in {genome}_tRF3b.csv, ',
            'found {length(tDR_col)}. Columns: {paste(names(tRFb_info), collapse = ", ")}'))
}

# Strip any prefix up to and including "tRNA-" (e.g. "Mus_musculus_tRNA-"),
# so names match whether or not the species prefix is present.
normalise_tRNA = function(x) str_remove(str_trim(x), '^.*?tRNA-')

# One row per (tRF3b sequence, source tRNA). source_tRNAs (e.g.
# "tRNA-Ala-AGC-10-1_tRNA-Ala-AGC-5-1") is split at each "_" that precedes
# "tRNA-" so matching is exact: a substring match would let tRNA-Glu-CTC-1-1
# also match tRNA-Glu-CTC-1-10, -1-11, etc.
tRNA_lookup = tRFb_info %>%
  select(unique_name, sequence, source_tRNAs) %>%
  mutate(tRNA_name = str_split(source_tRNAs, '_(?=tRNA-)|[,;|[:space:]]+')) %>%
  unnest(tRNA_name) %>%
  filter(tRNA_name != '') %>%
  mutate(tRNA_key = normalise_tRNA(tRNA_name)) %>%
  distinct()

multi = tRNA_lookup %>% count(tRNA_key) %>% filter(n > 1)
if (nrow(multi) > 0) {
  warning(glue('{nrow(multi)} tRNA(s) are listed as a source of more than one tRF3b sequence ',
               '(e.g. {paste(head(multi$tRNA_key, 3), collapse = ", ")}). ',
               'Reads from these tRNAs are counted towards each of those sequences.'))
}

tRF3b = tRFs %>%
  filter(class == 'tRF3b') %>%
  mutate(tRNA_key = normalise_tRNA(tRNA))

print(glue('{nrow(tRF3b)} tRF3b reads from {n_distinct(tRF3b$tRNA)} tRNAs'))

# Counts per full tRNA name
tRF3b_tRNA_counts = tRF3b %>%
  count(tRNA, tRNA_key, name = 'total_count') %>%
  full_join(tRNA_lookup %>% distinct(tRNA_key, tRNA_name), by = 'tRNA_key') %>%
  mutate(tRNA = coalesce(tRNA_name, tRNA),
         total_count = replace_na(total_count, 0L),
         sample = sample) %>%
  select(sample, tRNA, total_count) %>%
  arrange(desc(total_count), tRNA)

# Counts per unique tRF3b sequence
n_unmatched = sum(!tRF3b$tRNA_key %in% tRNA_lookup$tRNA_key)
if (nrow(tRF3b) > 0 && n_unmatched == nrow(tRF3b)) {
  stop(glue('None of the tRF3b reads matched a tRNA in {genome}_tRF3b.csv. ',
            'Example read tRNA: "{tRF3b$tRNA[1]}"; example source_tRNAs: "{tRFb_info$source_tRNAs[1]}". ',
            'Check the tRNA naming/separator in source_tRNAs.'))
}
if (n_unmatched > 0) {
  unmatched_tRNAs = unique(tRF3b$tRNA[!tRF3b$tRNA_key %in% tRNA_lookup$tRNA_key])
  print(glue('{n_unmatched} tRF3b reads ({round(100 * n_unmatched / nrow(tRF3b), 2)}%) came from ',
             '{length(unmatched_tRNAs)} tRNA(s) not in {genome}_tRF3b.csv, e.g. ',
             '{paste(head(unmatched_tRNAs, 5), collapse = ", ")}'))
}

tRF3b_sequence_counts = tRF3b %>%
  inner_join(tRNA_lookup %>% select(-tRNA_name), by = 'tRNA_key') %>%
  count(unique_name, sequence, name = 'total_count') %>%
  right_join(tRFb_info %>% select(unique_name, tDRNamer_ID = !!sym(tDR_col), sequence, source_tRNAs),
             by = c('unique_name', 'sequence')) %>%
  mutate(total_count = replace_na(total_count, 0L),
         sample = sample) %>%
  select(sample, unique_name, tDRNamer_ID, sequence, source_tRNAs, total_count) %>%
  arrange(desc(total_count), unique_name)

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

tRF_counts = all_tRFs %>%
  group_by(ID, sample) %>%
  summarise(n = n())

final_counts = bind_rows(tRF_counts, miRNA_counts, unassigned_counts)

saveRDS(object = final_counts, file = glue('{data}/bed_intersect/counts/{sample}_all_counts.rds'))

saveRDS(object = tRF3_counts, file = glue('{data}/bed_intersect/counts/{sample}_tRF3_counts.rds'))

saveRDS(object = all_tRFs, file = glue('{data}/bed_intersect/{sample}_tRF_bed_intersect.rds'))

saveRDS(object = tRF3b_sequence_counts, file = glue('{data}/bed_intersect/counts/{sample}_tRF3b_sequence_counts.rds'))

saveRDS(object = tRF3b_tRNA_counts, file = glue('{data}/bed_intersect/counts/{sample}_tRF3b_tRNA_counts.rds'))
