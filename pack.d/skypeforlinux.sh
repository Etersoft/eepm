#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

epm assure unsquashfs squashfs-tools || fatal "Install a package with unsquashfs command manually."
unsquashfs $TAR || fatal

VERSION=$(grep version squashfs-root/snapcraft.yaml | awk '{print $2}')
PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/
mkdir -p usr/share/applications/
mkdir -p usr/share/icons/hicolor/

mv squashfs-root/snap/gui/*.desktop usr/share/applications/
mv squashfs-root/usr/share/skypeforlinux opt/
for i in 16 32 256 512 1024; do
    install -Dm644 squashfs-root/usr/share/icons/hicolor/${i}x${i}/apps/skypeforlinux.png usr/share/icons/hicolor/${i}x${i}/apps/skypeforlinux.png
done

erc pack $PKGNAME.tar opt usr
return_tar $PKGNAME.tar
