#------------------------------------------------------
# sqlite.sh
# 
# Do typical queries with SQL.
#-----------------------------------------------------#

# Constants
__SQLITE="/usr/bin/sqlite3"		# Locate in the future

# Does SQLite exist on the system in question?
# Usage __SQLITE_EXISTS 
# Return 1 for false, 0 for true
__SQLITE_EXISTS() {
	for SEXEC in "/usr/bin/$__SQLITE" "/usr/local/bin/$__SQLITE" \
		"$( which sqlite3 )"
	do	
		test -f "$SEXEC" || return 1
	done
}

# Add some values.
# Usage __ADD <val1,val2,...,valN>
__ADD() {
	test ! -z "$1" || usage 1 "No statement supplied."
		$__SQLITE "$__DB" "INSERT INTO $__TABLE VALUES ( $1 );"
}

# Remove a value.
# Usage __REMOVE <val> <val>
__REMOVE() {
	test ! -z "$1" || usage 1 "No statement supplied."
		$__SQLITE "$__DB" "DELETE FROM $__TABLE WHERE $1 = '$2';"
}

# Update a value.
# Usage __UPDATE <col=new_val> <criteria>
__UPDATE() {
	test ! -z "$1" || usage 1 "No statement supplied."
		echo $__SQLITE "$__DB" "UPDATE $__TABLE SET $1 WHERE $2;"
}

# Select something.
# Usage: __SELECT [term] [clause]
__SELECT() {
	if  [ ! -z "$1" ]
	then
		if [[ $2 =~ "WHERE" ]] || [[ $2 =~ "where" ]] 
		then
			$__SQLITE -line "$__DB" "SELECT $1 FROM $__TABLE $2;"
		else
			$__SQLITE -line "$__DB" "SELECT $1 FROM $__TABLE;"
		fi
	else
		$__SQLITE -line "$__DB" "SELECT * FROM $__TABLE;"
	fi
}

# Select something and return in parseable form.
# Usage: __PSELECT [term] [clause]
__PSELECT() {
	if  [ ! -z "$1" ]
	then
		if [[ $2 =~ "WHERE" ]] || [[ $2 =~ "where" ]] 
		then
			$__SQLITE "$__DB" "SELECT $1 FROM $__TABLE $2;"
		else
			$__SQLITE "$__DB" "SELECT $1 FROM $__TABLE;"
		fi
	else
		$__SQLITE "$__DB" "SELECT * FROM $__TABLE;"
	fi
}

# Retrieve an ID by value.
# Usage: __GET_ID_BY_VALUE [term] [clause]
__GET_ID_BY_VALUE() {
	# Shut down multiple records.
	RESULT=$( $__SQLITE "$__DB" "SELECT id FROM $__TABLE WHERE $1 = '$2';")
	echo $RESULT
}

# Retrieve an ID by statement result. 
# Usage: __GET_ID_BY_STATEMENT [term] [clause]
__GET_ID_BY_STMT() {
	# Shut down multiple records.
	RESULT=$( $__SQLITE "$__DB" "SELECT id FROM $__TABLE $1;")
	echo $RESULT
}

# Set a clause of unknown length.
__SQLCLAUSE() {
	# Specify approximate match.
	__APPROX="${2-false}"	

	# Dynamically generate a long query.
	__VALUE="${BLOCK[1]}" 
	__OPERATOR="="

	# Check operators.
	test -z $__WHERE && __WHERE="WHERE" || __WHERE="AND"
	[ $__APPROX ] && __VALUE="${BLOCK[1]}%" && __OPERATOR="LIKE"

	QUERY="$__QUERY $__WHERE $__CONSTANT $__OPERATOR '$__VALUE'"
	echo $QUERY
}

# Check the syntax of value separated file.
__SQLSYNTAX() {
	echo "..."
}

# Load the file from second line.
__SQL_RELOAD() {
	# Setup
	TABLE="$1"
	HEADER="$2"
	SQLT="$3"
	SEPCHAR="|"
	CONV="$TMP/run"

	if [ ! -z "$TABLE" ] && [ ! -z "$SQLT" ]
	then
		# Get rid of everything.
		$__SQLITE "$__DB" \
			"DROP TABLE $TABLE;"

		printf "CREATE TABLE $TABLE (" > $CONV
		printf "\n${HEADER} );" >> $CONV
		printf "\n.separator ${SEPCHAR}" >> $CONV
		printf "\n.import $SQLT $TABLE" >> $CONV  # Get rid of header.
		printf "\n.quit" >> $CONV

		$__SQLITE -init $CONV "$__DB" '.exit'
		rm $CONV
	fi
}
