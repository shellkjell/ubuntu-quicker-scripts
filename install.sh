#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

source "$CurrentDirName/scripts/common.sh"
source "$CurrentDirName/scripts/alwaysSudo.sh"

printOut "Linking scripts to /usr/local/bin"

awk -F":" '{print "ln -s $CurrentDirName/scripts/" $1 " /usr/local/bin/" $2 }' ./install.scripts | echo 

#ln -s "$CurrentDirName/scripts/uptodate.sh" /usr/local/bin/uptodate