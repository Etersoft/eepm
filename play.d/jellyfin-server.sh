#!/bin/sh

PKGNAME=jellyfin-server
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Jellyfin is the volunteer-built media solution that puts you in control of your media."
URL="https://jellyfin.org/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info -a)

PKGURL=$(eget --list --latest "https://download1.rpmfusion.org/free/fedora/releases/42/Everything/$arch/os/Packages/j/" "jellyfin-server*$arch.rpm")

install_pkgurl || exit

echo "Note: You also need to install jellyfin-web using the command:
# epm play jellyfin-web
or change the parameter in /etc/sysconfig/jellyfin:
JELLYFIN_WEB_OPT=\"--webdir=/opt/jellyfin-web\" to JELLYFIN_WEB_OPT=\"--nowebclient\" 

Warning: Configuration files are stored in /var/lib/jellyfin due to the specifics of the original jellyfin package build.
"
