#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# epm replaces spaces with - in downloaded files
if echo "$TAR" | grep -q "Pantum[ -]Ubuntu[ -]Driver[- ]V.*.zip" ; then
    erc --here "$TAR" || fatal
elif echo "$TAR" | grep -q "Pantum[ -]Linux[ -]Driver[- ]V.*.zip" ; then
    erc --here "$TAR" || fatal
elif echo "$TAR" | grep -q "Pantum%20Ubuntu%20Driver%20V.*.zip" ; then
    erc --here "$TAR" || fatal
elif echo "$TAR" | grep -q "Pantum%20Linux%20Driver%20V.*.zip" ; then
    erc --here "$TAR" || fatal
elif echo "$TAR" | grep -q "linux_pantum.7z" ; then
    erc --here "$TAR" || fatal
    return_tar linux_pantum.deb
elif echo "$TAR" | grep -q "pantum.*astra.*_amd64.zip" ; then
    erc --here "$TAR" || fatal
    return_tar pantum_*_amd64.deb
# from Astra disk: Pantum_Ubuntu_Driver_V1.1.5.tar.gz
elif echo "$TAR" | grep -q "Pantum_Ubuntu_Driver_V.*.tar.gz" ; then
    erc --here "$TAR" || fatal
else
    fatal "We support only Pantum Ubuntu Driver V.*.zip"
fi

# normalize upstream directory name (archive may also contain the source .zip)
DRIVERDIR=
for d in * ; do
    [ -d "$d/Resources" ] || continue
    DRIVERDIR="$d"
    break
done

[ -n "$DRIVERDIR" ] || fatal "Can't find unpacked Pantum driver directory"

if [ "$DRIVERDIR" != "PantumDriver" ] ; then
    mv "$DRIVERDIR" PantumDriver || fatal
fi

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
