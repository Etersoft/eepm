#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

epm assure xdg-desktop-menu xdg-utils || fatal

# reaper711_linux_x86_64.tar.xz
BASENAME=$(basename $TAR .tar.xz)
VERSION=$(echo $BASENAME | sed -e 's|^reaper||' | sed -e 's|_linux_.*||')

erc --here unpack $TAR || fatal
# match extracted dir reaper_linux_*, not the tar.xz itself sitting in cwd
SUBDIR="$(echo reaper_linux_*)"
subst "s|xdg-desktop-menu install \$2 |xdg-desktop-menu install --mode user --noupdate |" $SUBDIR/install-reaper.sh
subst "s|--size 256|--size 256 --noupdate|" $SUBDIR/install-reaper.sh

# subst 's|cd "$(dirname "$0")"||' install-reaper.sh
sh $SUBDIR/install-reaper.sh --install $(pwd)/opt --integrate-desktop --quiet || fatal

mkdir -p usr/share/applications
mkdir -p usr/share/icons/hicolor/256x256/apps/
mkdir -p usr/share/mime/application/
mkdir -p usr/share/mime/packages/

mv .local/share/applications/*.desktop usr/share/applications/
mv .local/share/icons/hicolor/256x256/apps/*.png usr/share/icons/hicolor/256x256/apps/
mv .local/share/mime/application/*.xml usr/share/mime/application/
mv .local/share/mime/packages/*.xml  usr/share/mime/packages/

subst "s|$(pwd)/opt/REAPER/reaper|reaper|" usr/share/applications/cockos-reaper.desktop

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Sound
license: Proprietary
url: https://www.reaper.fm/
summary: REAPER digital audio production application
description: REAPER is a complete digital audio production application for computers, offering a full multitrack audio and MIDI recording, editing, processing, mixing and mastering toolset.
EOF

return_tar $PKGNAME.tar
