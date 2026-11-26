#!/bin/sh

PKGNAME=gigaideCE
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='GIGA IDE — IDE based on IDEA/PyCharm'
URL="https://gitverse.ru/features/gigaide/#desktop"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://gitverse.ru/features/gigaide/desktop/download/ 'gigaide-[0-9]*.tar.gz')"
else
    # Starting with the 261 builds (2026.1), upstream dropped CE from archive names.
    if is_version_older "$VERSION" 261 ; then
        archive=gigaideCE
    else
        archive=gigaide
    fi
    PKGURL="https://gigaide.ru/downloadlast/$archive-$VERSION.tar.gz"
fi

install_pkgurl

