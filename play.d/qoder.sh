#!/bin/sh

PKGNAME=qoder
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Agent Programming Platform for Real Software."
URL="https://qoder.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://download.qoder.com/release/latest/qoder_x86_64.rpm"

install_pkgurl
