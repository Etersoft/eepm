#!/bin/sh

PKGNAME=ascon-kompas3d-v24
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="KOMPAS-3D v24 from the official site"
URL="https://ascon.ru/news/2025/12/11/askon-vypustil-kompas-3d-dlya-otechestvennyh-os-na-linux/"
REPOURL="https://repo.ascon.ru/stable"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case $(epm print info -e) in
    ALTLinux/p10|ALTLinux/c10f*)
        epm repo addkey "$REPOURL/alt/ascon.gpg"
        epm repo add "rpm [ascon] $REPOURL/alt/ p10/x86_64 main"
        ;;
    ALTLinux/p11|ALTLinux/Sisyphus)
        epm repo addkey "$REPOURL/alt/ascon.gpg"
        epm repo add "rpm [ascon] $REPOURL/alt/ p11/x86_64 main"
        ;;
    RedOS/8.0)
        epm repo addkey ascon "$REPOURL/rpm/redos/8.0/" "$REPOURL/rpm/ascon.gpg" "Ascon"
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
epm install $PKGNAME || exit
# TODO: don\t use repo
epm repo remove "ascon"
