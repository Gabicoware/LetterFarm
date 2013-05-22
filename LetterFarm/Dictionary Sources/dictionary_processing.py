import sys

fileIndex = len(sys.argv) - 1

fileIN = open(sys.argv[fileIndex], "r")

minLength = 3
maxLength = 5

if (1 < fileIndex):
    minLength = maxLength = int(sys.argv[1])

words = []

line = fileIN.readline()

while line:
	word = line.strip()
	length = len(word)
	if (minLength <= length and length <= maxLength):
		words.append(word)
	
	line = fileIN.readline()

print("\n".join(words))
