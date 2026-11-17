#!/bin/sh

PKGNAME=portprotonqt
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Modern GUI for managing and launching games from PortProton and Steam"
URL="https://git.linux-gaming.ru/Linux-Gaming/PortProtonQt"

. $(dirname $0)/common.sh

REPOURL="https://repos.fyralabs.com/terra43"

[ "$VERSION" = "*" ] && VERSION='[0-9.]*'
[ -n "$RELEASE" ] && [ "$RELEASE" != "*" ] || RELEASE='[0-9]*'

# Terra includes the epoch in RPM filenames (for example, portprotonqt-0:1.5.0-1.fc43.x86_64.rpm).
filename="$(get_rpm_repo_latest_file "$REPOURL" "$PKGNAME-[0-9]*:$VERSION-$RELEASE\.fc43\.x86_64\.rpm")"
[ -n "$filename" ] || fatal "Can't find PortProtonQt $VERSION-$RELEASE for x86_64 in $REPOURL"
PKGURL="$REPOURL/$filename"

install_pkgurl
