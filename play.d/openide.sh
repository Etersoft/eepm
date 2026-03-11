#!/bin/sh

BASEPKGNAME=openIDE
PRODUCTALT="'' eap"
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="openIDE - Free IDE based on IntelliJ IDEA Community Edition"
URL="https://openide.ru/"
TIPS="Run 'epm play openide=eap' to install EAP version."

. $(dirname $0)/common.sh

arch=$(epm print info -a)
case "$arch" in
    x86_64)
        arch=""
        ;;
    arm64 | aarch64)
        arch="-aarch64"
        ;;
esac

if [ "$BRANCH" = "eap" ] ; then
    eap="-eap"
    download_page="https://openide.ru/download-eap/"
    # tarball always extracts as openIDE-VERSION/, so repack creates openIDE package
    override_pkgname "$BASEPKGNAME"
else
    eap=""
    download_page="https://openide.ru/download/"
fi

if [ "$VERSION" = "*" ]; then
    VERSION="$(eget -q -O- "$download_page" | grep "Сборка:" | sed -e "s|.*Сборка:</span>[[:space:]]||" -e "s|</p>.*||")"
    if [ -z "$VERSION" ] ; then
        VERSION="$(eget -q -O- https://download.openide.ru/ | grep -o "openIDE-[0-9.]*${eap}\.tar\.gz" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]*" | sort -V | tail -n1)"
    fi
fi

# https://download.openide.ru/252.27397.103.1/openIDE-252.27397.103.1.tar.gz
# https://download.openide.ru/253.28294.334.1/openIDE-253.28294.334.1-eap.tar.gz
# https://download.openide.ru/253.28294.334.1/openIDE-253.28294.334.1-eap-aarch64.tar.gz
PKGURL="https://download.openide.ru/$VERSION/openIDE-$VERSION${eap}${arch}.tar.gz"

install_pack_pkgurl
