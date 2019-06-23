# PLS
Partitioned Likelihood Support

### Installation

Simply copy the files or clone the repo
```
git clone https://github.com/AlexKnyshov/PLS
```

### Dependencies
Python 2
R with the following packages installed
- ape
- phangorn
- ggplot2
- grid
- gridExtra
- ggtree
RAxML or IQ-TREE


### Input
As input, the following files are needed:
- a (concatenated) alignment
- a partition file (currently, RAxML format is supported)
- an ML phylogeny in Newick format

### Workflow
(Adjust commands to provide a correct path to scripts and programs)
Assuming `MLtreefile.tre` is the ML phylogeny being tested, obtain the NNI topologies:
```
Rscript ./nniR.R MLtreefile.tre
```
Output is written to `pls_nni_tree.tre`

Assuming alignment.phy is the alignment file and partitions.txt is the partition scheme, evaluate likelihood of all trees using either:
```
./iqtree -nt 1 -s ./alignment.phy -spp ./alignment.prt -z pls_nni_tree.tre -wsl -pre calcPLS -n 0
```
Or if the ML partition model has been optimized and saved to a file `analysis.best_model.nex`:
```
./iqtree -nt 1 -s ./alignment.phy -spp ./analysis.best_model.nex -z pls_nni_tree.tre -wsl -pre calcPLS -n 0
```
Or using RAxML:
```
raxmlHPC -T 1 -f G -s ./alignment.phy -m GTRGAMMA -z pls_nni_tree.tre -n calcPLS
```
Given the prefix parameter in the examples above, the output is written to calcPLS.sitelh (in case of IQ-TREE) or RAxML_perSiteLLs.calcPLS (in case of RAxML). Adjust the prefix parameteres if needed

Assuming the output file name at the previous step is calcPLS.sitelh, calculate the per-partition sum of LnLs using the partitioning scheme of interest (usually the original partitioning scheme):
```
python ./PLS.py calcPLS.sitelh alignment.prt
```

Finally, calculate per partition difference, export tables and draw plots:
```
Rscript ./PLS.R pls_prtlls.csv MLtreefile.tre
```
Done