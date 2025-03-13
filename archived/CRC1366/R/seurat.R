library(tidyverse)
library(sleepwalk)
library(Seurat)

seu <- read_rds("cerebellum_lukas_seu.rds")
cell_cycle <- read_rds("cell_cycle.rds")

DimPlot(seu)

sleepwalk(Embeddings(Reductions(seu, "umap")), Embeddings(Reductions(seu, "pca")))

ggplot(as.data.frame(Embeddings(Reductions(seu, "umap")))) + 
  geom_point(aes(UMAP_1, UMAP_2, colour = cell_cycle$`G1/S`)) +
  scale_colour_viridis_c()

sleepwalk(Embeddings(Reductions(seu, "umap")), Embeddings(Reductions(seu, "pca")),
          saveToFile = "../src/cerebellum_lukas.html")
