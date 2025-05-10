#!/bin/sh

PKGNAME=pulsar
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A Community-led Hyper-Hackable Text Editor from the official site"
URL="https://pulsar-edit.dev/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag https://github.com/pulsar-edit/pulsar/)"
fi

arch=$(epm print info -a)
case $arch in
    aarch64)
        PKGURL="https://github.com/pulsar-edit/pulsar/releases/download/v${VERSION}/ARM.Linux.pulsar_${VERSION}_arm64.deb"
        ;;
    x86_64)
        PKGURL="https://github.com/pulsar-edit/pulsar/releases/download/v${VERSION}/Linux.pulsar_${VERSION}_amd64.deb"
        ;;
    *)
        fatal "Unsupported arch $arch"
        ;;
esac

install_pkgurl
