#!/bin/sh

PKGNAME="$(basename $0 .sh)"
SUPPORTEDARCHES="x86_64"
DESCRIPTION=''
URL="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"

. $(dirname $0)/common.sh

CODECS_JSON="https://browser-resources.s3.yandex.net/linux/codecs_snap.json"
JSON=$(curl -s "$CODECS_JSON")
VERSION=$(echo "$JSON" | grep -o '"[0-9]\+":' | tr -d '"' | tr -d ':' | tail -n1)
FFMPEG_PATH=$(echo "$JSON" | awk -v rev="$VERSION" '
    $0 ~ "\""rev"\"" {found=1; next}
    found && /"path"/ {gsub(/.*: *"|",?$/, ""); print; exit}
')
PKGURL=$(echo "$JSON" | awk -v rev="$VERSION" '
    $0 ~ "\""rev"\"" {found=1; next}
    found && /"url"/ {gsub(/.*: *"|",?$/, ""); print; exit}
')

install_pack_pkgurl "$VERSION" "$FFMPEG_PATH"
