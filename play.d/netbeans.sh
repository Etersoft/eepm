#!/bin/sh

PKGNAME=apache-netbeans
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Apache NetBeans from the official site"
URL="https://netbeans.apache.org"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info --debian-arch)

# It is too complex to support history
#if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget --list --latest https://installers.friendsofapachenetbeans.org/ "apache-netbeans_*_$arch.deb")
#lse
#   if [ "$VERSION" -ge 26 ] ; then
#       # TODO
#       PKGURL="https://github.com/Friends-of-Apache-NetBeans/netbeans-installers/releases/download/v27-build1/apache-netbeans_27-1_arm64.deb"
#   else
#       PKGURL="https://archive.apache.org/dist/netbeans/netbeans-installers/$VERSION/apache-netbeans_${VERSION}-*_all.deb"
#   fi
#i

install_pkgurl
