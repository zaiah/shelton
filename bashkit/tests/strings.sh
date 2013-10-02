#!/bin/bash - 
#------------------------------------------------------
# strings.sh 
# 
# Run some tests with strings.
#-----------------------------------------------------#

# Could use something to do what we've been doing.
# (Chop up some names, return some item based on the results of the case statement.)

source "include/string.sh"

# Test append of strings.
for n in "wil" "i" "am"
do
	__APPEND $n "."
done 

echo $__STRING

