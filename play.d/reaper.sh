#!/bin/sh

PKGNAME=reaper
SUPPORTEDARCHES="x86_64 x86 armhf aarch64"
VERSION="$2"
DESCRIPTION='REAPER is a complete digital audio production application for computers, offering a full multitrack audio and MIDI recording, editing, processing, mixing and mastering toolset.'
URL="https://www.reaper.fm/index.php"

. $(dirname $0)/common.sh


case "$(epm print info -a)" in
    x86_64)
        arch="x86_64" ;;
    x86)
        arch="i686" ;;
    armhf)
        arch="armv7l" ;;
esac


if [ "$VERSION" = "*" ] ; then
    VERSION="$(eget -O- https://www.reaper.fm/download.php | grep -oE 'REAPER [0-9]+\.[0-9]+(\.[0-9]+)?' | awk '{print $2}' | tr -d '.')"
else
    VERSION=$(echo $VERSION | tr -d '.')
fi

PKGURL="https://www.reaper.fm/files/7.x/reaper${VERSION}_linux_${arch}.tar.xz"

install_pack_pkgurl