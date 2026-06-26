#!/bin/sh

PKGNAME=max
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Быстрое и лёгкое приложение для общения и решения повседневных задач'
URL="https://max.ru/"

. $(dirname $0)/common.sh

# The native ALT repo is on a different release train, so install the EL9 rpm
# everywhere (including ALT) to keep one version across all distros.
# The download filename carries a build number that is absent from the rpm
# Version, so we keep it in our package version as VERSION~BUILD (26.20.0~73009).
# That makes the build number survive in app-versions, so the exact file stays
# reconstructible (and IPFS-cacheable) without re-scraping the index.
if [ "$VERSION" = "*" ] || ! echo "$VERSION" | grep -q '~' ; then
    # latest: take the build-numbered base name (MAX-26.20.0.73009) from the index
    filename=$(get_deb_repo_latest_filename https://download.max.ru/linux/deb/dists/stable/main/binary-amd64/Packages.gz max)
    [ -n "$filename" ] || fatal "Can't get MAX package filename from the deb repo"
    fnver=$(echo "$filename" | sed 's/^MAX-//')
    ver=$(echo "$fnver" | sed 's/\.[0-9]*$//')
    build=$(echo "$fnver" | sed 's/.*\.//')
    VERSION="${ver}~${build}"
fi

# VERSION format: 26.20.0~73009
ver=$(echo "$VERSION" | cut -d~ -f1)
build=$(echo "$VERSION" | cut -d~ -f2)
filebase="MAX-${ver}.${build}"

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://download.max.ru/linux/rpm/el/9/x86_64/${filebase}.rpm"
        ;;
    *)
        PKGURL="https://download.max.ru/linux/deb/pool/main/m/max/${filebase}.deb"
        ;;
esac

# pass full version with build number to repack so app-versions records it
export EPM_REPACK_VERSION="$VERSION"
install_pkgurl
