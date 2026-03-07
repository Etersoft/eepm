#!/bin/sh

PKGNAME=rstudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION='RStudio from the official site'
URL="https://posit.co/"

. $(dirname $0)/common.sh

arch=x86_64
pkgtype="$(epm print info -p)"

case $(epm print info -e) in
    Ubuntu/20.*|Debian/11)
        PKGFILTER="focal"
        arch=amd64
        ;;
    Ubuntu/22.*|Ubuntu/23*|Debian/12)
        PKGFILTER="jammy"
        arch=amd64
        ;;
    AstraLinux*|Debian/*|Ubuntu/*)
        PKGFILTER="bionic"
        arch=amd64
        ;;
    RedOS/7*|AlterOS/*|Fedora/19)
        PKGFILTER="centos7"
        ;;
    ROSA/*)
        PKGFILTER="rhel8"
        ;;
    CentOS/*|Fedora/34|Fedora/35|RHEL/8)
        PKGFILTER="rhel8"
        ;;
    Fedora/*|RHEL/9)
        PKGFILTER="rhel9"
        ;;
    OpenSUSE/*)
        PKGFILTER="opensuse15"
        ;;
    ALTLinux/p10|p9|c10*)
        PKGFILTER="focal"
        arch="amd64"
        pkgtype="deb"
        ;;
    ALTLinux/*)
        PKGFILTER="jammy"
        arch="amd64"
        pkgtype="deb"
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
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
