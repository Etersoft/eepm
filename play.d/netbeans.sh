#!/bin/sh

PKGNAME=apache-netbeans
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Apache NetBeans from the official site"
URL="https://netbeans.apache.org"

. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)
pkgtype=$(epm print info -p)

case "$pkgtype" in
    rpm)
        PKGURL=$(get_github_url "Friends-of-Apache-NetBeans/netbeans-installers" "apache-netbeans-${VERSION}-*.x86_64.rpm")
        ;;
    *)
        PKGURL=$(get_github_url "Friends-of-Apache-NetBeans/netbeans-installers" "apache-netbeans_${VERSION}-*_${arch}.deb")
        ;;
esac

install_pkgurl
