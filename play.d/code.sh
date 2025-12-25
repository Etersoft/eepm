#!/bin/sh

PKGNAME=code
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION="Visual Studio Code from the official site"
TIPS="Run epm play code=<version> to install specific version."
URL="https://code.visualstudio.com/"

. $(dirname $0)/common.sh

# override only checked version and latest version
if [ -n "$CHECKED_VERSION" ] || [ "$VERSION" = "*" ] ; then
    if ! is_openssl_enough 3 ; then
        VERSION="1.106.3"
        info "There is no needed OpenSSL 3 in the system,  we'll stick with the old version $VERSION"
    elif ! is_soname_present libwebkit2gtk-4.1.so.0 ; then
        VERSION="1.106.3"
        info "There is no libwebkit2gtk-4.1 in the system, we'll stick with the old version $VERSION"
    fi
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
