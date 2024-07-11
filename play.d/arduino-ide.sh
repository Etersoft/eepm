#!/bin/sh

PKGNAME=arduino-ide
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The new major release of the Arduino IDE is faster and even more powerful!'
URL="https://www.arduino.cc/en/software"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/arduino/arduino-ide/" "${PKGNAME}_.${VERSION}_Linux_64bit.AppImage")
else
    PKGURL="https://github.com/arduino/arduino-ide/releases/download/$VERSION/${PKGNAME}_${VERSION}_Linux_64bit.AppImage"
fi

install_pkgurl

