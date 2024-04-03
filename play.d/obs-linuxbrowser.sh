#!/bin/sh

PKGNAME=obs-linuxbrowser
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Portable version of OBS linux browser"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/bazukas/obs-linuxbrowser/releases ".tgz")

install_pack_pkgurl
