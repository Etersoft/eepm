#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
ORIGINPACKAGE="$4"

. $(dirname $0)/common.sh

# follow original requires
#reqs="$(epm requires "$ORIGINPACKAGE")"
#[ -n "$reqs" ] && add_requires $reqs

# ??
# echo "root ALL=(ALL) NOPASSWD:SETENV:/usr/bin/rudesktop" > /etc/sudoers.d/rudesktop

install_file usr/share/rudesktop-client/files/rudesktop.service /etc/systemd/system/rudesktop.service
install_file usr/share/rudesktop-client/files/rudesktop.desktop /usr/share/applications/rudesktop.desktop

#xdg-mime default rudesktop.desktop x-scheme-handler/rudesktop || true

subst "s|^Summary:.*|Summary: A remote control software.|" $SPEC

add_libs_requires
