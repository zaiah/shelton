#------------------------------------------------------
# string.sh
# 
# Do cool stuff with strings.
#-----------------------------------------------------#

# break-list - creates an array based on some set of delimiters.
_break_list() {
	local delim="${2-,}"			# Allow for an alternate delimiter.
	local mylist=(`printf $1 | sed "s/${delim}/ /g"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

# break_once - creates an array based on a delimiter, but only
# 	performs only on the first instance.
_break_once() {
	local delim="${2-,}"			# Allow for an alternate delimiter.
	local mylist=(`printf $1 | sed "s/${delim}/ /"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

# break-maps - gives a map based on a set of delimiters.
_break_maps() {
	join="${2-=}"			# Allow for an alternate map marker.
	local m=(`printf $1 | sed "s/${join}/ /g"`)
	echo ${m[@]}			# Return the list all ghetto-style.
}

# __APPEND - Dynamically create and add to some string.
__APPEND () {
	VALUE="$1"
	COMBINER="$2"
	__STRING=${__STRING}

	if [ ! -z "$VALUE" ]
	then
		# Check operators.
		test -z "$COMBINER" && COMBINER="" # use nothing and just combine.

		# Puke out a string 
		test -z "$__STRING" && __STRING=$VALUE || __STRING="${__STRING}${COMBINER}${VALUE}"
#		echo $__STRING
	fi
}

# aliases ...
__BREAK_MAPS="_break_maps"
__BREAK_ONCE="_break_once"
__BREAK_LIST="_break_list"

#------------------------------------------------------
# string.sh
# 
# Do cool stuff with strings.
#-----------------------------------------------------#

# break-list - creates an array based on some set of delimiters.
_break_list() {
	local delim="${2-,}"			# Allow for an alternate delimiter.
	local mylist=(`printf $1 | sed "s/${delim}/ /g"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

# break_once - creates an array based on a delimiter, but only
# 	performs only on the first instance.
_break_once() {
	local delim="${2-,}"			# Allow for an alternate delimiter.
	local mylist=(`printf $1 | sed "s/${delim}/ /"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

# break-maps - gives a map based on a set of delimiters.
_break_maps() {
	join="${2-=}"			# Allow for an alternate map marker.
	local m=(`printf $1 | sed "s/${join}/ /g"`)
	echo ${m[@]}			# Return the list all ghetto-style.
}

# __APPEND - Dynamically create and add to some string.
__APPEND () {
	VALUE="$1"
	COMBINER="$2"
	__STRING=${__STRING}

	if [ ! -z "$VALUE" ]
	then
		# Check operators.
		test -z "$COMBINER" && COMBINER="" # use nothing and just combine.

		# Puke out a string 
		test -z "$__STRING" && __STRING=$VALUE || __STRING="${__STRING}${COMBINER}${VALUE}"
#		echo $__STRING
	fi
}

# aliases ...
__BREAK_MAPS="_break_maps"
__BREAK_ONCE="_break_once"
__BREAK_LIST="_break_list"

#------------------------------------------------------
# string.sh
# 
# Do cool stuff with strings.
#-----------------------------------------------------#

# break-list - creates an array based on some set of delimiters.
_break_list() {
	local delim="${2-,}"			# Allow for an alternate delimiter.
	local mylist=(`printf $1 | sed "s/${delim}/ /g"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

# break_once - creates an array based on a delimiter, but only
# 	performs only on the first instance.
_break_once() {
	local delim="${2-,}"			# Allow for an alternate delimiter.
	local mylist=(`printf $1 | sed "s/${delim}/ /"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

# break-maps - gives a map based on a set of delimiters.
_break_maps() {
	join="${2-=}"			# Allow for an alternate map marker.
	local m=(`printf $1 | sed "s/${join}/ /g"`)
	echo ${m[@]}			# Return the list all ghetto-style.
}

# __APPEND - Dynamically create and add to some string.
__APPEND () {
	VALUE="$1"
	COMBINER="$2"
	__STRING=${__STRING}

	if [ ! -z "$VALUE" ]
	then
		# Check operators.
		test -z "$COMBINER" && COMBINER="" # use nothing and just combine.

		# Puke out a string 
		test -z "$__STRING" && __STRING=$VALUE || __STRING="${__STRING}${COMBINER}${VALUE}"
#		echo $__STRING
	fi
}

# aliases ...
__BREAK_MAPS="_break_maps"
__BREAK_ONCE="_break_once"
__BREAK_LIST="_break_list"

