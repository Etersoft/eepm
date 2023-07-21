#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

move_to_opt /usr/lib/pachca
rm usr/bin/pachca
add_bin_link_command

remove_dir /usr/share/lintian

add_electron_deps
fix_chrome_sandbox
