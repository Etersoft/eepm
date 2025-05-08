#!/bin/sh

PKGNAME=RubyMine
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="RubyMine — IDE for Ruby and Rails developers"
URL="https://www.jetbrains.com/ruby/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl RM ruby)"

install_pkgurl
