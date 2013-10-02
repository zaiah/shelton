#!/bin/bash
#------------------------------------
# arch_with_jack
#
# Build Arch in a VM with jack
# support.
#------------------------------------
PROTOCOL=ssh		# This may change in the future.

# This gets copied to the server.
COPY=(
	
)

# This gets executed on the server.
__EXEC=" 
echo ========================================
echo Arch Install
echo ========================================

"
