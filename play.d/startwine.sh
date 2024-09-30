#!/bin/sh

PKGNAME=startwine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Windows application launcher for GNU/Linux operating systems'
URL="https://github.com/RusNor/StartWine-Launcher"

. $(dirname $0)/common.sh

PKGURL=$(epm tool eget --list --latest https://github.com/RusNor/StartWine-Launcher/releases "startwine-$VERSION.x86_64.rpm")

epm install $PKGURL
