#!/bin/sh

PKGNAME=docker-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Docker Desktop from the official site"
URL="https://docs.docker.com/desktop/install/ubuntu/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# the vendor serves only the latest build at a versionless URL (no old versions)
pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm"
        ;;
    *)
        PKGURL="https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb"
        ;;
esac

install_pkgurl


cat <<EOF
Note: run
# epm prescription podman-enable-rootless from root
to enable rootless support
EOF
