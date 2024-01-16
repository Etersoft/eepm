#!/bin/sh

PKGNAME=rstudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='RStudio from the official site'

. $(dirname $0)/common.sh

arch=x86_64
pkgtype=$(epm print info -p)
repack=''

case $(epm print info -e) in
    Ubuntu/22*|Ubuntu/23*)
        PKGFILTER="jammy"
        ;;
    AstraLinux*|Debian/*|Ubuntu/*)
        PKGFILTER="bionic"
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
    ALTLinux/*)
        PKGFILTER="rhel8"
        repack='--repack'
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac

PKGMASK="$(epm print constructname $PKGNAME "$VERSION" $arch $pkgtype "-" "-")"
PKGURL="$(epm tool eget --list https://www.rstudio.com/products/rstudio/download/ $PKGMASK | grep $PKGFILTER)" || fatal "Can't get package URL"

epm install $repack "$PKGURL"
