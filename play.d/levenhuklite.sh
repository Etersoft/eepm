#!/bin/sh

PKGNAME=LevenhukLite
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="LevenhukLite microscope"
URL="https://www.levenhuk.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list --latest "https://www.levenhuk.ru/products/discovery-mikroskop-cifrovoj-atto-polar-s-knigoj/" "lvh_software_levenhuklite_*.zip")

install_pack_pkgurl
