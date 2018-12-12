#!/bin/bash

CurrentDirName=`dirname "$(readlink -f "$0")"`

source "$CurrentDirName/scripts/common.sh"
source "$CurrentDirName/scripts/alwaysSudo.sh"

printOut "Removing script links from /usr/local/bin"

rm /usr/local/bin/uptodate