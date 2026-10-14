#!/bin/sh

FILENAME="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

create_deb_spec()
{
    local spec="$1"
    local pkgname="$2"
    local version="$3"
    local file

    {
        echo "Name: $pkgname"
        echo "Version: $version"
        echo "Release: 1"
        echo "%files"
    } > "$spec"

    find "$BUILDROOT" -path "$BUILDROOT/DEBIAN" -prune -o \( -type f -o -type l \) -print | LC_ALL=C sort | while read -r file ; do
        echo "${file#"$BUILDROOT"}"
    done >> "$spec"
}

remove_deb_server_dependency()
{
    local pkgname="$1"
    local control="$BUILDROOT/DEBIAN/control"

    case "$pkgname" in
        *-thin-client|*-client) ;;
        *) return 0 ;;
    esac

    [ -f "$control" ] || return 0
    sed -i \
        -e 's|, *1c-enterprise-[^,]*-server (= [^)]*)||g' \
        -e 's|1c-enterprise-[^,]*-server (= [^)]*), *||g' \
        -e '/^Depends: 1c-enterprise-[^,]*-server (= [^)]*)$/d' \
        -e '/^Depends: *$/d' \
        "$control"
}

repack_deb()
{
    local package="$1"
    local pkgname version base outdeb spec

    pkgname="$(dpkg-deb -f "$package" Package)" || fatal "Can't read package name from $package"
    version="$(dpkg-deb -f "$package" Version)" || fatal "Can't read package version from $package"
    base="$(basename "$package")"
    outdeb="${base%.deb}_epm.deb"

    BUILDROOT="$(mktemp -d)"
    spec="$(mktemp)"
    SPEC="$spec"
    PRODUCT=1cv8
    PRODUCTDIR=/opt/1cv8

    export BUILDROOT SPEC PRODUCT PRODUCTDIR

    dpkg-deb -R "$package" "$BUILDROOT" || fatal "Can't unpack $package"
    create_deb_spec "$SPEC" "$pkgname" "$version"

    . $(dirname $0)/../repack.d/common.sh
    . $(dirname $0)/../repack.d/common-1c-enterprise.sh

    fix_1c_enterprise_package "$pkgname"
    remove_deb_server_dependency "$pkgname"
    rm -f "$BUILDROOT/.eepm_ignore_lib_requires" "$BUILDROOT/.eepm_ignore_lib_path" "$BUILDROOT/.eepm_stop_libs_requires"

    dpkg-deb -b "$BUILDROOT" "$outdeb" || fatal "Can't build $outdeb"
    rm -rf "$BUILDROOT" "$SPEC"

    REPACKED_DEB="$outdeb"
}

case "$(basename "$FILENAME")" in
    *.rpm|*.deb)
        package_list="$FILENAME"
        ;;
    *.zip|*.tar.gz|*.tgz)
        erc --here unpack "$FILENAME" || fatal
        package_list="$(find . -type f \( -name '1c-enterprise*.rpm' -o -name '1c-enterprise*.deb' \) | LC_ALL=C sort)"
        ;;
    *)
        fatal "run with 1C rpm/deb package or archive"
        ;;
esac

packages_list=''
deb_list=''
rpm_list=''

for package in $package_list ; do
    case "$package" in
        *.deb) deb_list="$deb_list $package" ;;
        *.rpm) rpm_list="$rpm_list $package" ;;
    esac
done

[ -n "$deb_list$rpm_list" ] || fatal "Can't find 1C rpm/deb packages in $(basename "$FILENAME")"
[ -z "$deb_list" ] || [ -z "$rpm_list" ] || fatal "Mixed rpm and deb archives are not supported"

if [ -n "$deb_list" ] ; then
    for package in $deb_list ; do
        repack_deb "$package"
        packages_list="$packages_list $REPACKED_DEB"
    done
else
    packages_list="$rpm_list"
fi

return_tar $packages_list
