#!/bin/sh

PKGNAME=Cursor
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="The AI-first Code Editor"
URL="https://www.cursor.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info --arch-arch)"
JSON="https://www.cursor.com/api/download?platform=linux-$arch&releaseTrack=stable"

PKGURL="$(eget -O- "$JSON" | parse_json_value "downloadUrl")"

install_pkgurl
