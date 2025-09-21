#!/bin/sh

PKGNAME="$(basename $0 .sh)"
SUPPORTEDARCHES="x86_64"
DESCRIPTION=''
URL="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"

. $(dirname $0)/common.sh

CODECS_JSON="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"
JSON="$(eget -O- "$CODECS_JSON")"

# TODO: use needed version
# use latest available version
VERSION=$(echo "$JSON" | grep -o '"[0-9]\+":' | tr -d '"' | tr -d ':' | tail -n1)

FFMPEG_PATH="$(echo "$JSON" | parse_json_value "[\"$VERSION\",\"path\"]")"
PKGURL="$(echo "$JSON" | parse_json_value "[\"$VERSION\",\"url\"]")"

install_pack_pkgurl "$VERSION" "$FFMPEG_PATH"
