#!/bin/sh

PKGNAME=svp4
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SmoothVideo Project 4 (SVP4)"
URL="https://svp-team.com/wiki/SVP:Linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# wget --trust-server-names "http://www.svp-team.com/files/svp4-latest.php?linux"
# TODO: add --trust-server-names to eget
PKGURL="$(curl -s -L -o /dev/null -w '%{url_effective}' "http://www.svp-team.com/files/svp4-latest.php?linux")"

install_pack_pkgurl
