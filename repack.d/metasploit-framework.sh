#!/bin/sh
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh

# Remove files with % in name (conflicts with RPM macro syntax)
find $BUILDROOT -name '*%*' -delete

# It installs to /opt/metasploit-framework with all dependencies bundled
