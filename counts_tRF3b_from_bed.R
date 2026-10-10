library(tidyverse)
library(glue)

## Counts tRF3b reads only (tRF3a reads are excluded), keeping the full name of
## the source tRNA rather than collapsing to isoacceptor (e.g. Arg-TCT).
##
## Same arguments and inputs as counts_from_bed.R:
##   Rscript counts_tRF3b_from_bed.R <data directory> <sample> <genome>
##
## Outputs (in {data}/bed_intersect/counts/):
##   {sample}_tRF3b_sequence_counts.rds : one row per unique tRF3b sequence in
##       {genome}_tRF3b.csv (unique_name, sequence, source_tRNAs, total_count).
##       Zero-filled for sequences with no reads.
##   {sample}_tRF3b_tRNA_counts.rds : one row per full tRNA name (e.g.
##       Mus_musculus_tRNA-Arg-TCT-1-1), as assigned by the aligner.
##       Zero-filled for tRNAs listed in source_tRNAs with no reads.

args = commandArgs(TRUE)

data = args[1]
sample = args[2]
genome = args[3]

print(glue('Counting tRF3b reads from sample {sample} in directory {data}'))

################################################################################
# tRF3b sequence info
################################################################################

tRFb_info = read_csv(glue('/grid/schorn/home/mpeacey/scripts/tRF_target_prediction/import/{genome}_tRF3b.csv'))

# Strip any prefix up to and including "tRNA-" (e.g. "Mus_musculus_tRNA-"),
# so names match whether or not the species prefix is present.
normalise_tRNA = function(x) str_remove(str_trim(x), '^.*?tRNA-')

# One row per (tRF3b sequence, source tRNA). source_tRNAs is split into
# individual names so that matching is exact: a substring match would let
# tRNA-Arg-TCT-1-1 also match tRNA-Arg-TCT-1-10, -1-11, etc.
tRNA_lookup = tRFb_info %>%
  select(unique_name, sequence, source_tRNAs) %>%
  mutate(tRNA_name = str_split(source_tRNAs, '[,;|/[:space:]]+')) %>%
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

################################################################################
# Classify tRNA reads (identical rules to counts_from_bed.R) and keep tRF3b
################################################################################

print('Counting tRF3b reads...')

tRFs = read.table(glue('{data}/bed_intersect/{sample}_tRNA_intersect.bed'), header=F)

tRF3b = dplyr::rename(tRFs, tRNA = V1, read_start = V2, read_end = V3, read = V4, annotation_start = V14, annotation_end = V15) %>%
  mutate(read_length = (read_end - read_start)) %>%
  mutate(class = case_when((annotation_end - read_end) <= 3 ~ 'other-tRF3',
                           (read_start - annotation_start) <= 3 ~ 'tRF5',
                           T ~ 'internal-tRF')) %>%
  mutate(class = case_when(class == 'other-tRF3' & (annotation_end - read_start) >= 14 & (annotation_end - read_start) < 20 ~ 'tRF3a',
                           class == 'other-tRF3' & read_length >= 20 & read_length < 24 ~ 'tRF3b',
                           T ~ class)) %>%
  filter(class == 'tRF3b') %>%
  mutate(tRNA_key = normalise_tRNA(tRNA))

print(glue('{nrow(tRF3b)} tRF3b reads from {n_distinct(tRF3b$tRNA)} tRNAs'))

################################################################################
# Counts per full tRNA name
################################################################################

tRF3b_tRNA_counts = tRF3b %>%
  count(tRNA, tRNA_key, name = 'total_count') %>%
  full_join(tRNA_lookup %>% distinct(tRNA_key, tRNA_name), by = 'tRNA_key') %>%
  mutate(tRNA = coalesce(tRNA, tRNA_name),
         total_count = replace_na(total_count, 0L),
         sample = sample) %>%
  select(sample, tRNA, total_count) %>%
  arrange(desc(total_count), tRNA)

################################################################################
# Counts per unique tRF3b sequence
################################################################################

matched = tRF3b %>%
  inner_join(tRNA_lookup %>% select(-tRNA_name), by = 'tRNA_key')

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

tRF3b_sequence_counts = matched %>%
  count(unique_name, sequence, name = 'total_count') %>%
  right_join(tRFb_info %>% select(unique_name, sequence, source_tRNAs), by = c('unique_name', 'sequence')) %>%
  mutate(total_count = replace_na(total_count, 0L),
         sample = sample) %>%
  select(sample, unique_name, sequence, source_tRNAs, total_count) %>%
  arrange(desc(total_count), unique_name)

################################################################################
# Save
################################################################################

dir.create(glue('{data}/bed_intersect/counts'), showWarnings = FALSE, recursive = TRUE)

saveRDS(object = tRF3b_sequence_counts, file = glue('{data}/bed_intersect/counts/{sample}_tRF3b_sequence_counts.rds'))

saveRDS(object = tRF3b_tRNA_counts, file = glue('{data}/bed_intersect/counts/{sample}_tRF3b_tRNA_counts.rds'))

print('Done.')
