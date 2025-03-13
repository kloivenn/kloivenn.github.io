library(tidyverse)

as_tibble(t(read.table("data/st_2"))) %>%
  rename(sample = V1, condition = V2) %>%
  separate(condition, c("tmp", "condition")) %>%
  select(-tmp) -> sampleTable

tpmsLong %>%
  select(gene_id, condition, patient, timePoint, tpm) %>%
  spread(timePoint, tpm) %>%
  group_by(patient) %>%
  mutate(diff = post - pre, av = (post + pre)/2) %>%
  group_by(gene_id, condition) %>%
  summarise(pvalue = t.test(diff, df = n() - 1)$p.value) %>%
  group_by(condition) %>%
  mutate(fdr = p.adjust(pvalue, method = "BH")) %>%
  filter(fdr < 0.1) %>%
  tally()

read_csv("data/RawCounts.csv.gz") %>%
  as.data.frame() %>%
  column_to_rownames("X1") %>%
  as.matrix() -> counts

tpms <- log2(t(t(counts)/colSums(counts)) * 1000000 + 1)
tpms <- tpms[apply(tpms, 1, max) > 1, ]
pvals <- apply(tpms, 1,  function(row) {
  t.test(row[sampleTable$condition == "Current"], row[sampleTable$condition == "Never"])$p.value
})
logfoldchange
padjs <- p.adjust(pvals, method = "BH")
  
  rename(gene = X1) %>%
  
  
  gather(sample, count, -gene) %>%
  group_by(sample) %>%
  mutate(tpm = count / sum(count) * 1000000) %>%
  left_join(sampleTable) %>%
  filter(condition != "Past") %>%
  ungroup() %>%
  select(gene, tpm, condition) %>%
  spread(condition, tpm) %>%
  
