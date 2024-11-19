#!/bin/sh

PKGNAME=softmaker-freeoffice
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SoftMaker Free Office from the official site"
TIPS="Run epm play freeoffice=<version> to install some specific version"

. $(dirname $0)/common.sh


PKGURL="$(eget --list --latest https://www.freeoffice.com/ru/download/applications "softmaker-freeoffice-$VERSION*-amd64.tgz")"

install_pack_pkgurl
