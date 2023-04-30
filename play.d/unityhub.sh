#!/bin/sh

PKGNAME=unityhub
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unity Hub from the official site"
REPOURL="https://unity.com/"


. $(dirname $0)/common.sh

arch=amd64
reponame=$(epm print info --repo-name)
vendor=$(epm print info -s)
#version=$(epm print info --base-version)

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unityhub

case $vendor in
    alt)
        if [ "$VERSION" = "*" ] ; then
            case $reponame in
                p10)
                    VERSION="3.3.0"
                    ;;
                *)
                    VERSION="3.4.2"
                    ;;
            esac
        fi
        PKGURL=https://hub.unity3d.com/linux/repos/deb/pool/main/u/unity/unityhub_$arch/unityhub-amd64-$VERSION.deb
        epm install --repack "$PKGURL"
        exit
        ;;
esac

case $vendor/$reponame in
    alt/Sisyphus)
        epm repo addkey "https://angie.software/keys/angie-signing.gpg" "EB8EAF3D4EF1B1ECF34865A2617AB978CB849A76" "Angie (Signing Key) <devops@tech.wbsrv.ru>" angie
        epm repo add "rpm [angie] https://download.angie.software/angie/altlinux/10/ x86_64 main"

        epm update
        epm install $PKGNAME
        ;;
    alt/p10)
        epm repo addkey "https://angie.software/keys/angie-signing.gpg" "EB8EAF3D4EF1B1ECF34865A2617AB978CB849A76" "Angie (Signing Key) <devops@tech.wbsrv.ru>" angie
        epm repo add "rpm [angie] https://download.angie.software/angie/altlinux/10/ x86_64 main"

        epm update
        epm install $PKGNAME
        ;;
esac

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
exit
