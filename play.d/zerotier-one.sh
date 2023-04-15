#!/bin/sh

PKGNAME=zerotier-one
SUPPORTEDARCHES="x86_64 aarch64 ppc64el"
DESCRIPTION="ZeroTier - A Smart Ethernet Switch for Earth from the official site"

. $(dirname $0)/common.sh

pkg="$(epm print info -p)"

arch="$(epm print info -a)"
[ "$pkg" = "deb" ] && arch="$(epm print info --distro-arch)"

# TODO
version=1.10.6

distr="$(epm print info -s)"
repo="$(epm print info -r)"

case "$distr" in
    alt)
        distr=redhat
        if [ "$repo" = "p9" ] || [ "$repo" = "c9f2" ] ; then
            repo=el6
        else
            repo=el8
        fi
        ;;
    centos|rhel)
        distr=redhat
        repo=fc$repo
        ;;
    debian|ubuntu)
        distr=debian
        ;;
    fedora)
        distr=redhat
        repo=fc$repo
        ;;
    *)
        ;;
esac

dv=$distr/$repo

# hack due broken answer from the server
PKGURL="$(eget --compressed --list --latest https://download.zerotier.com/RELEASES/$version/dist/$dv/${PKGNAME}[-_]$version*$arch.$pkg)"

epm install --scripts $PKGURL
