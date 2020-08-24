#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# Infowatch product Device

# remove broken script
rm -fv $BUILDROOT/etc/init.d/grafana-server
subst 's|"*/etc/init.d/grafana-server"*||' $SPEC
rm -fv $BUILDROOT/opt/iw/tm5/share/grafana/scripts/circle-test-*.sh
subst 's|"*/opt/iw/tm5/share/grafana/scripts/circle-test-.*.sh"*||' $SPEC
rm -rfv $BUILDROOT/opt/iw/tm5/share/grafana/scripts/build/
subst 's|"*/opt/iw/tm5/share/grafana/scripts/build/.*"*||' $SPEC