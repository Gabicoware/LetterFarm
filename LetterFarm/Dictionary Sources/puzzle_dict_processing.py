import os
import sys

fileIndex = len(sys.argv) - 1

input_dict_filename = sys.argv[fileIndex]

length = "3"

name = "3"

min_freq = "1000000"

if (1 < fileIndex):
    length = sys.argv[1]

if (2 < fileIndex):
    min_freq = sys.argv[2]

if (3 < fileIndex):
    name = sys.argv[3]
else:
    name = length

min_perm = "1"

if (4 < fileIndex):
    min_perm = sys.argv[4]


all_words_dict_filename = "/tmp/words."+name+".lfd.txt"

freq_words_dict_filename = "/tmp/freq."+name+".lfd.txt"

freq_output_filename = "/tmp/freq."+name+".lfwf.txt"

moves_output_filename = "/tmp/moves."+name+".lfm.txt"

dictionary_processing_command = "python dictionary_processing.py "+length+" "+input_dict_filename+" > "+all_words_dict_filename

ngrams_processing_command = "python ngram_dict_processing.py --dict "+all_words_dict_filename+" --badwords badwords.txt ngrams/ngrams-0.tmwsums ngrams/ngrams-1.tmwsums ngrams/ngrams-2.tmwsums ngrams/ngrams-3.tmwsums ngrams/ngrams-4.tmwsums ngrams/ngrams-5.tmwsums ngrams/ngrams-6.tmwsums ngrams/ngrams-7.tmwsums ngrams/ngrams-8.tmwsums ngrams/ngrams-9.tmwsums > "+freq_output_filename

freq_post_processing_command = "python frequency_post_processing.py "+min_freq+" "+all_words_dict_filename+" "+freq_output_filename+" > "+freq_words_dict_filename


start_word_processing_command = "./StartWordGenerator --input="+freq_words_dict_filename+" --output="+moves_output_filename+" --length=10"
start_word_filter_processing_command = "./StartWordGenerator --input="+freq_words_dict_filename+" --output="+moves_output_filename+" --length=1 --filter-only"

dryrun = 1 == 0

print(dictionary_processing_command)
if not dryrun:
    os.system(dictionary_processing_command)

print(ngrams_processing_command)
if not dryrun:
    os.system(ngrams_processing_command)

print(freq_post_processing_command)
if not dryrun:
    os.system(freq_post_processing_command)

print(start_word_processing_command)
if not dryrun:
    os.system(start_word_processing_command)

print(start_word_filter_processing_command)
if not dryrun:
    os.system(start_word_filter_processing_command)


#puzzles only
#python dictionary_post_processing.py words.3.tmwd words.3.tmwperm words.3.tmwwf > puzzle.3.tmwd