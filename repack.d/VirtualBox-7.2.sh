#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=VirtualBox
PRODUCTDIR=/usr/lib/virtualbox

. $(dirname $0)/common.sh

# conflict with the distro package
add_conflicts virtualbox

# create vboxusers group via systemd-sysusers
cat <<EOF | create_file /usr/lib/sysusers.d/virtualbox.conf
g vboxusers - -
EOF

# fix desktop file
fix_desktop_file /usr/bin/VirtualBox

add_libs_requires
