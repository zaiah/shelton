#!/bin/bash
#------------------------------------
# apache
#
# Deploy Apache into a production environment. 
#------------------------------------
PROTOCOL=ssh		# This may change in the future.

# This gets copied to the server.
COPY=(
	"httpd"
)

# This gets executed on the server.
__EXEC=" 

"
