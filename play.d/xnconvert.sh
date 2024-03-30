#!/bin/sh

PKGNAME=xnconvert
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="XnConvert: Image Converter from the official site"
URL="https://www.xnview.com/en/xnconvert/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://download.xnview.com/XnConvert-linux-x64.deb"

epm install "$PKGURL"
