#!/bin/sh

PKGNAME=okular-csp
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Okular GOST (free version) with CryptoPro support from the official site"
REPOURL="http://packages.lab50.net"

# TODO: remove repo too
case "$1" in
    "--remove")
        epm remove $(epmqp $PKGNAME-) $(epmqp poppler-csp-)
        exit
        ;;
esac

. $(dirname $0)/common.sh


# see
# https://okulargost.ru/info.html
# http://packages.lab50.net/okular/install


# Strict supported list
case $(epm print info -e) in
    Debian/11|Ubuntu/20.04)
        ;;
#     AstraLinuxSE/1.7*)
    AstraLinux/smolensk)
        ;;
    Fedora/35|ROSA/2021|RedOS/7)
        ;;
    ALTLinux/p10|ALTServer/10)
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac


# CryptoPro needed for install
if ! epmqp "cprocsp-" >/dev/null ; then
    fatal "Install CryptoPro before (via ecryptomgr package or manually)"
fi


distrib=$(epm print info --codename)
pkgsystem=$(epm print info -g)

case $(epm print info -e) in
# TODO:
    AstraLinux/orel)
        pkgsystem=''
        epm repo addkey "$REPOURL/lab50.gpg"
        epm repo add "deb $REPOURL/ce stable main"
        ;;
# TODO:
#     AstraLinuxSE/1.7*)
    AstraLinux/smolensk)
        distrib=alse17
        additional_packages="libkf5js5=5.78.0-0ubuntu2+alse17 libkf5jsapi5=5.78.0-0ubuntu2+alse17"
        ;;
    ALTLinux*|ALTServer*)
# TODO get key info from gpg file
        epm repo addkey "$REPOURL/lab50.gpg" "D0C721136AFF9319DCF8276EA98DF0BE319FACDA" "Laboratory 50 (APT Archive Key) <team@lab50.net>"
        epm repo add "rpm [lab50] $REPOURL/okular/alt x86_64 p10"
        ;;
esac

case $pkgsystem in
    apt-dpkg)
        epm repo addkey "$REPOURL/lab50.gpg"
        epm repo add "deb $REPOURL/okular $distrib main"
        ;;
    dnf-rpm)
        epm repo add "$REPOURL/okular/$distrib/okularcsp.repo"
        ;;
esac

epm update
epm install okular-csp $additional_packages
