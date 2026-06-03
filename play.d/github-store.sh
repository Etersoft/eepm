#!/bin/sh

PKGNAME=github-store
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A free, open-source app store for GitHub releases"
URL="https://github.com/OpenHub-Store/GitHub-Store"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

warn_version_is_not_supported

case $pkgtype in
    rpm)
        PKGURL=$(get_github_url https://github.com/OpenHub-Store/GitHub-Store "github-store-*.x86_64.rpm")
        ;;
    *)
        PKGURL=$(get_github_url https://github.com/OpenHub-Store/GitHub-Store "github-store_*_amd64.deb")
        ;;
esac

install_pkgurl
