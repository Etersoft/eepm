#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

if ! rhas "$TAR" "\.snap$" ; then
    fatal "No idea how to handle $TAR"
fi

alpkg=$(basename $TAR)

# improve me
epm assure unsquashfs squashfs-tools || fatal
a= unsquashfs $TAR || fatal

# name: plex-desktop
# version: 1.69.1
# summary: Plex for Linux
# description:
eval $(epm tool yaml squashfs-root/meta/snap.yaml | head | grep -E "(name|version|summary|description)=")
cat <<EOF >eepm.yaml
name: $name
version: $version
summary: $summary
description: $description
upstream_file: $alpkg
generic_repack: snap
EOF

PKGNAME=$name-$version.tar

install_file meta/gui/icon.png /usr/share/pixmaps.png
install_file meta/gui/*.desktop /usr/share/applications/$name.desktop
sed -i -e 's|^Icon=.*|Icon=$name|' usr/share/applications/$name.desktop

erc pack $PKGNAME squashfs-root eepm.yaml

return_tar $PKGNAME
