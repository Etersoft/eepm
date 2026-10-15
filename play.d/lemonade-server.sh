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
        # The native RPM contains the complete server integration, but its
        # binaries require Fedora-specific glibc and libwebsockets versions.
        # pack.d keeps the RPM payload and replaces only those binaries with
        # the portable upstream embeddable build.
        rpmurl="$URL/releases/download/v$ver/lemonade-server-$ver-fc43.$rpmarch.rpm"
        # https://github.com/lemonade-sdk/lemonade/releases/download/v2026.42.1/lemonade-embeddable-2026.42.1-ubuntu-x64.tar.gz
        emburl="$URL/releases/download/v$ver/lemonade-embeddable-$ver-ubuntu-$embarch.tar.gz"

        if [ -n "$print_url" ] ; then
            printf '%s\n%s\n' "$rpmurl" "$emburl"
            exit 0
        fi

        tmpdir="$(mktemp -d)" || fatal "Can't create temporary directory"
        trap 'rm -rf "$tmpdir"' EXIT

        eget -O "$tmpdir/lemonade-server.rpm" "$rpmurl" || fatal "Can't download $rpmurl"
        eget -O "$tmpdir/lemonade-embeddable.tar.gz" "$emburl" || fatal "Can't download $emburl"

        epm pack --install "$PKGNAME" "$tmpdir" "$ver" || __suggest_ipfs_on_error
        ;;
esac
