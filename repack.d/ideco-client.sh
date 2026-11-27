#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ideco-client
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# as in the vendor's installer: the wayland shell integration plugin is needed for Fedora only,
# it conflicts with other systems (GUI is drawn incorrectly)
[ "$(epm print info -s)" = "fedora" ] || remove_dir $PRODUCTDIR/plugins/wayland-shell-integration

# IdecoService uses resolvectl (systemd-resolved) to set up DNS for the VPN
# (the vendor's instruction for ALT: install systemd-networkd)
add_requires /usr/bin/resolvectl
