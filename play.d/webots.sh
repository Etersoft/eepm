#!/bin/sh

PKGNAME=webots
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Webots: open-source robot simulator"
URL="https://cyberbotics.com/"

. $(dirname $0)/common.sh


PKGURL=$(eget --list --latest https://github.com/cyberbotics/webots/releases/"*.deb") || fatal "Can't get package URL"

install_pkgurl
