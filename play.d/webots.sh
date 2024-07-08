#!/bin/sh

PKGNAME=webots
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Webots: open-source robot simulator"
URL="https://cyberbotics.com/"

. $(dirname $0)/common.sh


PKGURL=$(get_github_version "https://github.com/cyberbotics/webots/" ".*.deb")

install_pkgurl
