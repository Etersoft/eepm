#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$TAR" | sed -e 's|^ChimbaBenchCL-v||' -e 's|-.*||')"
[ -n "$VERSION" ] || fatal "Can't get package version"

# the zip contains binaries for Windows, Linux (x86_64, x86) and FreeBSD
case "$(epm print info -a)" in
    x86_64)
        BIN=ChimbaBenchCL-Linux
        ;;
    x86)
        BIN=ChimbaBenchCL-Linux-x86
        ;;
    *)
        fatal "Unsupported arch"
        ;;
esac

erc --here unpack "$TAR" || fatal

DIR="$(erc basename "$TAR")"
install -D -m755 "$DIR/$BIN" usr/bin/$PRODUCT || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr/bin || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: System/Configuration/Hardware
license: MIT
url: https://github.com/Shedou/ChimbaBenchCL
summary: OpenCL benchmark for CPU and GPU
description: ChimbaBenchCL is a lightweight OpenCL benchmark measuring PCIe and VRAM bandwidth, memory latency, FP16/FP32/FP64 and integer compute performance.
EOF

return_tar $PKGNAME.tar
