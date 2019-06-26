library (ape)
library (phangorn)
args = commandArgs(trailingOnly=TRUE)
if (length(args) == 0){
  cat("Syntax: Rscript nniR.R [path to the tree file]\n")
  cat("Example: Rscript nniR.R tree.tre \n")
  quit()
}
start <- read.tree(args[1])
nnis <- nni(start)
write.tree(c(start, nnis), "pls_nni_tree.tre")