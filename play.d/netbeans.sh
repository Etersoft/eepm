#!/bin/sh

PKGNAME=apache-netbeans
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Apache NetBeans from the official site"
URL="https://netbeans.apache.org"

. $(dirname $0)/common.sh


arch=$(epm print info --debian-arch)

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget --list --latest https://installers.friendsofapachenetbeans.org/ "apache-netbeans_*_$arch.deb")
else
    PKGURL="https://archive.apache.org/dist/netbeans/netbeans-installers/$VERSION/apache-netbeans_${VERSION}-*_all.deb"
fi

install_pkgurl
