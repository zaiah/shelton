# --------------------------
# globals.sh 
# 
# All of our global variables
# will go here.
# --------------------------

# Grab broken out code. 
__dep() {
	if [ ! -z "$1" ]
	then
		source "$BINDIR/include/$1"
	fi	
}

# Grab something out of bashkit.
__bashkit() {
	if [ ! -z "$1" ]
	then
		echo "$BINDIR/bashkit/include/${1}.sh"
		source "$BINDIR/bashkit/include/${1}.sh"
	fi	
}

# Throw an error.
error() {
	echo "$@" 1>&2
	usage 1 "An error occurred."
}

# Use Bashkit.
__bashkit "arg"
__bashkit "sql"
__bashkit "string"

# Source user variables and help.
__dep "user.sh"
__dep "defaults.sh"
__dep "usage.sh"

# Local globals. 
__FIRST_RUN="first_run.sh"
__SQLITE="$(which sqlite3)"
__DB="$SYS/trap.db"
__CONFIG="$BINDIR/include/user.sh"

__FDIR="$SYS/functions"
__CDIR="$SYS/configs"
__TDIR="$SYS/templates"

# Include wrapper.
__include() {
	if [ ! -z "$1" ] 
	then
		__FILE="$SYS/${1}.sh"
		if [ -f "$FILE" ]
		then
			source ${FILE}.sh
		fi
	fi
}

# Get templates.
tinclude() { include "templates/$1"; }

# Get functions.
finclude() { include "functions/$1"; }

# Get configurations.
cinclude() { include "config/$1"; }

