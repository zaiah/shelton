#------------------------------------------------------
# usage.sh 
# 
# Display a usage message and quit (or not).
#-----------------------------------------------------#

# Display a usage message.
usage() {
	__STATUS=${1-0}
	__USAGE_ERR="${__USAGE_ERR-$2}"

	if [ ! -z "$__USAGE_ERR" ]
	then
		echo $__USAGE_ERR
	fi

	echo "$__USAGE_MSG"
	exit $__STATUS
}
