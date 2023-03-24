#!/bin/sh

TAR="$1"
#VERSION="$2"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# TODO: get from  grep '^###Scripts version ' PortWINE/data_from_portwine/changelog_eng | head -n1
###Scripts version 2172###
VERSION="$(epm tool eget -O- https://api.github.com/repos/Castro-Fidel/PortWINE/commits/HEAD | grep '"message": "Scripts version' | sed -e 's|.*Scripts version ||' -e 's|".*||' )"

[ -n "$VERSION" ] || fatal "Missed archive version"

PKGNAME=portproton-$VERSION.tar

erc repack "$TAR" "$PKGNAME" || fatal

return_tar "$PKGNAME"

