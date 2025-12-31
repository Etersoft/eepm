#!/bin/sh

PKGNAME=fresh-editor
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A lightweight, fast terminal-based text editor with LSP support and TypeScript plugins"
URL="https://sinelaw.github.io/fresh/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag https://github.com/sinelaw/fresh)"
fi

pkgtype=$(epm print info -p)
rpm_arch=$(epm print info -a)
deb_arch=$(epm print info --debian-arch)
case $pkgtype in
    rpm)
        PKGURL="https://github.com/sinelaw/fresh/releases/download/v${VERSION}/fresh-editor-${VERSION}-1.${rpm_arch}.rpm"
        ;;
    *)
        PKGURL="https://github.com/sinelaw/fresh/releases/download/v${VERSION}/fresh-editor-${VERSION}-1.${deb_arch}.deb"
        ;;
esac

install_pkgurl
