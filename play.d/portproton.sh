#!/bin/sh

PKGNAME=portproton
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='PortProton (from the repository if the package is there, or from the official site)'
URL="https://github.com/Castro-Fidel/PortProton_dpkg/releases"

# ALT hack
epm installed i586-portproton-installer && PKGNAME="i586-portproton-installer"

. $(dirname $0)/common.sh

warn_version_is_not_supported

if epm install portproton ; then
    # ALT hack
    epm installed i586-portproton-installer && override_pkgname i586-portproton-installer
else
    PKGURL="https://github.com/Castro-Fidel/PortProton_dpkg/releases/download/portproton_amd64/portproton_amd64.deb"
    install_pkgurl
fi

# TODO: get from  grep '^###Scripts version ' PortWINE/data_from_portwine/changelog_eng | head -n1
###Scripts version 2172###
#VERSION="$(eget -O- https://api.github.com/repos/Castro-Fidel/PortWINE/commits/HEAD | grep '"message": "Scripts version' | sed -e 's|.*Scripts version ||' -e 's|".*||' )"
#epm pack --install $PKGNAME https://github.com/Castro-Fidel/PortWINE/archive/refs/heads/master.tar.gz $VERSION

epm play i586-fix
