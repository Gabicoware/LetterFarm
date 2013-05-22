import sys
from sets import Set

fileIN = open(sys.argv[1], "r")

def permutations(word,validWords,letters):
	perms = set()
	for index in range(0,len(word)):
		start = word[:index]
		end = word[index:len(word)]
		
		for letter in letters:
			perm = start + letter + end
			perms.add(perm)
	for index in range(0,len(word)+1):
		
		if index == 0:
			start = ""
		else:
			start = word[:index]
		
		if index == len(word):
			end = ""
		else:
			end = word[index+1:len(word)]
		
		for letter in letters:
			perm = start + letter + end
			perms.add(perm)
	
	for index in range(0,len(word)):
		start = word[:index]
		end = word[index+1:len(word)]
		perm = start + end
		perms.add(perm)
		
	return perms


words = []

line = fileIN.readline()
while line:
	word = line.strip()
	length = len(word)
	if (1 <= length and length <= 7):
		words.append(word)
	
	line = fileIN.readline()

alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

for word in words:

	current_level_words = set()
	
	current_level_words.add(word)
	
	levels_dict = {}
	
	for move in [1,2,3,4,5,6]:
		
		next_level_words = set()
		
		for current_word in current_level_words:
			perms = permutations(current_word,words,alphabet)
			
			perms = perms.intersection(words)
			perms.remove(current_word)
			
			for perm in perms:
				
				if levels_dict.has_key(perm):
					levels = levels_dict[perm]
				else:
					levels = []
					levels_dict[perm] = levels
				
				levels.append(move)
				
			next_level_words = next_level_words.union(perms);
			
		current_level_words = next_level_words
	
	result_words = []
	
	for top_word in current_level_words:
		
		levels = levels_dict[top_word]
		
		if len(levels) == 1 :
			result_words.append(word)
		
	print len(result_words)
#	print ",".join( permutations(word,words,alphabet) )

