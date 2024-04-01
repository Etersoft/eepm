#!/bin/sh

PKGNAME=alien
SUPPORTEDARCHES=""
VERSION="$2"
DESCRIPTION="Alien converting tool (use it if your repo has no alien)"
# disabled: useless
DESCRIPTION=''

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        # eget --list https://packages.altlinux.org/ru/p10/srpms/alien/rpms/*.noarch.rpm
        PKGURL="ipfs://QmXWpF7zgpWdXQiEMFAdVMCerxG7xMkSMXMjCostsejhA5?filename=alien-8.95-alt9.noarch.rpm"
        ;;
    deb)
        # https://packages.debian.org/buster/all/alien/download
        PKGURL="ipfs://QmNeGAcYGWmbZzrEpS4B4XGCbTvc3zknWvW37PJBsDLYQS?filename=alien_8.95_all.deb"
        ;;
esac

epm install --norepack $PKGURL
