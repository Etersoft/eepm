#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=opencode-desktop
PRODUCTDIR=/opt/OpenCode

. $(dirname $0)/common-chromium-browser.sh

subst "s|^Name:.*|Name: opencode-desktop|" "$SPEC"

# Fix empty License field from original package
subst "s|^License:.*|License: MIT|" "$SPEC"

# Fix empty Categories
fix_desktop_file "Categories=" "Categories=Development;IDE;"
fix_desktop_file "/opt/OpenCode/@opencode-aidesktop" "opencode-desktop"
fix_desktop_file '"opencode-desktop"' "opencode-desktop"

add_bin_exec_command opencode-desktop "/opt/OpenCode/@opencode-aidesktop"

add_electron_deps

ignore_lib_requires libc.so
