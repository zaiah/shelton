#!/bin/bash -xv
#------------------------------------------------------
# arg.sh 
# 
# Tests for arguments.
#-----------------------------------------------------#

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
test $(is_flag "-granny") && echo "???"

