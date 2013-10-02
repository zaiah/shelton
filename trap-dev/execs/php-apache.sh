#!/bin/bash
#------------------------------------
# php-apache
#
# Deploy PHP in a LAMP stack. 
#------------------------------------
PROTOCOL=ssh		# This may change in the future.

# This gets copied to the server.
COPY=(
	"php"
)

# This gets executed on the server.
__EXEC=" 

"
