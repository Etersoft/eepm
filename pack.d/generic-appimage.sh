#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

if ! rhas "$TAR" "\.AppImage$" ; then
    fatal "No idea how to handle $TAR"
fi

alpkg=$(basename $TAR)

if [ -n "$VERSION" ] ; then
    PRODUCT="$(basename $alpkg .AppImage)"
else
    # AppImage version
    # hack for ktalk2.4.2 -> ktalk 2.4.2
    VERSION="$(echo "$alpkg" | grep -o -P "[-_.a-zA-Z]([0-9])([0-9])*([.]*[0-9])*" | head -n1 | sed -e 's|^[-_.a-zA-Z]||' -e 's|--|-|g' )"  #"
    [ -n "$VERSION" ] && PRODUCT="$(echo "$alpkg" | sed -e "s|[-_.]$VERSION.*||")" || fatal "Can't get version from $TAR."
fi

PKGNAME=$PRODUCT-$VERSION.tar

[ -x "$TAR" ] || chmod u+x $verbose "$TAR"
$TAR --appimage-extract || fatal

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
upstream_file: $alpkg
generic_repack: appimage
EOF

erc pack $PKGNAME squashfs-root

return_tar $PKGNAME
