#!/bin/sh -x

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
FFMPEG_PATH="$5"

. $(dirname $0)/common.sh

YANDEX_PATH="opt/yandex/browser"

epm assure unsquashfs squashfs-tools || fatal
a= unsquashfs $TAR || fatal

[ -n "$FFMPEG_PATH" ] || fatal "Missing FFMPEG_PATH"
chmod 0644 "squashfs-root/$FFMPEG_PATH"
mkdir -p "$YANDEX_PATH"
cp "squashfs-root/$FFMPEG_PATH" "$YANDEX_PATH/"

PKGNAME=$PRODUCT-$VERSION.tar

erc a $PKGNAME opt

return_tar $PKGNAME
