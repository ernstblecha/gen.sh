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
if [ "$GET_VERSION" = "1" -o "$1" = "v" ]; then
  echo $VERSION
  exit 0
fi

ME=`basename $0`
if [ "$1" = "h" -o "$1" = "-h" -o "$1" = "--help" ]; then
  cat <<EOF
$ME - remove redundant information from the output of eix-test-obsolete
Version of $ME: $VERSION
EOF
  exit 0
fi;

generateControlOutput () {
cat <<EOF
No non-matching entries in /etc/portage/package.keywords
No non-matching entries in /etc/portage/package.accept_keywords
No non-matching entries in /etc/portage/package.mask
No non-matching entries in /etc/portage/package.unmask
No non-matching or empty entries in /etc/portage/package.use
No non-matching or empty entries in /etc/portage/package.env
No non-matching or empty entries in /etc/portage/package.license
No non-matching or empty entries in /etc/portage/package.accept_restrict
No non-matching or empty entries in /etc/portage/package.cflags
The names of all installed packages are in the database.
No  redundant  entries in /etc/portage/package.{,accept_}keywords
Skipping check: uninstalled entries in /etc/portage/package.{,accept_}keywords
No  redundant  entries in /etc/portage/package.mask
Skipping check: uninstalled entries in /etc/portage/package.mask
No  redundant  entries in /etc/portage/package.unmask
Skipping check: uninstalled entries in /etc/portage/package.unmask
Skipping check:  redundant  entries in /etc/portage/package.use
Skipping check: uninstalled entries in /etc/portage/package.use
Skipping check:  redundant  entries in /etc/portage/package.env
Skipping check: uninstalled entries in /etc/portage/package.env
No  redundant  entries in /etc/portage/package.license
Skipping check: uninstalled entries in /etc/portage/package.license
No  redundant  entries in /etc/portage/package.accept_restrict
Skipping check: uninstalled entries in /etc/portage/package.accept_restrict
Skipping check:  redundant  entries in /etc/portage/package.cflags
Skipping check: uninstalled entries in /etc/portage/package.cflags
All installed versions of packages are in the database.
EOF
}

check () {
diff <(generateControlOutput) <(LC_ALL=C eix-test-obsolete) | grep "^> ."

if [[ ${PIPESTATUS[0]} == 0 ]]; then
  printf "No up-to-date entries in config files found.\n"
fi
}

spinner() {
# as seen on http://fitnr.com/showing-a-bash-spinner.html
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while kill -0 -- $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

coproc checkfd { check; }
exec 3>&${checkfd[0]}
spinner $!
read -r -d '' -u 3 check_output

echo "$check_output"

exit 0
