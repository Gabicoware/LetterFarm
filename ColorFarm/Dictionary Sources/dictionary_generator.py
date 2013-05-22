import sys

def wordsWithLength(length,alphabet):
    words = []
    if (1 < length):
        initialWords = wordsWithLength(length - 1, alphabet)
    else:
        initialWords = [""]

    for initialWord in initialWords:
        for letter in alphabet:
            word = initialWord+letter
            words.append(word)
    return words


type = 0

if( 1 < len(sys.argv)):
    type = int(sys.argv[1])

fullAlphabet =["o","y","g","b","p","r","w"]
colorAlphabet =["o","y","g","b","p","r"]

if(type == 3):
    words = wordsWithLength(3, colorAlphabet)
elif(type == 4):
    words = wordsWithLength(4, colorAlphabet)
elif(type == 5):
    words = wordsWithLength(5, colorAlphabet)
else:
    _3_words = wordsWithLength(3, fullAlphabet)
    _4_words = wordsWithLength(4, fullAlphabet)
    _5_words = wordsWithLength(5, fullAlphabet)
    words = _3_words + _4_words + _5_words

print("\n".join(words))
