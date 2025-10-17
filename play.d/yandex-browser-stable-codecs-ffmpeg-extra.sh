#!/bin/sh

PKGNAME="$(basename $0 .sh)"
SUPPORTEDARCHES="x86_64"
DESCRIPTION=''
URL="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"

. $(dirname $0)/common.sh

CODECS_JSON="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"
JSON="$(eget -O- "$CODECS_JSON")"

case "$PKGNAME" in
    *beta*)
        VERSION=$(grep -ao "Chrome/[0-9.]*" /opt/yandex/browser-beta/yandex_browser | head -n1 | cut -d/ -f2 | cut -d. -f1)
        ;;
    *)
        VERSION=$(grep -ao "Chrome/[0-9.]*" /opt/yandex/browser/yandex_browser | head -n1 | cut -d/ -f2 | cut -d. -f1)
        ;;
esac


FFMPEG_PATH="$(echo "$JSON" | parse_json_value "[\"$VERSION\",\"path\"]")"
PKGURL="$(echo "$JSON" | parse_json_value "[\"$VERSION\",\"url\"]")"

install_pack_pkgurl "$VERSION" "$FFMPEG_PATH"
