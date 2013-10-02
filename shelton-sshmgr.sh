#!/bin/bash -
#-----------------------------------
# sshmgr.sh
#
# Manage all the different keys.
#-----------------------------------

# Get dependencies.
PROGRAM="sshmgr"
source "$(dirname "$(readlink -f $0)")/files/__config.sh"

# Usage message.
__USAGE_MSG="
Usage: 
 ./sshmgr.sh [ -acmrs ] {ukphdi:<item>}
             [ --first-run ]
             [ --everything ]
             [ -h ]

Options:
 Actions:
 -a | --add        Add a new host entry.
 -c | --create     Create a new key.
 -m | --modify     Update an existing host entry.
 -r | --remove     Remove a new host entry.

 Queries:
 -e | --show-all   Return a list of all hosts.
 -s | --string     Return a string formatted for use with openssh.
 -g | --get <key>  Return a single column with host information.

 General:
 -h | --help       Display help and quit.
 --first-run       Setup sshmgr on your system."

# help_format
help_format () {
	__hf_sshmgr
	usage 0
}

# This is so stupid...
sanitize() {
	STUFF=$(_break_list $1)  # I Just want the first arg.
	for EACH_VAL in ${STUFF[@]}
	do
		PARTS=( $(_break_once $EACH_VAL "$PDELIM") )
		case "${PARTS[0]}" in
			u|us|use|user|\
			k|ke|key|\
			p|po|por|port|\
			h|ho|hos|host|\
			i|id|\
			n|na|nam|name|\
			d|de|def|l|lo|loc|location|default_location)
			;;
			*)
			usage 1 "Error: Unrecognized identifier '${PARTS[0]}'"
			;;
		esac
	done
}


# Negotitate stdin.
nego() {
	test ! -z "$1" || usage 1 "No statement supplied."
	for VALUE in $( _break_list "$1" )
	do
		VALS=( $( _break_once "$VALUE" "$PDELIM" ) )
		case ${VALS[0]} in
			u|us|use|user)
				HOST_USER="${VALS[1]}"
			;;
			k|ke|key)
				KEY="${VALS[1]}"
			;;
			p|po|por|port)
				PORT="${VALS[1]}"
			;;
			h|ho|hos|host)
				HOST="${VALS[1]}"
			;;
			n|na|nam|name)
				NAME="${VALS[1]}"
			;;
			d|de|def|l|lo|loc|location|default_location)
				DEFAULT_LOCATION="${VALS[1]}"
			;;
		esac
	done
}

# Decide on an identifier and return something useful.
namespace() {
	test ! -z "$1" || usage 1 "No statement supplied."
	for VALUE in $( _break_list "$1" )
	do
		VALS=( $( _break_once "$VALUE" "$PDELIM" ) )
		case ${VALS[0]} in
			u|us|use|user)
				echo "user${PDELIM}${VALS[1]}"
			;;
			k|ke|key)
				echo "key${PDELIM}${VALS[1]}"
			;;
			p|po|por|port)
				echo "port${PDELIM}${VALS[1]}"
			;;
			h|ho|hos|host)
				echo "host${PDELIM}${VALS[1]}"
			;;
			n|na|nam|name)
				echo "name${PDELIM}${VALS[1]}"
			;;
			d|de|def|l|lo|loc|location|default_location)
				echo "default_location${PDELIM}${VALS[1]}"
			;;
			i|id)
				echo "id${PDELIM}${VALS[1]}"
			;;
		esac
	done
}


# Return just the column name. 
column_name() {
	test ! -z "$1" || usage 1 "No statement supplied."
	for VALUE in $( _break_list "$1" )
	do
		VALS=( $( _break_once "$VALUE" "$PDELIM" ) )
		case ${VALS[0]} in
			u|us|use|user)
				echo "user"
			;;
			k|ke|key)
				echo "key"
			;;
			p|po|por|port)
				echo "port"
			;;
			h|ho|hos|host)
				echo "host"
			;;
			n|na|nam|name)
				echo "name"
			;;
			d|de|def|l|lo|loc|location|default_location)
				echo "default_location"
			;;
			i|id)
				echo "id"
			;;
		esac
	done
}


