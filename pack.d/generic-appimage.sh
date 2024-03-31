#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# allow .appimage extension
if rhas "$TAR" "\.appimage$" ; then
    newtarname="${TAR/.appimage/.AppImage}"
    mv "$TAR" "$newtarname"
    TAR="$newtarname"
fi

if ! rhas "$TAR" "\.AppImage$" ; then
    fatal "No idea how to handle $TAR"
fi

alpkg=$(basename $TAR)

PRODUCT="$(basename $alpkg .AppImage)"

# unpack AppImage
[ -x "$TAR" ] || chmod u+x $verbose "$TAR"
$TAR --appimage-extract >/dev/null || fatal

# try separate VERSION from PRODUCT
if [ -z "$VERSION" ] ; then
    VERSION="$(echo "$PRODUCT" | grep -o -P "[-_.]([0-9v])([0-9])*([.]*[0-9])*" | head -n1 | sed -e 's|^[-_.a-zA-Z]||' -e 's|--|-|g' -e 's|^v\([0-9]\)|\1|' )"  #"
    [ -n "$VERSION" ] && PRODUCT="$(echo "$PRODUCT" | sed -e "s|[-_.]$VERSION.*||")"
    PRODUCT="${PRODUCT/-x86_64/}"
fi

# try get version from X-AppImage-Version
if [ -z "$VERSION" ] ; then
    DESKTOPFILE="$(echo squashfs-root/*.desktop | head -n1)"
    str="$(grep '^X-AppImage-Version=[0-9]' $DESKTOPFILE)"
    if [ -n "$str" ] ; then
        VERSION="$(echo $str | sed -e 's|.*X-AppImage-Version=||')"
    fi
fi

# try get version from URL
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
