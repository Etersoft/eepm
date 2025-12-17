#!/bin/sh

PKGNAME=claude-code
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Claude is a next generation AI assistant built by Anthropic"
URL="https://claude.ai/"

. $(dirname $0)/common.sh

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

#GCS_BUCKET="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
GCS_BUCKET="$(fetch_url https://claude.ai/install.sh | grep "^GCS_BUCKET=" | sed -e 's|^GCS_BUCKET=||' -e 's|^"||' -e 's|"$||')"
[ -n "$GCS_BUCKET" ] || fatal "Can't download https://claude.ai/install.sh"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$GCS_BUCKET/stable")" || fatal "Can't get version from $GCS_BUCKET/stable"
    [ -n "$VERSION" ] || fatal "Got empty version from $GCS_BUCKET/stable"
fi

# ["platforms","linux-x64","checksum"]
checksum="$(get_json_value "$GCS_BUCKET/$VERSION/manifest.json" '["platforms","'$platform'","checksum"]')" || fatal "Can't get checksum"

PKGURL="$GCS_BUCKET/$VERSION/$platform/claude"

# TODO: compare checksum

install_pack_pkgurl $VERSION $checksum
