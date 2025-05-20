#!/bin/sh

PKGNAME=ventoy
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A new bootable USB solution"
URL="https://github.com/ventoy/Ventoy"

. $(dirname $0)/common.sh


PKGURL="$(get_github_url https://github.com/ventoy/Ventoy "ventoy-$VERSION-linux.tar.gz")"

install_pack_pkgurl
