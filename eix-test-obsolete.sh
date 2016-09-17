#!/bin/bash

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
No uninstalled entries in /etc/portage/package.{,accept_}keywords
No  redundant  entries in /etc/portage/package.mask
No uninstalled entries in /etc/portage/package.mask
No  redundant  entries in /etc/portage/package.unmask
No uninstalled entries in /etc/portage/package.unmask
Skipping check:  redundant  entries in /etc/portage/package.use
Skipping check: uninstalled entries in /etc/portage/package.use
Skipping check:  redundant  entries in /etc/portage/package.env
Skipping check: uninstalled entries in /etc/portage/package.env
No  redundant  entries in /etc/portage/package.license
No uninstalled entries in /etc/portage/package.license
No  redundant  entries in /etc/portage/package.accept_restrict
No uninstalled entries in /etc/portage/package.accept_restrict
Skipping check:  redundant  entries in /etc/portage/package.cflags
Skipping check: uninstalled entries in /etc/portage/package.cflags
All installed versions of packages are in the database.
EOF
}

diff <(generateControlOutput) <(eix-test-obsolete) | grep "^> ."

exit 0
