#!/bin/sh

PKGNAME=podman-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="is the best free and open source tool to work with Containers and Kubernetes for developers."
URL="https://podman-desktop.io/"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

case "$arch" in
  arm64)
    file="podman-desktop-${VERSION}-arm64.tar.gz"
    pattern="$file"
    ;;
  amd64)
    # For amd64, the Podman Desktop archive has no architecture suffix.
    # Create a pattern that will not match ARM64.
    file="podman-desktop-${VERSION}.tar.gz"
    pattern='podman-desktop-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz'
    ;;
esac

if [ "$VERSION" = "*" ] ; then
  PKGURL=$(get_github_url "https://github.com/containers/podman-desktop" "$pattern")
else
  PKGURL="https://github.com/containers/podman-desktop/releases/download/v${VERSION}/${file}"
fi


install_pkgurl
