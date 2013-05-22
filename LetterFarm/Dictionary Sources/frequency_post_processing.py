import sys


freqFileIndex = len(sys.argv) - 1
dictFileIndex = freqFileIndex - 1

dictionaryIN = open(sys.argv[dictFileIndex], "r")
frequencyIN = open(sys.argv[freqFileIndex], "r")


outputString = ""

word_line = dictionaryIN.readline()
freq_line = frequencyIN.readline()

# 500,000 was selected as the appropriate minimuum frequency (6-13-12)
min_freq = 1000000

if 1 < dictFileIndex :
    minFreqIndex = dictFileIndex - 1
    min_freq = int(sys.argv[minFreqIndex])

words = []

while (word_line and freq_line):
    word = word_line.strip()
    freq = int(freq_line.strip())

    if ( min_freq <= freq):
        words.append( word )
	
    word_line = dictionaryIN.readline()
    freq_line = frequencyIN.readline()

print("\n".join(words))
