#!/bin/sh -x

# It will be run with two args: buildroot spec

# Upstream renamed the Linux viewer package to "realvnc-rvncconnect-viewer",
# but in EPM we keep the historical package name "realvnc-vnc-viewer".
BUILDROOT="$1"
SPEC="$2"
PKGNAME=realvnc-vnc-viewer

. $(dirname $0)/common.sh

subst "s|^Name:.*|Name: $PKGNAME|" "$SPEC"

add_conflicts tigervnc
