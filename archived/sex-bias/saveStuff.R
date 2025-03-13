species <- c("Human", "Mouse", "Rat", "Rabbit", "Opossum", "Chicken")
tissues <- c("Brain", "Cerebellum", "Liver", "Heart", "Kidney", "Gonads")

ntps <- sapply(species, function(sp) {
  data <- loadData(sp)
  if(sp == "Mouse")
    data <- data[, !(colnames(data) %in% c("Heart.e10.5.4", "Liver.e10.5.4", "Liver.e12.5.3"))]
  if(sp == "Rabbit")
    data$group <- paste0("r", data$group)
  if(sp == "Opossum")
    data$group <- paste0("o", data$group)  
  
  sapply(tissues, function(t) {

    st <- subset(as.data.frame(colData(data)), tissue == t)
    st %>%
      group_by(timePoint) %>%
      summarise(femCount = sum(sex == "Female"), maleCount = sum(sex == "Male")) %>%
      filter(femCount != 0 & maleCount != 0) %>%
      select(timePoint) %>% 
      unlist -> tps
    length(unique(tps))
  })
})

sp <- "Human"
t <- "Brain"

data <- logTransform(loadData(sp))
if(sp == "Mouse")
  data <- data[, !(colnames(data) %in% c("Heart.e10.5.4", "Liver.e10.5.4", "Liver.e12.5.3"))]
if(sp == "Rabbit")
  data$group <- paste0("r", data$group)
if(sp == "Opossum")
  data$group <- paste0("o", data$group)  
data <- newTimePoints(data, sp)

st <- subset(as.data.frame(colData(data)), tissue == t)
st %>%
  group_by(timePoint) %>%
  summarise(femCount = sum(sex == "Female"), maleCount = sum(sex == "Male")) %>%
  filter(femCount != 0 & maleCount != 0) %>%
  select(timePoint) %>% 
  unlist -> tps
st <- subset(st, timePoint %in% tps)

exprs <- assay(data, "logcounts")[, rownames(st)]

plotSimple <- function(gene) {
 st$expr <- exprs[gene, ]
 pl <- ggplot() + geom_point(aes(x = st$timePoint, y = st$expr, colour = st$sex), size = 4) +
   xlab("Time") + ylab("log2 expression") + scale_color_discrete(name = "Sex") +
   ggtitle(gene)
 print(pl)
}

genes <- c("interest" = "ENSG00000170561", "all" = "ENSG00000183878", "noise" = "ENSG00000035687", "same" = "ENSG00000152683")

for(i in 1:length(genes)) {
  png(filename = paste0("~/Work/Git/kloivenn.github.io/sex-bias/src/img/plots/", names(genes)[i], ".png"),
      width = 600, height = 300)
  plotSimple(genes[i])
  dev.off()
}

library(locfit)

