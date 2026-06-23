#!/bin/sh

PKGNAME=dmde-gui
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Powerful tool for data searching, editing, and recovery on disks (GUI version)"
URL="https://dmde.com/download.html"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "$URL" "dmde-*-lin64-gui.zip")"
    [ -n "$PKGURL" ] || fatal "Can't find DMDE Linux 64-bit GUI download URL."
else
    PKGURL="https://dmde.com/download/dmde-$(echo "$VERSION" | tr . -)-lin64-gui.zip"
fi

install_pack_pkgurl

cat <<EOF

Note: DMDE uses sudo to run with elevated privileges. Sudo must be enabled in the system:
$ su -
# control sudowheel enabled
# exit
EOF
