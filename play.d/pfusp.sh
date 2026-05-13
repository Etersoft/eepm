#!/bin/sh

PKGNAME=pfusp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Ricoh SP-1120N / SP-1125N / SP-1130N Image Scanner Driver Linux from the official site"
URL="https://www.pfu.ricoh.com/global/scanners/fi/dl/agree/ubuntu-64-221-sp.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=2.2.2

# check URL to upgrade the version
PKGURL="https://origin.pfultd.com/downloads/IMAGE/driver/ubuntu/222/pfusp-ubuntu_2.2.2_amd64.deb"

# repack always, even for deb system (broken preinst script)
install_pkgurl --repack
