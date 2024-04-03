#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PKGNAME="$(basename $TAR .run | tr "[A-Z_]" "[a-z-]")"

install -D $TAR opt/$PRODUCT/$PRODUCT || fatal

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=CUDA-Z
Comment=CUDA Information Utility
Type=Application
Icon=$PRODUCT
Exec=$PRODUCT
Terminal=false
EOF

install_file "https://cuda-z.sourceforge.net/img/web-download-detect.png" /usr/share/pixmaps/$PRODUCT.png


erc pack $PKGNAME.tar opt/$PRODUCT usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: GPLv2
url: https://cuda-z.sourceforge.net/
summary: CUDA-Z
description: CUDA-Z.
EOF

return_tar $PKGNAME.tar
