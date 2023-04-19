#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

if echo "$TAR" | grep "Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz" ; then
    erc $TAR || fatal
    TAR="Sentinel_LDK_Linux_Run-time_Installer_script/aksusbd-*.tar.gz"
fi

if echo "$TAR" | grep "aksusbd" ; then
    erc $TAR || fatal
else
    fatal "How no idea how to handle $TAR"
fi

pkgtype="$(epm print info -p)"
case $pkgtype in
    rpm)
        pkg="aksusbd-*.x86_64.rpm"
        ;;
    deb)
        pkg="aksusbd_*_amd64.deb"
        ;;
    *)
        pkg="aksusbd_*_amd64.deb"
        ;;
esac

cp -v $PRODUCT*/pkg/$pkg $CURDIR || fatal

return_tar $CURDIR/$pkg
