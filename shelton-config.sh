#!/bin/bash -
#------------------------------------------------------
# config.sh 
# 
# Let's just rethink this whole thing.
# One database in one place that can keep this little
# shit together.
#
# There are about seven scripts with their own sets
# of commands and whatnot, but the database can be 
# accessed from each of them.
#-----------------------------------------------------#

# Grab all dependencies.
PROGRAM="config"
source "$(dirname "$(readlink -f $0)")/files/__config.sh"

# Usage message.
__USAGE_MSG="
Usage:
./config.sh [ --first-run ] [ -cgpi ] <parameters>
            [ --help ]

Options:
--first-run              Run this for the first time, specifying options below.
--setup                  Configure global settings for shelton.
-c | --create            Create or recreate the databases.
-g | --generate          Generate a package list.  Must specify package-dir.
-p | --package-dir dir   Use <dir> as package directory.
-i | --install dir       Install all scripts to <dir>.
-h | --help              Show a help manual and exit.
"

# Generate config file.
generate_config_file() {
	echo "
EDITOR=vi
" > $CONFIG_FILE
}

# Database & Tables
create_db_and_tables() {
	$__SQLITE $__DB < $SQL_FILE
}


# Install the packages.
install_all() {
	# Must be an absolute path.
	CHAR=$(echo $MY_EXEC_DIR | cut -b 1)
	if [[ $CHAR == "/" ]]
	then
		for FILE in ${LIST[@]}
		do
			ln -s "$FILE" "$MY_EXEC_DIR/$(basename ${FILE%%.sh})"
		done
	else
		echo "Package directory specified by the --install flag must be"
		echo "an absolute path.  E.g. ( /home/mojo/my_repo )"
		usage 1
	fi
}


# Uninstall eveyrthing.
uninstall_all() {
	# Must be an absolute path.
	CHAR=$(echo $MY_EXEC_DIR | cut -b 1)h
	if [[ $CHAR == "/" ]]
	then
		for FILE in ${LIST[@]}
		do
			rm "$MY_EXEC_DIR/${FILE%%.sh}"
		done
	else
		echo "Package directory specified by the --uninstall flag must be"
		echo "an absolute path.  E.g. ( /home/mojo/my_repo )"
		usage 1
	fi
}


# Add to cache
generate_new_cache() {
	# If the cache doesn't exist add it.	
	__TABLE="caches"
	EXISTS=$(__GET_ID_BY_VALUE "name" "$PACKLIST_NAME")
	echo $EXISTS
#	$__SQLITE $__DB "INSERT INTO caches VALUES (
#		NULL, $PACKAGE_NAME, $PACKAGE_DIR," 
}


# Package directory.
generate_package_db() {
	PACKAGES=( $(ls $PACKAGE_DIR/{*.tar.gz,*.tgz,*tar.bz2,*tar.xz,*.zip}) )
	IMPORT="$TMP/.run"
	PACKLIST="$TMP/.packages"
	touch $IMPORT $PACKLIST

	# Create a cache if we have something new.
#	__TABLE="caches"
#	EXISTS=$(__GET_ID_BY_VALUE "name" "$PACKLIST_NAME")
#	if [ -z $EXISTS ]; then
#		echo "There is a cache with this name already."
#		exit 1
#	fi	

	exit	
	# Let's keep track of all these packages.
	for PACKAGE_FILE in ${PACKAGES[@]}
	do
		# Make a large SQL command.
		( 
			printf "'$( __GET_CUUID 8 )','$(basename $PACKAGE_FILE)',"
			printf "'name','$(md5sum $PACKAGE_FILE | awk '{print $1}')',"
			printf "'','$PACKLIST_NAME'\n" 
		) >> $PACKLIST
	done 

	# Load it.
	( 
		printf "\n.separator ," 
		printf "\n.import $PACKLIST packages" 
		printf "\n.quit" 
	) >> $IMPORT
	sqlite3 -init "$IMPORT" "$__DB" '.exit'

	# Clean up.
	rm $PACKLIST $IMPORT
}


# Options Evaluation
test -z $BASH_ARGV && usage 0 "Nothing to do."
while [ $# -gt 0 ]
do
	case "$1" in
		# Create / Recreate the databases.
		-r | --recreate)
			CREATE=true
		;;
		
		# First run
		--first-run)
			FIRST_RUN=true
		;;		

		# Setup the global variables that we use.
		--setup)						
			SETUP=true
		;;

		# Generate a package list. 
		-g | --generate)
			GENERATE=true
			shift
			PACKLIST_NAME="$1"
		;;
		
		# Set up a place to actually put and check for packages.
		-p | --package-dir)
			shift
			PACKAGE_DIR="$1"
		;;

		# Copy links to an executable directory of your choice.
		-i | --install)
			INSTALL=true
			shift
			MY_EXEC_DIR="$1"
		;;

		# Uninstall	
		-u | --uninstall)
			UNINSTALL=true
			shift
			MY_EXEC_DIR="$1"
		;;

		# Help message.
		-h | --help | -?)
			usage 0
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


# Run for the first time.
if [ ! -z $FIRST_RUN ]
then
	# Make all directories.
	NON_EX=( "$TMP" "$KEYS" "$EXECS" )
	[ ! -d "$DIR" ] && mkdir -p "$DIR" 
	for EACH_DIR in ${NON_EX[@]}; do
		[ ! -d "$EACH_DIR" ] && mkdir $EACH_DIR; done

	# Make the database. 
	[ ! -f "$__DB" ] && create_db_and_tables

	# If we needed a package directory, let's set that up now.
	[ ! -z "$PACKAGE_DIR" ] && generate_package_db

	# If we specifed an install directory, let's do that too.
	[ ! -z "$MY_EXEC_DIR" ] && install_all 

	# Generate a configuration file with other little details.
	[ ! -f "$CONFIG_FILE" ] && generate_config_file 

	# We don't want to evaluate anymore at this point, so let's quit.
	exit 0


# Setup the globals. 
elif [ ! -z $SETUP ]
then
	$EDITOR "$CONFIG_FILE"
	exit 0

	
# Recreate the databases if you want.
elif [ ! -z $CREATE ]
then	
	echo "This will wipe all of your current settings."
	echo "Are you sure you wish to do this?"
	read ans
	if [[ ans == "y" ]]; then create_db_and_tables 
	else 
		echo "No changes made." && exit 1; fi


# Install everything.
elif [ ! -z $INSTALL ]
then
	[ ! -z "$MY_EXEC_DIR" ] && install_all


# Uninstall everything.
elif [ ! -z $UNINSTALL ]
then
	[ ! -z "$MY_EXEC_DIR" ] && uninstall_all


# Generate a different package directory.
elif [ ! -z $GENERATE ]
then
	if [ -z "$PACKAGE_DIR" ] || [ -z "$PACKLIST_NAME" ]
	then usage 1 "Either there was no package directory specified or you didn't give your package directory a name.  Please use and set the following flags to make this work:\n./config.sh --package-dir <dir> --generate <name>"
	else generate_package_db
	fi
fi
