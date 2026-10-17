#!/bin/sh

PKGNAME=lemonade-server
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Lemonade Local LLM Server (AMD) — local AI server for text, images and speech'
URL="https://github.com/lemonade-sdk/lemonade"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        rpmarch=x86_64
        embarch=x64
        ;;
    aarch64)
        rpmarch=aarch64
        embarch=arm64
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag $URL)"
fi
ver="${VERSION#v}"

case "$(epm print info -s):$(epm print info -p)" in
    fedora:rpm)
        distrotag=fc44
        case "$(epm print info -v)" in
            43) distrotag=fc43 ;;
        esac
        PKGURL=$(get_github_url $URL "lemonade-server-$ver-$distrotag.$rpmarch.rpm") ||
            fatal "Can't get package URL for lemonade-server $ver ($distrotag.$rpmarch)"
        install_pkgurl
        ;;
    *)
        # Native packages require distro-specific library versions. Upstream's
        # embeddable server is the portable build intended for third-party packaging.
        if [ "$(epm print info -p)" = "deb" ] ; then
            epm assure libdrm-amdgpu1 || fatal
        fi
        PKGURL="$URL/releases/download/v$ver/lemonade-embeddable-$ver-ubuntu-$embarch.tar.gz"
        install_pack_pkgurl
        ;;
esac
