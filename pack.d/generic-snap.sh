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
eval $(epm tool yaml squashfs-root/meta/snap.yaml | grep -E "(name|version|summary|description)=") #"

[ -n "$name" ] || fatal "Can't get name from snap.yaml"
[ -n "$version" ] || fatal "Can't get version from snap.yaml"

mkdir -p opt/
mv squashfs-root opt/$name

PKGNAME=$name-$version.tar

cat <<EOF >$PKGNAME.eepm.yaml
name: $name
version: $version
summary: $summary
description: $description
upstream_file: $alpkg
generic_repack: snap
EOF

test -d opt/$name || fatal "Can't find opt/$name"
install_file opt/$name/meta/gui/icon.png usr/share/pixmaps.png
install_file opt/$name/meta/gui/*.desktop usr/share/applications/$name.desktop
sed -i -e 's|^Icon=.*|Icon=$name|' usr/share/applications/$name.desktop

erc pack $PKGNAME opt/$name usr/share

return_tar $PKGNAME
