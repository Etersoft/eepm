#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# use version from tarball
VERSION="$(basename "$TAR" | sed -E 's/.*_v([0-9][^_]*)_linux64.*/\1/')"
PKGNAME=$PRODUCT-$VERSION

install -D -m755 $TAR opt/$PRODUCT/$PRODUCT || fatal

install_file https://anilabx.xyz/assets/media/hero.png /usr/share/pixmaps/anilabxmax.png

cat <<EOF | create_file /usr/share/applications/anilabxmax.desktop
[Desktop Entry]
Name=AniLabXMax
Comment=AniLabX MAX - PC app for watching anime/dramas/cartoons and reading manga/comics/light novels
Exec=$PRODUCT -Dprism.order=sw
Type=Application
Icon=anilabxmax
Terminal=false
Categories=Utility;Multimedia;
EOF


erc pack $PKGNAME.tar opt/$PRODUCT usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking
license: Proprietary
url: https://anilabx.xyz
summary: AniLabX MAX - PC app for watching anime/dramas/cartoons and reading manga/comics/light novels
description: AniLabX MAX - PC app for watching anime/dramas/cartoons and reading manga/comics/light novels
EOF

return_tar $PKGNAME.tar
