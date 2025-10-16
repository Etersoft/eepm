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

# GitHub release tag only contains the msixbundle; the .deb isn't in the release assets and prereleases are disallowed.
# Download the .deb from the official website instead.
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget --list --latest "https://devtoys.app/download" "devtoys_linux_$arch.deb")
else
    PKGURL="https://github.com/DevToys-app/DevToys/releases/download/v$VERSION/devtoys_linux_$arch.deb"
fi

install_pkgurl
