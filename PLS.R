args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0){
  cat("Syntax: Rscript PLS.R [option: -g (alternative best NNI is selected globally using total LnL), -l (alternative best NNI is selected locally using partition LnL), -m (manually specified trees were compared)] [path to pls_prtlls.csv file] ([path to the tree file])\n")
  cat("Example: Rscript PLS.R -g pls_prtlls.csv tree.tre \n")
  cat("Example: Rscript PLS.R -m pls_prtlls.csv \n")
  quit()
}

library(ape)
library(phangorn)
library(ggtree)
library(ggplot2)
library(grid)
library(gridExtra)

###

opt <- args[1]
tab <- read.csv(args[2], stringsAsFactors=FALSE)
datalist <- data.frame() 
if (opt == "-m"){

  for (comparison in 3:length(tab[1,])){
    dfcomp <- data.frame(char=numeric(),value=numeric())
    for (partition in 1:length(tab[,1])){
      pls <- tab[partition,2] - tab[partition,comparison]
      
      dfcomp <- rbind(dfcomp, data.frame(char=partition, value=pls))
    }
    colnames(dfcomp) <- c("char", comparison)
    if (length(datalist) == 0){
      datalist <- dfcomp
    }
    else {
      datalist <- merge(datalist, dfcomp, by.x="char", by.y="char")
    }

  }
} else {
  start <- read.tree(args[3])
  print (start$Nnode)
  for (node in 2:start$Nnode){
    dfnode <- data.frame(char=numeric(),value=numeric()) 
    tr2 <- (node-1)*2-1
    tr3 <- (node-1)*2
    print ( paste0 (node,"_", tr2,"_", tr3))
    if (opt == "-g"){
      if (sum(tab[,tr2+2]) >= sum(tab[,tr3+2])){
        nextbesttopo <- tr2
      }
      else {
        nextbesttopo <- tr3
      }
    }
    for (partition in 1:length(tab[,1])){
      if (opt == "-l"){
        if (sum(tab[partition,tr2+2]) >= sum(tab[partition,tr3+2])){
          nextbesttopo <- tr2
        }
        else {
          nextbesttopo <- tr3
        }
      }
      pls <- tab[partition,2] - tab[partition,nextbesttopo+2]
      
      dfnode <- rbind(dfnode, data.frame(char=partition, value=pls))
      
    }
    colnames(dfnode) <- c("char", node)
    if (length(datalist) == 0){
      datalist <- dfnode
    }
    else {
      datalist <- merge(datalist, dfnode, by.x="char", by.y="char")
    }

  }
}



write.csv(datalist,"pls_datalist.csv",row.names=tab$partition)

#totals
insets <- list()

outlierprts <- numeric()

if (opt == "-m"){
  nodelabs <- (3:length(tab[1,]))-1
  #print(length(tab[1,]))
  #print(nodelabs)
  numplots <- 2:(length(tab[1,])-1)
  #print(numplots)
  outlierall <- data.frame(prt=character(),val=numeric(),node=numeric()) 
} else {
  treeplot <- ggtree(start, size=1) + geom_tiplab(size=2)
  nodelabs <- (2+Ntip(start)):(start$Nnode+Ntip(start))
  numplots <- 2:start$Nnode
  outlierall <- data.frame(prt=character(),val=numeric(),node=numeric(),tips=list()) 
}


