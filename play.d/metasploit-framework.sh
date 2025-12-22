#!/bin/sh

PKGNAME=metasploit-framework
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Penetration testing framework from Rapid7"
URL="https://www.metasploit.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list --latest https://rpm.metasploit.com/ "metasploit-framework-*.x86_64.rpm")

install_pkgurl
