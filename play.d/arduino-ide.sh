#!/bin/sh

PKGNAME=arduino-ide
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The new major release of the Arduino IDE is faster and even more powerful!'
URL="https://www.arduino.cc/en/software"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "https://github.com/arduino/arduino-ide/" "${PKGNAME}_${VERSION}_Linux_64bit.AppImage")

install_pkgurl

