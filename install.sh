#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

# Common utils, printOut, ...
source "$CurrentDirName/scripts/common.sh"

# Always run this script as sudo
source "$CurrentDirName/scripts/alwaysSudo.sh"

# Data about our release ($UBUNTU_CODENAME etc.)
source /etc/os-release

# We will need curl for dev install
apt update && apt install curl

# Standard install packages
installPackages="ranger apt-transport-https ca-certificates software-properties-common"

#
## Pre-install tasks - decide which packages to install
#

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
      
      if dpkg -l code
      then
        printOut "vscode already installed, skipping"
      else
        printOut "vscode is going to be installed"
        # Add microsoft gpg key for vscode
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
        # Create entry in sources.list.d
        add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
        
        installPackages="$installPackages code"
      fi
      
      if dpkg -l docker
      then
        printOut "Docker already installed, skipping"
      else
        printOut "Docker is going to be installed"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable"
        
        installPackages="$installPackages docker-ce"        
      fi

      # Since we added keys with root privileges, kill the root connection to the gpgconf socket
      gpgconf --kill dirmngr

      # Restore permissions (otherwise /home/user/.gnupg error later on aswell)
      chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/gnupg
      apt update

      shift
    ;;
  esac
  
  shift
done

#
## Install packages
#

installPackages=$((echo "$installPackages") | sed 's/[\n\t]/ /g' | xargs echo -n)

printOut "Trying to install these packages:\n\033[1;32m$(echo "$installPackages" | xargs -n5 | sed -e 's/^/   /')\033[0m"

apt install $installPackages

#
## Finish up with eventual post-install actions
#

eval set -- "$args"
while [ $# -ge 1 ]; do
  case "$1" in
    --)
      shift
      break
    ;;
    -d|--dev)
      # If we're running openvpn docker might have some trouble setting up a bridge
      # Check and if no bridge yet, create it
      if [ -z $(ls /sys/class/net | grep docker0) ]
      then
        sudo brctl addbr docker0
        sudo ip addr add 192.168.77.1/24 dev docker0
        sudo ip link set dev docker0 up
        ip addr show docker0
        sudo systemctl restart docker
        sudo iptables -t nat -L -n
      fi
      
      # Add user to docker group so we can run without sudo
      usermod -a -G docker $SUDO_USER
      shift
    ;;
  esac
  
  shift
done

#
## Link all scripts
#

printOut "Linking scripts to /usr/local/bin"

# Read every line in the file install.scripts, only using the ones with a valid configuration (i.e. `script.sh:desiredName`. look at the last line of the loop, `done < <`...)
while read installScript
do
  echo -e "$installScript"
  $installScript
done  < <(awk -F":" -v currDir="$CurrentDirName" '/.+\.sh:.+/{print "ln -s " currDir "/scripts/" $1 " /usr/local/bin/" $2 }' ./install.scripts)

printOut "Creating bash aliases"

cp ~/.bash_aliases ~/.bash_aliases.EUSbak
cat "$CurrentDirName/.bash_aliases" >> ~/.bash_aliases

printOut "Done"