plotScore <- function(gene) {
  dataTable <- st
  dataTable$expr <- exprs[gene, ]
  
  dataTableM <- subset(dataTable, sex == "Male")
  dataTableF <- subset(dataTable, sex == "Female")
  h <- max(diff(range(st$timePoint))/4, (tps[3] - tps[1]) * 1.25, (tps[length(tps)] - tps[length(tps) - 2] ) * 1.25)
  
  xM <- lp(dataTableM$timePoint, deg = 1, h = h)
  xF <- lp(dataTableF$timePoint, deg = 1, h = h)
  
  grid <- lfgrid(mg = 40, ll = min(st$timePoint), ur = max(st$timePoint))

  fitM <- locfit.raw(xM, dataTableM$expr, ev = grid )
  fitF <- locfit.raw(xF, dataTableF$expr, ev = grid )
      
  male <- (locfit:::preplot.locfit.raw(fitM, NULL, "fitp", "coef", "none"))$y
  female <- (locfit:::preplot.locfit.raw(fitF, NULL, "fitp", "coef", "none"))$y
      
  # average distance between curves
  dist <- mean(male - female)
      
  #keep only the values that have the same sign as dist
  vals <- male - female
  vals <- abs(vals[vals * dist >= 0])
  maxVal <- which(abs(male - female) == max(vals))
  
  score <- sqrt(dist * max(vals)) * sign(dist)
  tps <- seq(min(dataTable$timePoint), max(dataTable$timePoint), length.out = 40)
  pl <- ggplot() + geom_ribbon(aes(x = tps, ymin = pmin(male, female), ymax = pmax(male, female)), alpha = 0.3) +
    geom_point(aes(x = timePoint, y = expr, colour = sex), size = 4, data = dataTable) +
    geom_line(aes(x = timePoint, y = expr, colour = sex), 
              data = data.frame(timePoint = rep(tps, times = 2),
                                expr = c(male, female), sex = rep(c("Male", "Female"), each = 40))) +
    geom_vline(xintercept = tps[maxVal], colour = "grey") + 
    geom_segment(aes(x = tps[maxVal], xend = tps[maxVal], yend = male[maxVal], y = female[maxVal]),
                size = 1) + 
    xlab("Time") + ylab("log2 expression") + scale_color_discrete(name = "Sex") +
    ggtitle(paste0(gene, ", score: ", round(score * 100)/100))

  print(pl)
}

for(i in 1:length(genes)) {
  png(filename = paste0("~/Work/Git/kloivenn.github.io/sex-bias/src/img/plots/", names(genes)[i], "_score.png"),
      width = 700, height = 350)
  plotScore(genes[i])
  dev.off()
}

library(cowplot)
perms <- read_rds(paste0("maxDistScore_bootstrap/res/", sp, "_", t, "_bootstrap.rds"))
pvals <- (pmin(perms[, 1], perms[, 2]) + 1)/(perms[, 3] + 1)

plotLinesAndHist <- function(gene) {
  st$expr <- exprs[gene, ]
  dataTableM <- subset(st, sex == "Male")
  dataTableF <- subset(st, sex == "Female")
  
  tps <- sort(unique(st$newTimePoint))
  h <- max(diff(range(st$newTimePoint))/4, (tps[3] - tps[1]) * 1.25, (tps[length(tps)] - tps[length(tps) - 2] ) * 1.25)
  #h <- 10
  tpss <- seq(min(st$newTimePoint), max(st$newTimePoint), length.out = 50)
  xM <- lp(dataTableM$newTimePoint, deg = 1, h = h)
  xF <- lp(dataTableF$newTimePoint, deg = 1, h = h)
  grid <- lfgrid(mg = 30, ll = min(st$newTimePoint), ur = max(st$newTimePoint))
  
  fvals <- replicate( 500, {
    fitM <- locfit.raw(xM, dataTableM$expr, weights = rgamma( nrow(dataTableM), shape=1, scale=1 ), ev = grid )
    fitF <- locfit.raw(xF, dataTableF$expr, weights = rgamma( nrow(dataTableM), shape=1, scale=1 ), ev = grid )
    
    c(predict(fitM, tpss), predict(fitF, tpss))
  })
  fvals %>%
    as_tibble() %>%
    mutate(sex = rep(c("Male", "Female"), each = length(tpss)), 
           timePoint = c(tpss, tpss)) %>%
    gather(line, y, -(sex:timePoint)) -> lines
  
  lines %>%
    unite(id, sex, line, remove = F) %>%
    ggplot() + geom_line(aes(x = timePoint, y = y, colour = sex, group = id), alpha = 0.04) +
    geom_point(aes(x = newTimePoint, y = expr, fill = sex), data = st, size = 3, stroke = 0.75, 
               colour = "black", shape = 21) + ggtitle(gene)-> pl1
  
  lines %>%
    pivot_wider(names_from = sex, values_from = y) %>%
    group_by(line) %>%
    summarise(dist = mean(Male - Female), max = max(Male - Female), min = min(Male - Female)) %>%
    mutate(maxVal = ifelse(dist > 0, max, min)) %>%
    mutate(score = sqrt(abs(dist * maxVal)) * sign(dist)) %>%
    ggplot() + geom_histogram(aes(x = score)) +
      geom_vline(xintercept = c(-0.1, 0.1)) + 
    ggtitle(paste0("-log10 pvalue: ", round(-log10(pvals[gene]) * 100)/100))-> pl2
  
  print(plot_grid(pl1, pl2, nrow = 2))
}

