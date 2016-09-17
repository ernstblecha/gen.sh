#!/bin/bash
sudo -n echo -n 2> /dev/null
if [[ $? != 0 ]]; then
  gen.sh q i "User Interaction Needed"
fi
sudo $@
