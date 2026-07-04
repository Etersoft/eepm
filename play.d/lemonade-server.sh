#!/bin/sh

PKGNAME=lemonade-server
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Lemonade Local LLM Server (AMD) — local AI server for text, images and speech'
URL="https://github.com/lemonade-sdk/lemonade"

. $(dirname $0)/common.sh

# Upstream ships distro-pinned binaries built against a very recent glibc:
#   RPM (fc43/fc44) — glibc 2.40/2.43 + libwebsockets.so.21
#   DEB (debian13)  — glibc 2.38 + libwebsockets.so.19
# The binaries are not interchangeable across distro families (different
# libwebsockets soname). On rolling distros with a fresh glibc (ALT Sisyphus,
# Fedora rawhide) the fc44 build runs fine.

arch="$(epm print info -a)"
pkg="$(epm print info -p)"

case "$arch" in
    x86_64)
        rpmarch=x86_64
        debarch=amd64
        ;;
    aarch64)
        rpmarch=aarch64
        debarch=arm64
        ;;
    *)
        fatal "Unsupported architecture: $arch"
        ;;
esac

if [ "$pkg" = "deb" ] ; then
    distrotag=debian13
    filearch=$debarch
    ext=deb
else
    # Fedora ships version-tagged builds; match the running release, default fc44.
    distrotag=fc44
    if [ "$(epm print info -s)" = "fedora" ] ; then
        case "$(epm print info -v)" in
            43) distrotag=fc43 ;;
        esac
    fi
    filearch=$rpmarch
    ext=rpm
fi

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag $URL)"
fi
ver="${VERSION#v}"

PKGURL=$(get_github_url $URL "lemonade-server-$ver-$distrotag.$filearch.$ext") ||
    fatal "Can't get package URL for lemonade-server $ver ($distrotag.$filearch)"

install_pkgurl
