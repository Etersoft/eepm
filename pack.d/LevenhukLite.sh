#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# lvh_software_levenhuklite_4_12_2024_09.zip

VERSION=$(basename $TAR | sed -e 's/lvh_software_levenhuklite_//' | tr '_' '.')

TARDIR="$(erc basename "$TAR")"
erc --here unpack $TAR || fatal
cd "$TARDIR" || fatal

erc --here unpack LevenhukLite.x64.tar.bz2 || fatal
sed -n -e '1,/^exit 0$/!p' LevenhukLite.x64.sh > LevenhukLite.tgz

erc -C opt/$PRODUCT unpack LevenhukLite.tgz || fatal

# move system integration files out of opt
install -Dpm0644 opt/$PRODUCT/LevenhukLite.png usr/share/icons/hicolor/128x128/apps/LevenhukLite.png
install -Dm0644 opt/$PRODUCT/99-levenhukcam.rules usr/lib/udev/rules.d/99-levenhukcam.rules
install -Dpm0644 opt/$PRODUCT/LevenhukLite.desktop usr/share/applications/LevenhukLite.desktop
rm -f opt/$PRODUCT/LevenhukLite.png opt/$PRODUCT/99-levenhukcam.rules opt/$PRODUCT/LevenhukLite.desktop opt/$PRODUCT/uninstall.sh

PKGNAME=$PRODUCT-$VERSION
erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar 
