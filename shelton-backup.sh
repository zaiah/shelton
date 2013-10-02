#!/bin/bash 
#------------------------------------------------------
# shelton-backup 
# 
# GEt SSH backup hosts and keys.
#-----------------------------------------------------#

# Show usage and quit.
usage() {
	STATUS=${1-0}
	USAGE_MESSAGE=${2-""}
	printf "
$USAGE_MESSAGE
Usage:
./br [ -bdersnpx <file> ]
     [ -ygukl <params> ]
     [ -hv ]

  Actions:
   -s | --push         Push to a location.
   -l | --pull         Pull from a location.
   -e | --edit         Edit a backup profile.
   -r | --restore      Restore from a backup.
   -a | --list         Show all the profiles for your system.
   -n | --new <file>   Create a new profile.

  Parameters:
   -y | --editor <p>   Set a different editor (default is 'vim') 
   -g | --host <host>  Override the current host for your backups.
   -u | --user <user>  Override the current user for SSH backups.
   -r | --port <port>  Override the current port for SSH backups.
   -k | --key <key>    Use a different key for SSH backups.
   -l | --log <log>    Set a different log file.
   -p | --profile <p>  Utilize a different profile.
   -x | --exclude <p>  Create/Edit an exclude file for the current profile.
   -o | --output <dir> Use a different output directory on the host.
	
  General
   -h | --help         Show help and quit.
   -q | --query        Show all parameters.
   -v | --verbose      Be verbose.\n"
	exit $STATUS 
}


#-----------------------------------------------------#
# Option Processing 
#-----------------------------------------------------#
[[ -z "$@" ]] && usage 1 "Nothing to do."

while [ $# -gt 0 ]
do
	case "$1" in 
		# Action commands.
		-u|--push)
			ACTION="backup"
			shift
			PROFILE="$1"	
		;;
		-l|--pull)
			ACTION="restore"
			shift
			PROFILE="$1"
		;;
		-q|--query)
			ACTION="query"
			shift
			PROFILE="$1"
		;;
		-a|--show|--list|--list-all-profiles)
			ACTION="showAllProfiles"
		;;
		-x|--exclude)
			ACTION="edit"
			shift
			EXCLUDE="$1"
		;;
		-y|--set-editor)
			shift
			editor="$1"
		;;
		-n|--new)
			ACTION="newProfile"
			shift
			PROFILE="$1"
		;;	

		# Parameters
		-g|--host)
			shift
			host="$1"
		;;
		-u|--user)
			shift
			user="$1"
		;;
		-t|--port)
			shift
			port="$1"
		;;
		-k|--key)
			shift
			key="$1"
		;;
		-l|--log)
			shift
			log="$1"
		;;
		-d|--delete)
			ACTION="delete"
			shift
			PROFILE="$1"
		;;
		-e|--edit)
			ACTION="edit"
			shift
			PROFILE="$1"
		;;
		-o|--out)
			shift
			outDir="$1"
		;;
		-v|--verbose)
			verbose=true
		;;
		-h|--help|-?)
			usage 0
		;;
		-*)
			usage 1 "Unrecognized option: $1"
		;;
		*)
			break
		;;	
	esac
	shift
done


# Check if defaults exist.
CONFIG="$HOME/.shelton"
if [ ! -d $CONFIG ] || [ ! -d $CONFIG/profiles ]
then
	mkdir -p $CONFIG/{profiles,excludes}
fi



# Set config dir and default profile.
source $CONFIG/profiles/brStandard.sh

# If profile then include it too.
if [[ -n $PROFILE ]] && 
	[[ -f $CONFIG/profiles/${PROFILE}.sh ]]
then
	source $CONFIG/profiles/${PROFILE}.sh
fi

# Build flags and whatnot.



