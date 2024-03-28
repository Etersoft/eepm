#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q SANE_Driver_zip.download.zip ; then
    erc $TAR || fatal
elif echo "$TAR" | grep -q SANE_Driver.zip ; then
    erc $TAR || fatal
else
    fatal "Have no idea how to handle $(basename $TAR)"
fi

cd SANE_Driver* || fatal

case "$(epm print info -p)" in
    rpm)
        PKG="kyocera-sane-*.x86_64.rpm"
        ;;
    *)
        PKG="kyocera-sane_*_amd64.deb"
        ;;
esac

return_tar $PKG
