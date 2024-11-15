#!/bin/sh

PKGNAME=svp4
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SmoothVideo Project 4 (SVP4)"
URL="https://svp-team.com/wiki/SVP:Linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="http://www.svp-team.com/files/svp4-latest.php?linux"

install_pack_pkgurl
