#!/bin/sh

PKGNAME=librewolf
SUPPORTEDARCHES="x86_64"
DESCRIPTION="LibreWolf - a custom version of Firefox, focused on privacy, security and freedom"

. $(dirname $0)/common.sh

arch=amd64
pkgtype=deb

PKG=$(epm tool eget --list --latest https://deb.librewolf.net/pool/focal/main/libr/librewolf/librewolf_*all.deb) || fatal "Can't get package URL"

epm install --repack "$PKG"
