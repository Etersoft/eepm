#!/bin/sh

PKGNAME=xnconvert
SUPPORTEDARCHES="x86_64"
DESCRIPTION="XnConvert: Image Converter from the official site"
URL="https://www.xnview.com/en/xnconvert/"

. $(dirname $0)/common.sh

epm install https://download.xnview.com/XnConvert-linux-x64.deb
