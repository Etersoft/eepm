#!/bin/sh

PKGNAME=tflexcad
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="T-FLEX CAD - parametric 2D/3D CAD system from the official site"
URL="https://tflex.ru/downloads/linux/"
TIPS="T-FLEX CAD requires a license: with a local protection key activate it with 'T-FLEX Licensing' (tflex-licensing), a network key needs no local setup."

. $(dirname $0)/common.sh

# only the latest version is available
warn_version_is_not_supported

case "$(epm print info -e)" in
    AstraLinux*)
        file="TFLEX_CAD_18_Astra18.deb"
        ;;
    RedOS/*)
        file="TFLEX_CAD_18_RedOS8.rpm"
        ;;
    *)
        file="TFLEX_CAD_18_Alt11.rpm"
        ;;
esac

PKGURL="https://tflex.ru/downloads/linux/$file"

install_pkgurl || exit

echo
echo "$TIPS"
