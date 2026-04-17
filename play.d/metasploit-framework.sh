#!/bin/sh

PKGNAME=metasploit-framework
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Penetration testing framework from Rapid7"
URL="https://www.metasploit.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# file: metasploit-framework-VERSION-RELEASE.x86_64.rpm (e.g. 6.4.126~...~1rapid7-1.fedora30.x86_64.rpm)
PKGURL=""
if [ -n "$RELEASE" ] && [ "$VERSION" != "*" ] ; then
    PKGURL="https://rpm.metasploit.com/metasploit-omnibus/pkg/metasploit-framework-${VERSION}-${RELEASE}.x86_64.rpm"
    eget --check-url "$PKGURL" >/dev/null 2>&1 || PKGURL=""
fi
[ -n "$PKGURL" ] || PKGURL=$(eget --list --latest https://rpm.metasploit.com/ "metasploit-framework-*.x86_64.rpm")

install_pkgurl
