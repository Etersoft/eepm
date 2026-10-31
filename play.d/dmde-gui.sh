#!/bin/sh

BASEPKGNAME=dmde-gui
PRODUCTALT="'' beta"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Powerful tool for data searching, editing, and recovery on disks (GUI version)"
URL="https://dmde.com/download.html"
TIPS="Run 'epm play dmde-gui=beta' to install beta version."

. $(dirname $0)/common.sh

if [ "$BRANCH" = "beta" ] ; then
    beta=-beta
    beta_filter=
    override_pkgname "$BASEPKGNAME"
else
    beta=
    beta_filter=-v
fi

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list "$URL" "dmde-*-lin64-gui.zip" | grep $beta_filter -- '-beta-' | sort -V | tail -n1)"
    [ -n "$PKGURL" ] || fatal "Can't find DMDE Linux 64-bit GUI download URL."
else
    PKGURL="https://dmde.com/download/dmde-$(echo "$VERSION" | tr . -)$beta-lin64-gui.zip"
fi

install_pack_pkgurl

cat <<EOF

Note: DMDE uses sudo to run with elevated privileges. Sudo must be enabled in the system:
$ su -
# control sudowheel enabled
# exit
EOF
