import os
import sys

fileIndex = len(sys.argv) - 1

input_dict_filename = sys.argv[fileIndex]

length = "3"

min_freq = "1000000"

if (1 < fileIndex):
    length = sys.argv[1]

if (2 < fileIndex):
    min_freq = sys.argv[2]


all_words_dict_filename = "words."+length+".tmwd.debug.txt"

freq_words_dict_filename = "freq."+length+".tmwd.debug.txt"

freq_output_filename = "freq."+length+".tmwwf.debug.txt"

perms_filename = "freq."+length+".tmwperm.debug.txt"

final_output_filename = "puzzle."+length+".debug.tmwd"

dictionary_processing_command = "python dictionary_processing.py "+length+" "+input_dict_filename+" > "+all_words_dict_filename

ngrams_processing_command = "python ngram_dict_processing.py --dict "+all_words_dict_filename+" --badwords badwords.txt --debug-output ngrams/ngrams-0.tmwsums ngrams/ngrams-1.tmwsums ngrams/ngrams-2.tmwsums ngrams/ngrams-3.tmwsums ngrams/ngrams-4.tmwsums ngrams/ngrams-5.tmwsums ngrams/ngrams-6.tmwsums ngrams/ngrams-7.tmwsums ngrams/ngrams-8.tmwsums ngrams/ngrams-9.tmwsums > "+freq_output_filename

freq_post_processing_command = "python frequency_post_processing.py "+min_freq+" "+all_words_dict_filename+" "+freq_output_filename+" > "+freq_words_dict_filename

permutation_processing_command = "python permutation_processing.py "+freq_words_dict_filename+" > " + perms_filename

permutation_post_processing_command = "python permutation_post_processing.py "+freq_words_dict_filename+" "+perms_filename+" > "+final_output_filename


dryrun = 1 == 0

print(dictionary_processing_command)
if not dryrun:
    os.system(dictionary_processing_command)

print(ngrams_processing_command)
if not dryrun:
    os.system(ngrams_processing_command)

exit()

print(freq_post_processing_command)
if not dryrun:
    os.system(freq_post_processing_command)

print(permutation_processing_command)
if not dryrun:
    os.system(permutation_processing_command)

print(permutation_post_processing_command)
if not dryrun:
    os.system(permutation_post_processing_command)


#puzzles only
#python dictionary_post_processing.py words.3.tmwd words.3.tmwperm words.3.tmwwf > puzzle.3.tmwd