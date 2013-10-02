#!/bin/bash -
# ---------------------------------------
# sshexec 
# 
# Execute some set of commands on another
# server.
# ---------------------------------------

# Variables and stuff.
PROGRAM="sshexec"
source "$(dirname "$(readlink -f $0)")/files/__config.sh"
__TABLE="templates"

# And usage messages.
__USAGE_MSG="
Usage: ./$PROGRAM
          [ -arq ] { d,n,f,i: term }
          [ -ldo ] <item> 
          [ --first-run, --setup ]
          [ --repo ] <url or file>
          [ --help ]

-a | --add         Add a new administration template.
-r | --remove      Remove an administration template.
-n | --run         Run an administration template.
-q | --query       Get information about a template.
-x | --log         Set up a different directory to log errors to.
-d | --description Supply a description of a template when adding or modifying.
-t | --at          Specify server directory to run a template in.
-o | --on          Specify server host to run a template on.
-i | --with        Specify key to connect to server host.
-w | --where       Specify criteria and stuff.
-h | --help        Show usage message and exit.

Run either $PROGRAM --help-format or 'man trap' to see information on how to specify templates."


# help_format
help_format () {
	__hf_sshexec
	usage 0
}


# show_everything 
# 	Uh... show everything in the database.
show_everything() {
	__SELECT
}


# set_clause 
# 	Search to see if a string matches.
set_clause () {
	for TERM in $( _break_list $1 )
	do
		BLOCK=( $( _break_once $TERM "$PDELIM") )
		case ${BLOCK[0]} in
			d|de|des|desc|descr|descri|descrip|\
			descript|descripti|descriptio|description)
				CONSTANT="description"
			;;
			n|na|nam|name)
				CONSTANT="name"
			;;
			f|'fi'|fil|file)	
				CONSTANT="file"
			;;
			i|id)
				CONSTANT="id"
			;;
			*)
				echo "Error: Unrecognized identifier '${BLOCK[0]}'"
			;;
		esac

		# Dynamically generate a long query.
		VALUE="${BLOCK[1]}" 
		OPERATOR="="

		# Check operators.
		test -z $WHERE && WHERE="WHERE" || WHERE="AND"
		[[ $CONSTANT = "id" ]] && VALUE="${BLOCK[1]}%" && OPERATOR="LIKE"

		# Puke out a query.
		QUERY="$QUERY $WHERE $CONSTANT $OPERATOR '$VALUE'"
	done
	echo $QUERY
}


# new_template
# 	Create a new template file and track it.
new_template() {
	TF="$EXECS/${ARG}.sh"
	
	# Write a new file.
echo "#!/bin/bash
#------------------------------------
# $ARG
#
# ${DESCRIPTION-"<awaiting description>"} 
#------------------------------------
PROTOCOL=ssh		# This may change in the future.

# This gets copied to the server.
COPY=(

)

# This gets executed on the server.
EXEC () {

}" > $TF
	
	# Edit this file.
	$EDITOR $TF 

	# Write to DB if we haven't changed our mind.
	if [ -f "$TF" ]
	then
		__ADD "'$(__GET_SHORT_UUID)', '$ARG', '${ARG}.sh', '${DESCRIPTION}'" 
	else
		usage 1 "Could not create file." 
	fi 
}


# remove_template
# 	Remove some template. 
remove_template() {
	# Remove from the database.
	CLAUSE=$( set_clause "$1" )
	ACTIVE_ID=$(__GET_ID_BY_STMT "$CLAUSE")
	FILENAME=$(__PSELECT "file" "WHERE id = '$ACTIVE_ID'")
	__REMOVE "id" $ACTIVE_ID

	# Also remove the file.
	TF="$EXECS/$FILENAME"
	test -f $TF && rm $TF
}


# Edit
edit_template() {
	# Remove from the database.
	CLAUSE=$( set_clause "$1" )
	ACTIVE_ID=$(__GET_ID_BY_STMT "$CLAUSE")
	FILENAME=$(__PSELECT "file" "WHERE id = '$ACTIVE_ID'")

	# Also remove the file.
	TF="$EXECS/${FILENAME}.sh"
	$EDITOR $TF
}


