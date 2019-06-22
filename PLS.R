library(ape)
library(phangorn)
library(ggtree)
library(ggplot2)
library(grid)
library(gridExtra)
###

args = commandArgs(trailingOnly=TRUE)
tab <- read.csv(args[1], stringsAsFactors=FALSE)
start <- read.tree(args[2])
datalist <- list()
alllist <- list()
allmin <- 0
allmax <- 0
for (node in 2:start$Nnode){
	datalist[[node]] <- data.frame(char=numeric(),
                            		value=numeric(),
                            		col=numeric()) 
	tr2 <- (node-1)*2-1
	tr3 <- (node-1)*2
	if (sum(tab[,tr2+2]) >= sum(tab[,tr3+2])){
		nextbesttopo <- tr2
	}
	else {
		nextbesttopo <- tr3
	}
	for (partition in 1:length(tab[,1])){
		pls <- tab[partition,2] - tab[partition,nextbesttopo+2]
		if (pls < 0){
			colint <- 1
		}
		else {
			colint <- 0
		}
		datalist[[node]] <- rbind(datalist[[node]], list(char=partition, value=pls, col=colint))
	}

}
##print (datalist) #expor this as table

p1 <- ggtree(start, size=1) + geom_tiplab(size=2)

nodelabs <- (2+Ntip(start)):(start$Nnode+Ntip(start))

#totals
insets <- list()

outlierprts <- numeric()
outlierall <- data.frame(prt=character(),val=numeric(),node=numeric(),tips=list()) 

for (i in 2:start$Nnode){
	 datatemp <- datalist[[i]]
  	plot1 <- ggplot(data=datatemp, aes(x=char, y=value, fill=as.character(col)))+
  	labs(title=nodelabs[i-1])+
    geom_bar(stat="identity") + theme(legend.position="none",axis.title.x=element_blank(),# title=element_text(size=2),
                                      axis.title.y=element_blank(),
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
  			theme(legend.position="none",axis.title.x=element_blank(),# title=element_text(size=2),
  									  axis.title.y=element_blank(),
                                      axis.text.y=element_blank(),
                                      axis.text.x = element_text(size=1,margin = margin(t =0.01), colour = "black"),
                                      axis.ticks.x=element_blank(),
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
  	  		outlierall <- rbind(outlierall, data.frame(prt=tv, val=as.numeric(names(tempvec)[tempvec == tv]), node=nodelabs[i-1], tips=I(list(start$tip.label[unlist(Descendants(start,nodelabs[i-1],"tips"))]))))
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
  	  		# print (tv)
  	  		outlierall <- rbind(outlierall, data.frame(prt=tv, val=as.numeric(names(tempvec)[tempvec == tv]), node=nodelabs[i-1], tips=I(list(start$tip.label[unlist(Descendants(start,nodelabs[i-1],"tips"))]))))
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
names(insets) <- nodelabs

##print (sort(outlierprts)) # output this as table

outlierall$groups <- paste0("N_", outlierall$node, "_", outlierall$prt)
outlierall <- outlierall[order(-abs(outlierall$val)),]
##print (outlierall) #output this as table
outlierprtsdf <- as.data.frame(outlierprts)
ggbar1 <- ggplot(outlierprtsdf, aes(x=reorder(rownames(outlierprtsdf),-outlierprtsdf$outlierprts), y=outlierprtsdf$outlierprts)) + 
	geom_bar(stat="identity") +
	theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("bar1.pdf", ggbar1)
ggbar2 <- ggplot(outlierall, aes(x=reorder(outlierall$groups,-abs(outlierall$val)), y=abs(outlierall$val))) + 
	geom_bar(stat="identity") +
	theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("bar2.pdf", ggbar2)
###


p3 <- inset(p1, insets, width=max(p1$data$x)/10, height=length(p1$data$isTip[p1$data$isTip])/30,vjust=0.2,hjust=0.005)

ggsave("testplot.pdf",p3, width=8.5, height=20)

  	
