#!/bin/sh

PKGNAME="$(basename $0 .sh)"
SUPPORTEDARCHES="x86_64"
DESCRIPTION=''
URL="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"

. $(dirname $0)/common.sh

CODECS_JSON="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"
JSON="$(eget -O- "$CODECS_JSON")"

BROWSER_PKG="${PKGNAME%-codecs-ffmpeg-extra}"

case "$PKGNAME" in
    *beta*)
        BROWSER_BIN=/opt/yandex/browser-beta/yandex_browser
        ;;
    *)
        BROWSER_BIN=/opt/yandex/browser/yandex_browser
        ;;
esac

[ -x "$BROWSER_BIN" ] || fatal "$BROWSER_PKG is not installed. Install it first with: epm play $BROWSER_PKG"

VERSION=$(grep -ao "Chrome/[0-9.]*" "$BROWSER_BIN" | head -n1 | cut -d/ -f2 | cut -d. -f1)
[ -n "$VERSION" ] || fatal "Can't detect browser Chrome version from $BROWSER_BIN"


FFMPEG_PATH="$(echo "$JSON" | parse_json_value "[\"$VERSION\",\"path\"]")"
PKGURL="$(echo "$JSON" | parse_json_value "[\"$VERSION\",\"url\"]")"

install_pack_pkgurl "$VERSION" "$FFMPEG_PATH"
