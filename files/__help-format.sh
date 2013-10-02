# ---------------------------------------
# __help-format.sh
#
# DO NOT EDIT THIS FILE.
# Contains the help format messages.
# ---------------------------------------

__HELP_FORMAT="
Usage: ./$PROGRAM

Namespace & Editing Tutorial:
$PROGRAM will allow you to add, modify and remove entries by choosing one specific record by name or by making an approximation.  

$PROGRAM supports a pretty simple colon seperated syntax.  If you are not really certain of what entries you want to change you can use the --where flag to make an approximation. 
You can specify individual elements by a unique name.  I

Example #1: Update one record.
./$PROGRAM --change name=face --where id=1456

Example #2: Update one record.
./$PROGRAM --query --where name~something
"

# sshexec help
__hf_sshexec() {
__USAGE_MSG="
$__HELP_FORMAT

$PROGRAM accepts the following identifiers when modifying entries.  It will accept a substring of these identifiers for the sake of brevity.

description   Use when changing the description of some item (can also be 
              done with the -d flag)
file          Use when changing the name of a particular file.
name          Use when changing the name of a particular template.
id            Used when updating entries.
 
"
}

# sshmgr help
__hf_sshmgr() {
__USAGE_MSG="
$__HELP_FORMAT

$PROGRAM accepts the following identifiers when modifying entries.  It will accept a substring of these identifiers for the sake of brevity.

user:[ele]    Use [ele] as primary user for whatever this is.
def:[ele]     Modify the default location for scp.
key           Use supplied parameter as a key.
port          Specify a port number.
host          Use [ele] as host.
name          Use [ele] as a symbolic name to reference the host. 
id            Used when updating entries.
 
"
}