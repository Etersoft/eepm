#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

epm assure xdg-desktop-menu xdg-utils || fatal

# reaper711_linux_x86_64.tar.xz
BASENAME=$(basename $TAR .tar.xz)
VERSION=$(echo $BASENAME | sed -e 's|reaper||' | sed -e 's|_linux_*.tar.xz||')

ln -s $TAR $BASENAME.tar.xz
erc unpack $BASENAME.tar.xz || fatal

subst "s|xdg-desktop-menu install \$2 |xdg-desktop-menu install --mode user --noupdate |" reaper_linux_x86_64/install-reaper.sh
subst "s|--size 256|--size 256 --noupdate|" reaper_linux_x86_64/install-reaper.sh

# subst 's|cd "$(dirname "$0")"||' install-reaper.sh
sh reaper_linux_x86_64/install-reaper.sh --install $(pwd)/opt --integrate-desktop --quiet

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

return_tar $PKGNAME.tar
