#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | sed 's|^v||')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc --here unpack "$TAR" || fatal

SRCDIR="$(erc basename "$TAR")"
[ -d "$SRCDIR" ] || fatal "Cannot find extracted dir '$SRCDIR' from $TAR"

install -D -m755 "$SRCDIR/syncthing" usr/bin/syncthing
install -D -m644 "$SRCDIR/etc/linux-systemd/system/syncthing@.service" usr/lib/systemd/system/syncthing@.service
install -D -m644 "$SRCDIR/etc/linux-systemd/user/syncthing.service" usr/lib/systemd/user/syncthing.service
install -D -m644 "$SRCDIR/etc/linux-desktop/syncthing-start.desktop" usr/share/applications/syncthing-start.desktop
install -D -m644 "$SRCDIR/etc/linux-desktop/syncthing-ui.desktop" usr/share/applications/syncthing-ui.desktop
install -D -m644 "$SRCDIR/LICENSE.txt" usr/share/doc/syncthing/LICENSE.txt
install -D -m644 "$SRCDIR/AUTHORS.txt" usr/share/doc/syncthing/AUTHORS.txt
install -D -m644 "$SRCDIR/README.txt" usr/share/doc/syncthing/README.txt

erc pack $PKGNAME.tar usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/File transfer
license: MPLv2
url: https://syncthing.net/
summary: Continuous file synchronization between devices
description: |
 Syncthing is a continuous file synchronization program. It synchronizes
 files between two or more computers in real time, safely protected from
 prying eyes. Your data is your data alone and you deserve to choose where
 it is stored, whether it is shared with some third party and how it's
 transmitted over the internet.
EOF

return_tar $PKGNAME.tar
