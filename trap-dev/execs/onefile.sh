#!/bin/bash
#------------------------------------
# onefile
#
# <awaiting description> 
#------------------------------------
ON_THIS=
AT_LOCATION=
KEY=
PROTOCOL=ssh		# This may change in the future.

# This gets copied to the server.
COPY=(
	"a"
	"b"
	"c"
)

# This gets executed on the server.
EXEC () {
	touch "onefile"
}
