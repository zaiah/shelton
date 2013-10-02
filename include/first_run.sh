# --------------------------
# first_run.sh 
# 
# Do setup of this project.
# --------------------------

# Check ARG for possible.


# Make directories and stuff.
if [ ! -d "$SYS" ] ||
	[ ! -d "$SYS/functions" ] ||
	[ ! -d "$SYS/templates" ] ||
	[ ! -d "$SRC" ] ||
	[ ! -d "$TMP" ] 
then
	mkdir -p $SYS/{"functions","templates","config"}
	mkdir -p $TMP
	mkdir -p $SRC
fi

# Create all needed tables.
$__SQLITE $__DB "CREATE TABLE packages (
	id TEXT,
	software TEXT,
	name TEXT,
	md5 TEXT,
	addr TEXT
);"

$__SQLITE $__DB "CREATE TABLE functions (
	id TEXT,
	name TEXT,
	file TEXT
);"

$__SQLITE $__DB "CREATE TABLE templates (
	id TEXT,
	name TEXT,
	file TEXT
);"

$__SQLITE $__DB "CREATE TABLE dir_version (
	id TEXT,
	revision INTEGER,
	soft_id TEXT
);"

$__SQLITE $__DB "CREATE TABLE configurations (
	id TEXT,
	revision INTEGER,
	file TEXT
);"

