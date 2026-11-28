#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# upstream package installs bash completion into /usr/etc (relocated /etc)
move_file /usr/etc/bash_completion.d/pvs-studio.sh /etc/bash_completion.d/pvs-studio
remove_dir /usr/etc

# pvs-studio-analyzer trace uses strace (upstream Requires: strace)
add_requires strace
