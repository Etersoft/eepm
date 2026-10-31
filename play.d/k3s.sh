#!/bin/sh

BASEPKGNAME=k3s
PRODUCTALT="'' prerelease"
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="K3s - Lightweight Kubernetes from the official site"
URL="https://k3s.io"
GITHUBURL="https://github.com/k3s-io/k3s"
TIPS="Run 'epm play k3s=prerelease' to install prerelease version."

. $(dirname $0)/common.sh


arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="k3s"
        ;;
    armhf)
        file="k3s-armhf"
        ;;
    aarch64)
        file="k3s-arm64"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$BRANCH" = "prerelease" ] ; then
    prerelease=prerelease
    override_pkgname "$BASEPKGNAME"
fi

URLVERSION="$VERSION"
case "$RELEASE" in
    rc*)
        URLVERSION="$VERSION-$RELEASE"
        prerelease=prerelease
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$GITHUBURL" "$file" $prerelease)"
else
    PKGURL="$GITHUBURL/releases/download/v$URLVERSION+k3s1/$file"
fi

VERSION="$(echo "$PKGURL" | sed -e 's|.*download/v||' -e 's|%2Bk3s1.*||' -e 's|+k3s1.*||')"

install_pack_pkgurl $VERSION
