#!/bin/sh

PKGNAME=signal-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Signal private messenger from the official site'
DOWNURL="https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop"

. $(dirname $0)/common.sh

# Direct link to download .deb package
# https://github.com/signalapp/Signal-Desktop/issues/3506

# old way
#PKGURL=$(eget --list --latest https://mirror.cs.uchicago.edu/signal/pool/main/s/signal-desktop/ "${PKGNAME}_${VERSION}_amd64.deb")
#file="$(basename $PKGURL)"

#[ "$VERSION" = "*" ] && VERSION="$(eget --list --latest https://github.com/signalapp/Signal-Desktop/releases/ v$VERSION.tar.gz | sed -e 's|^v\(.*\)\.tar\.gz|\1|')"
[ "$VERSION" = "*" ] && VERSION="$(eget -O- https://api.github.com/repos/signalapp/Signal-Desktop/releases | grep '"name": "v[0-9]*\.[0-9]*\.[0-9]*"' | head -n1 | sed -e 's|.* "v\(.*\)".*|\1|')" #'
#file="$(eget -O- https://updates.signal.org/desktop/apt/dists/xenial/main/binary-amd64/Packages.gz | zcat | grep Filename | sed 's_Filename: _https://updates.signal.org/desktop/apt/_')"
[ -n "$VERSION" ] || fatal "Can't retrieve the latest version for $PKGNAME."

# signal-desktop_5.63.1_amd64.deb
file=signal-desktop_${VERSION}_amd64.deb

#PKGURL="https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop/$file"
PKGURL="https://updates.signal.org/desktop/apt/pool/s/signal-desktop/$file"

install_pkgurl
