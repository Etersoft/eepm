#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# Everty Desk is a RustDesk rebrand: the deb is named rustdesk and uses
# the same files (/usr/bin/rustdesk, rustdesk.service, /etc/rustdesk),
# so repack it the same way as rustdesk, but under its own name
PKGNAME=everty-desk
PRODUCT=rustdesk

. $(dirname $0)/rustdesk.sh

subst "s|^Name:.*|Name: $PKGNAME|" $SPEC

add_conflicts rustdesk

subst "s|^Name=RustDesk$|Name=Everty Desk|" usr/share/applications/$PRODUCT.desktop
subst "s|^Name=RustDesk$|Name=Everty Desk|" usr/share/applications/$PRODUCT-link.desktop
