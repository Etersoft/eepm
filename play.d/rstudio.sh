#!/bin/sh

PKGNAME=rstudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='RStudio from the official site'
URL="https://posit.co/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=x86_64
pkgtype="$(epm print info -p)"
distr="$(epm print info -s)"

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

PKGMASK="$(epm print constructname $PKGNAME "$VERSION" $arch $pkgtype "-" "-")"
PKGURL="$(eget --list https://posit.co/download/rstudio-desktop/ "$PKGMASK" | grep "$PKGFILTER")"

install_pkgurl
