#!/bin/sh
PKGNAME=floorp
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Firefox-based web browser focused on performance and customizability"
URL="https://github.com/Floorp-Projects/Floorp"

. $(dirname $0)/common.sh

arch=$(epm print info -a)

PKGURL=$(get_github_url "Floorp-Projects/Floorp" "floorp-linux-$arch.tar.xz")

install_pack_pkgurl
