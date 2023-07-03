#!/bin/sh

PKGNAME=Todoist
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Todoist client application from the official site'

. $(dirname $0)/common.sh

PKGURL="https://todoist.com/linux_app/appimage"

# TODO: rename AppImages on the fly (in pack.d/generic-appimage.sh)
cd_to_temp_dir
epm tool eget "$PKGURL" || fatal
newname="$(echo *.AppImage | sed -e "s|^Todoist-linux-x86_64-|$PKGNAME-|" )"
mv -v *.AppImage $newname || exit

epm install $newname
