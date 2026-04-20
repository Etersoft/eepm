#!/bin/sh

BASEPKGNAME=claude-code
SUPPORTEDARCHES="x86_64 aarch64"
PRODUCTALT="'' latest"
VERSION="$2"
DESCRIPTION="Claude is a next generation AI assistant built by Anthropic"
URL="https://claude.ai/"

. $(dirname $0)/common.sh

# claude-code uses stable channel, claude-code-latest uses latest channel
if [ "$PKGNAME" = "$BASEPKGNAME-latest" ] ; then
    CHANNEL="latest"
else
    CHANNEL="stable"
fi

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
esac

# TODO: Darwin support
os="linux"

platform="${os}-${arch}"

DOWNLOAD_BASE_URL="https://downloads.claude.ai/claude-code-releases"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$DOWNLOAD_BASE_URL/$CHANNEL")" || fatal "Can't get version from $DOWNLOAD_BASE_URL/$CHANNEL"
    [ -n "$VERSION" ] || fatal "Got empty version from $DOWNLOAD_BASE_URL/$CHANNEL"
fi

# ["platforms","linux-x64","checksum"]
checksum="$(get_json_value "$DOWNLOAD_BASE_URL/$VERSION/manifest.json" '["platforms","'$platform'","checksum"]')" || fatal "Can't get checksum"

PKGURL="$DOWNLOAD_BASE_URL/$VERSION/$platform/claude"

# TODO: compare checksum

install_pack_pkgurl $VERSION $checksum
