#!/bin/sh

PKGNAME=gitlab-runner
SUPPORTEDARCHES="armhf aarch64 x86 x86_64 ppc64le"
DESCRIPTION='Gitlab runner'

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
pkg="$(epm print info -p)"
case "$arch" in
    x86_64)
        arch=amd64
        ;;
    aarch64)
        arch=arm64
        ;;
    armhf)
        arch=armhf
        ;;
    x86)
        arch=i686
        [ "$pkg" = "deb" ] && arch=i386
        ;;
esac

repack=''
case $(epm print info -e) in
    ALTLinux/*)
        repack='--repack'
        ;;
esac

# https://docs.gitlab.com/runner/install/linux-manually.html
# https://gitlab-runner-downloads.s3.amazonaws.com/latest/index.html
epm install $repack "https://gitlab-runner-downloads.s3.amazonaws.com/latest/$pkg/gitlab-runner_${arch}.$pkg"
