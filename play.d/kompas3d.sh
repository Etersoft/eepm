#!/bin/sh

PKGNAME=ascon-kompas3d
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Kompas 3D beta from the official site"
URL="https://repo.ascon.ru/beta"
REPOURL="https://repo.ascon.ru/beta"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case $(epm print info -e) in
    ALTLinux/p11|ALTLinux/Sisyphus)
        epm repo addkey "$REPOURL/alt/ascon.gpg"
        epm repo add "rpm [ascon] $REPOURL/alt/ p11/x86_64 main"
        ;;
    RedOS/8.0)
        epm repo addkey ascon-beta "$REPOURL/rpm/redos/8.0/" "$REPOURL/rpm/ascon.gpg" "Ascon Beta"
        ;;
    AstraLinuxSE/1.8)
        # Copied from install script
        # echo "deb [signed-by=/etc/apt/trusted.gpg.d/ascon.gpg] https://repo.ascon.ru/beta/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/ascon-beta.list
        epm install lsb-release
        epm repo addkey "$REPOURL/deb/ascon.gpg"
        epm repo add "deb [signed-by=/etc/apt/trusted.gpg.d/ascon.gpg] $REPOURL/deb $(lsb_release -cs) main"
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac


epm update
epm install ascon-kompas3d-v24
