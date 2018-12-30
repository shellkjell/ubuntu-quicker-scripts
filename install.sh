#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

source "$CurrentDirName/scripts/common.sh"
source "$CurrentDirName/scripts/alwaysSudo.sh"

installPackages="ranger apt-transport-https ca-certificates software-properties-common"

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
	      net-tools basez golang-go npm vim"

      if [ command -v code ]
      then
      	printOut "vscode already installed, skipping"
      else
	printOut "vscode is going to be installed"
	# Add microsoft gpg key for vscode
	curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
	# Create entry in sources.list.d
	add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
        
	# Restore permissions
	chmod 770 /home/$SUDO_USER/.gnupg
	chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.gnupg
	
	installPackages="$installPackages code"
      fi

      if [ command -v docker && command -v docker-compose ]
      then
        printOut "Docker already installed, skipping"
      else
	printOut "Docker is going to be installed"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable"

	installPackages="$installPackages docker-ce"
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

# If we're running openvpn docker might have some trouble setting up a bridge
# Check and fix
if [ -z $(ls /sys/class/net | grep docker0) ]
then
  sudo brctl addbr docker0
  sudo ip addr add 192.168.77.1/24 dev docker0
  sudo ip link set dev docker0 up
  ip addr show docker0
  sudo systemctl restart docker
  sudo iptables -t nat -L -n
fi

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
