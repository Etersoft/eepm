#!/bin/sh

[ "$1" != "--run" ] && echo "Remove all possible python2 packages" && exit

distro="$(epm print info -d)" ; [ "$distro" = "ALTLinux" ] || [ "$distro" = "ALTServer" ] || { echo "Only ALTLinux is supported" ; exit 1 ; }

PACKAGES="$(epm qp python-module)"

[ -n "$PACKAGES" ] || { echo "All python2 packages are already removed" ; exit 0 ; }

epm remove $PACKAGES

epm remove python2-base
