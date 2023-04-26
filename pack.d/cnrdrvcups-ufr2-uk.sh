#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

if ! echo "$TAR" | grep "linux-UFRII-drv" ; then
    fatal "How no idea how to handle $TAR"
fi

erc unpack $TAR && cd linux-* || fatal

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
        PKG="RPM/*.rpm"
        ;;
    *)
        cd Debian || fatal
        PKG="Debian/*.deb"
        ;;
esac

return_tar $PKG
