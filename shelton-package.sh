#!/bin/bash -
# ---------------------------------------
# package.sh
#
# Package management.
# ---------------------------------------

PROGRAM="package"
source "$(dirname "$(readlink -f $0)")/files/__config.sh"

# Options
[ -z "$BASH_ARGV" ] && usage 1 "Nothing to do."
while [ $# -gt 0 ]
do
	case "$1" in
		-g|--generate)
		;;
		-u|--use)
		;;
		-q|--query)
		;;
		-h|--help|-?)
		;;
	esac
	shift
done
