#!/bin/sh

TAR="$1"
#VERSION="$2"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

epm assure erc || epm ei erc || fatal

CURDIR="$(pwd)"

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

if echo "$TAR" | grep Linux_Universal_Driver.zip ; then
    a= erc $TAR || fatal
    TAR=$(echo KyoceraLinuxPackages-*.tar.gz)
fi

if echo "$TAR" | grep KyoceraLinuxPackages ; then
    a= erc $TAR || fatal
else
    fatal "How no idea how to handle $TAR"
fi

cd KyoceraLinuxPackages-*.tar || fatal
case "$(epm print info -p)" in
    rpm)
        cd Fedora/Global/kyodialog_x86_64 || fatal
        PKG="kyodialog-*.x86_64.rpm"
        ;;
    *)
        cd Debian/Global/kyodialog_amd64 || faal
        PKG="kyodialog_*_amd64.deb"
        ;;
    # Debian/Global/kyodialog_i386 kyodialog_9.2-0_i386.deb
esac

cp $PKG $CURDIR || fatal

return_tar $PKG
