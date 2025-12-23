#!/bin/sh

PKGNAME=code
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION="Visual Studio Code from the official site"
TIPS="Run epm play code=<version> to install specific version."
URL="https://code.visualstudio.com/"

. $(dirname $0)/common.sh

# version 1.107+ requires OpenSSL 3 and WebKit2GTK 4.1
if [ "$VERSION" = "*" ] || [ "$(epm print compare version "$VERSION" 1.107)" != "-1" ] ; then
    is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."
    is_soname_present libwebkit2gtk-4.1.so.0 || fatal "There is no libwebkit2gtk-4.1 in the system."
fi

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
echo "NOTE: VS Code is a proprietary build. You can use follow open source editors: Zed, Pulsar, Codium."
