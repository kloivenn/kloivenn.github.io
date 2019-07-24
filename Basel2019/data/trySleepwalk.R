#installed.packages("sleepwalk")

#downoload from 
library(readr)
library(ggplot2)
data <- read_rds("e13_A.rds")

library(sleepwalk)

getHighGenes <- function(marked){
  
  # If no genes are marked, clear output, do nothing else
  if( length(marked) == 0 ) {
    return( "" )
  }
  
  #for each gene we calculate mean and standart deviation in marked cells and all other cells
  df <- data.frame(
    meanMarked   =  apply( data$expr[ marked, ], 2, mean ),
    sdMarked     =  apply( data$expr[ marked, ], 2, sd ),
    meanUnmarked =  apply( data$expr[ -marked, ], 2, mean ),
    sdUnmarked   =  apply( data$expr[ -marked, ], 2, sd )
  )
  #separation score
  df$sepScore <- ( df$meanMarked - df$meanUnmarked ) / pmax( df$sdMarked + df$sdUnmarked, 0.002 )
  
  # round to two decimal places
  df <- round(df * 100)/100
  
  #print top genes  
  print(head( df[ order( df$sepScore, decreasing=TRUE ), ], 15 ))
  
  #make a plot of gene expression
  topGene <- rownames(df)[which.max(df$sepScore)]
  pl <- ggplot() + geom_point(aes(x = data$um[, 1], y = data$um[, 2], colour = data$expr[, topGene])) +
    labs(colour = topGene) + scale_color_gradient(low = "Yellow", high = "Red")
  
  print(pl)
}

sleepwalk(data$umap, data$pca, pointSize = 2.5, on_selection = getHighGenes)

#make a snapshot
slw_snapshot(123)

#save to an HTML file
sleepwalk(data$umap, data$pca, pointSize = 2.5, saveToFile = "test.html")

