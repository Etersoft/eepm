#!/bin/sh

PKGNAME=gradle
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Gradle is a build automation tool known for its flexibility to build software'
URL="https://gradle.org/"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest "https://gradle.org/releases/" "gradle-$VERSION-bin.zip")

install_pkgurl
