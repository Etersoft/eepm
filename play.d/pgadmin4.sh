#!/bin/sh

# pgadmin4 ships as two rpms (server + desktop) installed and repacked together,
# so PKGNAME lists both — EEPM_INTERNAL_PKGNAME then covers both and the repack
# package-name check does not trip.
PKGNAME="pgadmin4-server pgadmin4-desktop"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION='pgAdmin4 - administration and management tool for PostgreSQL'

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] || VERSION="${VERSION}-${RELEASE}"

# pgadmin4 bundles a python venv built for a specific interpreter minor version
# (cpython-<minor> .so + symlinks into the system python stdlib), so pick the
# upstream build whose venv python matches the system python; the repacked package
# then Requires exactly that python ABI. Upstream venv pythons: el9=3.9,
# fedora-40=3.12, fedora-42=3.13, fedora-44=3.14.
pyminor="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null)"
case "$pyminor" in
    3.9)  repo="redhat/rhel-9-x86_64" ;;
    3.12) repo="fedora/fedora-40-x86_64" ;;
    3.13) repo="fedora/fedora-42-x86_64" ;;
    3.14) repo="fedora/fedora-44-x86_64" ;;
    # no upstream build matches this python (e.g. 3.11 on RED OS 8): use the
    # python3.13 build and let the package manager pull python3.13 as a dependency.
    *)    repo="fedora/fedora-42-x86_64" ;;
esac
BASEURL="https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/$repo"

pkgarch='x86_64'
PKGURL="$BASEURL/pgadmin4-server-$VERSION.*.$pkgarch.rpm $BASEURL/pgadmin4-desktop-$VERSION.*.$pkgarch.rpm"

install_pkgurl
