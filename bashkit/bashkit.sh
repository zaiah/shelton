#!/bin/bash -
#------------------------------------------------------
# bashkit.sh  
# 
# A small set of utilities for writing BASH scripts
# faster.
#
# Usage 
# Top level include for all the different scripts.
# If you want to pick and choose, simply use:
#
# source bashkit/include/$FILE  
# or
# . bashkit/include/$FILE
#
# Info
# Written by: Antonio R. Collins II 
#             (ramar.collins@gmail.com)
#
# To Do
# Move over the case word split code.   
# Or write some thing to iterate over the individual
# characters.
#-----------------------------------------------------#

# Should work on regular *nix & Cygwin too.
BINDIR=$(dirname "$(readlink -f $0)")
INCLUDE_DIR="include"
INCLUDE_DEPS=(
	"sqlite3.sh"
	"arg.sh"
	"string.sh"
	"litesec.sh"
	"unirand.sh"
)

# Little Message
bashkit_message() {
	echo "	
#------------------------------------------------------
# bashkit.sh  
# 
# Contains a small set of utilities for writing Bash 
# shell scripts faster.
#
# Written by: Antonio R. Collins II (vokayent@gmail.com)
# Modified:   `date +%F` 
#------------------------------------------------------"
}

# Usage
usage() {
	STATUS=${1-0}
	USMSG=${2-""}
	cat <<EOF
$USMSG
Usage: 
./bashkit.sh
         [ -adt ] 
         [ -oi { a,s,st,l,u: <item> } ]
         [ -l <location> ]
         [ --help ]

--one-file "1,2,n" Generate one file from a comma seperated list.
--all              Assemble the entire kit into one file.
--depcheck         Check a system for dependencies and output a list.
--location <dir>   Generate a bashkit file at the location specified.
--info             Give info on particular pieces of the library.
--update           Update the bashkit at a particular location.
--tests "1,2,n"    Run specified tests.
--help             Show this help and quit.
EOF
	exit $STATUS
}

# Evaluate what comes from the command line.
eval_cmd() {
	case "$1" in
		a|ar|arg) 
			echo "arg.sh" 
		;;	
		s|sq|sql|sqli|sqlit|sqlite|sqlite3) 
			echo "sqlite.sh" 
		;;	
		st|str|stri|strin|string) 
			echo "string.sh" 
		;;	
		l|ls|li|lit|lite|lites|litese|litesec) 
			echo "litesec.sh" 
		;;	
		u|un|uni|unir|unira|uniran|unirand)	
			echo "unirand.sh" 
		;;	
		*)
			usage 1 "Unknown identifier: $1"
		;;
	esac
}

# Process options.
while [ $# -gt 0 ]
do
	case "$1" in
		-1|-o|--one-file)
		shift
		FILES="$1"
		;;
		-a|--all)
		ALL=true
		shift
		LOCATION=$1
		;;
		-d|--depcheck)
		DEPCHECK=true	
		;;
		-l|--location)
		shift
		LOCATION=$1
		;;
		-i|--info|--functions-and-variables)
		shift
		INFO=$1
		;;
		-u|--update) # Note: use some delimiter to update a file's bashkit stuff.
		shift
		LOCATION=$1
		;;
		-t|--tests)
		TESTS=true
		;;
		-h|-?|--help)
		usage 0
		;;
		-*) usage 1 "Error: Unrecognized option: $1"
		;;
		*) break
		;;
	esac
	shift
done

# Logic.
if [ ! -z "$FILES" ] 
then
	source "$BINDIR/include/string.sh"
	FILE_LIST=( $( _break_list $FILES ) )
	LOCATION=${LOCATION-"${BINDIR}"}
	SRC="${LOCATION}/bashkit-custom.sh"

	# Concatenate our files.
	for EACH_FILE in ${FILE_LIST[@]}
	do
		cat "$BINDIR/include/$(eval_cmd $EACH_FILE)" >> "$SRC"
		printf "\n" >> $SRC
	done

# Combine all files.
elif [ ! -z "$ALL" ]
then
	if [ -z "$LOCATION" ]
	then
		printf "Error: No location specified.\n"
		printf "Try either the -l option or @ to echo to STDOUT.\n"	
		usage 1

	# Print to STDOUT
	elif [[ "$LOCATION" == '@' ]]
	then
		for EACH_FILE in ${INCLUDE_DEPS[@]}
		do
			bashkit_message
			cat "$BINDIR/include/$EACH_FILE"
			printf "\n" 
		done

	# Print to file.
	else	
		SRC="${LOCATION}/bashkit.sh"
		bashkit_message > $SRC
		for EACH_FILE in ${INCLUDE_DEPS[@]}
		do
			cat "$BINDIR/include/$EACH_FILE" >> "$SRC"
			printf "\n" >> $SRC
		done
	fi

# Get information about the different modules.
elif [ ! -z "$INFO" ]
then
	echo "info...."

# Run tests.
elif [ ! -z "$TESTS" ]
then
	echo "String library tests:"
	source "tests/strings.sh"		

	echo "Argument library tests:"
	source "tests/arg.sh"
fi	
