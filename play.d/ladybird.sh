#!/bin/sh

PKGNAME=ladybird
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Ladybird web browser with an independent rendering engine"
URL="https://ladybird.org/"
TIPS="Official Flatpak: https://flatpak.ladybird.org/ladybird.flatpakref
Source code: https://github.com/LadybirdBrowser/ladybird"

. $(dirname $0)/common.sh

is_glibc_enough 2.39 || fatal 'Ladybird needs glibc 2.39 or newer. See epm play --info ladybird for the official Flatpak.'

arch="$(epm print info --debian-arch)"
repo=https://apt.ladybird.org
if [ "$VERSION" = "*" ] ; then
    file="$(get_deb_repo_latest_filename "$repo/dists/noble/main/binary-$arch/Packages.xz" "$PKGNAME")"
    [ -n "$file" ] || fatal "Can't find Ladybird for $arch in $repo"
else
    case "$RELEASE" in
        ''|'*') RELEASE='1~ubuntu24.04' ;;
        *~ubuntu24.04) ;;
        *) RELEASE="$RELEASE~ubuntu24.04" ;;
    esac
    file="${PKGNAME}_$VERSION-${RELEASE}_$arch"
fi
PKGURL="$repo/pool/main/l/ladybird/$file.deb"

install_pkgurl
