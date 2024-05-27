#!/bin/sh

PKGNAME=ProtonUp-Qt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Install and manage GE-Proton and Luxtorpeda for Steam and Wine-GE for Lutris with this graphical user interface'
URL="https://github.com/DavidoTek/ProtonUp-Qt"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/DavidoTek/ProtonUp-Qt/releases "$PKGNAME-$VERSION-x86_64.AppImage")

install_pkgurl

