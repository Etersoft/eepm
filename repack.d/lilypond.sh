#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# The tarball unpacks to a single lilypond-<ver>/ dir; move it to /opt/lilypond
# (a specific repack script suppresses generic-default, which would do this).
move_to_opt "/lilypond-*"

# LilyPond is a relocatable command-line toolset; expose its tools
# (lilypond, convert-ly, midi2ly, musicxml2ly, ...) in PATH.
for tool in "$BUILDROOT$PRODUCTDIR"/bin/* ; do
    [ -f "$tool" ] || continue
    add_bin_link_command "$(basename "$tool")" "$PRODUCTDIR/bin/$(basename "$tool")"
done
