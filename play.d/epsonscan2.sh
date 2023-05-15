#!/bin/sh

PKGNAME=epsonscan2

SUPPORTEDARCHES="x86_64"
DESCRIPTION="Epson Scan 2 - Linux Scanner Driver from the official site"
URL="https://support.epson.net/linux/en/epsonscan2.php"

# TODO: remove repo too
case "$1" in
    "--remove")
        epm remove $(epm qp $PKGNAME-)
        exit
        ;;
esac


. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
arch="$(epm print info -a)"
case "$pkgtype-$arch" in
    rpm-x86_64)
        PKGURL="https://download.ebz.epson.net/dsc/du/02/DriverDownloadInfo.do?LG2=JA&CN2=US&CTI=171&PRN=Linux%20rpm%2064bit%20package&OSC=LX&DL"
        ;;
    *-x86_64)
        PKGURL="https://download.ebz.epson.net/dsc/du/02/DriverDownloadInfo.do?LG2=JA&CN2=US&CTI=171&PRN=Linux%20deb%2064bit%20package&OSC=LX&DL"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm pack $repack --install $PKGNAME "$PKGURL"
