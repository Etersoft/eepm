#!/bin/sh

PKGNAME=code
SUPPORTEDARCHES="x86_64 armhf aarch64"
DESCRIPTION="Visual Studio Code from the official site"
TIPS="Run epm play code=<version> to install specific version."

. $(dirname $0)/common.sh

VERSION="$2"

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

# we have workaround for their postinstall script, so always repack rpm package
[ "$pkgtype" = "deb" ] || repack='--repack'

if [ -n "$VERSION" ] ; then
    URL="https://update.code.visualstudio.com/$VERSION/linux-$pkgtype-$arch/stable"
else
    URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-$pkgtype-$arch"
fi

epm install $repack "$URL" || exit

echo
echo "NOTE: VS Code is a proprietary build. We recommend to use open source editors: Codium, Atom."
