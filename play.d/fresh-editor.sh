#!/bin/sh

PKGNAME=fresh-editor
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="A lightweight, fast terminal-based text editor with LSP support and TypeScript plugins"
URL="https://sinelaw.github.io/fresh/"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype=rpm
        ;;
esac

# https://github.com/sinelaw/fresh/releases/download/v0.1.88/fresh-editor-0.1.88-1.x86_64.rpm
# https://github.com/sinelaw/fresh/releases/download/v0.1.88/fresh-editor_0.1.88-1_amd64.deb
if [ "$VERSION" = "*" ] || [ "$RELEASE" = "*" ] ; then
    PKGURL="$(get_github_url sinelaw/fresh "$(epm print constructname $PKGNAME "$VERSION-*")")"
else
    PKGURL="https://github.com/sinelaw/fresh/releases/download/v$VERSION/$(epm print constructname $PKGNAME "$VERSION-$RELEASE")"
fi

install_pkgurl