edit_template_by_filename() {
	NAME=$(__PSELECT "file" "WHERE name = '$ARG'")
	TF="$EXECS/${NAME}"
	$EDITOR $TF
}

# get_template_id
#  Get template id. 
get_template_id() {
	CLAUSE=$( set_clause "$1" )
	ACTIVE_ID=$(__GET_ID_BY_STMT "$CLAUSE")
}


# execute
#  Run something on something.
execute() {
	# Invocations and checks.
	__SSH_CMD="$(which ssh)"
	__SCP_CMD="$(which scp)"
	__RSYNC_CMD="$(which rsync)"

	for EPROG in "ssh" "scp" "rsync"; do
		if [ ! $(which $EPROG) ]; then
			echo "Required dependency $EPROG is not installed!"  
			echo "Exiting."
			exit 1; fi 
	done 

	# Load up flags. 
	SSH_FLAGS=
	SCP_FLAGS=
	RSYNC_FLAGS=

	# Grab a host from the hosts.
	if [ ! -z "$ON_THIS" ]
	then
		# Grab the stuff we want.
		__TABLE="hosts"
		RESULT_SET=$(__PSELECT "port, key, user, host, default_location" \
			"where name='$ON_THIS'")

		# If no results, exit.
		if [ -z "$RESULT_SET" ]; then
			echo "No host named $ON_THIS is present."; exit 1; fi
	
		# Generate RSYNC, SSH and SCP strings.	
		XPORT="$(echo $RESULT_SET | awk -F '|' '{print $1}')"
		XKEY="$(echo $RESULT_SET | awk -F '|' '{print $2}')"
		XUSER="$(echo $RESULT_SET | awk -F '|' '{print $3}')"
		XHOST="$(echo $RESULT_SET | awk -F '|' '{print $4}')"
		XLOC="$(echo $RESULT_SET | awk -F '|' '{print $5}')"
	fi 

	# Set a directory, key, port, host and location from the command line.
#	[ ! -z "$AT_DIR" ] && SSH_FLAGS="${SSH_FLAGS-""} -f $DEATH" || \
#		SSH_FLAGS="${SSH_FLAGS-""}"
#	[ ! -z "$KEY_TO_INCLUDE" ] && SSH_FLAGS="${SSH_FLAGS-""} -f $DEATH"
#	[ ! -z "$PORT" ] && SSH_FLAGS="${SSH_FLAGS-""} -f $DEATH"

	# Load either the single macro or the macros referenced by the function.
	if [ -f "$EXECS/${ARG}.sh" ]; then 
		source "$EXECS/${ARG}.sh" 
	else
		echo "No template named $ARG exists."; exit 1; fi

	# Generate flag and command strings.
	# SSH
	REMOTE_HOST="${XUSER}@${XHOST}"

	SSH_FLAGS=
	[ ! -z "$XPORT" ] && SSH_FLAGS="-p $XPORT" 
	[ ! -z "$XKEY" ] && SSH_FLAGS="$SSH_FLAGS -i $XKEY" 

	# SCP
	SCP_FLAGS=
	[ ! -z "$XPORT" ] && SCP_FLAGS="$SCP_FLAGS -P $XPORT" 
	[ ! -z "$XKEY" ] && SCP_FLAGS="$SCP_FLAGS -i $XKEY" 
	[ ! -z "$XLOC" ] && XLOC="$REMOTE_HOST:${XLOC}" || XLOC="$REMOTE_HOST:~"

	# RSYNC
	RSYNC_FLAGS="$__RSYNC_CMD"
	[ ! -z "$XPORT" ] && RSYNC_FLAGS="$RSYNC_FLAGS -p $XPORT" 
	[ ! -z "$XKEY" ] && RSYNC_FLAGS="$RSYNC_FLAGS -p $XKEY" 
	[ ! -z "$XLOC" ] && RSYNC_FLAGS="$RSYNC_FLAGS -p $XLOC" 

	# Copy data.
	if [ ! -z "$COPY" ]
	then
		# Build array from package list.
		echo ${COPY[@]}
		
		# Copy the packages.
		$__SCP_CMD $SCP_FLAGS ${COPY[@]} $XLOC
	fi

	# Run any functions 
	echo $__SSH_CMD $SSH_FLAGS $REMOTE_HOST

	# Backup and restore (move this...) 
	echo $__RSYNC_CMD -e "'$__SSH_CMD $SSH_FLAGS'" $REMOTE_HOST
}
	


