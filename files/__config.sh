#-----------------------------------------------------#
# __config.sh
# 
# DO NOT TOUCH THIS FILE!
# These are internal settings for shelton to run
# correctly.   They may move over to the database
# eventually.  Keeps breaking with spaces.
#-----------------------------------------------------#

# General settings. 
BINDIR=$(dirname "$(readlink -f $0)")
#DIR="$BINDIR/trap-dev"				# System directory. 
DIR="$HOME/.shelton"			      # System directory. 
TMP="$DIR/tmp"							# Temporary files and handles.
EXECS="$DIR/execs"					# Files to execute on server.
KEYS="$DIR/keys"						# SSH keys can go here.
CONFIG_FILE="$DIR/shelton.conf"	# The configuration file for user settings.
SQL_FILE="$BINDIR/files/__setup.sql"	# SQL to make tables. 

# SQLite3 from Bashkit settings
__DB="$DIR/shelton.db"
__TABLE="hosts"
PDELIM='='

# All current files in the distribution.
LIST=( "$(ls $BINDIR/*.sh)" )		# Skip configuration files.

# Include Bashkit stuff
source "$BINDIR/bashkit/include/litesec.sh"
source "$BINDIR/bashkit/include/unirand.sh"
source "$BINDIR/bashkit/include/string.sh"
source "$BINDIR/bashkit/include/sqlite3.sh"
source "$BINDIR/bashkit/include/arg.sh"
source "$BINDIR/bashkit/include/usage.sh"

# Include any other side files.
source "$BINDIR/files/__help-format.sh"	# Help files.
source "$CONFIG_FILE"							# User help files.
