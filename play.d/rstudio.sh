#!/bin/sh

PKGNAME=rstudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION='RStudio from the official site'
URL="https://posit.co/"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

# ALTLinux: use deb package (better compatibility)
case $(epm print info -e) in
    ALTLinux/*)
        pkgtype="deb"
        ;;
esac

# RStudio provides only two builds: deb (jammy) and rpm (rhel9)
case $pkgtype in
    deb)
        PKGFILTER="jammy"
        arch=amd64
        ;;
    rpm)
        PKGFILTER="rhel9"
        arch=x86_64
        ;;
    *)
        fatal "Unsupported package type $pkgtype. RStudio provides only deb and rpm packages."
        ;;
esac

# RStudio uses VERSION-BUILD in filenames (e.g. 2026.01.1-403)
# app-versions gives 2026.01.1+403, replace + with -
VERSION="$(echo "$VERSION" | sed 's|+|-|')"
PKGMASK="$PKGNAME-${VERSION}-${arch}.${pkgtype}"

if [ "$VERSION" != "*" ] ; then
    PKGURL="https://download1.rstudio.org/electron/$PKGFILTER/$arch/$PKGMASK"
else
    PKGURL=$(eget --list --latest https://posit.co/download/rstudio-desktop/ "$PKGMASK" | grep "$PKGFILTER")
fi

install_pkgurl
