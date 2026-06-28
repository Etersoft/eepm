#!/bin/sh

# packaged as libreoffice-tdf to coexist with the distro libreoffice package
# (the TDF build installs in parallel into /opt/libreoffice<major.minor>)
PKGNAME=libreoffice-tdf
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="LibreOffice, official build from The Document Foundation (with Russian langpack and help)"
URL="https://www.libreoffice.org"
TIPS="The TDF build installs in parallel to the distro package. Run it as libreoffice<major.minor> (f.i. libreoffice26.2) or from the application menu."

. $(dirname $0)/common.sh

# TDF ships rpm and deb separately; only rpm is wired up here for now.
[ "$PKGFORMAT" = "rpm" ] || fatal "Only rpm-based distributions are supported for now"

BASEURL="https://download.documentfoundation.org/libreoffice/stable"

# resolve the latest stable version if none requested
if [ -z "$VERSION" ] || [ "$VERSION" = "*" ] ; then
    VERSION="$(eget --list "$BASEURL/" '[0-9]*' | sed -e 's|/*$||' -e 's|.*/||' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't detect the latest LibreOffice version"
fi

# the main archive; pack.d/libreoffice-tdf.sh fetches the ru langpack/help itself
PKGURL="$BASEURL/$VERSION/rpm/x86_64/LibreOffice_${VERSION}_Linux_x86-64_rpm.tar.gz"

install_pack_pkgurl
