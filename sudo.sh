#!/bin/bash

# This file is part of gen.sh.
#
# gen.sh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# gen.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gen.sh.  If not, see <http://www.gnu.org/licenses/>.

VERSION=1
if [ "$GET_VERSION" = "1" ]; then
  echo $VERSION
  exit 0
fi

if [[ $# -eq 0 ]]; then
  ME=`basename $0`
  echo "$ME [commands or sudo-options] - run a command with sudo and show a notification if a password is required"
  echo "Version of $ME: $VERSION"
  sudo -h
  exit 0
fi;

sudo -n echo -n 2> /dev/null
if [[ $? != 0 ]]; then
  gen.sh q i "User Interaction Needed (sudo)"
fi
sudo $@