pdf("pls_nodeplots.pdf")
for (i in numplots){
  print (i)
	 datatemp <- datalist[,c(1,i)]
   colnames(datatemp) <- c("char", "value")
   datatemp$col <- NA
   datatemp$col[datatemp$value<0] <- 1
   datatemp$col[datatemp$value>=0] <- 0

  	plot1 <- ggplot(data=datatemp, aes(x=char, y=value, fill=as.character(col)))+
  	labs(title=nodelabs[i-1])+
    geom_bar(stat="identity") + theme(legend.position="none",axis.title.x=element_blank(),
                                      axis.title.y=element_blank(),
                                      axis.ticks.x = element_line(size = 0.1),
                                      axis.ticks.y = element_line(size = 0.1),
                                      panel.border = element_blank(),
                                      panel.grid.major = element_blank(),
                                      panel.grid.minor = element_blank(),
                                      panel.background = element_rect(fill = 'white', colour = 'black', size=0.7),
                                      plot.background = element_blank(),
                                      plot.margin = margin(t=1.5, r=2, b=1.5, l=0),
                                      plot.title = element_text(margin = margin(t = 5, b = -10), size=3, colour="red"),
                                      axis.text.x = element_text(size=1,margin = margin(t =0.01), colour = "black"),
                                      axis.text.y = element_text(size=1,margin = margin(t =0.01), colour = "black")) +
    scale_fill_manual(values = c("green4","red")) +
    scale_x_continuous(breaks=seq(0,length(tab[,1]),10))
    plot2 <- ggplot(datatemp, aes(x=1, y=value)) + 
  			geom_boxplot(outlier.shape=NA) +
  			theme(legend.position="none",axis.title.x=element_blank(),
  									  axis.title.y=element_blank(),
                                      axis.text.y=element_blank(),
                                      axis.text.x = element_text(size=1,margin = margin(t =0.01), colour = "black"),
                                      axis.ticks.x = element_line(size = 0.1),
                                      axis.ticks.y=element_blank(),
                                      panel.border = element_blank(),
                                      panel.grid.major = element_blank(),
                                      panel.grid.minor = element_blank(),
                                      panel.background = element_rect(fill = 'white', colour = 'black', size=0.7),
                                      plot.background = element_blank(),
                                      plot.margin = margin(t=1.5, r=2, b=1.5, l=0))
  	print(paste0("node_", i-1, "_outliers_plotN_",nodelabs[i-1]))
    ###
  	tempvec <- tab[which(datatemp$value < boxplot(datatemp$value, plot=F)$stats[1]*3),1]
  	names(tempvec) <- datatemp$value[which(datatemp$value < boxplot(datatemp$value, plot=F)$stats[1]*3)]-boxplot(datatemp$value, plot=F)$stats[1]*3
  	print(tempvec)
  	if (length(tempvec) > 0){
  	  	for (tv in tempvec){
          if (opt == "-m"){
            outlierall <- rbind(outlierall, data.frame(prt=tv, val=as.numeric(names(tempvec)[tempvec == tv]), node=nodelabs[i-1]))
          } else {
            outlierall <- rbind(outlierall, data.frame(prt=tv, val=as.numeric(names(tempvec)[tempvec == tv]), node=nodelabs[i-1], tips=I(list(start$tip.label[unlist(Descendants(start,nodelabs[i-1],"tips"))]))))
          }
  	  		
    			if (tv %in% names(outlierprts)){
    				outlierprts[tv] = outlierprts[tv] + 1
    			}
  	  		else{
  	  			outlierprts <- c(outlierprts, setNames(1,tv))
  	  		}
  	  	}
  	}
   
    ###
  	tempvec <- tab[which(datatemp$value > boxplot(datatemp$value, plot=F)$stats[5]*3),1]
  	names(tempvec) <- datatemp$value[which(datatemp$value > boxplot(datatemp$value, plot=F)$stats[5]*3)]-boxplot(datatemp$value, plot=F)$stats[5]*3
  	print(tempvec)
   	if (length(tempvec) > 0){
  	  	for (tv in tempvec){
          if (opt == "-m"){
            outlierall <- rbind(outlierall, data.frame(prt=tv, val=as.numeric(names(tempvec)[tempvec == tv]), node=nodelabs[i-1]))
          } else {
            outlierall <- rbind(outlierall, data.frame(prt=tv, val=as.numeric(names(tempvec)[tempvec == tv]), node=nodelabs[i-1], tips=I(list(start$tip.label[unlist(Descendants(start,nodelabs[i-1],"tips"))]))))
          }
  	  		
			if (tv %in% names(outlierprts)){
				outlierprts[tv] = outlierprts[tv] + 1
			}
  	  		else{
  	  			outlierprts <- c(outlierprts, setNames(1,tv))
  	  		}
  	  	}
  	}
  	insets[[i-1]] <- grid.arrange(plot1, plot2, layout_matrix=matrix(c(1,1,1,2), ncol=4),ncol = 4)
}
dev.off()
names(insets) <- nodelabs

write.csv(sort(outlierprts),"pls_Nnode_outliers.csv")

outlierall$groups <- paste0("N_", outlierall$node, "_", outlierall$prt)
outlierall <- outlierall[order(-abs(outlierall$val)),]
outlierprtsdf <- as.data.frame(outlierprts)

write.csv(outlierall,"pls_LnLdiff_outliers.csv")

ggbar1 <- ggplot(outlierprtsdf, aes(x=reorder(rownames(outlierprtsdf),-outlierprtsdf$outlierprts), y=outlierprtsdf$outlierprts)) + 
	geom_bar(stat="identity") +
  labs(title="Outliers with most nodes", x="Partition", y="Number of nodes with outlier")+
	theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("pls_Nnode_outliers.pdf", ggbar1)
ggbar2 <- ggplot(outlierall, aes(x=reorder(outlierall$groups,-abs(outlierall$val)), y=abs(outlierall$val))) + 
	geom_bar(stat="identity") +
  labs(title="Outliers with highest likelihood difference", x="Node and Partition", y="Absolute LnL difference") +
	theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("pls_LnLdiff_outliers.pdf", ggbar2)
###

if (opt != "-m"){
  finalplot <- inset(treeplot, insets, width=max(treeplot$data$x)/10, height=length(treeplot$data$isTip[treeplot$data$isTip])/30,vjust=0.2,hjust=0.005)
  ggsave("pls_annotated_tree.pdf",finalplot, width=8.5, height=20)
}

  	
