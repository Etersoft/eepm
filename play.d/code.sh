#!/bin/sh

PKGNAME=code
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION="Visual Studio Code from the official site"
TIPS="Run epm play code=<version> to install specific version."
URL="https://code.visualstudio.com/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    armhf)
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac


pkgtype="$(epm print info -p)"

if [ "$VERSION" != "*" ] ; then
    PKGURL="https://update.code.visualstudio.com/$VERSION/linux-$pkgtype-$arch/stable"
else
    PKGURL="https://code.visualstudio.com/sha/download?build=stable&os=linux-$pkgtype-$arch"
fi

install_pkgurl

echo
echo "NOTE: VS Code is a proprietary build. We recommend you to use open source editors: Codium, Atom."
