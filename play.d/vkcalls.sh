#!/bin/sh

PKGNAME=vk-calls
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VK Calls for Linux from the official site"
URL="https://calls.vk.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://vkcalls-native-ac.vk-apps.com/latest/vk-calls-amd64.deb"

epm install "$PKGURL"
