#!/bin/sh
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh

# Remove files/dirs with % in name (conflicts with RPM macro syntax)
find $BUILDROOT -name '*%*' -exec rm -rf {} + 2>/dev/null || true
# Also remove file entries with % from spec (but keep RPM macros like %files)
sed -i '/^".*%.*"$/d' $SPEC

# It installs to /opt/metasploit-framework with all dependencies bundled
