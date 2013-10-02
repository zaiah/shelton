#!/bin/bash
#------------------------------------
# postgres-install
#
# Install Postgres on a server.  Note: 
# This will handle the install only.  
# Roles and access permissions are not 
# done from here. 
#------------------------------------
PROTOCOL=ssh		# This may change in the future.

# This gets copied to the server.
COPY=(
	"postgresql-9.2.2"
)

# This gets executed on the server.
__EXEC=" 

"
