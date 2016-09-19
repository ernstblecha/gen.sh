#!/bin/bash

VERSION=1
if [ "$GET_VERSION" = "1" ]; then
  echo $VERSION
  exit 0
fi

if [[ $# -eq 0 ]]; then
  echo `basename $0`" [commands or sudo-options] - run a command with sudo and show a notification if a password is required"
  echo "Version of "`basename $0`": $VERSION"
  sudo -h
  exit 0
fi;

sudo -n echo -n 2> /dev/null
if [[ $? != 0 ]]; then
  gen.sh q i "User Interaction Needed"
fi
sudo $@
