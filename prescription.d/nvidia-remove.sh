#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Remove all proprietary NVIDIA cards support"

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

epm remove $(epm qp ^nvidia_glx)