# Set defaults and runtime variables.
backupType=${backupType-$backupTypeDefault}
backupFile=${backupFile-""}
src=${src-$srcDefault}
profile=${PROFILE-brStandard.sh}
editor=${editor-$editorDefault}
host=${host-$hostDefault}
user=${user-$userDefault}
port=${port-$portDefault}
key=${key-$keyDefault}
log=${log-$logDefault}
exc=${exc-$excDefault}
bandwidthLimit=${bandwidthLimit-$bandwidthLimitDefault}


# Generate Profiles.
_makeProfile() {
echo "# $1
backupType=
backupFile=
src=
dest=
editor=
host=
user=
port=
key=
log=
exc=
bandwidthLimit=
"
}

# Generate Excludes
_makeExclude() {
echo "
# Exclude file for $1
#
# Follows the format:
# - dir/*
# - dir2/*.c
# + dir3/*.wav
# 
# Where entries prefixed with - specifically exclude those matches.
"
}

# Standard Backup
_standard() {
	# Everything goes to the .config directory.
	# This is almost ALWAYS a bad idea.
	# But we're gonna do it anyway.
	_src=$1
	_dest=$2

	if [ -d $CONFIG/$dest ]; then
		mkdir -p $CONFIG/$dest
	fi

	# Die if $CONFIG/$dest is invalid.

	# Rsync it (Silly example).
	rsync -arvz $src $dest
	tar czvf $CONFIG/${dest}.tar.gz $dest/*
#	rm -rf $CONFIG/$dest
}

# query
#  Echo all parameters for a backup script. 
query() {
	if [ -f $CONFIG/profiles/${PROFILE}.sh ]
	then
		printf "Parameters for [ $PROFILE ]:\n"
		printf "  Backup Type:    $backupType\n"
		printf "  Backup File:    $backupFile\n"
		printf "  Exclude File:   $exc\n"
		printf "  Source:         $src\n"
		printf "  Destination:    $dest\n"
		printf "  Editor:         $editor\n"
		printf "  Host:           $host\n"
		printf "  User:           $user\n"
		printf "  Port:           $port\n"
		printf "  Key:            $key\n"
		printf "  Log:            $log\n"
		printf "  B/W Limit:      $bandwidthLimit\n"
	else
		usage 1 "Profile specified does not exist."
	fi
}

# editProfile 
editProfile() {
	if [ -f $CONFIG/profiles/${PROFILE}.sh ] && [[ $PROFILE != 'brStandard.sh' ]]; then
		$editor $CONFIG/profiles/${PROFILE}.sh
		exit 0
	elif [ ! -z $EXCLUDE ] && [ ! -f $CONFIG/excludes/$EXCLUDE ]; then
		$editor $CONFIG/excludes/${EXCLUDE}.exc
	else
		usage 1 "No profile specified."
	fi
}

# Generates a new profile.
newProfile() {
	# Check for existent files.
	if [ -f $CONFIG/profiles/${PROFILE}.sh ]; then
		printf "File $CONFIG/${PROFILE}.sh already exists!
				  Do you wish to overwrite? [ y or n ]"
		read ans
		if [[ $ans = y ]]; then
			printf "Overwriting $CONFIG/profiles/${PROFILE}.sh...."
		else
			printf "Exiting because ${PROFILE}.sh already exists."
			exit 1
		fi
	fi

	# Generate profile.	
	_makeProfile $PROFILE > $CONFIG/profiles/${PROFILE}.sh

	# Generate exclude.
	_makeExclude $PROFILE > $CONFIG/excludes/${PROFILE}.exc
	
	# Edit the profile.
	$editor $CONFIG/profiles/${PROFILE}.sh

	# Edit the exclude file.
	excBefore=$(cat $CONFIG/excludes/${PROFILE}.exc)
	$editor $CONFIG/excludes/${PROFILE}.exc
	excAfter=$(cat $CONFIG/excludes/${PROFILE}.exc)

	# If no change, delete the exclude file.
	if [[ "$excBefore" == "$excAfter" ]]; then
		rm $CONFIG/excludes/${PROFILE}.exc
	fi
}

# Show all the profiles available.
showAllProfiles() {
	ls $CONFIG/profiles
}

# Do an rsync.
backup() {
	# If you include any music (.wav,.mp3,.flac)
	# or images (.jpg, .png, .bla)
	# Forgo compression.
	e=$CONFIG/excludes/${PROFILE}.exc

	# Network backups.
	if [[ $backupType == 'net' ]]; then
		if [ -f $e ]; then
			rsync -arvz -e "ssh -p $port -i $key" $src \
				$user@$host:$dest --exclude-from $e
		else
			rsync -arvz -e "ssh -p $port -i $key" $src \
				$user@$host:$dest
		fi

	# Local backups.
	elif [[ $backupType == 'local' ]]; then
		# Define some conditions.
		# This is still throwing an error (too many arguments...)
		if [ -d "$dest" ] && 			
			[ ! -n $(ls $dest/) ] && 
			[ ! -f $CONFIG/.br${PROFILE} ]
		then
			printf "Files are in this directory and it doesn't seem like you've run a backup here yet. Proceed?"
			read ans
			case $ans in
				y|ye|yes) echo "Resuming backup...";;
				n|no)		 echo "Aborting backup.  Location not suitable."; exit 1;;
			esac
		elif [ ! -d $dest ]; then
			mkdir	$dest
		fi

		# Perform a local backup.
		touch $CONFIG/.br${PROFILE}
		if [ -f $e ]; then
			rsync -arvz $src $dest --exclude-from $e
		else
			rsync -arvz $src $dest
		fi

		# Compress said archive
		if [ ! -z $backupFile ]; then
			printf "Compressing..."
			_backupType="${backupFile#*.tar.}"		# Extract file name suffix.
			case $_backupType in
				b|bz|bzi|bzip|bz2) cd $dest; tar cjvf ${backupFile%%.$_backupType}.bz2 .; exit 0;;
				g|gz|gzi|gzip)		 cd $dest; tar czvf ${backupFile%%.$_backupType}.gz .; exit 0;;
				*)	echo 'Not a valid compression type.  Please go back and edit the profile for this backup.'; exit 1;;
			esac
		fi
	else
		printf "You must have a backup type of 'net' or 'local' to use this option.\n"
		usage && exit 1
	fi
}

# Delete
# Gets rid of files (exclude and parameters) plus any database descriptions.
delete() {
	if [ -f $CONFIG/profiles/${PROFILE}.sh ]
	then
		rm -f $CONFIG/profiles/${PROFILE}.sh $CONFIG/excludes/${PROFILE}.exc
	fi
}

# Restore
restore() {
	# Syncback!
	# There is an interesting problem here.
	# How do you go about a fresh restore when there is no key?
	e=$CONFIG/excludes/${PROFILE}.exc

	# Network
	if [[ $backupType == 'net' ]]
	then
		if [ -f $e ]
		then
			rsync -arvz -e "ssh -p $port -i $key" \
			   $user@$host:${dest}* ${src%/*}/ --exclude-from $e
		else
			rsync -arvz -e "ssh -p $port -i $key" \
			   $user@$host:${dest}* ${src%/*}/ 
		fi

	# Local
	elif [[ $backupType == 'local' ]]
	then
		if [ ! -d $dest ]
		then
			mkdir	$dest
		fi
		rsync -arvz $dest $src 
	else
		usage 1 "You must specify a restore type of 'net' or 'local' to use this option.\n" 
	fi
}

# Dump
#
# Dumps can be of two types:
# direct-to-disk - simply dumps .br files to disk so you can do stuff later.
# web server	  - dumps through ssh, creates a web server and runs on its own port.
brDump() {
	echo "This requires dependencies: deathout and something to mount drives (fdisk & mount)..."
}

# Evaluate
case "$ACTION" in
	backup) backup;;
	delete) delete;;
	restore) restore;;
	query) query;;
	edit) editProfile;; 
	newProfile) newProfile;;
	showAllProfiles) showAllProfiles;;
	showHelp) usage;; 
esac	
