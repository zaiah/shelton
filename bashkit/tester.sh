#!/bin/bash -xv
#------------------------------------------------------
# tester.sh 
# 
# Some tests and terms to use when checking this out.
#-----------------------------------------------------#

# This should run within bashkit.sh


# Source the libs in question.
source "include/arg.sh"

# Is it an argument.
echo 'Results of:'
echo 'is_arg "granny"'
test $(is_arg "granny") && echo "Is an arg!" || echo "Not an arg!"

# Is it a flag? 
echo 'Results of:'
echo 'is_flag "granny"'
test $(is_flag "granny") && echo "Is a flag!" || echo "Not a flag!"

# If it's an arg, die!
echo 'Results of:'
echo 'is_flag "-granny"'
test $(is_flag "-granny") && exit 1

# We should never make it this far.
echo "Yay, we made it to the end."



