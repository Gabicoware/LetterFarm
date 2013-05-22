import sys

dictionaryFilePath = ""
badWordsFilePath = ""

fileIndex = 1

argc = len(sys.argv)

isDebugOutput = 0

for index in range(1,argc):
	arg = sys.argv[index]
	if arg == "--dict":
		dictionaryFilePath = sys.argv[index+1]
		fileIndex = index + 2
	elif arg == "--badwords":
		badWordsFilePath = sys.argv[index+1]
		fileIndex = index + 2
	elif arg == "--debug-output":
		isDebugOutput = 1
		fileIndex = index + 1
		
countDict = {}

for index in range(fileIndex,argc):
	fileIN = open(sys.argv[index], "r")
	line = fileIN.readline()
	while line:
		if len(line.strip()) < 3:
			break
		pieces = line.split()
		word = pieces[0].lower().strip()
		count = int(pieces[1].lower().strip())
		if word in countDict:
			currentCount = countDict[word]
			countDict[word] = count + currentCount
		else:
			countDict[word] = count
		
		line = fileIN.readline()

try:
   fileIN = open(badWordsFilePath, "r")
except IOError as e:
   fileIN = None

line = None

if fileIN is not None:
	line = fileIN.readline()
	
while line:
	word = line.strip()
	if word in countDict:
		countDict[word] = 0
	line = fileIN.readline()

fileIN = open(dictionaryFilePath, "r")

counts = []

line = fileIN.readline()

if isDebugOutput:
	reverseDict = {}
	
	intCounts = []
	
	while line:
		word = line.strip()
		count = 0
		
		if word in countDict:
			count = countDict[word]
		
		intCounts.append(count)
		
		reverseDict[str(count)] = word
		
		line = fileIN.readline()
	
	intCounts.sort()
	
	for count in intCounts:
		word = reverseDict[str(count)]
		counts.append( word + " " + str(count) )
	
else:
	while line:
		word = line.strip()
		count = "0"
		
		if word in countDict:
			count = str(countDict[word])
		
		if 0 < len(word):
			counts.append( count )
		
		line = fileIN.readline()

print("\n".join(counts))