# Add a new host record.
add_host() {
	nego "$1"
	UUID=$( __GET_SHORT_UUID )
	__ADD "'$UUID','${HOST_USER-""}','${HOST-""}','${KEY-""}',${PORT-22},'${DEFAULT_LOCATION-""}','${NAME-""}'"
}


# Remove a host record.
remove_host() {
	# Filter bad calls.
	if [ -z "$1" ]
	then
		usage 1 "Error: Criteria must be specified."
	fi
	
	# Set up our identifier.
	CRITERIA=( $( _break_once $( namespace "$1" ) "$PDELIM" ) )

	# Update where we find the unique ID.
	ID=$( __GET_ID_BY_VALUE ${CRITERIA[0]} ${CRITERIA[1]} )
	__REMOVE "${CRITERIA[0]}" "${CRITERIA[1]}" 
}


# Modify a host record.
modify_host() {
	# Filter bad calls.
	if [ -z "$1" ] || [ -z "$2" ]
	then
		usage 1 "Error: Criteria and values must be specified."
	fi
	
	# Set up our identifier.
	CRITERIA=( $( _break_once $( namespace "$1" ) $PDELIM ) )

	# Set up our new value.
	UPDATED=( $( _break_once $( namespace "$2" ) $PDELIM ) )

	# Update where we find the unique ID.
	ID=$( __GET_ID_BY_VALUE ${CRITERIA[0]} ${CRITERIA[1]} )
	__UPDATE "${UPDATED[0]}='${UPDATED[1]}'" "id='$ID'"
}


# Return all hosts.
grab() {
	if [ -z $1 ]
	then
		__SELECT 
	else
		# Need some clauses to make each results output a little smarter.
		TERM=""
		for term in $( _break_list $1 )
		do
			TERM=$TERM
		done
		__PSELECT "$1"
	fi
}


# Return information in ssh command form.
sshready() {
	# Find multiple arguments....
	sanitize $1
	NAMESPACE=( $( _break_once $( namespace "$1" ) $PDELIM ) )
 	RESPONSE=$( __PSELECT "user, host, default_location" \
		"WHERE ${NAMESPACE[0]} = '${NAMESPACE[1]}'" )
	echo $RESPONSE | sed 's/|/@/' | sed 's/|/:/'
}


# Create a new key when necessary.
create_key() {
	# This should be wrapped to choose strength.
	ssh-keygen -t rsa -b 4096 "$KEYNAME"
 }


# Option processing.
[ -z $BASH_ARGV ] && usage 1 "Nothing to do."
while [ $# -gt 0 ]
do
	case "$1" in

		# ???
		-e|--show-all)
			grab
		;;

		-a | --add)
			shift
			add_host "$1"
		;;

		# Must check that $2 is not a cli arg.
		-r | --remove)
			shift
#			is_arg_or_exit $1
			remove_host "$1" 
			shift
		;;
		-m | --modify)
			shift
#			is_arg_or_exit $1
#			is_arg_or_exit $2	
			modify_host "$1" "$2"
			shift
		;;
	
		# Change some element.	
		-c | --change)
		;;
		
		-g | --get)
			shift
			grab "$1"
		;;

		-s | --string)
			shift
#			is_arg_or_exit $1 
			sshready "$1"	
		;;
		-k | --keyname)
			shift
			#is_arg $1		t or f
			KEYNAME="-i $1"
		;;
		-h | --help | -?)
			usage 0
		;;
		--help-format)
			help_format	
		;;
		-*)
			usage 1 "Unrecognized option $1";
		;;
		*)
			break	
		;;
	esac
	shift
done

# Logic?
