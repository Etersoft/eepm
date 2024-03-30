#!/bin/sh

PKGNAME=lunacy
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Lunacy - Graphic Design Editor"
URL="https://icons8.ru/lunacy"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        file="Lunacy.deb"
        ;;
    aarch64)
        file="Lunacy.ARM.deb"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if ! is_glibc_enough 2.34 ; then
    fatal "glibc is too old"
fi

# https://icons8.ru/lunacy
epm install "https://lcdn.icons8.com/setup/$file"

