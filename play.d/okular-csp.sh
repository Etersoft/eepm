#!/bin/sh

PKGNAME=okular-csp
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Okular GOST (free version) with CryptoPro support from the official site"
REPOURL="http://packages.lab50.net"

# TODO: remove repo too
case "$1" in
    "--remove")
        epm remove $(epm qp $PKGNAME-) $(epm qp poppler-csp-)
        epm repo remove okular
        exit
        ;;
esac

. $(dirname $0)/common.sh


# see
# https://okulargost.ru/info.html
# http://packages.lab50.net/okular/install

distrib=$(epm print info --repo-name)
vendor=$(epm print info -s)

# Strict supported list
case $(epm print info -e) in
    Debian/1*|Ubuntu/20.04)
        ;;
    AstraLinuxSE/1.7*)
        ;;
    Fedora/3*|ROSA/2021.1|RedOS/7.3)
        distrib=$vendor
        ;;
    ALTLinux/p10)
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac


# CryptoPro needed for install
if ! epm qp "cprocsp-" >/dev/null ; then
    # TODO: install ecryptomgr here and check ecryptomgr status cryptopro
    fatal "Install CryptoPro before (install ecryptomgr package and check https://github.com/Etersoft/ecryptomgr )"
# TODO: check:
# $ tar -xf linux-amd64_deb.tgz -C /tmp
# $ sudo /tmp/linux-amd64_deb/install.sh cprocsp-rdr-gui-gtk
fi


pkgsystem=$(epm print info -g)

case $(epm print info -e) in
# TODO:
    AstraLinuxCE*)
        pkgsystem=''
        epm repo addkey "$REPOURL/lab50.gpg"
        epm repo add "deb $REPOURL/ce stable main"
        ;;
# TODO:
    AstraLinuxSE*)
        distrib=alse17
        additional_packages="libkf5js5=5.78.0-0ubuntu2+alse17 libkf5jsapi5=5.78.0-0ubuntu2+alse17"
        ;;
esac

case $vendor in
    alt)
# TODO get key info from gpg file
        epm repo addkey "$REPOURL/lab50.gpg" "D0C721136AFF9319DCF8276EA98DF0BE319FACDA" "Laboratory 50 (APT Archive Key) <team@lab50.net>"
        epm repo add "rpm [lab50] $REPOURL/okular/alt x86_64 p10"
        ;;
esac

case $pkgsystem in
    apt-dpkg)
        epm repo addkey "$REPOURL/lab50.gpg"
        epm repo add "deb $REPOURL/okular $distrib main non-free"
        ;;
    dnf-rpm)
        epm repo add "$REPOURL/okular/$distrib/okularcsp.repo"
        ;;
esac

epm update
epm install okular-csp $additional_packages
