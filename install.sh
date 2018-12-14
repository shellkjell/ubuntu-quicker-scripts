#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

source "$CurrentDirName/scripts/common.sh"
source "$CurrentDirName/scripts/alwaysSudo.sh"

printOut "Linking scripts to /usr/local/bin"

while read installScript 
do
  echo -e "$installScript"
  $installScript
done  < <(awk -F":" -v currDir="$CurrentDirName" '/.+\.sh:.+/{print "ln -s " currDir "/scripts/" $1 " /usr/local/bin/" $2 }' ./install.scripts)

printOut "Creating bash aliases"

cp ~/.bash_aliases ~/.bash_aliases.EUSbak
cat "$CurrentDirName/.bash_aliases" >> ~/.bash_aliases

printOut "Done"