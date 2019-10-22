data <- read.table("ex2plorer.txt", header = T, stringsAsFactors = F)

library(tidyverse)
library(stringi)
as_tibble(data[, 1:104]) %>%
  gather(col, fpkm, -(Gene_ID)) %>%
  rename(geneId = Gene_ID) %>%
  separate(col, c("species", "tissue", "assay", "repl"), sep = "[_.]") %>%
  filter(assay == "TR") %>%
  group_by(geneId, species, tissue) %>%
  summarise(med = median(fpkm)) %>%
  group_by(geneId, tissue) %>%
  summarise(med = median(med)) -> medians


as_tibble(data[, c(1, 141:154)]) %>%
  select(-(Brain.TR_median)) %>%
  rename(geneId = Gene_ID) %>%
  gather(col, value, -(geneId)) %>%
  separate(col, c("tissue", "type"), sep = "[.]") %>%
  mutate(type = ifelse(is.na(type), "delta", type),
         tissue = stri_sub(tissue, from = 7)) %>%
  mutate(type = ifelse(type == "p_value", "pval", type)) %>%
  mutate(type = ifelse(type == "p_value_corrected", "padj", type)) %>%
  filter(type != "color" & type != "size") %>%
  mutate(value = as.numeric(value)) %>%
  spread(type, value) %>%
  mutate(pval = pval * 2) %>%
  group_by(tissue) %>%
  mutate(padj = p.adjust(pval, method = "BH")) %>%
  inner_join(medians, by = c("geneId", "tissue")) %>%
  mutate(med = log2(med + 1)) -> globalData
  #filter(padj_new < 0.1) %>% View()
  ggplot() + geom_point(aes(-log10(padj_bh), -log10(padj_new))) + facet_wrap(~tissue) + ylim(0, 10) + xlim(0, 10)
    select(pval) %>% unlist() %>% max()

as_tibble(data[, 1:104]) %>%
  gather(col, fpkm, -(Gene_ID)) %>%
  rename(geneId = Gene_ID) %>%
  separate(col, c("species", "tissue", "assay", "repl"), sep = "[_.]") %>%
  mutate(fpkm = log2(fpkm + 1)) %>%
  group_by(geneId, species, tissue, assay) %>%
  summarise(med = median(fpkm), min = min(fpkm), max = max(fpkm)) -> fpkm

library(jsonlite)
writeLines(c(paste0("var data = ", toJSON(globalData), ";"),
             paste0("var fpkm = ", toJSON(fpkm, dataframe = "columns"), ";")), "data.js")
    