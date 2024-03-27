#!/bin/sh -x

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

erc $TAR || fatal

[ -n libffmpeg.so ] || fatal
chmod 0644 libffmpeg.so
mkdir -p usr/lib64/ffmpeg-plugin-browser
mv libffmpeg.so usr/lib64/ffmpeg-plugin-browser/

if [ -z "$VERSION" ] && rhas "$URL" "github.com.*/releases/download" ; then
    VERSION="$(echo "$URL" | sed -e 's|.*/releases/download/||' -e "s|/$(basename $TAR)||")"
fi

[ -n "$VERSION" ] || fatal "Can't get version from either tarball $TAR or URL $URL"

PKGNAME=$PRODUCT-$VERSION.tar

erc a $PKGNAME usr

return_tar $PKGNAME
