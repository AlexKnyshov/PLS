import sys

if len(sys.argv) >= 3:
	opt = sys.argv[1]
	tab = sys.argv[2]
	if opt == "-prt":
		prts = sys.argv[3]
else:
	print "FORMAT: python PLS.py [option: -prt (use partition file), -sl (use per site calculation), -stN (sum every N positions)] [path to .sitelh file] [path to partition file]"
	print "EXAMPLE: python PLS.py -prt analysis.sitelh partitions.txt"
	print "EXAMPLE: python PLS.py -st10 analysis.sitelh"
	sys.exit()

tabout = {}

with open(tab, "rb") as tabfile:
	next(tabfile)
	for row in tabfile:
		row1 = row.strip().split()
		tabout[int(row1[0][4:])] = [float(i) for i in row1[1:]]

prtout = {}

if opt == "-prt":
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
elif opt == "-sl":
	for i in range(1,len(tabout[1])):
		prtout[i] = [i,i+1]
elif opt[:3] == "-st":
	step = int(opt[3:])
	for i in range(1,len(tabout[1]),step):
		prtout[i] = [i,i+step]

finaout = open("pls_prtlls.csv","w")
print >> finaout, "partition,"+",".join([str(i) for i in sorted(tabout.keys())])
for partition, prtrange in sorted(prtout.items()):
	treeprtll = []
	for tree, psll in sorted(tabout.items()):
		prtll = sum(psll[prtrange[0]-1:prtrange[1]-1])
		treeprtll.append(str(prtll))
	print >> finaout, str(partition)+","+",".join(treeprtll)
finaout.close()
print "done"