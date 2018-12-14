#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

source "$CurrentDirName/scripts/common.sh"
source "$CurrentDirName/scripts/alwaysSudo.sh"

printOut "Removing script links from /usr/local/bin"

while read installScript 
do
  echo -e "$installScript"
  $installScript
done  < <(awk -F":" '/.+\.sh:.+/{print "rm /usr/local/bin/" $2 }' ./install.scripts)

printOut "Restoring .bash_aliases if existed"

mv -f ~/.bash_aliases.EUSbak ~/.bash_aliases

printOut "Done"