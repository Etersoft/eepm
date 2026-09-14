#!/bin/sh

BASEPKGNAME=ascon-kompas3d
PRODUCTALT="v25 v24"
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="KOMPAS-3D from the official site"
URL="https://ascon.ru/news/2025/12/11/askon-vypustil-kompas-3d-dlya-otechestvennyh-os-na-linux/"
REPOURL="https://repo.ascon.ru/stable"

. $(dirname $0)/common.sh

# Migrate legacy Ascon entries from sources.list to a named disabled repository.
# EPM can temporarily enable only the latter for ascon/<package> installs.
case $(epm print info -g) in
    apt-rpm)
        epm --quiet repo remove "$REPOURL"
        ;;
esac

case $(epm print info -e) in
    ALTLinux/p10|ALTLinux/c10f*)
        epm repo addkey "$REPOURL/alt/ascon.gpg"
        epm repo add --disabled --name ascon "rpm [ascon] $REPOURL/alt/ p10/x86_64 main"
        ;;
    ALTLinux/p11|ALTLinux/Sisyphus)
        epm repo addkey "$REPOURL/alt/ascon.gpg"
        epm repo add --disabled --name ascon "rpm [ascon] $REPOURL/alt/ p11/x86_64 main"
        ;;
    RedOS/8.0)
        epm repo addkey ascon "$REPOURL/rpm/redos/8.0/" "$REPOURL/rpm/ascon.gpg" "Ascon"
        ;;
    AstraLinuxSE/1.8)
        # Copied from install script
        # echo "deb [signed-by=/etc/apt/trusted.gpg.d/ascon.gpg] https://repo.ascon.ru/beta/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/ascon-beta.list
        epm install lsb-release
        epm repo addkey "$REPOURL/deb/ascon.gpg"
        epm repo add --disabled --name ascon "deb [signed-by=/etc/apt/trusted.gpg.d/ascon.gpg] $REPOURL/deb $(lsb_release -cs) main"
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac

case $(epm print info -g) in
    apt-rpm)
        # Ascon RPMs omit post-install dependencies on fc-cache and CP1251 maps.
        epm install --skip-installed fontconfig glibc-locales || exit
        epm install ascon/$PKGNAME || exit
        ;;
    apt-dpkg)
        epm install ascon/$PKGNAME || exit
        ;;
    *)
        epm update
        epm install $PKGNAME || exit
        ;;
esac
