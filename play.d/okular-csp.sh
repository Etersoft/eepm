#!/bin/sh

PKGNAME=okular-csp
# TODO: okular-gost contains ugly hack with libcurl
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Okular GOST (free version) with CryptoPro support from the official site"
URL="https://packages.lab50.net"
REPOURL="http://packages.lab50.net"

# TODO: remove repo too
case "$1" in
    "--remove")
        epm remove $(epm qp $PKGNAME-) $(epm qp poppler-csp-) okular-gost
        epm repo remove okular
        exit
        ;;
esac

. $(dirname $0)/common.sh

warn_version_is_not_supported

# see
# https://okulargost.ru/info.html
# http://packages.lab50.net/okular/install

distr=$(epm print info -e)
distrib=$(epm print info --repo-name)
vendor=$(epm print info -s)

# Strict supported list
case $(epm print info -e) in
    Debian/1*|Ubuntu/2*)
        ;;
    AstraLinuxSE/1.7*)
        distrib=alse17
        additional_packages="libkf5js5=5.78.0-0ubuntu2+alse17 libkf5jsapi5=5.78.0-0ubuntu2+alse17"
        ;;
    AstraLinuxSE/1.8*)
        distrib=alse18
        ;;
    Fedora/*|ROSA/2021.1|ROSA/13|RedOS/7.3|RedOS/8.0)
        distrib=$vendor
        ;;
    ALTLinux/p10|ALTLinux/p11|ALTLinux/Sisyphus)
        [ "$distrib" = "Sisyphus" ] && distrib="p11"
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

case $vendor in
    alt)
        epm installed lsb-cprocsp-capilite-64 || fatal "lsb-cprocsp-capilite-64 is not installed. Use 'ecryptomgr install cryptopro' to install it."
        epm installed cprocsp-pki-cades-64 || fatal "cprocsp-pki-cades-64 is not installed. Use 'ecryptomgr install cades' to install it."
        epm repo addkey "$REPOURL/lab50.gpg"
        epm repo add "rpm [lab50] $REPOURL/okular/alt $distrib/x86_64 okulargost"
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
epm install $PKGNAME $additional_packages
