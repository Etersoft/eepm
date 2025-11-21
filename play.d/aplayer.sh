#!/bin/sh

PKGNAME=aplayer
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Cвободно распространяемый (Freeware) проигрыватель музыкальных файлов для операционной системы Linu "
URL="https://albumplayer.ru/linux/"

. $(dirname $0)/common.sh

arch=$(epm print info -a)

case $arch in
    x86_64)
        arch=64 ;;
    aarch64)
        arch=arm64 ;;
esac

warn_version_is_not_supported

if [ "$VERSION" = "*" ] ; then
    VERSION="$(eget -O- https://albumplayer.ru/linux/ | grep -o 'Album Player [0-9\.]\+' | head -n1 | sed 's/Album Player //')"
fi

PKGURL="https://albumplayer.ru/linux/aplayer$arch.tar.gz"

install_pack_pkgurl $VERSION
