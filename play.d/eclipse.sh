#!/bin/sh

BASEPKGNAME=eclipse
PRODUCTALT="java jee cpp embedcpp php modeling rcp dsl scout committers"
SUPPORTEDARCHES="x86_64 aarch64 riscv64"
VERSION="$2"
DESCRIPTION="Eclipse IDE from the official site"
URL="https://eclipseide.org/"
TIPS="Run 'epm play eclipse=<edition>' to install another edition: $PRODUCTALT (java by default)."

. $(dirname $0)/common.sh

RELURL="https://download.eclipse.org/technology/epp/downloads/release"

# the package version is the simultaneous release name with a dot: 2026.09 (2026-09/R)
if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$RELURL/release.xml" | sed -n 's|.*<present>\([0-9]*-[0-9]*\)/R</present>.*|\1|p' | head -n1 | tr '-' '.')"
    [ -n "$VERSION" ] || fatal "Can't get the current Eclipse release from $RELURL/release.xml"
fi

release="$(echo "$VERSION" | tr '.' '-')"

PKGURL="$RELURL/$release/R/eclipse-$BRANCH-$release-R-linux-gtk-$(epm print info -a).tar.gz"

# one pack.d/eclipse.sh for all editions: it takes the edition from the tarball name
PKGNAME="$BASEPKGNAME"
install_pack_pkgurl
