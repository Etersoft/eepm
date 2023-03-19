#!/bin/sh

DESCRIPTION="Vivaldi browser from the official site"

PRODUCTALT="stable snapshot"
BRANCH=stable
if [ "$2" = "snapshot" ] || epm installed vivaldi-snapshot ; then
    BRANCH=snapshot
fi
PKGNAME=vivaldi-$BRANCH
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
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

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi

# TODO:
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vivaldi-ffmpeg-codecs

# https://repo.vivaldi.com/archive/rpm/x86_64/

# epm uses eget to download * names
#epm install "https://repo.vivaldi.com/archive/deb/pool/main/$(epm print constructname $PKGNAME "*" $arch deb)"

if [ "$BRANCH" = "snapshot" ] ; then
    # copied from install-vivaldi.sh script
    # https://help.vivaldi.com/desktop/install-update/install-snapshots-on-non-deb-rpm-distros/
    DEBARCH=$arch
    VIVALDI_STREAM=vivaldi-snapshot
    VIVALDI_VERSION=$(epm tool eget -O- "https://repo.vivaldi.com/archive/deb/dists/stable/main/binary-$DEBARCH/Packages.gz" | gzip -d | grep -A6 -x "Package: $VIVALDI_STREAM" | sed -n 's/^Version: \(\([0-9]\+\.\)\{3\}[0-9]\+-[0-9]\+\)/\1/p' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | tail -n 1) #"
    PKGURL="https://downloads.vivaldi.com/snapshot/vivaldi-snapshot_${VIVALDI_VERSION}_$arch.deb"
else
    PKGURL="$(epm tool eget --list --latest https://vivaldi.com/ru/download "$(epm print constructname $PKGNAME "*" $arch deb)")" || fatal
fi
epm install $PKGURL || fatal

epm play vivaldi-codecs-ffmpeg-extra $BRANCH
