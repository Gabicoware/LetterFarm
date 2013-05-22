import sys
import os.path


fileIndex = len(sys.argv) - 1

input_file_name = sys.argv[fileIndex]

fileIN = open(input_file_name, "r")
    
print("")
print("########################################")
print("############## Word Judger #############")
print("########################################")
print("")
name = raw_input("Enter your first name:")

output_file_name = name + "." + input_file_name




if os.path.isfile(output_file_name):

    fileOUT_R = open(output_file_name, "r")
    
    outLine = fileOUT_R.readline()
    
    while outLine:
        line = fileIN.readline()
        outLine = fileOUT_R.readline()


fileOUT = open(output_file_name, "a+")

line = fileIN.readline()


while line:
    word = line.strip()
    value = ""
    print("\n\n>>>>" + word + "\n")
    while (value == ""):
        input = raw_input("(1,2,3,x):")
        if input == "x":
            fileOUT.close()
            exit()
        elif (input == "1" or input == "2" or input == "3") :
            value = input
        else:
            print("\""+input+"\" is invalid")

    fileOUT.write(str(value)+"\n")
    line = fileIN.readline()
