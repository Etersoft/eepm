#!/bin/sh

PKGNAME="devtoys"
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="a Swiss Army knife for developers"
URL="https://devtoys.app/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    aarch64)
        arch="arm" ;;
    x86_64)
        arch="x64" ;;
esac

# GitHub tags use 4-component versions (v2.0.8.0)
# Add trailing .0 if version has only 3 components
case "$VERSION" in
    *.*.*.*) ;;
    *.*.*) VERSION="$VERSION.0" ;;
esac

if [ "$VERSION" = "*" ] ; then
    # All 2.x versions are marked as prerelease on GitHub
    PKGURL=$(get_github_url "DevToys-app/DevToys" "devtoys_linux_$arch.deb" prerelease)
else
    PKGURL="https://github.com/DevToys-app/DevToys/releases/download/v$VERSION/devtoys_linux_$arch.deb"
fi

install_pkgurl
