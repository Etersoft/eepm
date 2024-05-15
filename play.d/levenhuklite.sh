#!/bin/sh

PKGNAME=LevenhukLite
SUPPORTEDARCHES="x86_64"
VERSION="4.11.2023.12"
DESCRIPTION="LevenhukLite microscope"
URL="https://www.levenhuk.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://www.levenhuk.ru/products/materials/0/lvh_software_levenhuklite_${VERSION//./_}.zip"

install_pack_pkgurl $VERSION
