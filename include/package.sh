#------------------------------------------------------
# package.sh
# 
# Administer packages.
#-----------------------------------------------------#

# Setup.
__EDITOR=$EDITOR			# Vim !!! Yay!!!
__PDELIM=":"				# Primary delimiter.
__SDELIM=","				# Secondary or set delimiter.
__TABLE="packages"		# Table choice.

__bashkit "string.sh"	# String lib.
__bashkit "unirand.sh"	# Random lib.
__bashkit "sql.sh"		# SQLite3 lib.

# Does record exist?
__EXISTS() {
	if [ -z "$1" ]
	then
		usage 1 "No identifer supplied"
	fi

	BY_ID=$($__SQLITE $__DB "SELECT id FROM ${__TABLE} WHERE id LIKE '${1}'")
	BY_NAME=$($__SQLITE $__DB "SELECT name FROM ${__TABLE} WHERE name = '${1}'")
	
	# You'll have to make sure multiple records do not exist when using name.
	if [[ $BY_ID != '' ]]
	then
		KEY="id"
		VALUE=$BY_ID
	elif [[ $BY_NAME != '' ]]
	then
		KEY="name"
		VALUE=$BY_NAME
	fi
} 

# Add a record.
__ADD() {
	UUID=$(__GET_UUID)
	$__SQLITE $__DB \
		"INSERT INTO ${__TABLE} VALUES (
			'$UUID',
			'${1}',
			'${2}',
			'${3}',
			'${4}'	
		);"
}

# Update a record.
__UPDATE() {
	if [ ! -z $ID ]
	then
	$__SQLITE $__DB \
			"UPDATE ${__TABLE} SET $1 = '$2' WHERE id LIKE '${ID}%';"
	fi
}

# Evaluate record to update.
__EVAL() {
	case $1 in
		s|software)
			__UPDATE "software" $2
		;;
		n|name)
			__UPDATE "name" $2
		;;
		m|md5)
			__UPDATE "md5" $2
		;;
		a|addr)
			__UPDATE "addr" $2
		;;
		i|id|identifier) 
			ID=${2-""}
		;;
		*)  # Jump out of the loop?
			break
		;;
	esac
}

# Decide what's being written.
# (JSONish colons help, but I know of no other way to simplify this.)
__SET_NAMESPACE() {
	case $1 in
		s|software) 
			PKGRECORD[0]=${2-""}
		;;	
		n|name) 
			PKGRECORD[1]=${2-""}
		;;	
		m|md5) 
			PKGRECORD[2]=${2-""}
		;;	
		a|addr) 
			PKGRECORD[3]=${2-""}
		;;	
		*)
		break
		;;
	esac
}

# Do some cool stuff with packages.
if [[ $ARG == "@e" ]]
then
	# Create temp dir.
	if [ ! -d "$TMP" ]
	then
		mkdir -p $TMP
	fi 

	# Edit the SQL dump.
	UUID=$(__GET_UUID)
	TMP_DUMP="$TMP/${UUID}.csv"  	# Some random file name.

	# If this is blank, you need something to alert you or the user.
	$__SQLITE $__DB "SELECT * FROM ${__TABLE};" > "$TMP_DUMP"
	$__EDITOR "$TMP_DUMP" 

	__SQL_RELOAD "${__TABLE}" \
		"id TEXT,software TEXT,name TEXT,md5 TEXT,addr TEXT" \
		"$TMP_DUMP"

	rm $TMP_DUMP

# Show what's loaded.
elif [[ $ARG == "@s" ]]
then
	$__SQLITE -line $__DB "SELECT * FROM ${__TABLE};"
	
elif [ ! -z "$ARG" ]
then
	# Chop up list argument to see what we want.
	LIST=( $(_break_list "$ARG" "${__SDELIM}") )

	# Search for id, then modify the record. 
	# Does this work in other versions of Bash?
	if [[ $ARG =~ "id${__PDELIM}" ]] || 
		[[ $ARG =~ "i${__PDELIM}" ]] 
	then
		for ENTRY in ${LIST[@]}
		do
			__EVAL $(_break_once $ENTRY "${__PDELIM}") 
		done

	# Search for name, and add a new record. 
	elif [[ $ARG =~ "name${__PDELIM}" ]] || 
		[[ $ARG =~ "n${__PDELIM}" ]]  
	then
		# Save results from the CLI.
		# if record exists, modify unless told to remove
		# if record does not exist, add
		for ENTRY in ${LIST[@]}
		do
			__SET_NAMESPACE $(_break_once $ENTRY "${__PDELIM}")
		done

		__ADD "${PKGRECORD[0]}" \
			"${PKGRECORD[1]}" \
			"${PKGRECORD[2]}" \
			"${PKGRECORD[3]}" 
	fi
else
	usage 1 "No string supplied."
fi
