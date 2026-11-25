#!/bin/sh

PKGNAME=streamtube
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Stream Tube - a native YouTube client with SponsorBlock and libmpv playback"
URL="https://github.com/Avaneesh-Inamdar/Stream-Tube-Desktop"

. $(dirname $0)/common.sh

is_glibc_enough 2.35 || fatal 'Stream Tube needs glibc 2.35 or newer.'

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "streamtube_*_amd64.deb")"
else
    # Package metadata uses 0.7.3~alpha, while play parses =0.7.3-alpha
    # into VERSION=0.7.3 and RELEASE=alpha.
    tag="$(echo "$VERSION" | tr '~' '-')"
    case "$RELEASE" in
        alpha*|beta*|rc*) tag="$tag-$RELEASE" ;;
    esac
    PKGURL="$URL/releases/download/v$tag/streamtube_${tag}_amd64.deb"
fi

install_pkgurl
