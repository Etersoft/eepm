#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q "Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz" ; then
    erc $TAR || fatal
    TAR="Sentinel_LDK_Linux_Run-time_Installer_script/aksusbd-*.tar.gz"
fi

if echo "$TAR" | grep -q "aksusbd" ; then
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

mv -v $PRODUCT*/pkg/$pkg . || fatal

return_tar $pkg
