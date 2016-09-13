#!/usr/bin/python3 -u
#using -u here to make stdin unbuffered
import sys

l=0
n=""
s=""
if len(sys.argv) > 1: #get the needle and its length
    l = len(sys.argv[1])
    n = sys.argv[1]

while l > 0: #"endless" loop if we have a needle
    c=sys.stdin.read(1)
    if len(c) == 0:
        sys.exit(1) #stream ended, needle not found
    s+=c
    s=s[-l:] #store the last l characters for comparison
    if s == n:
        sys.exit(0) #needle was found

#usage message if needle is missing
import os.path
print("Usage:")
print(os.path.basename(sys.argv[0])+" needle")
print("")
print("blocks until the string passed in the first argument (\"needle\") is found on stdin or the stream ends")
print("additional parameters are ignored")
print("")
print("returns 0 if string is found")
print("returns 1 if string is not found")
print("returns 2 if no string is given")
print("")
print("This message is shown if no string is given")

sys.exit(2) #errorcode for missing needle
