#!/bin/sh

PKGNAME=robboScratch
VERSION="$2"
RELEASE="$3"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Robbo Scratch (visual programming environment for Robbo educational robotics) from the official site"
URL="https://robboclub.ru"
TIPS="Robbo devices are USB serial adapters: add your user to the group owning /dev/ttyUSB* (uucp on ALT, dialout on other distros) to use them, f.i. 'sudo usermod -a -G uucp \$USER', then log in again."

. $(dirname $0)/common.sh

# https certificate of files.robbo.ru is broken (issued for another host)
URLBASE="http://files.robbo.ru/Software/RobboScratch3.0/release/Linux"

# only the latest version is kept on the server
warn_version_is_not_supported

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "$URLBASE/" "$PKGNAME-*.x86_64.rpm")"
else
    PKGURL="$URLBASE/$PKGNAME-$VERSION-$RELEASE.x86_64.rpm"
fi

install_pkgurl

echo
echo "$TIPS"
