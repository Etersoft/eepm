#!/bin/sh

BASEPKGNAME=vivaldi
PRODUCTALT="stable snapshot"
VERSION="$2"
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
DESCRIPTION="Vivaldi browser from the official site"
URL="https://vivaldi.com"
TIPS="Run 'epm play vivaldi=snapshot' to install snapshot version of the browser."

. $(dirname $0)/common.sh


arch="$(epm print info --debian-arch)"
case "$arch" in
    amd64|aarch64|i386|armhf)
        ;;
    *)
        fatal "Debian $arch arch is not supported"
        ;;
esac

warn_version_is_not_supported

# can't use wildcard for -1
[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi

# TODO:
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi-ffmpeg-codecs

# https://repo.vivaldi.com/archive/rpm/x86_64/

# epm uses eget to download * names
#epm install "https://repo.vivaldi.com/archive/deb/pool/main/$(epm print constructname $PKGNAME "*" $arch deb)"

if [ "$PKGNAME" = "$BASEPKGNAME-snapshot" ] ; then
    # copied from install-vivaldi.sh script
    # https://help.vivaldi.com/desktop/install-update/install-snapshots-on-non-deb-rpm-distros/
    DEBARCH=$arch
    if [ "$VERSION" = "*" ] ; then
        VERSION=$(eget -O- "https://repo.vivaldi.com/archive/deb/dists/stable/main/binary-$DEBARCH/Packages.gz" | gzip -d | grep -A6 -x "Package: $PKGNAME" | sed -n 's/^Version: \(\([0-9]\+\.\)\{3\}[0-9]\+-[0-9]\+\)/\1/p' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | tail -n 1) #'
    fi
    PKGURL="https://downloads.vivaldi.com/snapshot/vivaldi-snapshot_${VERSION}_$arch.deb"
else
    if [ "$VERSION" = "*" ] ; then
        PKGURL="$(eget --list --latest https://vivaldi.com/ru/download "")" #"
    else
        PKGURL="https://downloads.vivaldi.com/stable/$(epm print constructname $PKGNAME "$VERSION" $arch deb)"
    fi
fi

install_pkgurl

#UPDATEFFMPEG=$(epm ql $PKGNAME | grep update-ffmpeg) || fatal
#epm pack --install $PKGNAME-codecs-ffmpeg-extra $UPDATEFFMPEG
