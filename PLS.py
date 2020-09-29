import sys

if len(sys.argv) >= 3:
	opt = sys.argv[1]
	tab = sys.argv[2]
	if opt[:4] == "-prt":
		prts = sys.argv[3]
	elif opt == "-sl":
		if sys.argv[3] and sys.argv[4]:
			start = int(sys.argv[3])
			end = int(sys.argv[4])
		else:
			start = 0
			end = -1
	elif opt[:3] == "-st":
		if sys.argv[3] and sys.argv[4]:
			start = int(sys.argv[3])
			end = int(sys.argv[4])
		else:
			start = 0
			end = -1
	else:
		print "incorrect command, exiting"
		sys.exit()
else:
	print "FORMAT: python PLS.py [option: -prt (use partition file), -prtS (use partition file, standardize by length), -sl (use per site calculation), -stN (sum every N positions)] [path to .sitelh file] [path to partition file] ([start] [end])"
	print "EXAMPLE: python PLS.py -prt analysis.sitelh partitions.txt"
	print "EXAMPLE: python PLS.py -prtS analysis.sitelh partitions.txt"
	print "EXAMPLE: python PLS.py -st10 analysis.sitelh"
	print "EXAMPLE: python PLS.py -st10 analysis.sitelh 1 2075"
	print "EXAMPLE: python PLS.py -sl analysis.sitelh 2075 3028"
	sys.exit()

tabout = {}

with open(tab, "rb") as tabfile:
	next(tabfile)
	counter = 1
	for row in tabfile:
		row1 = row.strip().split()
		tabout[counter] = [float(i) for i in row1[1:]]
		counter += 1

prtout = {}

if opt[:4] == "-prt":
	with open(prts, "rb") as prtfile:
		for row in prtfile:
			row_eq = row.strip().split("=")
			row_prt = row_eq[0].strip().split(",")[1].strip()
			row_ranges = row_eq[1].strip().split(",")
			if len(row_ranges) == 1:
				prtout[row_prt] = [[int(i) for i in row_ranges[0].strip().split("-")]]
			else:
				prtout[row_prt] = []
				for r in range(len(row_ranges)):
					prtout[row_prt].append([int(i) for i in row_ranges[r].strip().split("-")])
			print "partition", row_prt, "ranges", prtout[row_prt]
elif opt == "-sl":
	if start == 0 and end == -1:
		print "site likelihoods, beginning to end"
		for i in range(1,len(tabout[1])):
			prtout[i] = [[i,i+1]]
	else:
		print "site likelihoods, start", start, "end", end
		for i in range(start,end+1):
			prtout[i] = [[i,i+1]]
elif opt[:3] == "-st":
	step = int(opt[3:])
	if start == 0 and end == -1:
		print "site likelihoods, beginning to end, step", step
		for i in range(1,len(tabout[1]),step):
			prtout[i] = [[i,i+step]]
	else:
		print "site likelihoods, start", start, "end", end, "step", step
		for i in range(start,end+1,step):
			prtout[i] = [[i,i+step]]

finaout = open("pls_prtlls.csv","w")
print >> finaout, "partition,"+",".join([str(i) for i in sorted(tabout.keys())])
for partition, prtrange in sorted(prtout.items()):
	treeprtll = []
	for tree, psll in sorted(tabout.items()):
		totalpos = []
		for posrange in prtrange:
			for x in psll[posrange[0]-1:posrange[1]-1]:
				totalpos.append(x)
		prtll = sum(totalpos)
		if opt == "-prtS":
			prtll = prtll/len(totalpos)
		treeprtll.append(str(prtll))
	print >> finaout, str(partition)+","+",".join(treeprtll)
finaout.close()
print "done"