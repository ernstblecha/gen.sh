#!/usr/bin/python3 -u
# using -u here to make stdin unbuffered

# This file is part of gen.sh.
#
# gen.sh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# gen.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gen.sh.  If not, see <http://www.gnu.org/licenses/>.

import sys
import os
VERSION = 2
if os.environ.get("GET_VERSION") == "1":
    print(VERSION)
    sys.exit(0)

w = 0
n = ""
s = ""
if len(sys.argv) > 1:  # get the needle and its length
    w = len(sys.argv[1])
    n = sys.argv[1]

while w > 0:  # "endless" loop if we have a needle
    c = sys.stdin.read(1)
    if len(c) == 0:
        sys.exit(1)  # stream ended, needle not found
    s += c
    s = s[-w:]  # store the last l characters for comparison
    if s == n:
        sys.exit(0)  # needle was found

# usage message if needle is missing
print(os.path.basename(sys.argv[0])+" needle")
print("")
print("blocks until the string passed in the first argument (\"needle\") is found on stdin or the stream ends")  # noqa: E501
print("additional parameters are ignored")
print("")
print("returns 0 if string is found")
print("returns 1 if string is not found")
print("returns 2 if no string is given")
print("")
print("This message is shown if no string is given")
print("")
print("Version of "+os.path.basename(sys.argv[0])+": " + str(VERSION))

sys.exit(2)  # errorcode for missing needle
