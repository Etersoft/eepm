#!/bin/sh

PKGNAME=warp-terminal
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='The intelligent terminal from the official site'
URL="https://www.warp.dev/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        deb_arch=amd64
        appimage_arch=x86_64
        ;;
    aarch64)
        deb_arch=arm64
        appimage_arch=aarch64
        ;;
esac

WARP_VERSION="$(get_json_value https://releases.warp.dev/channel_versions.json '["stable","version"]' | sed -e 's|^v||')"
[ -n "$WARP_VERSION" ] || fatal "Can't get Warp version"
WARP_PKG_VERSION="$(echo "$WARP_VERSION" | sed -e 's|\.stable_|.stable.|')"
WARP_BASE_URL="https://releases.warp.dev/stable/v$WARP_VERSION"

case $(epm print info -p) in
    # force repack for all rpm based (due scripts)
    #rpm)
    #    PKGURL="https://app.warp.dev/download?package=rpm$ARCHSUFF"
    #    ;;
    *)
        PKGURL="$WARP_BASE_URL/warp-terminal_${WARP_PKG_VERSION}_${deb_arch}.deb"
        ;;
esac

case "$(epm print info -d)" in
    ALTLinux)
        # due warp-terminal: /lib64/libcurl.so.4: version `CURL_OPENSSL_4' not found (required by warp-terminal)
        PKGURL="$WARP_BASE_URL/Warp-$appimage_arch.AppImage"
        install_pack_pkgurl "$WARP_PKG_VERSION"
        exit
        ;;
esac

install_pkgurl
