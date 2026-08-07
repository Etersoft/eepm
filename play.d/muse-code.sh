#!/bin/sh

PKGNAME=muse-code
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Muse Code - AI coding agent from Meta"
URL="https://dev.meta.ai/"

. $(dirname $0)/common.sh

CHANNEL_URL="https://api.meta.ai/muse-code/channels/muse-stable"

# use oficial muse installer user agent for by pass 400 error
export EGET_OPTIONS="--header User-Agent:muse-code/launcher-2"

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        platform=x86_linux
        ;;
    aarch64)
        platform=aarch64_linux
        ;;
esac


if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_json_value "$CHANNEL_URL" '["version"]')"
fi

[ -n "$VERSION" ] || fatal "Got empty Muse Code version"

MANIFEST_URL="https://lookaside.facebook.com/lookaside/muse/download/?channel=muse&version=$VERSION&file=manifest.json"
PKGURL="$(get_json_value "$MANIFEST_URL" '["artifacts","'$platform'","url"]' | sed 's|\\/|/|g')"
checksum="$(get_json_value "$MANIFEST_URL" '["artifacts","'$platform'","checksum"]')"

[ -n "$PKGURL" ] || fatal "Can't get Muse Code package URL"
[ -n "$checksum" ] || fatal "Can't get Muse Code checksum"


package_version="$(printf '%s\n' "$VERSION" | tr '-' '.')"

install_pack_pkgurl "$package_version" "$checksum"
