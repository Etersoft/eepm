#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

if [ -z "$VERSION" ] ; then
    # extract version from URL path like .../ide-zips/2025.3.1.8/android-studio-...
    VERSION="$(echo "$URL" | sed -n 's|.*/ide-zips/\([0-9][0-9.]*\)/.*|\1|p')"
    [ -n "$VERSION" ] || fatal "Can't get version for $PRODUCT"
fi

PKGNAME=$PRODUCT-$VERSION

erc repack "$TAR" $PKGNAME.tar || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/C
license: Proprietary
url: https://developer.android.com/studio
summary: The official Android IDE
description: Android Studio is the official IDE for Android application development.
upstream_file: $(basename "$TAR")
EOF

return_tar $PKGNAME.tar
