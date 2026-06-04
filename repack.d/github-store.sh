#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# jpackage layout: app lives under /opt/github-store with an ELF launcher in bin/
add_bin_link_command github-store $PRODUCTDIR/bin/GitHub-Store

# upstream postinstall only runs: xdg-desktop-menu install .../github-store-GitHub-Store.desktop
# (maintainer scripts are dropped on repack), so install the bundled desktop file system-wide.
# It already uses absolute Exec/Icon paths into /opt, so no rewriting is needed.
install_file $PRODUCTDIR/lib/github-store-GitHub-Store.desktop /usr/share/applications/github-store.desktop
