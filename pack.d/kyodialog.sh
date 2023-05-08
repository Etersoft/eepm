#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q Linux_Universal_Driver.zip ; then
    erc $TAR || fatal
    TAR=$(echo KyoceraLinuxPackages-*.tar.gz)
fi

if echo "$TAR" | grep -q KyoceraLinuxPackages ; then
    erc $TAR || fatal
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
        cd Debian/Global/kyodialog_amd64 || fatal
        PKG="kyodialog_*_amd64.deb"
        ;;
    # Debian/Global/kyodialog_i386 kyodialog_9.2-0_i386.deb
esac

return_tar $PKG
