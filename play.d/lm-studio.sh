#!/bin/sh

PKGNAME=LM-Studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Download and run Llama, DeepSeek, Mistral, Phi on your computer."
URL="https://lmstudio.ai/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

LINK="$(eget -O- "https://lmstudio.ai/download")"

VERSION="$(echo "$LINK" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | tail -n 1)"
BUILD="$(echo "$LINK" | sed -nE 's/.*\\"build\\":\\"([0-9]+)\\".*/\1/p')"

PKGURL="https://installers.lmstudio.ai/linux/x64/$VERSION-$BUILD/LM-Studio-$VERSION-$BUILD-x64.AppImage"

install_pkgurl
