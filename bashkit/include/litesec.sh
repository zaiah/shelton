#------------------------------------------------------
# litesec.sh
# 
# Historical cruft that exists solely because it's the
# BASH shell.
#-----------------------------------------------------#

# Set the right internal field seperator for command line args.
IFS=' 
	'

# Limits file creation permissions.
UMASK=002
umask $UMASK

# Set a normal path.
PATH="/usr/local/bin:/bin:/usr/bin"
export PATH
