import sys

dictionaryINIndex = len(sys.argv) - 2
permutationINIndex = len(sys.argv) - 1

min_perm = 1

if (1 < dictionaryINIndex):
    min_perm = int(sys.argv[1])

dictionaryIN = open(sys.argv[dictionaryINIndex], "r")
permutationIN = open(sys.argv[permutationINIndex], "r")

outputString = ""

word_line = dictionaryIN.readline()
perm_line = permutationIN.readline()


while (word_line and perm_line ):
    word = word_line.strip()
    perm = int(perm_line)
        
    if (min_perm <= perm):
        outputString += word + "\n"
	
    word_line = dictionaryIN.readline()
    perm_line = permutationIN.readline()

print(outputString)
