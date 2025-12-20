#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^Summary:.*|Summary: Binary plugin for HPs hplip printer driver library|" $SPEC

# While hplip-plugin requires the version of hplip to match exactly,
# specifying such a requirement breaks the ability to upgrade hplip.
VERSION=$(grep "^Version:" $SPEC | sed -e "s|Version: ||")
add_requires "hplip >= $VERSION"

