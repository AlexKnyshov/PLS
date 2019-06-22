import sys

tab = sys.argv[1]
prts = sys.argv[2]

tabout = {}

with open(tab, "rb") as tabfile:
	next(tabfile)
	for row in tabfile:
		row1 = row.strip().split()
		tabout[int(row1[0][4:])] = [float(i) for i in row1[1:]]


prtout = {}

with open(prts, "rb") as prtfile:
	for row in prtfile:
		row1 = row.strip().split(" ")[1].split("=")
		prtout[row1[0]] = [int(i) for i in row1[1].split("-")]


finaout = open("prtlls.csv","w")
print >> finaout, "partition,"+",".join([str(i) for i in sorted(tabout.keys())])
for partition, prtrange in sorted(prtout.items()):
	treeprtll = []
	for tree, psll in sorted(tabout.items()):
		prtll = sum(psll[prtrange[0]-1:prtrange[1]-1])
		treeprtll.append(str(prtll))
	print >> finaout, partition+","+",".join(treeprtll)
finaout.close()
print "done"