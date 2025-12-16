#!/bin/sh

PKGNAME=scanner-driver-avision
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Avision Scanner Driver"
URL="https://www.avision.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# eget can't get filename
#PKGURL="https://www.dropbox.com/scl/fi/cu7kn1kzvqihulroqp1k3/scanner-driver-avision_rpm64_0.1.0.25311_20251107.tar.gz?rlkey=gvpdoma72x0dr4jwr3mpm8p0c&dl=1"
PKGURL="ipfs://QmXHNSts68ZCAEw49Ug7EFwwH3T3ZFu5DBDb5nbVpUV7eF?filename=scanner-driver-avision_rpm64_0.1.0.25311_20251107.tar.gz"

install_pack_pkgurl
