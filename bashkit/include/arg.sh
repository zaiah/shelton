#------------------------------------------------------
# arg.sh 
# 
# Stuff with arguments.
#-----------------------------------------------------#

# Usage: is_arg - If $1 is an argument, return true 
is_arg() {
	( [ ! -z "$1" ] && [[ "${1:0:1}" != '-' ]] ) && echo 0 || return 1
}

# Usage: is_flag - If $1 is a flag, return true.
is_flag() {
	( [ -z "$1" ] || [[ "${1:0:1}" == "-" ]] ) && echo 0 || return 1
}

# Usage: error - Die if something bad happpened.
#  (Can't kill from here?
error() {
	echo $1 >&2
}
