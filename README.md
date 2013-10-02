Shelton

Welcome to Shelton!  This is a tool to handle infrastructure.  It is heavily tuned for our purposes at Vokayent.  It may or may not work for your needs.

Stuff that Shelton handles:
		  SSH key management
		  Server and software setup
		  Host management
		  Package management
		  And some other things

This may never see a release date.

There are a large set of tools here, so I'll explain for reference.
config 	Controls the configuration of the database that shelton runs on.
deploy 	Deploys a project following a set of criteria.
package	Manages the packages used for building sites, projects and servers.
sshexec	Carries out functions on different servers. 
sshmgr	Manages keys and what not.
sshfresh Controls key timeouts (may be merged into sshmgr)


Anyway:

Stuff to address:
- Make sure all dependencies are on your system
	if [ -f $e ] && [ -x $e ] && [ link actually goes some where... ]
	then ... fi
- Get the newest packages and checksums
	wget $e ${e%%x}.md5sum; 
	md5sum --check $e 
- Custom installs (options can change per build)
	??? f() { ... }		# This has proven to be a shit solution, must be something better...
		What if builds change?, What if you want to reuse?, ??? WTF???!!
- Rollback to previous versions (install side by side and alter symlinks)
	N=$e_`date +%F`_<id>
	tar xzvf $N $src (unpack to src_`date +%F`_<some other id>)
	ln -s $N exec_name in fs
	track by writing to db..?
- Managing configuration (many ways to go about it)
	git commit and use symlinks again... for a particular dir

Additional things to address:
- Permissions, who are you installing as
	For the symlink stages, you'll need root access (OR!) a modified path that is pulling from a directory you don't need elevation for


NIX *************************
nix addresses most of these:
1
2 ?
3 ?
4 x
5 x

nix also requires a couple of perl dependencies (which isn't really bad, but its something to keep track of...)
Perl DBI/DBD for Sqlite
Perl WWW Curl

nix makes a directory at /
Be careful with this one...

I will give it a try, 2 deps not too bad...
*****************************

CUSTOM **********************

Must run super fast....
So that means you'll need multithreading logic somewhere....
(At least when downloading and building...)
However, make can be optimized to take advantage of all cores when necessary...

You'll need a tool chain for this:
One for checking for CUSTOM's dependencies (regardless of system choice)
One for downloading the packages (I can't think of any other way to update the end points....,
	maybe through a front end web int
	or a text file (you'll have to rebuild whatever db)
One for building and running other functions
One to track and write links
One for rolling back
And one for managing config

Think about other issues too:
-Building from source does take time...
-Binary will take far less time to administer
-Most of the time we're using VMs, so copying binary files won't be a big issue
-We can even copy certain VMs for certain purposes...
	(dunno how to do this with Xen, however...)
*****************************





*** ADDTIIONAL INFORMATION ***


http://ftp.postgresql.org/pub/source/v9.2.2/postgresql-9.2.2.tar.bz2
HAProxy -	 				Load Balancing
Apache, Lighttpd, Hiawatha 	Server Backend
RRDTool / Custom Solution  	Monitoring
Puppet / Custom Solution  	Configuration Management
Xen / VirtualBox  			Virtualization
? - 						Failover
? - 						Caching? (this can be done at application level)
qmail - 					Mail Management
Fail2Ban / SSH Recycler 	Access
Custom Solution + IP tables	Firewall
DNSMasq						DNS
??							Logging
?Cron						Scheduled Jobs
(custom rkhunter / clamav)	Auditing

rsync						Backups   # This doesn't need compilation from source.


