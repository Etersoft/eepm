#!/bin/sh

PKGNAME=vinteo.desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Client for Vinteo videoconferencing server"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKGURL=$(epm tool eget --list --latest https://download.vinteo.com/VinteoClient/linux/ "Vinteo.Desktop-$VERSION-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKGURL"
