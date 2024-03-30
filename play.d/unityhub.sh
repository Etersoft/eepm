#!/bin/sh

PKGNAME=unityhub
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unity Hub from the official site"
URL="https://unity.com/"

. $(dirname $0)/common.sh

arch=amd64
reponame=$(epm print info --repo-name)
vendor=$(epm print info -s)
#version=$(epm print info --base-version)

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unityhub

case $vendor in
    alt)
        if is_glibc_enough 2.35 ; then
            VERSION="3.4.2"
        else
            VERSION="3.3.0"
        fi
        PKGURL="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_$arch/unityhub-amd64-$VERSION.deb"
        epm install --repack "$PKGURL"
        exit
        ;;
esac

echo "Adding vendor repo ..."

case $(epm print info -p) in
    rpm)
        epm repo addkey unityhub "https://hub.unity3d.com/linux/repos/rpm/stable" "https://hub.unity3d.com/linux/repos/rpm/stable/repodata/repomd.xml.key" "Unity Hub"
        ;;
    deb)
        epm repo addkey "https://hub.unity3d.com/linux/keys/public"
        # TODO
        #epm repo add "deb [signedby=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main"
        epm repo add "deb https://hub.unity3d.com/linux/repos/deb stable main"
        ;;
esac

epm update
epm install $PKGNAME

