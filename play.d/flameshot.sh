#!/bin/sh

PKGNAME=flameshot
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Powerful yet simple to use screenshot software"
URL="https://github.com/flameshot-org/flameshot/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag https://github.com/flameshot-org/flameshot)"
fi

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://github.com/flameshot-org/flameshot/releases/download/v${VERSION}/flameshot-${VERSION}-1.fc41.x86_64.rpm"
        ;;
    *)
        PKGURL="https://github.com/flameshot-org/flameshot/releases/download/v${VERSION}/flameshot-${VERSION}-1.ubuntu-24.04.amd64.deb"
        ;;
esac

install_pkgurl
