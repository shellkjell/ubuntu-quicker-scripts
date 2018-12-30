#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

source "$CurrentDirName/scripts/common.sh"
source "$CurrentDirName/scripts/alwaysSudo.sh"

installPackages="ranger"

args=$(getopt -l "dev" -o "d" -- "$@")

eval set -- "$args"

while [ $# -ge 1 ]; do
  case "$1" in
    --)
      shift
      break
      ;;
    -d|--dev)
      printOut "common development environment software is going to be installed (option $1)"
      installPackages="$installPackages build-essential git make curl \
	      net-tools basez golang-go npm"

      if [ command -v code ]
      then
      	printOut "vscode already installed, skipping"
      else
	printOut "vscode is going to be installed (option $1)"
	# Add microsoft gpg key for vscode
	curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
	# Create entry in sources.list.d
	sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        
	# Restore permissions
	chmod 770 /home/$SUDO_USER/.gnupg
	chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.gnupg
	
	installPackages="$installPackages code"
      fi
      shift
      ;;
  esac

  shift
done

installPackages=$((echo "$installPackages") | sed 's/[\n\t]/ /g' | xargs echo -n)

printOut "Trying to install these packages:\n\033[1;32m$(echo "$installPackages" | xargs -n5 | sed -e 's/^/   /')\033[0m"

apt update
apt install $installPackages

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
