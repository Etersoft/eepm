#!/bin/sh

PKGNAME=upscayl
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Free and Open Source AI Image Upscaler'
URL="https://github.com/upscayl/upscayl"

. $(dirname $0)/common.sh

# FIXME: they put some wrong version to X-AppImage-Version
# https://github.com/upscayl/upscayl/issues/761

PKGURL=$(eget --list --latest https://github.com/upscayl/upscayl/releases "upscayl-$VERSION-linux.AppImage")

install_pkgurl
