#!/bin/bash

# dbmgr
# A few scripts to help with managing regularly used databases.
#
# More
# We don't care about which ones do what, we just want to be able
# to stop, start and modify at different places regardless of what
# the stack is running on and where.

# Spec
# Our primary logic and options are here.
# We run from database or files.
# We can do some replication and stuff as well.
# and a little bit more...

# postgres, mysql, sql-server (testing)


# Options
# install
#  *builds from source or uses a package manager depending on os...
# configure (and create a profile or whatever)
#	*copy / initialize a key for a system that runs a database
#	*add credentials and database type 
# start
# stop
# restart
# move
# replicate
#  *replicate and start the slave process
# deploy
#	*a metafunction that installs, creates an instance and calls it a day

# Installs


# usage()
PROGRAM="shelton-db"
usage() {
	STATUS=${1-0}
	printf "
Usage: ./$PROGRAM
"
}

# Run and stuff
[[ -z "$@" ]] && usage 1 "Nothing to do."

while [ $# -gt 0 ]
do
	case "$1" in
		-i|--install)
		INSTALL=true
		;;
		-d|--dump)		# Perform a dump.
		DUMP=true
		;;
		-c|--configure)
		CONFIGURE=true
		;;
		-s|--start)
		START=true
		;;
		-x|--stop)
		STOP=true
		;;
		-r|--restart)
		RESTART=true
		;;
		-m|--move)
		MOVE=true
		;;
		-t|--replicate)
		REPLICATE=true
		;;
		-h|--help)
		;;
		-*);;
		*)
		;;
	esac
done






