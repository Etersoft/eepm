#!/bin/sh

PKGNAME=ramus
SUPPORTEDARCHES=""
DESCRIPTION="Java-based IDEF0 & DFD Modeler"
URL="https://github.com/Vitaliy-Yakovchuk/ramus"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Hardcode VERSION for fix work with java 11
VERSION="2.0.2"

PKGURL="https://github.com/Vitaliy-Yakovchuk/ramus/archive/refs/tags/v$VERSION.tar.gz"

install_pack_pkgurl
