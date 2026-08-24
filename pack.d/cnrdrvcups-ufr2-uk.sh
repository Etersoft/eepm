#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

case "$TAR" in
    *.tar.gz|*.tgz)
        ARCHIVE="$TAR"
        ;;
    *)
        ARCHIVE="$(basename "$TAR").tar.gz"
        cp "$TAR" "$ARCHIVE" || fatal
        ;;
esac

erc --here unpack "$ARCHIVE" || fatal
cd "$(ls -d linux-*/)" || fatal

case "$(epm print info -a)" in
    x86_64)
        cd x64 || fatal
        ;;
    x86)
        cd x86 || fatal
        ;;
    aarch64)
        cd ARM64 || fatal
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

case "$(epm print info -p)" in
    rpm)
        for i in RPM/*.rpm ; do
            [ -f "$i" ] || continue
            PKG="$i"
            break
        done
        ;;
    *)
        for i in Debian/*.deb Debian/Debian/*.deb ; do
            [ -f "$i" ] || continue
            PKG="$i"
            break
        done
        ;;
esac

[ -n "$PKG" ] || fatal "Can't find package in $TAR"

return_tar "$PKG"
