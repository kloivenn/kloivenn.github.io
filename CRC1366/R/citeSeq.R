library(Matrix)
library(irlba)
library(uwot)
library(ggplot2)
library(sleepwalk)

rawCounts <- readRDS("citeSeq_RNA.rds")
rawCounts[5:10, 5:10]

sf <- colSums(rawCounts)
sf[1:10]

normCounts <- t(t(rawCounts/sf * 10000))
pca <- prcomp_irlba(log1p(t(normCounts)), n = 50)
set.seed(123)
um <- umap(pca$x, min_dist = 0.3, n_neighbors = 30, spread = 3)

ggplot() + geom_point(aes(um[, 1], um[, 2]), size = 1)

sleepwalk(um, pca$x)

###scaling
library(sparseMatrixStats)
library(scales)
library(rlc)

#getting variable genes
means <- rowMeans(normCounts)
vars <- rowVars(normCounts)
plot(means, vars/means, pch = ".", log = "xy", col = adjustcolor("black", 0.4))
abline(h = mean(1/sf * 10000), col = adjustcolor("red", 0.5))
lc_scatter(x = means, y = vars/means, logScaleX = 10, logScaleY = 10, size = 2,
           opacity = 0.4)
genes <- getMarked()
genes[1:5]

variableGenes <- as.matrix(log1p(normCounts[genes, ]))
scaled <- (variableGenes - rowMeans(variableGenes))/rowSds(variableGenes)
scaled <- squish(scaled, c(-10, 10))

pca_scaled <- prcomp_irlba(t(scaled), n = 50)
set.seed(12345)
um_scaled <- umap(pca_scaled$x, min_dist = 0.3,
                  spread = 3,
                  n_neighbors = 30, metric = "cosine")

ggplot() + geom_point(aes(um_scaled[, 1], um_scaled[, 2]), size = 1)

sleepwalk(list(um, um_scaled), list(pca$x, pca_scaled$x), 
          metric = c("euclid", "cosine"))

###ADT
countsADT <- readRDS("citeSeq_ADT.rds")
countsADT[1:10, 1:10]
normCountsADT <- t(countsADT)/colSums(countsADT) * 10000
sleepwalk(list(um, um_scaled), log1p(normCountsADT))