# Options.
[ -z "$BASH_ARGV" ] && usage 1 "Nothing to do."
while [ $# -gt 0 ]
do
	case $1 in

		# Explicitly add a new template.
		-a | --add)
			ADD=true
			shift	
			test $(is_arg $1) || usage 1 \
				"Error: Must supply a argument if using the -a flag."
			ARG="$1"
		;;

		# Remove a template.
		-r | --remove)
			REMOVE=true
			shift	
			test $(is_arg $1) || usage 1 \
				"Error: Must supply a argument if using the -r flag."
			ARG="$1"
		;;

		# Remove a template.
		-u | --update)
			UPDATE=true
			shift	
			test $(is_arg $1) || usage 1 \
				"Error: Must supply a argument if using the -u flag."
			ARG="$1"
		;;

		# Choose a host to run on.
		-o|--on)
			shift
			ON_THIS=$1
		;;

		# Choose a directory to run your work on.
		-t|--at)
			shift
			AT_DIR="$1"
		;;
	
		# Chooose a key to setup
		-w|--with)
			shift
			KEY_TO_INCLUDE="$1"
		;;	

	
		# Get information about one or many templates.
		-q | --query)
			SHOW_VALS=true
			shift	
			test $(is_arg $1) && ARG="$1"
		#	ARG="$1"
		;;

		# Set a different log location.
		-x | --log)
			shift
			test $(is_arg $1) && usage 1 \
				"Error: Must supply an argument if using the -l flag."
			LOGDIR=$1
		;;

		# Supply a description.	
		-d | --desc | --description )		
			shift							
			DESCRIPTION=$1
		#	test $(is_arg $DESCRIPTION ) && usage 1 \
		#		"Error: Must supply a description if using the -d flag."
		;;

		# Execute profile
		-n|--run)
			EXECUTE=true
			shift
			ARG="$1"	
		;;

		# select everything.
		-l|--list|--everything)
			show_everything	
		;;

		# Show a short help and exit.
		-h | --help) 
			usage 0
		;;
		--help-format) 
			help_format
		;;
		-*) 
			usage 1 "Error: Unrecognized option: $1"
		;;
		*)
			break
		;;
	esac
	shift
done


# Just execute a query.
if [ ! -z $SHOW_VALS ]
then
	[ -z $ARG ] && __SELECT && exit 0
	[[ $ARG =~ "=" ]] && \
		CLAUSE=$( set_clause $ARG )
		__SELECT '*' "$CLAUSE"


# Remove a query. 
elif [ ! -z $REMOVE ]
then
	[[ $ARG =~ "=" ]] && \
		remove_template $ARG

# Edit a template
elif [ ! -z $UPDATE ]
then
	[[ $ARG =~ "=" ]] && \
		edit_template $ARG || \
		edit_template_by_filename $ARG

# Add a query.
elif [ ! -z "$ADD" ]	
then
	new_template	

# Execute
elif [ ! -z "$EXECUTE" ]
then
	execute

# Add if nothing is there, otherwise execute.
# elif [ ! -z $MAD_DEADLY ]
else 
	# No duplicate names.
	if [[ $ARG =~ "=" ]]
	then 
		CLAUSE=$( set_clause $ARG )
		new_template	
	else
	
		new_template	
	fi		
fi
