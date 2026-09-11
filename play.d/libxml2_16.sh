#!/bin/sh

PKGNAME=libxml2_16
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='libxml2.so.16 runtime library from GNOME 49 for applications such as Orion'
URL="https://gitlab.gnome.org/GNOME/libxml2"

. $(dirname $0)/common.sh

warn_version_is_not_supported

epm assure ostree || fatal

# GNOME's libxml2 is built with ICU support.
if [ ! -e /usr/lib64/libicuuc.so.77 ] && [ ! -e /usr/lib/libicuuc.so.77 ] ; then
    epm play libicu77 || fatal "Can't install libicu77 (needed for libxml2.so.16)"
fi

# The pack recipe uses this repository descriptor and its signing key to fetch
# just libxml2 from the runtime, without installing Flatpak or the whole runtime.
PKGURL="https://dl.flathub.org/repo/flathub.flatpakrepo"
install_pack_pkgurl
