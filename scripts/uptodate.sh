#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

source "$CurrentDirName/common.sh"
source "$CurrentDirName/alwaysSudo.sh"

printOut "Updating package lists"

apt update

args=$(getopt -l "dist:up" -o "d:u" -- "$@")

eval set -- "$args"

while [ $# -ge 1 ]; do
  case "$1" in
    --)
      shift
      break
      ;;
    -u|--up)
      printOut "Performing normal upgrade (-u)"
      apt upgrade -y
      shift
      ;;
    -d|--dist) 
      printOut "Performing dist-upgrade (-d)"
      apt dist-upgrade -y
      shift
      ;;
  esac

  shift
done