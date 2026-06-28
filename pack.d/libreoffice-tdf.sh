#!/bin/sh

# Pack the official LibreOffice build from The Document Foundation (a tarball of
# ~42 rpm payloads, plus the Russian langpack and help) into a single package.
# The TDF build is self-contained in /opt/libreoffice<major.minor> and ships its
# own desktop files and icons (the libreoffice<MM>-freedesktop-menus payload).

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# derive the download version from the main archive name:
# LibreOffice_<VER>_Linux_x86-64_rpm.tar.gz
URLVER="$(basename "$TAR" | sed -e 's|^LibreOffice_||' -e 's|_Linux_.*||')"
[ -n "$URLVER" ] || fatal "Can't derive LibreOffice version from $TAR"

BASEURL="https://download.documentfoundation.org/libreoffice/stable/$URLVER/rpm/x86_64"

# the main archive is already downloaded as $TAR; fetch the Russian langpack and help
eget -O langpack.tar.gz "$BASEURL/LibreOffice_${URLVER}_Linux_x86-64_rpm_langpack_ru.tar.gz" || fatal "Can't download langpack"
eget -O helppack.tar.gz "$BASEURL/LibreOffice_${URLVER}_Linux_x86-64_rpm_helppack_ru.tar.gz" || fatal "Can't download helppack"

tar xzf "$TAR" || fatal "Can't unpack $TAR"
tar xzf langpack.tar.gz || fatal "Can't unpack langpack"
tar xzf helppack.tar.gz || fatal "Can't unpack helppack"

# merge every rpm payload into a single tree: opt/ (suite) + usr/ (menus, icons)
for r in */RPMS/*.rpm ; do
    rpm2cpio "$r" | cpio -idmu --quiet || fatal "Can't extract $r"
done

[ -d opt ] || fatal "No payload extracted (opt/ is missing)"

# use the real (4-part) build version from the core payload as the package version
set -- */RPMS/libobasis*-core-*.rpm
[ -r "$1" ] && PKGVER="$(rpm -qp --qf '%{VERSION}\n' "$1" 2>/dev/null)"
[ -n "$PKGVER" ] || PKGVER="$URLVER"

erc pack "$PRODUCT-$PKGVER.tar" opt usr || fatal "Can't pack"

return_tar "$PRODUCT-$PKGVER.tar"
