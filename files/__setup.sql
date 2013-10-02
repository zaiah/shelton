/**********************************
 * __setup.sql
 *
 * DO NOT TOUCH THIS FILE!
 *
 * Tables for shelton scripts. 
 **********************************/

/* 
 packages
	software	- Name of the software. 
	name		- A user-friendly software name.
	md5		- MD5 sum of the software package.
	addr		- HTTP address of the software.
	cache		- Cache that the package belongs to.
*/
CREATE TABLE packages (
		id TEXT,
		software TEXT,
		name TEXT,
		md5 TEXT,
		addr TEXT,
		cache TEXT
);

/* 
 caches
	name		- Name of the cache we're working with. 
	local_dir - Where it's located on this system.
	sync_dir  - If online, then we can sync it from here
*/
CREATE TABLE caches (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT,
	local_dir TEXT,
	sync_dir TEXT
);

/*
	templates
	# name	   - Name of the template
	# file		- File name of the template
	# short_description  - A very short description of what this does.
*/
CREATE TABLE templates (
	id TEXT,
	name TEXT,
	file TEXT,
	short_description TEXT
);

/*
	# super
	# name		- Name of macro.
	# file		- Location of macro.
*/
CREATE TABLE super (
	id TEXT,
	name TEXT,
	file TEXT
);

/*
	# hosts
	# user		- User to connect as.
	# host		- Host to jump on.
	# key		   - Key file to use for authentication.
	# port		- Port to use fpr connection
	# location	- Location to drop files to on default.
	# name 		- Unique name for the host.
*/
CREATE TABLE hosts ( 
	id TEXT,
	user TEXT,
	host TEXT,
	key TEXT,
	port INTEGER,
	default_location TEXT,
	name TEXT
);

/*
	# logs
	# date_run	- Date that the script was last run.
	# log_file	- Location of log file.
	# host		- Host that ran the script.
	# item_run  - The item that was run.
*/
CREATE TABLE logs (
	id TEXT,
	date_run INTEGER,
	log_file TEXT,
	host TEXT,
	item_run TEXT
);
