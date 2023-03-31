#!/bin/sh

[ "$1" != "--run" ] && echo "Remove all proprietary NVIDIA cards support" && exit

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

epm remove $(epm qp ^nvidia_glx)
