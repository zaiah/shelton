#!/bin/bash
#------------------------------------
# build-postgres
#
# <awaiting description> 
#------------------------------------
PROTOCOL=ssh		# This may change in the future.

# This gets copied to the server.
COPY=(

)

# This gets executed on the server.
EXEC () {
	TARFLAGS="xvjf"
	./configure
}
