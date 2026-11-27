#!/bin/sh -x

# It will be run with args: buildroot spec package-name source-package
BUILDROOT="$1"
SPEC="$2"
PKGNAME="$3"

. $(dirname $0)/common.sh
. $(dirname $0)/common-1c-enterprise.sh

fix_1c_enterprise_package "$PKGNAME"
