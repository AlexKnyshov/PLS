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
		row_eq = row.strip().split("=")
		row_prt = row_eq[0].strip().split(",")[1].strip()
		row_ranges = row_eq[1].strip().split(",")
		if len(row_ranges) == 1:
			prtout[row_prt] = [int(i) for i in row_ranges[0].strip().split("-")]
		else:
			for r in range(len(row_ranges)):
				prtout[row_prt+"_"+str(r+1)] = [int(i) for i in row_ranges[r].strip().split("-")]

finaout = open("pls_prtlls.csv","w")
print >> finaout, "partition,"+",".join([str(i) for i in sorted(tabout.keys())])
for partition, prtrange in sorted(prtout.items()):
	treeprtll = []
	for tree, psll in sorted(tabout.items()):
		prtll = sum(psll[prtrange[0]-1:prtrange[1]-1])
		treeprtll.append(str(prtll))
	print >> finaout, partition+","+",".join(treeprtll)
finaout.close()
print "done"