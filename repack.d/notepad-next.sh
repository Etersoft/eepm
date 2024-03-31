#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|Icon=NotepadNext|Icon=notepad-next|" $BUILDROOT/usr/share/applications/NotepadNext.desktop

add_libs_requires
