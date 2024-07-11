#!/bin/sh

PKGNAME=portproton
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='PortProton (from the repository if the package is there, or from the official site)'

. $(dirname $0)/common.sh

if ! epm install portproton ; then
    if [ "$VERSION" = "*" ] ; then
        PKGURL=$(get_github_version "https://github.com/Castro-Fidel/PortProton_dpkg/" "portproton_.${VERSION}amd64.deb")
    else
        PKGURL="https://github.com/Castro-Fidel/PortProton_dpkg/releases/download/portproton_${VERSION}amd64/portproton_${VERSION}amd64.deb"
    fi
    install_pkgurl
fi

# TODO: get from  grep '^###Scripts version ' PortWINE/data_from_portwine/changelog_eng | head -n1
###Scripts version 2172###
#VERSION="$(eget -O- https://api.github.com/repos/Castro-Fidel/PortWINE/commits/HEAD | grep '"message": "Scripts version' | sed -e 's|.*Scripts version ||' -e 's|".*||' )"
#epm pack --install $PKGNAME https://github.com/Castro-Fidel/PortWINE/archive/refs/heads/master.tar.gz $VERSION

epm play i586-fix
