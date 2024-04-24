#!/bin/sh

PKGNAME=bellsoft-java11-full
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='BellSoft Liberica JDK is a build of OpenJDK that is tested and verified to be compliant with the Java SE specification using OpenJDK Technology Compatibility Kit test suite'
URL="https://github.com/bell-sw/Liberica/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# bellsoft-jdk22.0.1+10-linux-amd64-full.rpm
PKGURL="https://github.com/bell-sw/Liberica/releases/download/11.0.20%2B8/bellsoft-jdk11.0.20%2B8-linux-amd64-full.rpm"

install_pkgurl