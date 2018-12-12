#!/bin/bash

# Makes sure this or any file that `source`s this one has super user privvies
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@" 
fi