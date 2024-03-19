#!/bin/sh

PKGNAME=reaper
SUPPORTEDARCHES="x86_64 x86 armhf aarch64"
DESCRIPTION='REAPER is a complete digital audio production application for computers, offering a full multitrack audio and MIDI recording, editing, processing, mixing and mastering toolset.'
URL="https://www.reaper.fm/index.php"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    x86)
        arch="i686" ;;
    armhf)
        arch="armv7l" ;;
esac

PKGURL=$(epm tool eget --list --latest https://www.reaper.fm/download.php "*$arch.tar.xz") 
[ -n "$PKGURL" ] || fatal "Can't get package URL"

epm pack --install reaper "$PKGURL"