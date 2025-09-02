#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
PRODUCTDIR=/opt/arduino-ide

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command

ignore_lib_requires libnode.so.72

add_requires '/usr/bin/node'

# Rename plugins for compatibility with rpmbuild
find "$BUILDROOT$PRODUCTDIR/resources/app/plugins" -name '*\[*\]*' | while read -r file; do
    newfile=$(echo "$file" | sed 's/\[//g; s/\]//g')
    mv "$file" "$newfile"
done

# Clean up any existing plugin entries from spec file
subst '/\/resources\/app\/plugins\//d' "$SPEC"

# Add all plugin files to spec
find "$BUILDROOT$PRODUCTDIR/resources/app/plugins" -type f | sed "s|$BUILDROOT||" | while read -r path; do
    echo "$path" >> "${SPEC}.plugins"
done

# Insert the plugin files after %files
if [ -f "${SPEC}.plugins" ]; then
    sed '/^%files$/r '"${SPEC}.plugins" "$SPEC" > "${SPEC}.new"
    mv "${SPEC}.new" "$SPEC"
    rm -f "${SPEC}.plugins"
fi


add_libs_requires
