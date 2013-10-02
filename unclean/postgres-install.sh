#!/bin/bash - 
#===============================================================================
#
#          FILE:  postgres-install.sh
# 
#         USAGE:  ./postgres-install.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Antonio Ramar Collins II (), zaiah.dj@gmail.com, ramar.collins@gmail.com
#       COMPANY: Vokay Ent. (vokayent@gmail.com)
#       CREATED: 03/19/2013 01:08:17 PM EDT
#      REVISION:  ---
#===============================================================================
PROTOCOL="ssh"
TAR="/usr/bin/tar"
TARFLAGS="xvjf"
COPY=()
EXEC() {
	tar $TARFLAGS
	./configure
}
