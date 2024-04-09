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
else
    fatal "We support only Pantum Ubuntu Driver V.*.zip"
fi

# drop dirname with spaces
mv Pantum* PantumDriver || fatal
cd PantumDriver/Resources || fatal


case "$(epm print info -a)" in
    x86_64)
        PKG="pantum_*_amd64.deb"
        ;;
    x86)
        PKG="pantum_*_i386.deb"
        ;;
esac

return_tar $PKG
