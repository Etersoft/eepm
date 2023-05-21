#!/bin/sh

PKGNAME=alivecolors
SUPPORTEDARCHES="x86_64"
DESCRIPTION="AliveColors from the official site"

case "$1" in
    "--remove")
        epm remove $(epm qp $PKGNAME-)
        epm repo remove akvis
        exit
        ;;
esac

. $(dirname $0)/common.sh

# Vendor instruction: https://alivecolors.com/ru/tutorial/howwork/install-linux.php

case $(epm print info -s) in
    alt)
        epm repo add "rpm https://akvis-alt.sfo2.cdn.digitaloceanspaces.com x86_64 akvis"
        epm repo add "rpm https://akvis-alt.sfo2.cdn.digitaloceanspaces.com noarch akvis"
        epm update
        epm install $PKGNAME
        echo "Run alivecolors:"
        echo "$ LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu alivecolors"
        exit
        ;;
    suse)
        # TODO: check and remove, the same as for dnf-part
        #a= rpm --import http://akvis.com/akvis.asc
        epm repo addkey https://akvis.com/akvis.asc
        # zypper ar -r https://akvis.com/akvis.repo akvis
        epm repo add https://akvis.com/akvis.repo
        # zypper ref
        epm update
        epm install $PKGNAME
        exit
        ;;
    *)
        fatal "Unsupported distro."
esac



case $(epm print info -g) in
    dnf-rpm|yum-rpm)
        #sudo rpm --import https://akvis.com/akvis.asc
        epm repo addkey https://akvis.com/akvis.asc
        #sudo wget -O /etc/yum.repos.d/akvis.repo https://akvis.com/akvis.repo
        epm repo add https://akvis.com/akvis.repo
        epm update
        epm install $PKGNAME
        exit
        ;;
    apt-dpkg)
        # TODO: add key support
        #sudo mkdir -p /usr/share/keyrings
        #eget -O - https://akvis.com/akvis.gpg | sudo tee /usr/share/keyrings/akvis.gpg >/dev/null
        #epm repo add 'deb [arch-=i386 signed-by=/usr/share/keyrings/akvis.gpg] https://akvis-deb.sfo2.cdn.digitaloceanspaces.com akvis non-free'
        epm repo add 'deb [arch-=i386] https://akvis-deb.sfo2.cdn.digitaloceanspaces.com akvis non-free'
        epm update
        epm install $PKGNAME
        exit
        ;;
    *)
        fatal "Unsupported packaging system"
esac

