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
            if [ "$VERSION" = "*" ] ; then
                VERSION="$(get_deb_repo_latest_version "https://hub.unity3d.com/linux/repos/deb/dists/stable/main/binary-amd64/Packages.gz" unityhub)"
                [ -n "$VERSION" ] || fatal "Can't get latest unityhub version from Unity deb repo"
            fi
        else
            [ "$VERSION" = "*" ] && VERSION="3.3.0"
            info "glibc version below 2.35, we'll stick with the old version $VERSION"
        fi
        # Unity changed the deb naming scheme starting at 3.15.3
        if is_version_older "$VERSION" 3.15.3 ; then
            PKGURL="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_$arch/unityhub-amd64-$VERSION.deb"
        else
            PKGURL="https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_$arch/UnityHubSetup-$VERSION-amd64.deb"
        fi
        install_pkgurl
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
