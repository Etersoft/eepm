#!/bin/sh

FILENAME="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

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

same_package_build()
{
    local field left right
    for field in arch version-release ; do
        left="$(epm print "$field" for package "$1")" || fatal "Can't read $field from $1"
        right="$(epm print "$field" for package "$2")" || fatal "Can't read $field from $2"
        [ -n "$left" ] && [ "$left" = "$right" ] || return 1
    done
}

# Pack only extracts/selects vendor artifacts; metadata belongs to repack.
packages_list=''
pkgtype=''
for package in $package_list ; do
    type="${package##*.}"
    [ -z "$pkgtype" ] || [ "$pkgtype" = "$type" ] || fatal "Mixed rpm and deb archives are not supported"
    pkgtype="$type"
    pkgname="$(epm print name for package "$package")" || fatal "Can't read package name from $package"
    case "$pkgname" in
        *-thin-client|*-thin-client-nls)
            fullpkg="${pkgname%-thin-client*}-client"
            # Full and thin clients of the same version ship the same launchers.
            skip=''
            for candidate in $package_list ; do
                name="$(epm print name for package "$candidate")" || fatal
                [ "$name" = "$fullpkg" ] || continue
                same_package_build "$package" "$candidate" || continue
                skip=1
                break
            done
            if [ -n "$skip" ] ; then
                echo "Skipping $pkgname: $fullpkg already includes the thin client."
                continue
            fi
            ;;
    esac
    packages_list="$packages_list $package"
done

[ -n "$packages_list" ] || fatal "Can't find 1C rpm/deb packages in $(basename "$FILENAME")"
return_tar $packages_list
