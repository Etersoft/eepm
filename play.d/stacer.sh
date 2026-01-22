#!/bin/sh

PKGNAME=stacer
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Linux System Optimizer and Monitoring'
URL="https://github.com/QuentiumYT/Stacer"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
rpm_arch=$(epm print info -a)
deb_arch=$(epm print info --debian-arch)
case $pkgtype in
    rpm)
        if [ "$VERSION" = "*" ] ; then
            PKGURL=$(get_github_url "https://github.com/QuentiumYT/Stacer" "${PKGNAME}-${VERSION}.${rpm_arch}.rpm")
        else
            PKGURL="https://github.com/QuentiumYT/Stacer/releases/download/v${VERSION}/${PKGNAME}-${VERSION}.${rpm_arch}.rpm"
        fi
        ;;
    *)
        if [ "$VERSION" = "*" ] ; then
            PKGURL=$(get_github_url "https://github.com/QuentiumYT/Stacer" "${PKGNAME}_${VERSION}-1_${deb_arch}.deb")
        else
            PKGURL="https://github.com/QuentiumYT/Stacer/releases/download/v${VERSION}/${PKGNAME}_${VERSION}-1_${deb_arch}.deb"
        fi
        ;;
esac

install_pkgurl
