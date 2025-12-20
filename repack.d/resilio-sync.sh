#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

cat <<EOF | create_file /usr/lib/sysusers.d/resilio-sync.conf
    u rslsync - "rslsync daemon" /var/lib/rslsync
EOF
 
cat <<EOF | create_file /usr/lib/tmpfiles.d/resilio-sync.conf
    # Override this file with a modified version in /etc/tmpfiles.d/
    D /run/resilio 0755 rslsync rslsync -
    d /var/lib/rslsync 0755 rslsync rslsync
    Z /var/lib/rslsync - rslsync rslsync
    z /etc/rslsync.conf 0600 rslsync rslsync
EOF

