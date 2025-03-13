library(irlba)
library(uwot)
library(sleepwalk)

load("cerebellum_timepoints.RData")

getEmbedding <- function(data) {
  set.seed(12345)
  pca <- prcomp_irlba(data, n = 50)
  umap(pca$x, spread = 5, n_sgd_threads = 1, negative_sample_rate = 3)
}

um13_A <- getEmbedding(e13_A_norm)
um13_B <- getEmbedding(e13_B_norm)
um14 <- getEmbedding(e14_norm)

commonGenes <- intersect(intersect(colnames(e13_A_norm), colnames(e13_B_norm)), colnames(e14_norm))

pca <- prcomp_irlba(rbind(e13_A_norm[, commonGenes], 
                          e13_B_norm[, commonGenes], 
                          e14_norm[, commonGenes]), n = 50)
comFeatures13_A <- e13_A_norm[, commonGenes] %*% pca$rotation
comFeatures13_B <- e13_B_norm[, commonGenes] %*% pca$rotation
comFeatures14 <- e14_norm[, commonGenes] %*% pca$rotation

sleepwalk(list(um13_A, um13_B, um14), 
          list(comFeatures13_A, comFeatures13_B, comFeatures14), 
          same = "features",
          titles = c("e13.5_A", "e13.5_B", "e14.5"), nrow = 1)
