#!/bin/sh

PKGNAME=upscayl
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Free and Open Source AI Image Upscaler'
URL="https://github.com/upscayl/upscayl"

. $(dirname $0)/common.sh

PKGURL=$(epm tool eget --list --latest https://github.com/upscayl/upscayl/releases "upscayl-$VERSION-linux.AppImage")

epm install $PKGURL
