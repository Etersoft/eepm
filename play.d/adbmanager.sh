#!/bin/sh

PKGNAME=adbmanager
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="ADB Manager - GUI tool for managing Android devices via ADB (freeze/unfreeze, remove bloatware)"
URL="https://github.com/AKotov-dev/adbmanager"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        mask="${PKGNAME}-${VERSION}-*.x86_64.rpm"
        ;;
    *)
        mask="${PKGNAME}_${VERSION}-*_amd64.deb"
        ;;
esac

# GitHub asset URLs require the exact file name; resolve the wildcard for both
# catalog-provided versions and the latest-version lookup.
PKGURL=$(get_github_url "https://github.com/AKotov-dev/adbmanager" "$mask")

install_pkgurl
