#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q KyoceraLinux-Phase5 ; then
    erc --here $TAR || fatal
    TAR=$(echo KyoceraLinux-Phase5*.tar.gz)
fi

if echo "$TAR" | grep -q KyoceraLinux-Phase5 ; then
    erc --here $TAR || fatal
else
    fatal "Have no idea how to handle $(basename $TAR)"
fi
rm $TAR

# tar.gz extracts without subdirectory
cd Debian/Global/kyodialog_amd64 || fatal
PKG="kyodialog_*_amd64.deb"

return_tar $PKG
