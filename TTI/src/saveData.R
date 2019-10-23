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
  mutate(med = log2(med + 1)) %>%
  select(-(pval)) %>%
  ungroup() -> globalData

as_tibble(data[, 1:104]) %>%
  gather(col, fpkm, -(Gene_ID)) %>%
  rename(geneId = Gene_ID) %>%
  separate(col, c("species", "tissue", "assay", "repl"), sep = "[_.]") %>%
  mutate(fpkm = log2(fpkm + 1)) %>%
  group_by(geneId, species, tissue, assay) %>%
  summarise(med = median(fpkm), min = min(fpkm), max = max(fpkm)) %>%
  gather(type, fpkm, (med:max)) %>%
  unite(colId, species, tissue, assay, type) %>%
  spread(colId, fpkm) -> fpkm

library(biomaRt)
mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl",  host = "dec2016.archive.ensembl.org")
genes <- getBM(c("ensembl_gene_id","chromosome_name", "external_gene_name", "description", 
                      "mmusculus_homolog_ensembl_gene", "mmulatta_homolog_ensembl_gene",
                      "oanatinus_homolog_ensembl_gene", "ggallus_homolog_ensembl_gene",
                      "mdomestica_homolog_ensembl_gene"), "ensembl_gene_id", data$Gene_ID, mart)
colnames(genes) <- c("geneId_Human", "chr_Human", "geneName", colnames(genes)[-(1:3)])
species <- c("hsapiens" = "Human", "mmusculus" = "Mouse", "mmulatta" = "Macaque", 
             "mdomestica" = "Opossum", "oanatinus" = "Platypus", "ggallus" = "Chicken")
for(sp in names(species)[-1]) {
  mart <- useMart("ensembl", dataset = paste0(sp, "_gene_ensembl"),  host = "dec2016.archive.ensembl.org")
  newGenes <- getBM(c("ensembl_gene_id", "chromosome_name"), 
                    "ensembl_gene_id", genes[[paste0(sp, "_homolog_ensembl_gene")]], mart)
  colnames(newGenes) <- paste(c("geneId", "chr"), species[sp], sep = "_")
  by <- paste0(sp, "_homolog_ensembl_gene")
  names(by) <- paste0("geneId_", species[sp])
  genes <- inner_join(newGenes, genes, by = by)
}

right_join(genes, select(globalData, geneId), by = c("geneId_Human" = "geneId")) %>%
  re

library(jsonlite)
writeLines(c(paste0("var data = ", toJSON(globalData), ";"),
             paste0("var fpkm = ", toJSON(fpkm, dataframe = "columns"), ";"),
             paste0("var geneInfo = ", toJSON(genes, dataframe = "columns"), ";")), "data.js")
      