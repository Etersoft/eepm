#!/bin/sh

PKGNAME=lunacy
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="Lunacy - Graphic Design Editor"

. $(dirname $0)/common.sh

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

# https://icons8.ru/lunacy
epm install "https://lcdn.icons8.com/setup/$file"

