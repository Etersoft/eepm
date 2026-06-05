#!/bin/bash
# Test AppImage product name / version separation as done in pack.d/generic-appimage.sh
# Uses bash parameter expansion (${var/from/to}) to mirror the pack script exactly.

failed=0

check()
{
    local in="$1" exp_name="$2" exp_ver="$3"
    if [ "$got_name" = "$exp_name" ] && [ "$got_ver" = "$exp_ver" ] ; then
        echo "OK   '$in' -> name='$got_name' version='$got_ver'"
    else
        echo "FAIL '$in' -> name='$got_name' version='$got_ver' (expected name='$exp_name' version='$exp_ver')"
        failed=1
    fi
}

# the same logic as in pack.d/generic-appimage.sh
parse()
{
    PRODUCT="$1"
    VERSION=""

    # strip architecture, OS and build type suffix from PRODUCT name
    PRODUCT="${PRODUCT/-x86_64/}"
    PRODUCT="${PRODUCT/-x86-64/}"
    PRODUCT="${PRODUCT/-aarch64/}"
    PRODUCT="${PRODUCT/-arm64/}"
    PRODUCT="${PRODUCT/-x64/}"
    PRODUCT="${PRODUCT/-linux64/}"
    PRODUCT="${PRODUCT/-Linux/}"
    PRODUCT="${PRODUCT/-linux/}"
    PRODUCT="${PRODUCT/-stable/}"
    # same suffixes with underscore separator (e.g. ElegooSlicer_Linux_V1.5.0.7)
    PRODUCT="${PRODUCT/_x86_64/}"
    PRODUCT="${PRODUCT/_Linux/}"
    PRODUCT="${PRODUCT/_linux/}"

    # match version with optional v/V prefix and pre-release suffix like -b1, -rc1, -beta
    vermatch="$(echo "$PRODUCT" | grep -o -P "[-_.][vV]?[0-9]+(?:\.[0-9]+)*(?:-(?:alpha|beta|rc|b|a|pre|dev|nightly)[0-9]*)?" | head -n1)"
    [ -n "$vermatch" ] && PRODUCT="$(echo "$PRODUCT" | sed -e "s|$vermatch.*||")"
    [ -n "$vermatch" ] && VERSION="$(echo "$vermatch" | sed -e 's|^[-_.]||' -e 's|^[vV]||')"

    got_name="$PRODUCT"
    got_ver="$VERSION"
}

t()
{
    parse "$1"
    check "$1" "$2" "$3"
}

# the reported case: _Linux OS suffix and uppercase V version prefix
t "ElegooSlicer_Linux_V1.5.0.7" "ElegooSlicer"  "1.5.0.7"
t "ElegooSlicer_Linux_V1.5.1.6" "ElegooSlicer"  "1.5.1.6"
t "OrcaSlicer_Linux_V2.3.0"     "OrcaSlicer"    "2.3.0"

# regressions for the existing dash-separated styles
t "neovide-0.12.2-x86_64"       "neovide"       "0.12.2"
t "SomeApp-1.2.3"               "SomeApp"       "1.2.3"
t "balena-etcher-1.18.11-x64"   "balena-etcher" "1.18.11"
t "Cursor-0.42.3-x86_64"        "Cursor"        "0.42.3"
t "someapp-1.2.0-rc1"           "someapp"       "1.2.0-rc1"
t "AppImage-v2.1.0"             "AppImage"      "2.1.0"

exit $failed
