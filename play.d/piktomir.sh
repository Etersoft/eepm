#!/bin/sh

PKGNAME=piktomir
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Piktomir ПиктоМир Младший брат КуМира"
URL="https://piktomir.ru/"

. $(dirname $0)/common.sh

PKGURL="https://dl.piktomir.ru/PiktoMir-x86_64.AppImage"

# hack: original AppImage have no version
cd_to_temp_dir
epm tool eget "$PKGURL" || fatal
newname="$PKGNAME-0.1.AppImage"
mv -v *.AppImage $newname

epm install $newname
