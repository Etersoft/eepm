#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

# Replace the old unofficial Codex App package.
add_conflicts codex-app
add_obsoletes codex-app
add_provides codex-app

move_to_opt

# /usr/bin/chatgpt originally points to ../lib/chatgpt/codex-launcher.
# Recreate it after moving the application to /opt.
rm -f "$BUILDROOT/usr/bin/chatgpt"
add_bin_link_command chatgpt "$PRODUCTDIR/codex-launcher"

# These shims enable native Qt file dialogs when Qt is present, but Qt itself
# is optional and must not become a package dependency.
ignore_lib_requires 'libQt5.*' 'libQt6.*'
