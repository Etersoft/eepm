#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

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
    [ -n "$VERSION" ] && PRODUCT="$(echo "$alpkg" | sed -e "s|[-_.]$VERSION.*||")" || PRODUCT="$(basename $alpkg .AppImage)"
fi

[ -x "$TAR" ] || chmod u+x $verbose "$TAR"
$TAR --appimage-extract >/dev/null || fatal

DESKTOPFILE="$(echo squashfs-root/*.desktop | head -n1)"
str="$(grep '^X-AppImage-Version=' $DESKTOPFILE)"
if [ -n "$str" ] ; then
    VERSION="$(echo $str | sed -e 's|.*X-AppImage-Version=||')"
fi

# https://github.com/neovide/neovide/releases/download/0.12.2/neovide.AppImage
if [ -z "$VERSION" ] && rhas "$URL" "github.com.*/releases/download" ; then
    VERSION="$(echo "$URL" | sed -e 's|.*/releases/download/||' -e "s|/$alpkg||")"
fi

[ -n "$VERSION" ] || fatal "Can't get version from $TAR. Please, inform ustream about https://docs.appimage.org/reference/desktop-integration.html (X-AppImage-Version field)"

PKGNAME=$PRODUCT-$VERSION.tar

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
upstream_file: $alpkg
generic_repack: appimage
EOF

chmod og-w -R squashfs-root
chmod a+rX -R squashfs-root

erc pack $PKGNAME squashfs-root

return_tar $PKGNAME
