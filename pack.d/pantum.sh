#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# epm replaces spaces with - in downloaded files
if echo "$TAR" | grep -q "Pantum[ -]Ubuntu[ -]Driver[- ]V.*.zip" ; then
    erc "$TAR" || fatal
elif echo "$TAR" | grep -q "Pantum%20Ubuntu%20Driver%20V.*.zip" ; then
    erc "$TAR" || fatal
elif echo "$TAR" | grep -q "linux_pantum.7z" ; then
    erc "$TAR" || fatal
    return_tar linux_pantum.deb
elif echo "$TAR" | grep -q "pantum.*astra.*_amd64.zip" ; then
    erc "$TAR" || fatal
    return_tar pantum_*_amd64.deb
# from Astra disk: Pantum_Ubuntu_Driver_V1.1.5.tar.gz
elif echo "$TAR" | grep -q "Pantum_Ubuntu_Driver_V.*.tar.gz" ; then
    erc "$TAR" || fatal
else
    fatal "We support only Pantum Ubuntu Driver V.*.zip"
fi

# drop dirname with spaces
mv Pantum* PantumDriver || fatal
cd PantumDriver/Resources || fatal

case "$(epm print info -a)" in
    x86_64)
        PKG="pantum[-_]*[-_]amd64.deb"
        ;;
    x86)
        PKG="pantum[-_]*[-_]i386.deb"
        ;;
esac

return_tar $PKG