for(i in 1:length(genes)) {
  png(filename = paste0("~/Work/Git/kloivenn.github.io/sex-bias/src/img/plots/", names(genes)[i], "_hist.png"),
      width = 700, height = 500)
  plotLinesAndHist(genes[i])
  dev.off()
}

genes <- c("outlier1" = "ENSG00000183185" , "outlier2" = "ENSG00000102239", 
           "edge1" = "ENSG00000155363", "edge2" = "ENSG00000166558")

plotGene <- function(gene) {
  st$expr <- exprs[gene, ]
  dataTableM <- subset(st, sex == "Male")
  dataTableF <- subset(st, sex == "Female")
  
  tps <- sort(unique(st$newTimePoint))
  h <- max(diff(range(st$newTimePoint))/4, (tps[3] - tps[1]) * 1.25, (tps[length(tps)] - tps[length(tps) - 2] ) * 1.25)
  #h <- 10
  tpss <- seq(min(st$newTimePoint), max(st$newTimePoint), length.out = 50)
  xM <- lp(dataTableM$newTimePoint, deg = 1, h = h)
  xF <- lp(dataTableF$newTimePoint, deg = 1, h = h)
  grid <- lfgrid(mg = 30, ll = min(st$newTimePoint), ur = max(st$newTimePoint))
  
  fvals <- replicate( 500, {
    fitM <- locfit.raw(xM, dataTableM$expr, weights = rgamma( nrow(dataTableM), shape=1, scale=1 ), ev = grid )
    fitF <- locfit.raw(xF, dataTableF$expr, weights = rgamma( nrow(dataTableM), shape=1, scale=1 ), ev = grid )
    
    c(predict(fitM, tpss), predict(fitF, tpss))
  })
  fvals %>%
    as_tibble() %>%
    mutate(sex = rep(c("Male", "Female"), each = length(tpss)), 
           timePoint = c(tpss, tpss)) %>%
    gather(line, y, -(sex:timePoint)) -> lines
  
  lines %>%
    unite(id, sex, line, remove = F) %>%
    ggplot() + geom_line(aes(x = timePoint, y = y, colour = sex, group = id), alpha = 0.04) +
    geom_point(aes(x = newTimePoint, y = expr, fill = sex), data = st, size = 3, stroke = 0.75, 
               colour = "black", shape = 21) + ggtitle(gene)-> pl1
  
  print(pl1)
}

for(i in 1:length(genes)) {
  png(filename = paste0("~/Work/Git/kloivenn.github.io/sex-bias/src/img/plots/", names(genes)[i], ".png"),
      width = 700, height = 400)
  plotGene(genes[i])
  dev.off()
}

genes <- c("ENSG00000067840", "ENSG00000092096", "ENSG00000160469", "ENSG00000184702")
for(i in 1:length(genes)) {
  png(filename = paste0("~/Work/Git/kloivenn.github.io/sex-bias/src/img/plots/cluster1/gene", i, ".png"),
      width = 700, height = 400)
  plotGene(genes[i])
  dev.off()
}

genes <- c("ENSG00000149806", "ENSG00000145741", "ENSG00000196531")
for(i in 1:length(genes)) {
  png(filename = paste0("~/Work/Git/kloivenn.github.io/sex-bias/src/img/plots/cluster2/gene", i, ".png"),
      width = 700, height = 350)
  plotGene(genes[i])
  dev.off()
}
